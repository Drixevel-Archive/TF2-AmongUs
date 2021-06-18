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
			
			char sInfo[32];
			menu.GetItem(param2, sInfo, sizeof(sInfo));

			strcopy(g_UpdatingGameSetting[param1], 32, sInfo);
			CPrintToChat(param1, "Please type in chat the new value for key '%s':", sInfo);
		}

		case MenuAction_End:
			delete menu;
	}
}