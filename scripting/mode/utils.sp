/*****************************/
//Utils

/////
//Roles

void GetRoleName(Roles role, char[] buffer, int size)
{
	switch (role)
	{
		case Role_Crewmate:
			strcopy(buffer, size, "Crewmate");
		case Role_Imposter:
			strcopy(buffer, size, "Imposter");
	}
}

bool IsValidRole(const char[] name)
{
	char sRole[32];
	for (Roles i = Role_Crewmate; i < Role_Total; i++)
	{
		GetRoleName(i, sRole, sizeof(sRole));

		if (StrEqual(sRole, name, false))
			return true;
	}

	return false;
}

void RoleNamesBuffer(char[] buffer, int size)
{
	char sRole[32];
	for (Roles i = Role_Crewmate; i < Role_Total; i++)
	{
		GetRoleName(i, sRole, sizeof(sRole));

		if (i == Role_Crewmate)
			FormatEx(buffer, size, "%s", sRole);
		else
			Format(buffer, size, "%s, %s", buffer, sRole);
	}
}

Roles GetRoleByName(const char[] name)
{
	char sRole[32];
	for (Roles i = Role_Crewmate; i < Role_Total; i++)
	{
		GetRoleName(i, sRole, sizeof(sRole));

		if (StrEqual(sRole, name, false))
			return i;
	}

	//Return -1 which just means this role wasn't found.
	return view_as<Roles>(-1);
}

int GetTaskByName(const char[] name)
{
	for (int i = 0; i < g_TotalTasks; i++)
		if (StrEqual(g_Task[i].name, name, false))
			return i;
	
	return -1;
}

int GetRandomTask(int type)
{
	int[] tasks = new int[256];
	int amount;

	for (int i = 0; i < g_TotalTasks; i++)
		if ((g_Task[i].type & type) == type)
			tasks[amount++] = i;
	
	return tasks[GetRandomInt(0, amount - 1)];
}

bool HasTasks(int client)
{
	return g_Player[client].tasks.Length > 0;
}

bool IsTaskAssigned(int client, int task)
{
	return g_Player[client].tasks.FindValue(task) != -1;
}

bool IsTaskCompleted(int client, int task)
{
	char sTask[16];
	IntToString(task, sTask, sizeof(sTask));

	bool value;
	g_Player[client].tasks_completed.GetValue(sTask, value);

	return value;
}

void MarkTaskComplete(int client, int task)
{
	if (g_Player[client].role == Role_Imposter)
		return;
	
	char sTask[16];
	IntToString(task, sTask, sizeof(sTask));

	g_Player[client].tasks_completed.SetValue(sTask, 1);
	g_Match.tasks_current++;
}

void AssignRandomTask(int client, int type)
{
	int task = GetRandomTask(type);
	AssignTask(client, task);
}

void AssignTask(int client, int task)
{
	g_Player[client].tasks.Push(task);

	char sTask[16];
	IntToString(task, sTask, sizeof(sTask));

	g_Player[client].tasks_completed.SetValue(sTask, 0);
}

void ClearTasks(int client)
{
	g_Player[client].tasks.Clear();
	g_Player[client].tasks_completed.Clear();
}

void MuteAllClients()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client) || TF2_GetClientTeam(client) < TFTeam_Red)
			continue;
		
		for (int target = 1; target <= MaxClients; target++)
		{
			if (!IsClientInGame(target) || IsFakeClient(target) || TF2_GetClientTeam(target) < TFTeam_Red)
				continue;
			
			if (!IsPlayerAlive(client) && !IsPlayerAlive(target))
			{
				SetListenOverride(client, target, Listen_Yes);
				SetListenOverride(target, client, Listen_Yes);
			}
			else
			{
				SetListenOverride(client, target, Listen_No);
				SetListenOverride(target, client, Listen_No);
			}
		}
	}
}

