/*****************************/
//Commands

public Action Command_MainMenu(int client, int args)
{
	if (client == 0)
		return Plugin_Handled;
	
	OpenMainMenu(client);
	return Plugin_Handled;
}

public Action Command_Colors(int client, int args)
{
	if (client == 0)
		return Plugin_Handled;
	
	OpenColorsMenu(client);
	return Plugin_Handled;
}

public Action Command_Role(int client, int args)
{
	if (client == 0)
		return Plugin_Handled;
	
	char sRole[32];
	GetRoleName(g_Player[client].role, sRole, sizeof(sRole));
	CPrintToChat(client, "Current Role: {H1}%s", sRole);
	
	return Plugin_Handled;
}

public Action Command_GameSettings(int client, int args)
{
	OpenSettingsMenu(client);
	return Plugin_Handled;
}

public Action Command_Owner(int client, int args)
{
	if (g_GameOwner != -1)
		CReplyToCommand(client, "Current Owner: {H1}%N", g_GameOwner);
	else
		CReplyToCommand(client, "Current Owner: {H1}<Vacant>");
	
	return Plugin_Handled;
}

public Action Command_Voting(int client, int args)
{
	CreateVoteMenu(client);
	return Plugin_Handled;
}

public Action Command_ReloadColors(int client, int args)
{
	ParseColors();
	CReplyToCommand(client, "Colors have been reloaded.");
	return Plugin_Handled;
}

public Action Command_SetRole(int client, int args)
{
	if (args < 2)
	{
		char sCommand[32];
		GetCmdArg(0, sCommand, sizeof(sCommand));
		CReplyToCommand(client, "Usage: {H2}%s {H1}<target> <role>", sCommand);
		return Plugin_Handled;
	}

	char sTarget[MAX_TARGET_LENGTH];
	GetCmdArg(1, sTarget, sizeof(sTarget));

	int target = FindTarget(client, sTarget, true, false);

	if (target < 1)
	{
		CReplyToCommand(client, "Target {H1}%s {default}not found, please try again.", sTarget);
		return Plugin_Handled;
	}

	char sRole[32];
	GetCmdArg(2, sRole, sizeof(sRole));

	if (!IsValidRole(sRole))
	{
		char sRoles[255];
		RoleNamesBuffer(sRoles, sizeof(sRoles));
		CPrintToChat(client, "Specified role invalid, please choose the following: {H1}%s", sRoles);
		return Plugin_Handled;
	}

	g_Player[target].role = GetRoleByName(sRole);
	SendHud(target);

	if (g_Player[target].role == Role_Imposter)
		SetVariantString("fog_imposters");
	else
		SetVariantString("fog_crewmates");
	
	AcceptEntityInput(target, "SetFogController");

	if (g_Player[target].role == Role_Imposter)
		TF2_GiveItem(target, "tf_weapon_pda_engineer_build", 25, TF2Quality_Vintage, 1);
	else
	{
		TF2_EquipWeaponSlot(target, TFWeaponSlot_Melee);
		TF2_RemoveWeaponSlot(target, TFWeaponSlot_Grenade);
	}

	if (client == target)
		CPrintToChat(client, "You have updated your role to: {H1}%s", sRole);
	else
	{
		CPrintToChat(client, "You have updated {H2}%N{default}'s role to: {H1}%s", target, sRole);
		CPrintToChat(target, "{H2}%N has updated your role to: {H1}%s", client, sRole);
	}

	return Plugin_Handled;
}

public Action Command_SetOwner(int client, int args)
{
	if (args < 1)
	{
		char sCommand[32];
		GetCmdArg(0, sCommand, sizeof(sCommand));
		CReplyToCommand(client, "Usage: {H2}%s {H1}<target>", sCommand);
		return Plugin_Handled;
	}

	char sTarget[MAX_TARGET_LENGTH];
	GetCmdArgString(sTarget, sizeof(sTarget));

	int target = FindTarget(client, sTarget, true, false);

	if (target < 1)
	{
		CReplyToCommand(client, "Target {H1}%s {default}not found, please try again.", sTarget);
		return Plugin_Handled;
	}

	g_GameOwner = target;
	LoadGameSettings(target);
	OpenSettingsMenu(target);
	SendHudToAll();

	CPrintToChatAll("{H1}%N {default}has set the game owner to: {H1}%N", client, target);

	return Plugin_Handled;
}

public Action Command_RemoveOwner(int client, int args)
{
	if (g_GameOwner == -1)
	{
		CReplyToCommand(client, "There currently isn't an active game owner.");
		return Plugin_Handled;
	}

	CPrintToChatAll("{H1}%N {default}has removed game ownership from {H1}%N{default}.", client, g_GameOwner);
	g_GameOwner = -1;
	ParseGameSettings();
	SendHudToAll();

	return Plugin_Handled;
}

public Action Command_Respawn(int client, int args)
{
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsPlayerAlive(i))
			TF2_RespawnPlayer(i);
	
	CPrintToChatAll("{H1}%N {default}has respawnd all dead players on teams.");
	return Plugin_Handled;
}

