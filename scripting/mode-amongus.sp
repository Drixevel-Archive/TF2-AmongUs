/**
 * Notes

Task Entities:
target: task
type: common/visual/short/long
task: <task name>

 */

/*****************************/
//Pragma
#pragma semicolon 1
#pragma newdecls required

/*****************************/
//Defines
#define PLUGIN_NAME "[Mode] Among Us"
#define PLUGIN_DESCRIPTION "A mode which replicates the Among Us game."
#define PLUGIN_VERSION "1.0.0"

#define NO_COLOR -1

/*****************************/
//Includes
#include <sourcemod>
#include <tf2_stocks>
#include <colors>

/*****************************/
//ConVars

/*****************************/
//Globals

enum Roles
{
	Role_Crewmate,
	Role_Imposter
};

enum struct Player
{
	int color;
	Roles role;

	void Init()
	{
		this.color = NO_COLOR;
		this.role = Role_Crewmate;
	}

	void Clear()
	{
		this.color = NO_COLOR;
		this.role = Role_Crewmate;
	}
}

Player g_Player[MAXPLAYERS + 1];

enum struct Colors
{
	char name[32];
	int color[4];
}

Colors g_Colors[256];
int g_TotalColors;

/*****************************/
//Managed

#include "mode/commands.sp"
#include "mode/events.sp"
#include "mode/natives.sp"
#include "mode/stocks.sp"

/*****************************/
//Plugin Info
public Plugin myinfo = 
{
	name = PLUGIN_NAME, 
	author = "Drixevel", 
	description = PLUGIN_DESCRIPTION, 
	version = PLUGIN_VERSION, 
	url = "https://scoutshideaway.com/"
};

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("post_inventory_application", Event_OnPostInventoryApplication);

	HookUserMessage(GetUserMessageId("VGUIMenu"), OnVGUIMenu, true);

	RegConsoleCmd("sm_colors", Command_Colors, "Displays the list of available colors which you can pick.");
	RegConsoleCmd("sm_role", Command_Role, "Displays what your current role is in chat.");

	RegAdminCmd("sm_reloadcolors", Command_ReloadColors, ADMFLAG_GENERIC, "Reload available colors players can use.");

	ParseColors();

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientConnected(i))
			OnClientConnected(i);
}

public Action OnVGUIMenu(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) 
{
	char sMSG[12];
	BfReadString(msg, sMSG, sizeof(sMSG));

	// PrintToServer(sMSG);

	//Is only called whenever a player joins and then see's the class menu, not while they're already on the server.
	//We don't want that menu to pop up because there's no point to choosing your class so we return Plugin_Stop here.
	if (StrContains(sMSG, "class_", false) == 0)
	{
		int client = players[0];
		FakeClientCommand(client, "joinclass engineer");
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action OnClientCommand(int client, int args)
{
	char sCommand[32];
	GetCmdArg(0, sCommand, sizeof(sCommand));
	// PrintToServer(sCommand);

	// char sArg[32];
	// for (int i = 1; i <= args; i++)
	// {
	// 	GetCmdArg(i, sArg, sizeof(sArg));
	// 	PrintToServer(" - %s", sArg);
	// }

	if (StrEqual(sCommand, "joinclass", false))
	{
		char sClass[32];
		GetCmdArg(1, sClass, sizeof(sClass));

		if (!StrEqual(sClass, "engineer", false))
		{
			FakeClientCommand(client, "joinclass engineer");
			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}

void ParseColors()
{
	g_TotalColors = 0;

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/amongus/colors.cfg");

	KeyValues kv = new KeyValues("colors");

	if (kv.ImportFromFile(sPath) && kv.GotoFirstSubKey(false))
	{
		do
		{
			kv.GetSectionName(g_Colors[g_TotalColors].name, sizeof(Colors::name));
			kv.GetColor4(NULL_STRING, g_Colors[g_TotalColors].color);
			g_TotalColors++;
		}
		while (kv.GotoNextKey(false));
	}

	delete kv;
	LogMessage("Parsed %i colors successfully.", g_TotalColors);
}

public void OnClientConnected(int client)
{
	g_Player[client].Init();
}

public void OnClientDisconnect_Post(int client)
{
	g_Player[client].Clear();
}

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

void SetColor(int client, int color)
{
	g_Player[client].color = color;
	
	if (color != NO_COLOR)
	{
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, g_Colors[color].color[0], g_Colors[color].color[1], g_Colors[color].color[2], g_Colors[color].color[3]);
	}
	else
	{
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

void AssignColor(int client)
{
	// TODO: Make it so it doesn't assign colors other players have already.
	SetColor(client, GetRandomInt(0, g_TotalColors - 1));
}

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