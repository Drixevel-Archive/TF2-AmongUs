/*****************************/
//Menus

void OpenMainMenu(int client)
{
	Menu menu = new Menu(MenuHandler_MainMenu);
	menu.SetTitle("%s (%s)", PLUGIN_NAME, PLUGIN_VERSION);

	menu.AddItem("description", "Brief Description");
	menu.AddItem("color", "Set your Color");
	menu.AddItem("gamesettings", "Change your Game Settings");

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_MainMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sInfo[32];
			menu.GetItem(param2, sInfo, sizeof(sInfo));

			if (StrEqual(sInfo, "description", false))
			{
				CPrintToChat(param1, "%T", "brief description", param1, PLUGIN_DESCRIPTION);
				OpenMainMenu(param1);
			}
			else if (StrEqual(sInfo, "color", false))
				OpenColorsMenu(param1, true);
			else if (StrEqual(sInfo, "gamesettings", false))
				OpenSettingsMenu(param1, true);
		}
		
		case MenuAction_End:
			delete menu;
	}
}

/////
//Colors
void OpenColorsMenu(int client, bool backbutton = false)
{
	Menu menu = new Menu(MenuHandler_Colors);
	menu.SetTitle("Available Colors:");

	menu.AddItem("-1", "No Color");

	char sID[16];
	for (int i = 0; i < g_TotalColors; i++)
	{
		IntToString(i, sID, sizeof(sID));
		menu.AddItem(sID, g_Colors[i].name);
	}

	menu.ExitBackButton = backbutton;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Colors(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sID[16];
			menu.GetItem(param2, sID, sizeof(sID));
			int color = StringToInt(sID);

			SetColor(param1, color);
			OpenColorsMenu(param1);
		}

		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				OpenMainMenu(param1);
		
		case MenuAction_End:
			delete menu;
	}
}

