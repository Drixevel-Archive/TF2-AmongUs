/**
 * Notes

References:
https://among-us.fandom.com/wiki/Tasks
https://www.sportco.io/article/among-us-tasks-list-skeld-map-330951
https://i.pinimg.com/originals/3e/4e/52/3e4e52a4f1ac53a517af367542abe407.jpg
https://i.redd.it/tv8ef4iqszh41.png

Task Entities:
target: task
task: <task name>
type: common/visual/short/long
part: <part name>

 * TODO
 - Add vent indexes for routing.
 - Add security cameras action.
 - Update tasks to take into consideration parts and orders.
 - Add sabotages for Imposters to use.
 - Update the eject feature to use map logic instead.
 - Add admin map action.
 - Add map section names to the hud.
 - Add automatic game owner commands and features.
 - Implement MOTD minigames for tasks.

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
//#define DEBUG

#define NO_COLOR -1

//Types of tasks. (They can have multiple)
#define TASK_TYPE_LONG (1<<0)
#define TASK_TYPE_SHORT (1<<1)
#define TASK_TYPE_COMMON (1<<2)
#define TASK_TYPE_VISUAL (1<<3)
#define TASK_TYPE_CUSTOM (1<<4)

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
#include <customkeyvalues>
#include <tf2attributes>
#include <colors>

/*****************************/
//ConVars

ConVar convar_Time_Setup;
ConVar convar_Time_Round;

ConVar convar_Hud;
ConVar convar_Hud_Position;
ConVar convar_Hud_Color;

ConVar convar_VotePercentage_Ejections;

ConVar convar_Setting_ToggleTaskGlows;

/*****************************/
//Globals

bool g_Late;
bool g_BetweenRounds;

Handle g_Hud;

StringMap g_GameSettings;
ArrayList g_CleanEntities;

int g_GameOwner = -1;
char g_UpdatingGameSetting[MAXPLAYERS + 1][32];

