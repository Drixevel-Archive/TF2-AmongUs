/**
 * Notes

References:
https://among-us.fandom.com/wiki/Tasks
https://www.sportco.io/article/among-us-tasks-list-skeld-map-330951
https://i.pinimg.com/originals/3e/4e/52/3e4e52a4f1ac53a517af367542abe407.jpg

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

//Debug mode to make it easier to work on the mode.
#define DEBUG

#define NO_COLOR -1

/////
//It's easier to give maps complete control of the plugin by just using relays and firing those when needed.

//These control the relays we fire to handle lobby doors.
#define RELAY_LOBBY_DOORS_OPEN "lobby_doors_open"	//Is intended to open all lobby doors.
#define RELAY_LOBBY_DOORS_CLOSE "lobby_doors_close"	//Is intended to close all lobby doors.
#define RELAY_LOBBY_DOORS_LOCK "lobby_doors_lock"	//Is intended to lock all lobby doors.
#define RELAY_LOBBY_DOORS_UNLOCK "lobby_doors_unlock"	//Is intended to unlock all lobby doors.

#define RELAY_MEETING_BUTTON_OPEN "meeting_button_open"	//Is intended to open the meeting button model, turn the light on and play a sound.
#define RELAY_MEETING_BUTTON_CLOSE "meeting_button_close"	//Is intended to close the meeting button and turn off the light.
#define RELAY_MEETING_BUTTON_ACTIVATE "meeting_button_activate"	//Is intended to fire the button so a meeting starts.
#define RELAY_MEETING_BUTTON_LOCK "meeting_button_lock"	//Is intended to lock the meeting button from use.
#define RELAY_MEETING_BUTTON_UNLOCK "meeting_button_unlock"	//Is intended to unlock the meeting button so it can be used.

/*****************************/
//Includes
#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <colors>

/*****************************/
//ConVars

ConVar convar_Time_Setup;
ConVar convar_Time_Round;

ConVar convar_Hud_Position;
ConVar convar_Hud_Color;

/*****************************/
//Globals

bool g_Late;

Handle g_Hud;

enum Roles
{
	Role_Crewmate,
	Role_Imposter,
	Role_Total
};

enum struct Player
{
	int color;
	Roles role;
	int target;

	void Init()
	{
		this.color = NO_COLOR;
		this.role = Role_Crewmate;
		this.target = -1;
	}

	void Clear()
	{
		this.color = NO_COLOR;
		this.role = Role_Crewmate;
		this.target = -1;
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

//Stocks and utility functions should go above the rest so the other files can access them.
#include "mode/stocks.sp"
#include "mode/utils.sp"

#include "mode/commands.sp"
#include "mode/events.sp"
#include "mode/hooks.sp"
#include "mode/gamelogic.sp"
#include "mode/menus.sp"
#include "mode/natives.sp"

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

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CPrintToChatAll("Mode: Initializing...");
	RegPluginLibrary("mode-amongus");

	g_Late = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	CSetPrefix("[Among Us]");

	convar_Time_Setup = CreateConVar("sm_mode_amongus_timer_setup", "120", "What should the setup time be for matches?", FCVAR_NOTIFY, true, 0.0);
	convar_Time_Round = CreateConVar("sm_mode_amongus_timer_round", "99999", "What should the round time be for matches?", FCVAR_NOTIFY, true, 0.0);

	convar_Hud_Position = CreateConVar("sm_mode_amongus_hud_position", "0.0 0.0", "Where should the hud be on screen?", FCVAR_NOTIFY);
	convar_Hud_Color = CreateConVar("sm_mode_amongus_hud_color", "255 255 255 255", "What should the text color for the hud be?", FCVAR_NOTIFY);

	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeathPre, EventHookMode_Pre);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("post_inventory_application", Event_OnPostInventoryApplication);

	HookUserMessage(GetUserMessageId("VGUIMenu"), OnVGUIMenu, true);

	AddCommandListener(Listener_VoiceMenu, "voicemenu");

	RegConsoleCmd("sm_colors", Command_Colors, "Displays the list of available colors which you can pick.");
	RegConsoleCmd("sm_role", Command_Role, "Displays what your current role is in chat.");