public Action Command_Eject(int client, int args)
{
	if (client == 0)
		return Plugin_Handled;
	
	char sTarget[MAX_TARGET_LENGTH];
	GetCmdArgString(sTarget, sizeof(sTarget));
	
	int target = FindTarget(client, sTarget, false, true);

	if (target < 1)
	{
		CReplyToCommand(client, "Target {H1}%s {default}not found, please try again.", sTarget);
		return Plugin_Handled;
	}

	if (!IsClientInGame(target))
	{
		CReplyToCommand(client, "Target {H1}%N {default}is not available, please try again.", target);
		return Plugin_Handled;
	}

	if (!IsClientInGame(target))
	{
		CReplyToCommand(client, "Target {H1}%N {default}is not alive, please try again.", target);
		return Plugin_Handled;
	}

	EjectPlayer(target);
	CPrintToChatAll("{H1}%N {default}has ejected {H1}%N {default}into space!", client, target);

	return Plugin_Handled;
}

public Action Command_ListImposters(int client, int args)
{
	char sImposters[255];
	FormatEx(sImposters, sizeof(sImposters), "Imposters: {H1}");

	bool found; bool first = true;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && g_Player[i].role == Role_Imposter)
		{
			if (first)
				Format(sImposters, sizeof(sImposters), "%s%N", sImposters, i);
			else
				Format(sImposters, sizeof(sImposters), "%s, %N", sImposters, i);
			
			found = true;
			first = false;
		}
	}

	if (!found)
		Format(sImposters, sizeof(sImposters), "%s<None Found>", sImposters);

	CReplyToCommand(client, sImposters);
	return Plugin_Handled;
}

public Action Command_Start(int client, int args)
{
	if (!CheckCommandAccess(client, "", ADMFLAG_SLAY, true) && client != g_GameOwner)
	{
		CPrintToChat(client, "You do not have access to this menu.");
		return Plugin_Handled;
	}

	TF2_SetSetupTime(6); //Starts at 6 so the announcer starts counting from 5 instead of 4.
	CPrintToChatAll("{H1}%N {default}has started the match.", client);
	return Plugin_Handled;
}

public Action Command_Mark(int client, int args)
{
	if (client == 0)
	{
		return Plugin_Handled;
	}

	if (args < 1)
	{
		return Plugin_Handled;
	}

	if (!IsPlayerAlive(client))
	{
		return Plugin_Handled;
	}

	if (!NavMesh_Exists())
	{
		return Plugin_Handled;
	}

	float origin[3];
	GetClientAbsOrigin(client, origin);

	CNavArea area = NavMesh_GetNearestArea(origin, true, 10000.0, false, true, -2);

	if (area == INVALID_NAV_AREA)
	{
		return Plugin_Handled;
	}

	int id = area.ID;

	char sName[64];
	GetCmdArgString(sName, sizeof(sName));

	char sID[16];
	IntToString(id, sID, sizeof(sID));

	g_AreaNames.SetString(sID, sName);

	CPrintToChat(client, "Name {H1}%s {default}set for Navmesh ID {H2}%i{default}.", sName, id);
	
	return Plugin_Handled;
}

public Action Command_SaveMarks(int client, int args)
{
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));

	SaveMarks(sMap);
	CReplyToCommand(client, "Marks for map {H1}%s {default}has been saved.", sMap);
	
	return Plugin_Handled;
}

public Action Command_Cameras(int client, int args)
{
	OpenCamerasMenu(client);
	return Plugin_Handled;
}

public Action Command_GiveTask(int client, int args)
{
	if (args < 2)
	{
		char sCommand[32];
		GetCmdArg(0, sCommand, sizeof(sCommand));
		CReplyToCommand(client, "Usage: {H2}%s {H1}<target> <task>", sCommand);
		return Plugin_Handled;
	}

	char sTarget[MAX_TARGET_LENGTH];
	GetCmdArg(1, sTarget, sizeof(sTarget));
	int target = FindTarget(client, sTarget, true, false);

	if (target < 1)
	{
		CReplyToCommand(client, "Target {H1}%s {default}not found, please try again.", sTarget);
		return Plugin_Handled;
	}

	char sTask[32];
	GetCmdArg(2, sTask, sizeof(sTask));
	int task = GetTaskByName(sTask);

	if (task == -1)
	{
		CReplyToCommand(client, "Invalid task specified, please try again.");
		return Plugin_Handled;
	}

	AssignTask(target, task);
	SendHud(target);

	CReplyToCommand(client, "You have assigned task {H1}%s {default} to {H2}%N{default}.", sTask, target);
	CPrintToChat(target, "{H2}%N {default}has assigned you the task: {H1}%s", client, sTask);

	return Plugin_Handled;
}

public Action Command_AssignTask(int client, int args)
{
	OpenAssignTaskMenu(client);
	return Plugin_Handled;
}

public Action Command_EditMarks(int client, int args)
{
	g_Player[client].editingmarks = !g_Player[client].editingmarks;
	CPrintToChat(client, "Marks Editor: {H2}%s", g_Player[client].editingmarks ? "Enabled" : "Disabled");
	return Plugin_Handled;
}

public Action Command_PaintMarks(int client, int args)
{
	if (strlen(g_Player[client].paintmarks) > 0)
	{
		g_Player[client].paintmarks[0] = '\0';
		CPrintToChat(client, "Mark painting has been disabled.");
		return Plugin_Handled;
	}

	char sName[64];
	GetCmdArgString(sName, sizeof(sName));

	strcopy(g_Player[client].paintmarks, 64, sName);
	CPrintToChat(client, "Painting areas of movement for: %s", g_Player[client].paintmarks);

	return Plugin_Handled;
}