int g_GlowEnt[2048 + 1] = {-1, ...};

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
	float lastkill;

	bool ejected;
	Handle ejectedtimer;

	bool showdeath;
	float deathorigin[3];
	int neardeath;

	int nearvent;
	bool venting;

	ArrayList tasks;
	StringMap tasks_completed;
	int neartask;

	int taskticks;
	Handle doingtask;

	int voted_for;
	int voted_to;

	bool scanning;

	void Init()
	{
		this.color = NO_COLOR;
		this.role = Role_Crewmate;

		this.target = -1;
		this.lastkill = -1.0;

		this.ejected = false;
		this.ejectedtimer = null;

		this.showdeath = false;
		this.deathorigin[0] = 0.0;
		this.deathorigin[0] = 0.0;
		this.deathorigin[0] = 0.0;
		this.neardeath = -1;

		this.nearvent = -1;
		this.venting = false;

		this.tasks = new ArrayList();
		this.tasks_completed = new StringMap();
		this.neartask = -1;

		this.taskticks = 0;
		this.doingtask = null;

		this.voted_for = -1;
		this.voted_to = 0;

		this.scanning = false;
	}

	void Clear()
	{
		this.color = NO_COLOR;
		this.role = Role_Crewmate;

		this.target = -1;
		this.lastkill = -1.0;

		this.ejected = false;
		StopTimer(this.ejectedtimer);

		this.showdeath = false;
		this.deathorigin[0] = 0.0;
		this.deathorigin[0] = 0.0;
		this.deathorigin[0] = 0.0;
		this.neardeath = -1;

		this.nearvent = -1;
		this.venting = false;

		delete this.tasks;
		delete this.tasks_completed;
		this.neartask = -1;

		this.taskticks = 0;
		StopTimer(this.doingtask);

		this.voted_for = -1;
		this.voted_to = 0;

		this.scanning = false;
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

enum struct Task
{
	char name[32];
	int type;
	int part;
	int entity;

	void Add(const char[] name, int type, int part, int entity)
	{
		strcopy(this.name, sizeof(Task::name), name);
		this.type = type;
		this.part = part;
		this.entity = entity;
	}
}

Task g_Task[256];
int g_TotalTasks;

enum struct Match
{
	int tasks_current;
	int tasks_goal;

	int meeting_time;
	Handle meeting;
	int total_meetings;
	float last_meeting;
}

Match g_Match;

/*****************************/
//Managed

//Stocks and utility functions should go above the rest so the other files can access them.
#include "mode/stocks.sp"
#include "mode/utils.sp"

#include "mode/commands.sp"
#include "mode/events.sp"
#include "mode/gamesettings.sp"
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
	CPrintToChatAll("{H1}Mode{default}: Initializing...");
	RegPluginLibrary("mode-amongus");

	g_Late = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	CSetPrefix("{black}[{ghostwhite}Among Us{black}]");
	CSetHighlight("{crimson}");
	CSetHighlight2("{darkorchid}");

	convar_Time_Setup = CreateConVar("sm_mode_amongus_timer_setup", "120", "What should the setup time be for matches?", FCVAR_NOTIFY, true, 0.0);
	convar_Time_Setup.AddChangeHook(OnConVarChange);
	convar_Time_Round = CreateConVar("sm_mode_amongus_timer_round", "3600", "What should the round time be for matches?", FCVAR_NOTIFY, true, 0.0);
	convar_Time_Round.AddChangeHook(OnConVarChange);

	convar_Hud = CreateConVar("sm_mode_amongus_hud", "1", "Should the global hud be enabled or disabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Hud.AddChangeHook(OnConVarChange);
	convar_Hud_Position = CreateConVar("sm_mode_amongus_hud_position", "0.0 0.0", "Where should the hud be on screen?", FCVAR_NOTIFY);
	convar_Hud_Position.AddChangeHook(OnConVarChange);
	convar_Hud_Color = CreateConVar("sm_mode_amongus_hud_color", "255 255 255 255", "What should the text color for the hud be?", FCVAR_NOTIFY);
	convar_Hud_Color.AddChangeHook(OnConVarChange);

	convar_VotePercentage_Ejections = CreateConVar("sm_mode_amongus_vote_percentage_ejections", "0.75", "What percentage between 0.0 and 1.0 should votes be required to eject players?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	convar_Setting_ToggleTaskGlows = CreateConVar("sm_mode_amongus_toggle_task_colors", "1", "Should the glows for tasks be enabled or disabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeathPre, EventHookMode_Pre);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("post_inventory_application", Event_OnPostInventoryApplication);
	HookEvent("teamplay_round_start", Event_OnRoundStart);
	HookEvent("teamplay_round_win", Event_OnRoundWin);

	HookUserMessage(GetUserMessageId("VGUIMenu"), OnVGUIMenu, true);

	AddCommandListener(Listener_VoiceMenu, "voicemenu");
	AddCommandListener(Listener_Kill, "kill");
	AddCommandListener(Listener_Kill, "explode");

	HookEntityOutput("logic_relay", "OnTrigger", OnLogicRelayTriggered);

	RegConsoleCmd("sm_colors", Command_Colors, "Displays the list of available colors which you can pick.");
	RegConsoleCmd("sm_role", Command_Role, "Displays what your current role is in chat.");
	RegConsoleCmd("sm_gamesettings", Command_GameSettings, "Allows for the game settings to be changed by admins or the game owner.");
	RegConsoleCmd("sm_owner", Command_Owner, "Displays who the current game owner is in chat.");
	RegConsoleCmd("sm_voting", Command_Voting, "Displays the voting menu during meetings.");

	RegAdminCmd("sm_reloadcolors", Command_ReloadColors, ADMFLAG_GENERIC, "Reload available colors players can use.");
	RegAdminCmd("sm_setrole", Command_SetRole, ADMFLAG_GENERIC, "Sets a specific player to a specific role.");
	RegAdminCmd("sm_setowner", Command_SetOwner, ADMFLAG_GENERIC, "Sets a specific player to own the match.");
	RegAdminCmd("sm_removeowner", Command_RemoveOwner, ADMFLAG_GENERIC, "Removes the current owner if there is one.");
	RegAdminCmd("sm_respawn", Command_Respawn, ADMFLAG_SLAY, "Respawn all players who are actively dead on teams.");
	RegAdminCmd("sm_eject", Command_Eject, ADMFLAG_SLAY, "Eject players from the map and out of the match.");
	RegAdminCmd("sm_givetask", Command_GiveTask, ADMFLAG_GENERIC, "Give a player a certain task to do.");
	RegAdminCmd("sm_listimposters", Command_ListImposters, ADMFLAG_SLAY, "List the current imposters in the match.");
	RegAdminCmd("sm_start", Command_Start, ADMFLAG_SLAY, "Start the match during the lobby automatically.");

	//Stores all game settings.
	g_GameSettings = new StringMap();

	//Entity classnames present in this array will be automatically deleted on creation.
	g_CleanEntities = new ArrayList(ByteCountToCells(32));
	g_CleanEntities.PushString("tf_ammo_pack");
	g_CleanEntities.PushString("halloween_souls_pack");

	g_Hud = CreateHudSynchronizer();

	ParseColors();
	ParseGameSettings();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i))
			OnClientConnected(i);

		if (IsClientInGame(i))
			OnClientPutInServer(i);
	}

	int entity = -1; char classname[32];
	while ((entity = FindEntityByClassname(entity, "*")) != -1)
		if (GetEntityClassname(entity, classname, sizeof(classname)))
			OnEntityCreated(entity, classname);
	
	CPrintToChatAll("{H1}Mode{default}: Loaded");
	
	if (g_Late)
	{
		CPrintToChatAll("{H1}Mode{default}: Setting up Round...");
		TF2_CreateTimer(convar_Time_Setup.IntValue, convar_Time_Round.IntValue);

		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && !IsFakeClient(i))
				SendHud(i);
	}
}