void OpenSettingsMenu(int client, bool backbutton = false)
{
	if (!IsAdmin(client) && client != g_GameOwner)
	{
		CPrintToChat(client, "%T", "denied settings change not game owner", client);
		return;
	}

	Menu menu = new Menu(MenuHandler_GameSettings);
	menu.SetTitle("[Mode] Settings %s", IsAdmin(client) ? "(ADMIN)" : "");

	char sInfo[32];
	char sDisplay[256];

	menu.AddItem("start", "Start Match");

	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));

	menu.AddItem("reset", "Reset Settings To Default");

	FormatEx(sInfo, sizeof(sInfo), "map");
	FormatEx(sDisplay, sizeof(sDisplay), "Map: %s", sMap);
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "imposters");
	FormatEx(sDisplay, sizeof(sDisplay), "# Imposters: %i (Limit: 0)", GetGameSetting_Int("imposters"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "confirm_ejects");
	FormatEx(sDisplay, sizeof(sDisplay), "Confirm Ejects: %s", GetGameSetting_Bool("confirm_ejects") ? "On" : "Off");
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "emergency_meetings");
	FormatEx(sDisplay, sizeof(sDisplay), "# Emergency Meetings: %i", GetGameSetting_Int("emergency_meetings"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "emergency_cooldowns");
	FormatEx(sDisplay, sizeof(sDisplay), "Emergency Cooldowns: %is", RoundFloat(GetGameSetting_Float("emergency_cooldowns")));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "discussion_time");
	FormatEx(sDisplay, sizeof(sDisplay), "Discussion Time: %is", GetGameSetting_Int("discussion_time"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "voting_time");
	FormatEx(sDisplay, sizeof(sDisplay), "Voting Time: %is", GetGameSetting_Int("voting_time"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "player_speed");
	FormatEx(sDisplay, sizeof(sDisplay), "Player Speed: %.0fx", GetGameSetting_Float("player_speed"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "crewmate_vision");
	FormatEx(sDisplay, sizeof(sDisplay), "Crewmate Vision: %.0fx", GetGameSetting_Float("crewmate_vision"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "imposter_vision");
	FormatEx(sDisplay, sizeof(sDisplay), "Imposter Vision: %.0fx", GetGameSetting_Float("imposter_vision"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "kill_cooldown");
	FormatEx(sDisplay, sizeof(sDisplay), "Kill Cooldown: %is", GetGameSetting_Int("kill_cooldown"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "kill_distance");
	FormatEx(sDisplay, sizeof(sDisplay), "Kill Distance: %.2f", GetGameSetting_Float("kill_distance"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "visual_tasks");
	FormatEx(sDisplay, sizeof(sDisplay), "Visual Tasks: %s", GetGameSetting_Bool("visual_tasks") ? "On" : "Off");
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "common_tasks");
	FormatEx(sDisplay, sizeof(sDisplay), "Common Tasks: %i", GetGameSetting_Int("common_tasks"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "long_tasks");
	FormatEx(sDisplay, sizeof(sDisplay), "Long Tasks: %i", GetGameSetting_Int("long_tasks"));
	menu.AddItem(sInfo, sDisplay);

	FormatEx(sInfo, sizeof(sInfo), "short_tasks");
	FormatEx(sDisplay, sizeof(sDisplay), "Short Tasks: %i", GetGameSetting_Int("short_tasks"));
	menu.AddItem(sInfo, sDisplay);

	menu.ExitBackButton = backbutton;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_GameSettings(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!IsAdmin(param1) && param1 != g_GameOwner)
			{
				CPrintToChat(param1, "%T", "denied settings change not game owner", param1);
				return;
			}

			if (TF2_IsInSetup())
			{
				char sInfo[32];
				menu.GetItem(param2, sInfo, sizeof(sInfo));

				if (StrEqual(sInfo, "reset", false))
				{
					ParseGameSettings();
					SaveGameSettings(param1);
					OpenSettingsMenu(param1);
					CPrintToChat(param1, "%T", "game settings reset", param1);

				}
				else if (StrEqual(sInfo, "start", false))
				{
					TF2_SetSetupTime(6);
					CPrintToChatAll("%t", "match manually started", param1);
				}
				else
				{
					strcopy(g_UpdatingGameSetting[param1], 32, sInfo);
					CPrintToChat(param1, "%T", "change game setting", param1, sInfo);
				}
			}
			else
			{
				CPrintToChat(param1, "%T", "denied settings change match is live", param1);
				OpenSettingsMenu(param1);
			}
		}

		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				OpenMainMenu(param1);

		case MenuAction_End:
			delete menu;
	}
}

void CreateVoteMenu(int client)
{
	if (g_Match.meeting == null)
	{
		SendDenyMessage(client, "You can only cast votes while a meeting is going on.");
		return;
	}
	
	Menu menu = new Menu(MenuHandler_Vote);
	menu.SetTitle("Choose a player to eject: %s", g_Player[client].voted_for != -1 ? "(Vote Casted)" : "");

	menu.AddItem("0", "Vote to Skip", g_Player[client].voted_for != -1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	char sID[16]; char sDisplay[256]; int draw; int votes; char sStatus[32];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || TF2_GetClientTeam(i) < TFTeam_Red)
			continue;
		
		draw = ITEMDRAW_DEFAULT;
		votes = 0;
		sStatus[0] = '\0';

		//Player isn't alive so they can't be voted on.
		if (!IsPlayerAlive(i))
		{
			draw = ITEMDRAW_DISABLED;
			Format(sStatus, sizeof(sStatus), "%s (Dead)", sStatus);
		}
		
		//Player who owns the menu has voted already, disable all of the voting options.
		if (g_Player[client].voted_for != -1)
			draw = ITEMDRAW_DISABLED;
		
		//No status found so lets just display their current amount of votes.
		if (strlen(sStatus) == 0)
		{
			for (int x = 1; x <= MaxClients; x++)
				if (IsClientInGame(x) && IsPlayerAlive(x) && g_Player[x].voted_for == i)
					votes++;

			FormatEx(sStatus, sizeof(sStatus), "(%i)", votes);
		}
		
		IntToString(GetClientUserId(i), sID, sizeof(sID));
		FormatEx(sDisplay, sizeof(sDisplay), "%N %s", i, sStatus);
		menu.AddItem(sID, sDisplay, draw);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Vote(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!IsPlayerAlive(param1))
			{
				CPrintToChat(param1, "%T", "voting while dead", param1);
				CreateVoteMenu(param1);
				return;
			}

			if (g_Match.meeting == null)
			{
				CPrintToChat(param1, "%T", "meeting not active", param1);
				CreateVoteMenu(param1);
				return;
			}
				
			char sID[16];
			menu.GetItem(param2, sID, sizeof(sID));
			
			int userid = StringToInt(sID);
			int target = GetClientOfUserId(userid);

			g_Player[param1].voted_for = target;
			g_Player[target].voted_to++;

			bool allvoted = true;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i) && g_Player[i].voted_for == -1)
				{
					allvoted = false;
					break;
				}
			}
			
			if (allvoted)
			{
				g_Match.meeting_time = 0;
				TriggerTimer(g_Match.meeting);
			}
			else
			{
				for (int i = 1; i <= MaxClients; i++)
					CreateVoteMenu(i);
			}

			if (param1 == target)
				CPrintToChatAll("%t", "voted themself", param1);
			else if (target == 0)
				CPrintToChatAll("%t", "voted to skip", param1);
			else
				CPrintToChatAll("%t", "voted against", param1, target);
			
			EmitSoundToClient(param1, SOUND_VOTE_CONFIRM);

			if (g_Match.meeting != null)
				CreateVoteMenu(param1);
		}

		case MenuAction_End:
			delete menu;
	}
}