void UnmuteAllClients()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client) || TF2_GetClientTeam(client) < TFTeam_Red)
			continue;
		
		for (int target = 1; target <= MaxClients; target++)
		{
			if (!IsClientInGame(target) || IsFakeClient(target) || TF2_GetClientTeam(target) < TFTeam_Red)
				continue;
			
			if (TF2_IsInSetup() || !IsPlayerAlive(client) && !IsPlayerAlive(target))
			{
				SetListenOverride(client, target, Listen_Yes);
				SetListenOverride(target, client, Listen_Yes);
			}
			else if (IsPlayerAlive(client) && !IsPlayerAlive(target))
			{
				SetListenOverride(client, target, Listen_No);
				SetListenOverride(target, client, Listen_Yes);
			}
			else if (!IsPlayerAlive(client) && IsPlayerAlive(target))
			{
				SetListenOverride(client, target, Listen_Yes);
				SetListenOverride(target, client, Listen_No);
			}
		}
	}
}

void SetPlayerSpeed(int client)
{
	float speed = GetGameSetting_Float("player_speed");
	
	if (speed > 1.0)
	{
		speed -= 1.0;
		TF2Attrib_ApplyMoveSpeedBonus(client, speed);
	}
	else if (speed < 1.0)
	{
		TF2Attrib_ApplyMoveSpeedPenalty(client, speed);
	}
	else
	{
		TF2Attrib_RemoveMoveSpeedBonus(client);
		TF2Attrib_RemoveMoveSpeedPenalty(client);
	}
}

int FindNewImposter()
{
	int[] clients = new int[MaxClients];
	int amount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || IsFakeClient(i))
			continue;
		
		if (g_Player[i].role != Role_Crewmate)
			continue;

		clients[amount++] = i;
	}
	
	if (amount < 1)
		return -1;

	return clients[GetRandomInt(0, amount - 1)];
}

/**
 * Easy function to call a round as won for either imposters or crewmates.
 *
 * imposters - If true, imposters won otherwise crewmates won.
 *
 * @return     N/A
 */
void ForceWin(bool imposters = false)
{
	//We want to set teams for players based on what role they are right before we end the round so the proper win screen pops up for them.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		if (IsPlayerAlive(i))
		{
			if (g_Player[i].role == Role_Imposter)
				ChangeClientTeam_Alive(i, view_as<int>(TFTeam_Red));
			else
				ChangeClientTeam_Alive(i, view_as<int>(TFTeam_Blue));
		}
		else
		{
			if (g_Player[i].role == Role_Imposter)
				ChangeClientTeam(i, view_as<int>(TFTeam_Red));
			else
				ChangeClientTeam(i, view_as<int>(TFTeam_Blue));
		}
	}
	
	if (imposters)
	{
		//Imposters won
		TF2_ForceWin(TFTeam_Red);
	}
	else
	{
		//Crewmates won
		TF2_ForceWin(TFTeam_Blue);
	}
}

void CreateCamera(int client)
{
	if (g_Camera[client] != 0)
		return;
	
	SetEntProp(client, Prop_Send, "m_iObserverMode", 1);

	int entCamera = CreateEntityByName("point_viewcontrol");

	char sWatcher[64];
	Format(sWatcher, sizeof(sWatcher), "target%i", client);

	DispatchKeyValue(client, "targetname", sWatcher);

	if(IsValidEntity(entCamera))
	{
		DispatchKeyValue(entCamera, "targetname", "playercam");
		DispatchKeyValue(entCamera, "wait", "3600");
		DispatchSpawn(entCamera);

		TeleportEntity(entCamera, view_as<float>({1600.0, 500.0, 700.0}), view_as<float>({89.9, -89.0, 0.0}), NULL_VECTOR);

		SetVariantString(sWatcher);
		AcceptEntityInput(entCamera, "Enable", client, entCamera, 0);
		
		g_Camera[client] = entCamera;
	}
}

void DestroyCamera(int client)
{
	if (g_Camera[client] == 0)
		return;
	
	SetClientViewEntity(client, client);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 0);

	char sWatcher[64];
	Format(sWatcher, sizeof(sWatcher), "target%i", client);

	SetVariantString(sWatcher);
	AcceptEntityInput(g_Camera[client], "Disable", client, g_Camera[client], 0);

	RemoveEdict(g_Camera[client]);
	g_Camera[client] = 0;
}