public void OnPluginEnd()
{
	CPrintToChatAll("{H1}Mode{default}: Unloaded");

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			ClearSyncHud(i, g_Hud);
	
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "*")) != -1)
		if (entity > MaxClients && g_GlowEnt[entity] > MaxClients)
			AcceptEntityInput(g_GlowEnt[entity], "Kill");
}

public void OnMapStart()
{
	//Parse the available tasks on the map by parsing entity names and logic.
	ParseTasks();

	/////
	//Precache Files

	PrecacheSound ("ambient_mp3/alarms/doomsday_lift_alarm.mp3"); //Used when finding a body for an emergency meeting.

	PrecacheSound("doors/vent_open2.wav");	//Played whenever a player is finished venting.
	PrecacheSound("doors/vent_open3.wav");	//Played whenever a player starts venting or moves to a different vent.
}

public void OnConVarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	int value = StringToInt(newValue);

	if (convar == convar_Time_Setup)
		TF2_SetSetupTime(value);
	else if (convar == convar_Time_Round)
		TF2_SetTime(value);
	else if (convar == convar_Hud_Position || convar == convar_Hud_Color)
		SendHudToAll();
	else if (convar == convar_Hud)
	{
		if (StrEqual(newValue, "1", false))
			SendHudToAll();
		else
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i))
					ClearSyncHud(i, g_Hud);
		}
	}
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

public void OnClientDisconnect(int client)
{
	//If the owner of the game disconnects then free up the slot.
	if (client == g_GameOwner)
	{
		g_GameOwner = -1;
		SendHudToAll();
	}

	if (!TF2_IsInSetup())
	{
		int imposters;
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && IsPlayerAlive(i) && g_Player[i].role == Role_Imposter)
				imposters++;
		
		if (imposters < 1)
		{
			ForceWin();
			CPrintToChatAll("All imposters have disconnected, Crewmates win!");
		}
	}
}

