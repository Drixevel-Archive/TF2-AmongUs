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
			
			char sInfo[32];
			menu.GetItem(param2, sInfo, sizeof(sInfo));

			strcopy(g_UpdatingGameSetting[param1], 32, sInfo);
			CPrintToChat(param1, "Please type in chat the new value for key '%s':", sInfo);
		}

		case MenuAction_End:
			delete menu;
	}
}

void CreateVoteMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Vote);
	menu.SetTitle("Choose a player to eject:");

	char sID[16]; char sDisplay[256]; int draw; int votes;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || TF2_GetClientTeam(i) < TFTeam_Red)
			continue;
		
		draw = ITEMDRAW_DEFAULT;
		votes = 0;

		if (!IsPlayerAlive(i))
			draw = ITEMDRAW_DISABLED;
		
		if (g_Player[client].voted_for != -1)
			draw = ITEMDRAW_DISABLED;
		
		for (int x = 1; x <= MaxClients; x++)
			if (IsClientInGame(x) && IsPlayerAlive(x) && g_Player[x].voted_for == i)
				votes++;
		
		IntToString(GetClientUserId(i), sID, sizeof(sID));
		FormatEx(sDisplay, sizeof(sDisplay), "%N (%i)", i, votes);
		menu.AddItem(sID, sDisplay, draw);
	}

	menu.AddItem("-1", "Close Menu");

	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Vote(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sID[16];
			menu.GetItem(param2, sID, sizeof(sID));
			int userid = StringToInt(sID);

			if (userid == -1)
				return;

			int target = GetClientOfUserId(userid);

			if (target < 1)
			{
				if (g_Match.meeting != null)
					CreateVoteMenu(param1);
				
				return;
			}

			g_Player[param1].voted_for = target;
			g_Player[target].voted_to++;

			if (param1 == target)
				CPrintToChatAll("{H1}%N {default}voted for {H2}Themself!", param1);
			else
				CPrintToChatAll("{H1}%N {default}voted for {H2}%N!", param1, target);

			if (g_Match.meeting != null)
				CreateVoteMenu(param1);
		}

		case MenuAction_End:
			delete menu;
	}
}