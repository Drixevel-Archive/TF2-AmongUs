/*****************************/
//Commands

public Action Command_MainMenu(int client, int args)
{
	if (client == 0)
		return Plugin_Handled;
	
	OpenMainMenu(client);
	return Plugin_Handled;
}

public Action Command_Commands(int client, int args)
{
	if (client == 0)
		return Plugin_Handled;
	
	OpenCommandsMenu(client);
	return Plugin_Handled;
}

public Action Command_AdminCommands(int client, int args)
{
	if (client == 0)
		return Plugin_Handled;
	
	OpenCommandsMenu(client, true);
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
	CPrintToChat(client, "%T", "current role", client, sRole);
	
	return Plugin_Handled;
}

public Action Command_GameSettings(int client, int args)
{
	OpenSettingsMenu(client);
	return Plugin_Handled;
}

public Action Command_Owner(int client, int args)
{
	char sName[MAX_NAME_LENGTH];
	if (g_GameOwner != -1)
		GetClientName(g_GameOwner, sName, sizeof(sName));
	else
		strcopy(sName, sizeof(sName), "<Not Active>");
	
	CReplyToCommand(client, "%T", "current owner", client, sName);
	
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
	CReplyToCommand(client, "%T", "colors reloaded", client);
	return Plugin_Handled;
}

public Action Command_SetRole(int client, int args)
{
	if (args < 2)
	{
		char sCommand[32];
		GetCmdArg(0, sCommand, sizeof(sCommand));
		CReplyToCommand(client, "%T", "usage set role", client, sCommand);
		return Plugin_Handled;
	}

	char sTarget[MAX_TARGET_LENGTH];
	GetCmdArg(1, sTarget, sizeof(sTarget));

	int target = FindTarget(client, sTarget, true, false);

	if (target < 1)
	{
		CReplyToCommand(client, "%T", "target not found", client, sTarget);
		return Plugin_Handled;
	}

	char sRole[32];
	GetCmdArg(2, sRole, sizeof(sRole));

	if (!IsValidRole(sRole))
	{
		char sRoles[255];
		RoleNamesBuffer(sRoles, sizeof(sRoles));
		CPrintToChat(client, "%T", "invalid role specified", client ,sRoles);
		return Plugin_Handled;
	}

	g_Player[target].role = GetRoleByName(sRole);
	SendHud(target);

	Call_StartForward(g_Forward_OnRoleAssignedPost);
	Call_PushCell(target);
	Call_PushCell(g_Player[target].role);
	Call_Finish();

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
		CPrintToChat(client, "%T", "role updated", client, sRole);
	else
	{
		CPrintToChat(client, "%T", "target role updated", client, target, sRole);
		CPrintToChat(target, "%T", "admin role updated", target, client, sRole);
	}

	return Plugin_Handled;
}

public Action Command_SetOwner(int client, int args)
{
	if (args < 1)
	{
		char sCommand[32];
		GetCmdArg(0, sCommand, sizeof(sCommand));
		CReplyToCommand(client, "%T", "usage set owner", client, sCommand);
		return Plugin_Handled;
	}

	char sTarget[MAX_TARGET_LENGTH];
	GetCmdArgString(sTarget, sizeof(sTarget));

	int target = FindTarget(client, sTarget, true, false);

	if (target < 1)
	{
		CReplyToCommand(client, "%T", "target not found", client, sTarget);
		return Plugin_Handled;
	}

	g_GameOwner = target;
	LoadGameSettings(target);
	OpenSettingsMenu(target);
	SendHudToAll();

	CPrintToChatAll("%t", "game owner set by admin", client, target);

	return Plugin_Handled;
}

public Action Command_RemoveOwner(int client, int args)
{
	if (g_GameOwner == -1)
	{
		CReplyToCommand(client, "%T", "no active game owner", client);
		return Plugin_Handled;
	}

	CPrintToChatAll("%t", "game owner removed", client, g_GameOwner);
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
	
	CPrintToChatAll("%t", "admin respawned dead players");
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
		CReplyToCommand(client, "%T", "target not found", client, sTarget);
		return Plugin_Handled;
	}

	if (!IsClientInGame(target))
	{
		CReplyToCommand(client, "%T", "target not ingame", client, target);
		return Plugin_Handled;
	}

	if (!IsPlayerAlive(target))
	{
		CReplyToCommand(client, "%T", "target not alive", client, target);
		return Plugin_Handled;
	}

	EjectPlayer(target);
	CPrintToChatAll("%t", "admin ejection", client, target);

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
		CPrintToChat(client, "%T", "no command access", client);
		return Plugin_Handled;
	}

	TF2_SetSetupTime(6); //Starts at 6 so the announcer starts counting from 5 instead of 4.
	CPrintToChatAll("%t", "match manually started", client);

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

	CPrintToChat(client, "%T", "mark set", client, sName, id);
	
	return Plugin_Handled;
}

public Action Command_SaveMarks(int client, int args)
{
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));

	SaveMarks(sMap);
	CReplyToCommand(client, "%T", "marks saved", client, sMap);
	
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
		CReplyToCommand(client, "%T", "usage give task", client, sCommand);
		return Plugin_Handled;
	}

	char sTarget[MAX_TARGET_LENGTH];
	GetCmdArg(1, sTarget, sizeof(sTarget));
	int target = FindTarget(client, sTarget, true, false);

	if (target < 1)
	{
		CReplyToCommand(client, "%T", "target not found", client, sTarget);
		return Plugin_Handled;
	}

	char sTask[32];
	GetCmdArg(2, sTask, sizeof(sTask));
	int task = GetTaskByName(sTask);

	if (task == -1)
	{
		CReplyToCommand(client, "%T", "invalid task specified", client);
		return Plugin_Handled;
	}

	AssignTask(target, task);
	SendHud(target);

	CReplyToCommand(client, "%T", "task assigned admin", client, sTask, target);
	CPrintToChat(target, "%T", "task assigned maually", target, client, sTask);

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
	CPrintToChat(client, "%T", "marks editor toggle", client, g_Player[client].editingmarks ? "Enabled" : "Disabled");
	return Plugin_Handled;
}

public Action Command_PaintMarks(int client, int args)
{
	if (strlen(g_Player[client].paintmarks) > 0)
	{
		g_Player[client].paintmarks[0] = '\0';
		CPrintToChat(client, "%T", "marks painting disabled", client);
		return Plugin_Handled;
	}

	char sName[64];
	GetCmdArgString(sName, sizeof(sName));

	strcopy(g_Player[client].paintmarks, 64, sName);
	CPrintToChat(client, "%T", "marks painting enabled", client, g_Player[client].paintmarks);

	return Plugin_Handled;
}

public Action Command_PlayIntro(int client, int args)
{
	if (g_Match.intro)
	{
		if (client > 0)
			SendDenyMessage(client, "%T", "error intro already active", client);
		else
			CReplyToCommand(client, "%T", "error intro already active", client);

		return Plugin_Handled;
	}

	PlayIntro();
	CPrintToChatAll("%t", "admin played intro", client);
	
	return Plugin_Handled;
}