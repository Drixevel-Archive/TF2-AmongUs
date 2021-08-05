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
		TF2_ForceWin(TFTeam_Red); //Imposters won
	else
		TF2_ForceWin(TFTeam_Blue); //Crewmates won
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

void SetGhost(int client)
{
	if (g_IsDead[client])
		return;
	
	SetEntProp(client, Prop_Send, "m_lifeState", 2);

	SetEntityRenderMode(client, RENDER_TRANSALPHA);
	SetEntityRenderColor(client, _, _, _, 70);
	SetEntityMoveType(client, MOVETYPE_NOCLIP);
	SetEntProp(client, Prop_Send, "m_CollisionGroup", 2);
	
	g_IsDead[client] = true;
}

void RemoveGhost(int client)
{
	if (!g_IsDead[client])
		return;
	
	SetEntProp(client, Prop_Send, "m_lifeState", 0);

	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, _, _, _, _);
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
	
	g_IsDead[client] = false;
}

bool IsValidTask(int task)
{
	if (task < 0)
		return false;
	
	if (task > (g_TotalTasks - 1))
		return false;
	
	return true;
}

int GetTaskByName(const char[] name)
{
	for (int i = 0; i < g_TotalTasks; i++)
		if (StrEqual(g_Tasks[i].display, name, false))
			return i;
	
	return -1;
}

void GetTaskTypeDisplayName(TaskType tasktype, char[] buffer, int size)
{
	switch (tasktype)
	{
		case TaskType_Single:
			strcopy(buffer, size, "Single");
		case TaskType_Map:
			strcopy(buffer, size, "Map");
		case TaskType_Part:
			strcopy(buffer, size, "Part");
	}
}

int GetRandomTask(int type)
{
	int[] tasks = new int[256];
	int amount;

	for (int i = 0; i < g_TotalTasks; i++)
	{
		if (g_Tasks[i].tasktype == TaskType_Part)
			continue;
		
		if ((g_Tasks[i].type & type) != type)
			continue;

		tasks[amount++] = i;
	}
	
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
	EmitSoundToClient(client, SOUND_TASK_COMPLETE);
	
	if (g_Player[client].role == Role_Imposter)
		return;
	
	char sTask[16];
	IntToString(task, sTask, sizeof(sTask));

	g_Player[client].tasks_completed.SetValue(sTask, 1);
	g_Match.tasks_current++;

	if (g_Match.tasks_current >= g_Match.tasks_goal)
		CreateTimer(0.2, Frame_ResetGoal);
	
	Call_StartForward(g_Forward_OnTaskCompletedPost);
	Call_PushCell(client);
	Call_PushCell(task);
	Call_Finish();
}

void AssignRandomTask(int client, int type)
{
	int task = GetRandomTask(type);
	AssignTask(client, task);
}

void AssignTask(int client, int task)
{
	if (g_Tasks[task].tasktype == TaskType_Part)
		return;
	
	g_Player[client].tasks.Push(task);

	char sTask[16];
	IntToString(task, sTask, sizeof(sTask));

	g_Player[client].tasks_completed.SetValue(sTask, 0);

	if (g_Tasks[task].tasktype == TaskType_Map)
	{
		int entity = EntRefToEntIndex(g_Tasks[task].entityref);

		if (!IsValidEntity(entity))
			return;

		char sStart[64];
		GetCustomKeyValue(entity, "start", sStart, sizeof(sStart));

		g_Player[client].lockout = StrContains(sStart, "*", false) != -1;
		g_Player[client].random = StrContains(sStart, "%", false) != -1;
		g_Player[client].intgen = StrContains(sStart, "{", false) != -1;

		if (g_Player[client].random)
		{
			char sLookup[512];
			Format(sLookup, sizeof(sLookup), "part %i", GetTaskStep(client, task) + 2);

			char sPart[512];
			GetCustomKeyValue(entity, sLookup, sPart, sizeof(sPart));

			char sParts[64][64];
			int parts = ExplodeString(sPart, ",", sParts, 64, 64);

			int random = GetRandomInt(0, parts - 1);

			strcopy(g_Player[client].randomchosen, 64, sParts[random]);
		}
	}
}

void ClearTasks(int client)
{
	g_Player[client].tasks.Clear();
	g_Player[client].tasks_completed.Clear();
}

int GetTaskStep(int client, int task)
{
	char sTask[16];
	IntToString(task, sTask, sizeof(sTask));

	int steps;
	g_Player[client].tasks_steps.GetValue(sTask, steps);

	return steps;
}

void IncrementTaskSteps(int client, int task)
{
	int steps = GetTaskStep(client, task) + 1;

	char sTask[16];
	IntToString(task, sTask, sizeof(sTask));

	g_Player[client].tasks_steps.SetValue(sTask, steps);

	if (GetTaskStep(client, task) >= GetTaskMapParts(task))
		MarkTaskComplete(client, task);
}

int GetTaskMapParts(int task)
{
	if (g_Tasks[task].tasktype != TaskType_Map)
		return -1;
	
	int entity = EntRefToEntIndex(g_Tasks[task].entityref);

	if (!IsValidEntity(entity))
		return -1;

	char sParts[16];
	GetCustomKeyValue(entity, "parts", sParts, sizeof(sParts));

	return StringToInt(sParts);
}