void OpenVentsMenu(int client, int vent)
{
	if (!g_Player[client].venting)
		return;

	char sRoutes[32];
	GetCustomKeyValue(vent, "routes", sRoutes, sizeof(sRoutes));

	char sPart[32][32];
	int parts = ExplodeString(sRoutes, ",", sPart, 32, 32);
	
	Menu menu = new Menu(MenuHandler_Vents);
	menu.SetTitle("Teleport to a vent:");

	int entity = -1; char sName[32]; char sID[16]; char sItemDisplay[256];
	while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

		if (StrContains(sName, "vent", false) != 0)
			continue;
		
		char sDisplay[64];
		GetCustomKeyValue(entity, "display", sDisplay, sizeof(sDisplay));
		
		char sIndex[32];
		GetCustomKeyValue(entity, "index", sIndex, sizeof(sIndex));
		int index = StringToInt(sIndex);
		
		bool routed;
		for (int x = 0; x < parts; x++)
			if (StringToInt(sPart[x]) == index)
				routed = true;
		
		if (!routed)
			continue;
		
		IntToString(EntIndexToEntRef(entity), sID, sizeof(sID));
		FormatEx(sItemDisplay, sizeof(sItemDisplay), "Vent #%i (%s)", index, sDisplay);
		menu.AddItem(sID, sItemDisplay);
	}

	PushMenuInt(menu, "vent", vent);

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Vents(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!g_Player[param1].venting)
				return;
			
			int vent = GetMenuInt(menu, "vent");
			
			char sID[16];
			menu.GetItem(param2, sID, sizeof(sID));

			int entity = EntRefToEntIndex(StringToInt(sID));

			if (!IsValidEntity(entity))
			{
				OpenVentsMenu(param1, vent);
				return;
			}

			float origin[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
			origin[2] += 20.0;

			TeleportEntity(param1, origin, NULL_VECTOR, NULL_VECTOR);
			//EmitSoundToClient(param1, "doors/vent_open3.wav", SOUND_FROM_PLAYER, SNDCHAN_REPLACE, SNDLEVEL_NONE, SND_CHANGEVOL, 0.75);
			
			switch (GetRandomInt(1, 3))
			{
				case 1:
					EmitSoundToClient(param1, SOUND_VENT_MOVE1);
				case 2:
					EmitSoundToClient(param1, SOUND_VENT_MOVE2);
				case 3:
					EmitSoundToClient(param1, SOUND_VENT_MOVE3);
			}

			g_Player[param1].nearvent = entity;
			OpenVentsMenu(param1, entity);

			Call_StartForward(g_Forward_OnVentingSwitchPost);
			Call_PushCell(param1);
			Call_PushCell(vent);
			Call_Finish();
		}

		case MenuAction_End:
			delete menu;
	}
}

void OpenCamerasMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Cameras);
	menu.SetTitle("Cameras:");

	menu.AddItem("no", "Exit Camera View");

	int entity = -1; char sID[16]; char sName[64];
	while ((entity = FindEntityByClassname(entity, "point_viewcontrol")) != -1)
	{
		IntToString(entity, sID, sizeof(sID));
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

		if (StrContains(sName, "camera", false) != 0)
			continue;
		
		char sDisplay[64];
		GetCustomKeyValue(entity, "display", sDisplay, sizeof(sDisplay));

		menu.AddItem(sID, sDisplay);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Cameras(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (g_Player[param1].camera != -1 && !g_IsDead[param1])
			{
				char sLight[256];
				GetCustomKeyValue(g_Player[param1].camera, "light", sLight, sizeof(sLight));
				int light = FindEntityByName(sLight, "light");
				if (IsValidEntity(light))
					AcceptEntityInput(light, "TurnOff");
			}
			
			char sID[16]; char sName[64];
			menu.GetItem(param2, sID, sizeof(sID), _, sName, sizeof(sName));
			
			int entity = StringToInt(sID);

			char sLight[256];
			GetCustomKeyValue(entity, "light", sLight, sizeof(sLight));
			int light = FindEntityByName(sLight, "light");

			if (StrEqual(sID, "no", false))
			{
				SetClientViewEntity(param1, param1);
				TF2_SetFirstPerson(param1);
				AcceptEntityInput(entity, "Disable", param1);
				g_Player[param1].camera = -1;
				SetEntityMoveType(param1, MOVETYPE_WALK);
				return;
			}

			DispatchKeyValue(entity, "spawnflags", "8");
			TF2_SetThirdPerson(param1);
			AcceptEntityInput(entity, "Enable", param1);
			
			if (IsValidEntity(light) && !g_IsDead[param1])
				AcceptEntityInput(light, "TurnOn");
			
			g_Player[param1].camera = entity;
			SetEntityMoveType(param1, MOVETYPE_NONE);

			OpenCamerasMenu(param1);
		}

		case MenuAction_End:
			delete menu;
	}
}

