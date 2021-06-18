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
	CPrintToChat(client, "Current Role: %s", sRole);
	
	return Plugin_Handled;
}

public Action Command_GameSettings(int client, int args)
{
	OpenSettingsMenu(client);
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
		CReplyToCommand(client, "Usage: %s <target> <role>", sCommand);
		return Plugin_Handled;
	}

	char sTarget[MAX_TARGET_LENGTH];
	GetCmdArg(1, sTarget, sizeof(sTarget));

	int target = FindTarget(client, sTarget, true, false);

	if (target < 1)
	{
		CReplyToCommand(client, "Target '%s' not found, please try again.", sTarget);
		return Plugin_Handled;
	}

	char sRole[32];
	GetCmdArg(2, sRole, sizeof(sRole));

	if (!IsValidRole(sRole))
	{
		char sRoles[255];
		RoleNamesBuffer(sRoles, sizeof(sRoles));
		CPrintToChat(client, "Specified role invalid, please choose the following: %s", sRoles);
		return Plugin_Handled;
	}

	g_Player[target].role = GetRoleByName(sRole);
	SendHud(target);

	if (client == target)
		CPrintToChat(client, "You have updated your role to: %s", sRole);
	else
	{
		CPrintToChat(client, "You have updated %N's role to: %s", target, sRole);
		CPrintToChat(target, "%N has updated your role to: %s", client, sRole);
	}

	return Plugin_Handled;
}