void RegConsoleCmdEx(const char[] cmd, ConCmd callback, const char[] description="", int flags=0)
{
	if (g_PlayerCommands.FindString(cmd) == -1)
		g_PlayerCommands.PushString(cmd);
	
	g_PlayerCommandDescriptions.SetString(cmd, description);
	
	RegConsoleCmd(cmd, callback, description, flags);
}

void RegAdminCmdEx(const char[] cmd, ConCmd callback, int adminflags, const char[] description="", const char[] group="", int flags=0)
{
	if (g_AdminCommands.FindString(cmd) == -1)
		g_AdminCommands.PushString(cmd);
	
	g_AdminCommandDescriptions.SetString(cmd, description);
	
	RegAdminCmd(cmd, callback, adminflags, description, group, flags);
}

void PrintCommandsInConsole(int client, bool admin)
{
	PrintToConsole(client, "==================================\n== Available %s Commands:", admin ? "Admin" : "Player");

	DataPack pack = new DataPack();
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(admin);

	RequestFrame(Frame_ListCommands, pack);
}

public void Frame_ListCommands(DataPack pack)
{
	pack.Reset();

	int userid = pack.ReadCell();
	bool admin = pack.ReadCell();

	delete pack;

	int client;
	if ((client = GetClientOfUserId(userid)) == 0)
		return;

	int amount = admin ? g_AdminCommands.Length : g_PlayerCommands.Length;

	char sCommand[64]; char sDescription[128];
	for (int i = 0; i < amount; i++)
	{
		if (admin)
		{
			g_AdminCommands.GetString(i, sCommand, sizeof(sCommand));
			g_AdminCommandDescriptions.GetString(sCommand, sDescription, sizeof(sDescription));
		}
		else
		{
			g_PlayerCommands.GetString(i, sCommand, sizeof(sCommand));
			g_PlayerCommandDescriptions.GetString(sCommand, sDescription, sizeof(sDescription));
		}

		PrintToConsole(client, "%s - %s", sCommand, sDescription);
	}

	//Add a VERY slight delay to this.
	if (GetRandomInt(0, 1) < 2)
	{
		PrintToConsole(client, "==================================");
		CPrintToChat(client, "%T", "commands in console", client);
	}
}

void PlayIntro()
{
	if (g_Match.intro)
		return;
	
	g_Match.intro = true;

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i))
			TF2_RespawnPlayer(i);
	
	ScreenFadeAll(100, 2500, FFADE_OUT, view_as<int>({0, 0, 0, 255}), true);
	
	CreateTimer(0.5, Timer_ShowSHH, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, Timer_SetPlayerIntro, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(5.0, Timer_PlayIntroSound, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(10.0, Timer_HideIntro, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(15.0, Timer_RespawnPlayers, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_ShowSHH(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		SetHudTextParams(-1.0, -1.0, 3.0, 255, 255, 255, 255);
		ShowHudText(i, -1, "SHHHH....");
	}
}

public Action Timer_SetPlayerIntro(Handle timer)
{
	int camera = FindEntityByName("intro_cam", "point_viewcontrol");
	DispatchKeyValue(camera, "spawnflags", "8");

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;
		
		IntroTele(i);
		AcceptEntityInput(camera, "Enable", i);
		SetEntityMoveType(i, MOVETYPE_NONE);
	}
}

float g_LastTeleOrigin[MAXPLAYERS + 1][3];
float g_LastTeleAngles[MAXPLAYERS + 1][3];

void IntroTele(int client)
{
	GetClientAbsOrigin(client, g_LastTeleOrigin[client]);
	GetClientAbsAngles(client, g_LastTeleAngles[client]);
	
	int entity = -1; float origin1[3]; float origin2[3]; float angles[3]; char sName[64];
	while ((entity = FindEntityByClassname(entity, "info_teleport_destination")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

		if (StrContains(sName, "intro_tele", false) != 0)
			continue;
		
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin1);
		origin1[2] += 5.0;

		int count;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i))
			{
				GetClientAbsOrigin(i, origin2);

				if (GetVectorDistance(origin1, origin2) <= 50.0)
					count++;
			}
		}

		if (count < 1)
		{
			GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
			TeleportEntity(client, origin1, angles, view_as<float>({0.0, 0.0, 0.0}));
			break;
		}
	}
}

public Action Timer_PlayIntroSound(Handle timer)
{
	EmitSoundToAll(SOUND_ROUNDSTART);
}

public Action Timer_HideIntro(Handle timer)
{
	ScreenFadeAll(100, 3500, FFADE_OUT, view_as<int>({0, 0, 0, 255}), true);
}

public Action Timer_RespawnPlayers(Handle timer)
{
	int camera = FindEntityByName("intro_cam", "point_viewcontrol");

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		TeleportEntity(i, g_LastTeleOrigin[i], g_LastTeleAngles[i], view_as<float>({0.0, 0.0, 0.0}));
		AcceptEntityInput(camera, "Disable", i);
		SetClientViewEntity(i, i);
		SetEntityMoveType(i, MOVETYPE_WALK);
	}

	g_Match.intro = false;
}