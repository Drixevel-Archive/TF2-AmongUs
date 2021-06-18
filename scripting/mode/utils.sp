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