stock void GetEntityAbsOrigin(int entity, float origin[3])
{
	float mins[3]; float maxs[3];
	GetEntPropVector(entity,Prop_Send,"m_vecOrigin",origin);
	GetEntPropVector(entity,Prop_Send,"m_vecMins",mins);
	GetEntPropVector(entity,Prop_Send,"m_vecMaxs",maxs);

	origin[0] += (mins[0] + maxs[0]) * 0.5;
	origin[1] += (mins[1] + maxs[1]) * 0.5;
	origin[2] += (mins[2] + maxs[2]) * 0.5;
}

void OpenAssignTaskMenu(int client)
{
	Menu menu = new Menu(MenuHandler_AssignTask);
	menu.SetTitle("Assign a task to you:");

	char sID[16]; char sItemDisplay[256];
	for (int i = 0; i < g_TotalTasks; i++)
	{
		TaskType type = g_Tasks[i].tasktype;

		if (type == TaskType_Part)
			continue;
		
		char sType[32];
		GetTaskTypeDisplayName(type, sType, sizeof(sType));

		IntToString(i, sID, sizeof(sID));
		FormatEx(sItemDisplay, sizeof(sItemDisplay), "%s (%s)", g_Tasks[i].display, sType);

		menu.AddItem(sID, sItemDisplay);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_AssignTask(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sID[16];
			menu.GetItem(param2, sID, sizeof(sID));
			int id = StringToInt(sID);

			AssignTask(param1, id);
			SendHud(param1);
			
			OpenAssignTaskMenu(param1);
		}

		case MenuAction_End:
			delete menu;
	}
}

void OpenMap(int client, bool repeat = false)
{
	if (!NavMesh_Exists())
		return;
	
	Panel panel = new Panel();
	panel.SetTitle("Admin Panel (Updates every Second)");

	ArrayList locations = new ArrayList(ByteCountToCells(64));
	StringMap amounts = new StringMap();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || g_Player[i].venting)
			continue;

		float origin[3];
		GetClientAbsOrigin(i, origin);

		CNavArea area = NavMesh_GetNearestArea(origin, true, 10000.0, false, true, -2);

		if (area != INVALID_NAV_AREA)
		{
			char sID[16];
			IntToString(area.ID, sID, sizeof(sID));

			char sName[64];
			g_AreaNames.GetString(sID, sName, sizeof(sName));

			if (locations.FindString(sName) == -1)
				locations.PushString(sName);
			
			int total;
			amounts.GetValue(sName, total);
			total++;
			amounts.SetValue(sName, total);
		}
	}

	for (int i = 0; i < locations.Length; i++)
	{
		char sLocation[64];
		locations.GetString(i, sLocation, sizeof(sLocation));

		int total;
		amounts.GetValue(sLocation, total);

		char sDisplay[128];
		FormatEx(sDisplay, sizeof(sDisplay), "%s: %i", sLocation, total);
		panel.DrawText(sDisplay);
	}

	delete locations;
	delete amounts;

	panel.DrawItem("Exit");

	panel.Send(client, MenuAction_Void, MENU_TIME_FOREVER);
	delete panel;

	if (repeat)
	{
		StopTimer(g_Player[client].map);
		g_Player[client].map = CreateTimer(1.0, Timer_OpenMap, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public int MenuAction_Void(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			StopTimer(g_Player[param1].map);
			SetEntityMoveType(param1, MOVETYPE_WALK);
		}

		case MenuAction_End:
			delete menu;
	}
}

public Action Timer_OpenMap(Handle timer, any data)
{
	int client = data;
	OpenMap(client);
}