public void OnClientDisconnect_Post(int client)
{
	g_Player[client].Clear();
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (IsPlayerAlive(client) && g_Player[client].ejected)
	{
		float origin[3];
		GetClientAbsOrigin(client, origin);
		origin[0] -= 3.0;
		origin[2] += 0.1;

		float vecAngles[3];
		GetClientAbsAngles(client, vecAngles);
		RotateYaw(vecAngles, 10.0);

		TeleportEntity(client, origin, vecAngles, NULL_VECTOR);
	}

	if (IsPlayerAlive(client) && g_Player[client].scanning)
	{
		float origin[3];
		GetClientAbsOrigin(client, origin);
		TF2_Particle("ping_circle", origin);
	}

	switch (g_Player[client].role)
	{
		case Role_Crewmate:
		{

		}

		case Role_Imposter:
		{
			if (IsPlayerAlive(client) && !TF2_IsInSetup() && g_Match.meeting == null)
			{
				float origin[3];
				GetClientAbsOrigin(client, origin);

				float targetorigin[3];
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsPlayerAlive(i) || client == i || g_Player[i].role == Role_Imposter)
						continue;
					
					GetClientAbsOrigin(i, targetorigin);

					if (GetVectorDistance(origin, targetorigin) > GetGameSetting_Float("kill_distance"))
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

				int entity = -1; char sName[32];
				while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != -1)
				{
					GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

					if (StrContains(sName, "vent", false) != 0)
						continue;

					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetorigin);

					if (GetVectorDistance(origin, targetorigin) > 100.0)
					{
						if (g_Player[client].nearvent == entity)
						{
							g_Player[client].nearvent = -1;
							PrintCenterText(client, "");
						}
					}
					else if (g_Player[client].nearvent == -1)
					{
						g_Player[client].nearvent = entity;
						PrintCenterText(client, "Near Vent\n(Press MEDIC! to vent)");
					}
				}
			}
		}
	}

	if (IsPlayerAlive(client) && g_Match.meeting == null)
	{
		float origin[3];
		GetClientEyePosition(client, origin);
		
		float origin2[3];
		for (int i = 0; i < g_TotalTasks; i++)
		{
			if (g_Task[i].entity == -1)
				continue;
			
			GetEntPropVector(g_Task[i].entity, Prop_Send, "m_vecOrigin", origin2);

			if (GetVectorDistance(origin, origin2) > 100.0)
			{
				if (g_Player[client].neartask == i)
				{
					g_Player[client].neartask = -1;

					if (StopTimer(g_Player[client].doingtask))
						PrintHintText(client, "Task cancelled.");

					PrintCenterText(client, "");
				}
			}
			else
			{
				g_Player[client].neartask = i;

				char sPart[32];
				if (g_Task[i].part > 0)
					FormatEx(sPart, sizeof(sPart), " (Part %i)", g_Task[i].part);
				
				PrintCenterText(client, "%s%s", g_Task[i].name, sPart);
			}
		}

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsPlayerAlive(i) || !g_Player[i].showdeath)
				continue;
			
			if (GetVectorDistance(origin, g_Player[i].deathorigin) > 100.0)
			{
				if (g_Player[client].neardeath == i)
				{
					g_Player[client].neardeath = -1;
					PrintCenterText(client, "");
				}
			}
			else
			{
				g_Player[client].neardeath = i;
				PrintCenterText(client, "Near Dead Body\nInteract with the by by calling for MEDIC!");
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

void SendHudToAll()
{
	if (!convar_Hud.BoolValue)
		return;
	
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			SendHud(i);
}

void SendHud(int client)
{
	if (!convar_Hud.BoolValue)
		return;
	
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

	//Owner
	char[] sOwner = new char[MAX_NAME_LENGTH + 32];

	if (g_GameOwner != -1)
		FormatEx(sOwner, MAX_NAME_LENGTH + 32, " (Owner: %N)", g_GameOwner);

	//Mode Name
	Format(sHud, sizeof(sHud), "%s[Mode] Among Us%s", sHud, sOwner);

	//Role
	char sRole[32];
	GetRoleName(g_Player[client].role, sRole, sizeof(sRole));

	Format(sHud, sizeof(sHud), "%s\nRole: %s", sHud, sRole);

	//Tasks
	if (HasTasks(client))
		Format(sHud, sizeof(sHud), "%s\n--%sTasks-- (%i/%i)", sHud, g_Player[client].role == Role_Imposter ? "Fake " : "", g_Match.tasks_current, g_Match.tasks_goal);

	for (int i = 0; i < g_Player[client].tasks.Length; i++)
	{
		int task = g_Player[client].tasks.Get(i);
		Format(sHud, sizeof(sHud), "%s\n%s(%i) %s", sHud, g_Task[task].name, g_Task[task].part, IsTaskCompleted(client, task) ? "(c)" : "");
	}

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
	
	//Make it so you can't interact with anything between rounds.
	if (g_BetweenRounds)
		return Plugin_Stop;
	
	if (g_Player[client].neardeath != -1 && !TF2_IsInSetup())
	{
		g_Player[client].neardeath = -1;
		CallMeeting(client);
	}
	else if (g_Player[client].neartask != -1 && g_Player[client].doingtask == null && !TF2_IsInSetup())
	{
		int task = g_Player[client].neartask;

		if (IsTaskAssigned(client, task) && !IsTaskCompleted(client, task) && g_Player[client].role != Role_Imposter)
		{
			int time;

			if ((g_Task[task].type & TASK_TYPE_LONG) == TASK_TYPE_LONG)
				time = 10;
			else if ((g_Task[task].type & TASK_TYPE_SHORT) == TASK_TYPE_SHORT)
				time = 5;
			else if ((g_Task[task].type & TASK_TYPE_COMMON) == TASK_TYPE_COMMON)
				time = 5;
			
			//This is considered a task AND an action so we just do a hacky update.
			if (StrEqual(g_Task[task].name, "Submit Scan", false))
			{
				SetEntityMoveType(client, MOVETYPE_NONE);

				int entity = g_Task[task].entity;

				float origin[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
				origin[2] += 5.0;
				TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);

				g_Player[client].scanning = true;
			}

			g_Player[client].taskticks = time;
			StopTimer(g_Player[client].doingtask);
			g_Player[client].doingtask = CreateTimer(1.0, Timer_DoingTask, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
		else
			CPrintToChat(client, "You are not assigned to do this task.");
	}
	else if (g_Player[client].target > 0 && g_Player[client].target <= MaxClients)
	{
		if (g_Player[client].lastkill > 0 && g_Player[client].lastkill > GetGameTime())
		{
			TF2_PlayDenySound(client);
			CPrintToChat(client, "You must wait {H1}%.2f {default}seconds before executing another person.", (g_Player[client].lastkill - GetGameTime()));
			return Plugin_Stop;
		}

		SDKHooks_TakeDamage(g_Player[client].target, 0, client, 99999.0, DMG_SLASH);
		g_Player[client].target = -1;
		g_Player[client].lastkill = GetGameTime() + GetGameSetting_Float("kill_cooldown");
		PrintCenterText(client, "");
	}
	else if (g_Player[client].nearvent != -1)
	{
		if (g_Player[client].venting)
			StopVenting(client);
		else
			StartVenting(client);
	}

	return Plugin_Stop;
}

public Action Listener_Kill(int client, const char[] command, int argc)
{
	return Plugin_Stop;
}

public Action Timer_DoingTask(Handle timer, any data)
{
	int client = data;

	g_Player[client].taskticks--;
	int task = g_Player[client].neartask;

	if (g_Player[client].taskticks > 0)
	{
		if (StrEqual(g_Task[task].name, "Submit Scan", false) && g_Player[client].taskticks == 2)
		{
			float origin[3];
			GetClientAbsOrigin(client, origin);
			CreateParticle(g_Player[client].role == Role_Imposter ? "teleporter_red_entrance" : "teleporter_blue_entrance", origin, 5.0);
		}

		PrintHintText(client, "Doing Task... %i", g_Player[client].taskticks);
		return Plugin_Continue;
	}

	if (g_Player[client].role != Role_Imposter)
	{
		MarkTaskComplete(client, task);
		SendHud(client);
	}

	if (StrEqual(g_Task[task].name, "Submit Scan", false))
	{
		g_Player[client].scanning = false;
		SetEntityMoveType(client, MOVETYPE_ISOMETRIC);
	}

	PrintHintText(client, "Task Completed.");
	g_Player[client].doingtask = null;

	return Plugin_Stop;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	SDKHook(entity, SDKHook_Spawn, OnEntitySpawn);

	if (g_Late)
		OnEntitySpawn(entity);
}

void ParseTasks()
{
	g_TotalTasks = 0;

	int entity = -1; char sName[32];
	while ((entity = FindEntityByClassname(entity, "*")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

		if (StrContains(sName, "task", false) != 0)
			continue;
		
		char sTask[32];
		if (!GetCustomKeyValue(entity, "task", sTask, sizeof(sTask)))
			continue;
		
		char sType[32];
		if (!GetCustomKeyValue(entity, "type", sType, sizeof(sType)))
			continue;
		
		int type;
		if (StrContains(sType, "long", false) != -1)
			type |= TASK_TYPE_LONG;
		if (StrContains(sType, "short", false) != -1)
			type |= TASK_TYPE_SHORT;
		if (StrContains(sType, "common", false) != -1)
			type |= TASK_TYPE_COMMON;
		if (StrContains(sType, "visual", false) != -1)
			type |= TASK_TYPE_VISUAL;
		if (StrContains(sType, "custom", false) != -1)
			type |= TASK_TYPE_CUSTOM;
		
		char sPart[32];
		GetCustomKeyValue(entity, "part", sPart, sizeof(sPart));
		
		g_Task[g_TotalTasks].Add(sTask, type, StringToInt(sPart), entity);
		g_TotalTasks++;
	}

	LogMessage("Detected %i tasks for this map.", g_TotalTasks);
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs)
{
	if (strlen(g_UpdatingGameSetting[client]) > 0)
	{
		if (!IsAdmin(client) && client != g_GameOwner)
		{
			g_UpdatingGameSetting[client][0] = '\0';
			return;
		}

		char sValue[32];
		strcopy(sValue, sizeof(sValue), sArgs);
		TrimString(sValue);

		SetGameSetting_String(g_UpdatingGameSetting[client], sValue);

		g_UpdatingGameSetting[client][0] = '\0';
		OpenSettingsMenu(client);
	}
}

public void OnGameFrame()
{
	//Get the current amount of players on a team in the server.
	int count = GetTotalPlayers();

	//If it's during the round and there's less than 2 players on the server then end the round since this mode requires 3 players to play.
	if (!TF2_IsInSetup() && count < 2 && !g_BetweenRounds)
	{
		g_BetweenRounds = true;
		TF2_ForceWin(TFTeam_Unassigned);
	}

	//If there's less than 2 players then make sure the timer's paused and send a hud message saying the mode requires 3 players to play.
	if (count < 2)
	{
		if (!TF2_IsTimerPaused())
			TF2_PauseTimer();
		
		PrintCenterTextAll("3 players required to start.");
	}
	else if (count >= 2 && TF2_IsTimerPaused()) //If there's more than 2 players and the timer's paused then unpause it.
		TF2_ResumeTimer();
	
	//Check if the current amount of tasks completed is more than or equal to the goal.
	//If the current tasks amount has met the tasks goal then end the round and give the victory the the non-imposters.
	if (g_Match.tasks_goal > 0 && g_Match.tasks_current >= g_Match.tasks_goal && !g_BetweenRounds)
	{
		g_BetweenRounds = true;

		ForceWin();
		CPrintToChatAll("Crewmates have completed all tasks, Crewmates win!");
	}
}

void CallMeeting(int client = -1, bool button = false)
{
	if (g_Match.last_meeting > 0 && g_Match.last_meeting > GetGameTime())
	{
		TF2_PlayDenySound(client);
		CPrintToChat(client, "You must wait {H1}%.2f {default}seconds to call another meeting.", (g_Match.last_meeting - GetGameTime()));
		return;
	}

	if (client > 0)
	{
		if (button)
			CPrintToChatAll("{H1}%N {default}has called a meeting!", client);
		else
			CPrintToChatAll("{H1}%N {default}has found a body!", client);
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		if (IsPlayerAlive(i))
		{
			g_Player[i].target = -1;

			TF2_RespawnPlayer(i);
			SetEntityMoveType(i, MOVETYPE_NONE);
		}
		else
		{
			g_Player[i].showdeath = false;
		}
	}

	EmitSoundToAll("ambient_mp3/alarms/doomsday_lift_alarm.mp3");
	UnmuteAllClients();

	TriggerRelay("meeting_button_lock");

	TriggerRelay("lobby_doors_close");
	TriggerRelay("lobby_doors_lock");

	g_Match.meeting_time = GetGameSetting_Int("discussion_time");
	StopTimer(g_Match.meeting);
	g_Match.meeting = CreateTimer(1.0, Timer_StartVoting, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	g_Match.total_meetings++;
}

public Action Timer_StartVoting(Handle timer)
{
	g_Match.meeting_time--;

	if (g_Match.meeting_time > 0)
	{
		PrintCenterTextAll("Voting Begins In: %i", g_Match.meeting_time);
		return Plugin_Continue;
	}

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
			CreateVoteMenu(i);

	g_Match.meeting_time = GetGameSetting_Int("voting_time");
	g_Match.meeting = CreateTimer(1.0, Timer_EndVoting, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Stop;
}

public Action Timer_EndVoting(Handle timer)
{
	g_Match.meeting_time--;

	if (g_Match.meeting_time > 0)
	{
		PrintCenterTextAll("Voting Ends In: %i", g_Match.meeting_time);
		return Plugin_Continue;
	}

	int total = GetTotalAlivePlayers();
	bool confirm = GetGameSetting_Bool("confirm_ejects");
	float percentage = convar_VotePercentage_Ejections.FloatValue;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;
		
		g_Player[i].voted_for = -1;

		if (GetVotePercent(g_Player[i].voted_to, total) > percentage)
		{
			EjectPlayer(i);

			if (confirm)
				CPrintToChatAll("%N has been ejected! They were %san Imposter!", i, g_Player[i].role != Role_Imposter ? "NOT " : "");
			else
				CPrintToChatAll("%N has been ejected!", i);
		}
		
		g_Player[i].voted_to = 0;
	}

	PrintCenterTextAll("Emergency Meeting: Ended");

	TriggerRelay("meeting_button_unlock");

	TriggerRelay("lobby_doors_unlock");
	TriggerRelay("lobby_doors_open");

	g_Match.last_meeting = GetGameTime() + GetGameSetting_Float("emergency_cooldowns");

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i))
			SetEntityMoveType(i, MOVETYPE_ISOMETRIC);

	MuteAllClients();

	g_Match.meeting = null;
	return Plugin_Stop;
}

void EjectPlayer(int client)
{
	//Mark the player as ejected.
	g_Player[client].ejected = true;

	//Temporary coordinates until better logic is setup with the map.
	TeleportEntity(client, view_as<float>({640.0, -1500.0, 500.0}), view_as<float>({0.0, 90.0, 0.0}), view_as<float>({0.0, 0.0, 0.0}));

	//Create The timer so we know they're gonna be dead after a bit of being ejected.
	StopTimer(g_Player[client].ejectedtimer);
	g_Player[client].ejectedtimer = CreateTimer(10.0, Timer_Suicide, GetClientUserId(client));
}

public Action Timer_Suicide(Handle timer, any data)
{
	int client;
	if ((client = GetClientOfUserId(data)) > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && g_Player[client].ejected)
			ForcePlayerSuicide(client);
		
		g_Player[client].ejectedtimer = null;
	}
}

void StartVenting(int client)
{
	g_Player[client].venting = true;

	TF2_HidePlayer(client);
	SetEntityMoveType(client, MOVETYPE_NONE);

	TF2_SetThirdPerson(client);
	EmitSoundToClient(client, "doors/vent_open3.wav", SOUND_FROM_PLAYER, SNDCHAN_REPLACE, SNDLEVEL_NONE, SND_CHANGEVOL, 0.75);

	OpenVentsMenu(client);
}

void StopVenting(int client)
{
	g_Player[client].venting = false;

	TF2_ShowPlayer(client);
	SetEntityMoveType(client, MOVETYPE_ISOMETRIC);

	TF2_SetFirstPerson(client);
	EmitSoundToClient(client, "doors/vent_open2.wav", SOUND_FROM_PLAYER, SNDCHAN_REPLACE, SNDLEVEL_NONE, SND_CHANGEVOL, 0.75);
}

public Action OnLogicRelayTriggered(const char[] output, int caller, int activator, float delay)
{
	char sName[32];
	GetEntPropString(caller, Prop_Data, "m_iName", sName, sizeof(sName));
	//PrintToChatAll("[%s][%i][%i][%.2f]", output, caller, activator, delay);

	if (StrEqual(sName, RELAY_MEETING_BUTTON_OPEN, false) && g_Match.meeting == null)
	{
		if (g_BetweenRounds)
			return Plugin_Stop;
		
		int max = GetGameSetting_Int("emergency_meetings");

		if (max > 0 && g_Match.total_meetings >= max)
		{
			TF2_PlayDenySound(activator);
			CPrintToChat(activator, "Maximum number of emergency meetings reached!");
			return Plugin_Stop;
		}

		CallMeeting(activator, true);
	}

	return Plugin_Continue;
}