	RegAdminCmd("sm_reloadcolors", Command_ReloadColors, ADMFLAG_GENERIC, "Reload available colors players can use.");
	RegAdminCmd("sm_setrole", Command_SetRole, ADMFLAG_GENERIC, "Sets a specific player to a specific role.");

	g_Hud = CreateHudSynchronizer();

	ParseColors();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i))
			OnClientConnected(i);

		if (IsClientInGame(i))
			OnClientPutInServer(i);
	}
	
	CPrintToChatAll("Mode: Loaded");
	
	if (g_Late)
	{
		CPrintToChatAll("Mode: Setting up Round...");
		TF2_CreateTimer(convar_Time_Setup.IntValue, convar_Time_Round.IntValue);

		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && !IsFakeClient(i))
				SendHud(i);
	}
}

public void OnPluginEnd()
{
	CPrintToChatAll("Mode: Unloaded");

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			ClearSyncHud(i, g_Hud);
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

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

public void OnClientDisconnect_Post(int client)
{
	g_Player[client].Clear();
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	switch (g_Player[client].role)
	{
		case Role_Imposter:
		{
			if (IsPlayerAlive(client) && !TF2_IsInSetup())
			{
				float origin[3];
				GetClientAbsOrigin(client, origin);

				float targetorigin[3];
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsPlayerAlive(i) || client == i || g_Player[i].role == Role_Imposter)
						continue;
					
					GetClientAbsOrigin(i, targetorigin);

					if (GetVectorDistance(origin, targetorigin) > 100.0)
					{
						if (g_Player[client].target == i)
						{
							g_Player[client].target = -1;
							PrintCenterText(client, "");
						}
						
						continue;
					}
					else if (g_Player[client].target == -1)
					{
						g_Player[client].target = i;
						PrintCenterText(client, "Current Target: %N\n(Press MEDIC! to kill them)", i);
					}
				}
			}
		}
	}

	return Plugin_Continue;
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

void SendHud(int client)
{
	/////
	//Parse the position and colors for the hud.

	//Position
	char sPosition[32];
	convar_Hud_Position.GetString(sPosition, sizeof(sPosition));

	char sPosPart[2][4];
	ExplodeString(sPosition, " ", sPosPart, 2, 4);

	float vec2DPos[2];
	vec2DPos[0] = StringToFloat(sPosPart[0]);
	vec2DPos[1] = StringToFloat(sPosPart[1]);

	//Color
	char sColor[32];
	convar_Hud_Color.GetString(sColor, sizeof(sColor));

	char sColorPart[4][4];
	ExplodeString(sColor, " ", sColorPart, 4, 4);

	int color[4];
	color[0] = StringToInt(sColorPart[0]);
	color[1] = StringToInt(sColorPart[1]);
	color[2] = StringToInt(sColorPart[2]);
	color[3] = StringToInt(sColorPart[3]);

	//Set the parameters for the hud.
	SetHudTextParams(vec2DPos[0], vec2DPos[1], 99999.0, color[0], color[1], color[2], color[3]);

	/////
	//Fill the buffer of text to send.
	char sHud[255];

	//Mode Name
	Format(sHud, sizeof(sHud), "%s[Mode] Among Us", sHud);

	//Role
	char sRole[32];
	GetRoleName(g_Player[client].role, sRole, sizeof(sRole));

	Format(sHud, sizeof(sHud), "%s\nRole: %s", sHud, sRole);

	//Send the Hud.
	ShowSyncHudText(client, g_Hud, sHud);
}

public Action Listener_VoiceMenu(int client, const char[] command, int argc)
{
	char sVoice[32];
	GetCmdArg(1, sVoice, sizeof(sVoice));

	char sVoice2[32];
	GetCmdArg(2, sVoice2, sizeof(sVoice2));
	
	//MEDIC! is called if both of these values are 0.
	if (!StrEqual(sVoice, "0", false) || !StrEqual(sVoice2, "0", false))
		return Plugin_Continue;
	
	if (g_Player[client].role == Role_Imposter && g_Player[client].target != -1)
	{
		SDKHooks_TakeDamage(g_Player[client].target, 0, client, 99999.0, DMG_SLASH);
		g_Player[client].target = -1;
		PrintCenterText(client, "");
	}

	return Plugin_Stop;
}