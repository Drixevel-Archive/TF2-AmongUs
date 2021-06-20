/*****************************/
//Menus

/////
//Colors
void OpenColorsMenu(int client)
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

		case MenuAction_End:
			delete menu;
	}
}

void OpenSettingsMenu(int client)
{
	if (!IsAdmin(client) && client != g_GameOwner)
	{
		CPrintToChat(client, "You are not currently the game owner, you aren't allowed to change game settings.");
		return;
	}

	Menu menu = new Menu(MenuHandler_GameSettings);
	menu.SetTitle("[Mode] Settings %s", IsAdmin(client) ? "(ADMIN)" : "");

	char sInfo[32];
	char sDisplay[256];

	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));

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
				CPrintToChat(param1, "You are not currently the game owner, you aren't allowed to change game settings.");
				return;
			}

			if (TF2_IsInSetup())
			{
				char sInfo[32];
				menu.GetItem(param2, sInfo, sizeof(sInfo));
				strcopy(g_UpdatingGameSetting[param1], 32, sInfo);
				CPrintToChat(param1, "Please type in chat the new value for key '%s':", sInfo);
			}
			else
			{
				CPrintToChat(param1, "You are not allowed to change settings while the match is live.");
				OpenSettingsMenu(param1);
			}
		}

		case MenuAction_End:
			delete menu;
	}
}

void CreateVoteMenu(int client)
{
	if (g_Match.meeting == null)
	{
		TF2_PlayDenySound(client);
		CPrintToChat(client, "You can only cast votes while a meeting is going on.");
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
				CPrintToChat(param1, "You are not allowed to vote while dead.");
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
				CPrintToChatAll("{H1}%N {default}voted for {H2}Themself!", param1);
			else if (target == 0)
				CPrintToChatAll("{H1}%N {default}voted to Skip!", param1);
			else
				CPrintToChatAll("{H1}%N {default}voted for {H2}%N!", param1, target);

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

	int entity = -1; char sName[32]; char sID[16]; char sDisplay[256];
	while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

		if (StrContains(sName, "vent", false) != 0)
			continue;
		
		ReplaceString(sName, sizeof(sName), "vent_", "");
		
		bool routed;
		for (int x = 0; x < parts; x++)
			if (StringToInt(sPart[x]) == StringToInt(sName))
				routed = true;
		
		if (!routed)
			continue;
		
		IntToString(EntIndexToEntRef(entity), sID, sizeof(sID));
		FormatEx(sDisplay, sizeof(sDisplay), "Vent #%i", entity);
		menu.AddItem(sID, sDisplay);
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
			EmitSoundToClient(param1, "doors/vent_open3.wav", SOUND_FROM_PLAYER, SNDCHAN_REPLACE, SNDLEVEL_NONE, SND_CHANGEVOL, 0.75);

			OpenVentsMenu(param1, vent);
		}

		case MenuAction_End:
			delete menu;
	}
}

void OpenCamerasMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Cameras);
	menu.SetTitle("Cameras:");

	menu.AddItem("no", "no camera");

	int entity = -1; char sID[16]; char sName[64];
	while ((entity = FindEntityByClassname(entity, "point_viewcontrol")) != -1)
	{
		IntToString(entity, sID, sizeof(sID));
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

		if (StrContains(sName, "camera", false) == 0)
			menu.AddItem(sID, sName);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Cameras(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sID[16]; char sName[64];
			menu.GetItem(param2, sID, sizeof(sID), _, sName, sizeof(sName));

			if (StrEqual(sID, "no", false))
			{
				SetEntProp(param1, Prop_Send, "m_iObserverMode", 0);
				SetClientViewEntity(param1, param1);
				SetEntityMoveType(param1, MOVETYPE_WALK);
				OpenCamerasMenu(param1);
				return;
			}

			int entity = StringToInt(sID);

			char sWatcher[64];
			Format(sWatcher, sizeof(sWatcher), "target%i", param1);
			DispatchKeyValue(param1, "targetname", sWatcher);

			SetClientViewEntity(param1, entity);
			SetEntProp(param1, Prop_Send, "m_iObserverMode", 1);
			SetEntityMoveType(param1, MOVETYPE_OBSERVER);

			SetVariantString(sWatcher);
			AcceptEntityInput(entity, "Enable", param1, entity, 0);

			float origin[3];
			GetEntityAbsOrigin(entity, origin);
			TeleportEntity(param1, origin, NULL_VECTOR, NULL_VECTOR);

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