/*****************************/
//Commands

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
	
	int target = GetClientAimTarget(client, true);

	if (target < 1)
	{
		CReplyToCommand(client, "Target not found, please aim your crosshair at them.");
		return Plugin_Handled;
	}

	EjectPlayer(client);
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