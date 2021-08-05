/**
 * Notes

References:
https://among-us.fandom.com/wiki/Tasks
https://www.sportco.io/article/among-us-tasks-list-skeld-map-330951
https://i.pinimg.com/originals/3e/4e/52/3e4e52a4f1ac53a517af367542abe407.jpg
https://i.redd.it/tv8ef4iqszh41.png

Tasks:
 - Name: task
 - Key 'display' (Display name to show in the HUD and chat prints.)
 - Key 'type' (common/visual/short/long/custom)

Task Maps:
 - Name: task_map
 - Key 'display' (Display name to show in the HUD and chat prints.)
 - Key 'type' (common/visual/short/long/custom)
 - Key 'start' (Starting task part for this task map.)
 - Key 'parts' (Amount of parts to complete this task map.)
 - Key 'part %i' (Parts in order that go down a list with task part names and formatting rules.)
 - Format * (Lock out the next task part on the list after it's done.)
 - Format % (Choose a random task part from the list in the next part.)
 - Format {1:2} (Replace in the string a random number between these two numbers.)

Task Parts:
 - Name: task_part
 - Key 'display' (Display name to show in the HUD and chat prints.)
 - Key 'link' (Reference for task maps to use.)

Actions:
 - Name: action
 - Key 'display' (Display name to show in the HUD and chat prints.)
 - Key 'type' (What type of action it is.)

Sabotages:
 - Name: sabotage
 - Key 'display' (Display name to show in the HUD and chat prints.)
 - Key 'type' (What sabotage type it's tied to to turn off on use.)
 - Key 'sync' (If more than 0, sync all entity interactions required to fix sabotage.)

Vents:
 - Name: vent
  - Key 'display' (Display name to show in the HUD and chat prints.)
 - Key: 'index' (The index of the vent for routing usage.)
 - Key: 'route' (A list of indexes for vents to tie them together.)

 * TODO
 - Update tasks to take into consideration parts and orders.
 - Update the eject feature to use map logic instead.
 - Add admin map action.
 - Implement MOTD minigames for tasks.
 - Implement task maps.

Cameras:
 - Name: camera
 - Key 'display' (Display name to show in the HUD and chat prints.)
 - Key 'light' (Name of the light entity to toggle on and off for cameras being active.)

- Task Data for The Skeld
:::
task_part_eg_1 = eg_1
task_part_eg_2 = eg_2

task_part_chu_1 = chu_1
task_part_chu_2 = chu_2

task_part_data_1 = data_1
task_part_data_2 = data_2
task_part_data_3 = data_3
task_part_data_4 = data_4

task_part_dp_electrical = dp_electrical
task_part_dp_1 = dp_1
task_part_dp_2 = dp_2
task_part_dp_3 = dp_3
task_part_dp_4 = dp_4
task_part_dp_5 = dp_5
task_part_dp_6 = dp_6
task_part_dp_7 = dp_7
task_part_dp_8 = dp_8

task_part_lower_fuel = fuel_lower
task_part_lower_fuel = fuel_upper
task_part_storage_gascan = storage_gascan

task_part_engine_lower = engine_lower
task_part_engine_upper = engine_upper
:::

Actions data for The Skeld
:::
Look at Admin Map = map
Check Security Cameras = cameras
:::

Sabotages data for the Skeld
:::
Communications Disabled = communications
Reactor Meltdown = meltdown
Oxygen Depletion = oxygen
Fix Lights = lights
:::

Tasks: (Thanks to Muddy)

well if you look on that map for fill fuel, there's 4 steps to it:
1) hold a button on the gas can in storage to fill your gas tank
2) go to an engine and hold a button again to put it into the engine
3) go back to storage and refill
4) fill the other engine
your progress is saved between steps if you die and have to continue them as a ghost or if a meeting is called etc, and in the hud it shows steps (1/4 etc)

divert power is a switch in electrical you turn up and then go flip a breaker in the room that you routed the power to (the room is randomly selected as well, so there are technically as many divert power tasks for each room that has a breaker)
you won't ever get more than one divert power task but internally they're just separate tasks for each possible divert

empty garbage/empty chute you actually can get both of, you pull a lever to let some trash fall down a compactor/garbage disposal thing and then do it again in a 2nd location, the difference between garbage and chute is that one's first part is in cafeteria but the other's is in O2, and the 2nd part is in storage

upload/download is more similar to divert power, you get a random location to download files from and then go into admin and upload them, and you'll never get more than one download/upload

 */

/*****************************/
//Pragma
#pragma semicolon 1
#pragma newdecls required

/*****************************/
//Defines
#define PLUGIN_NAME "[TF2] Among Us"
#define PLUGIN_DESCRIPTION "A gamemode for Team Fortress 2 which replicates the Among Us game."
#define PLUGIN_VERSION "1.0.0"

//Debug mode to make it easier to work on the mode.
//#define DEBUG

#define NO_COLOR -1

#define MAX_BUTTONS 25

//Types of tasks. (They can have multiple)
#define TASK_TYPE_LONG (1<<0)
#define TASK_TYPE_SHORT (1<<1)
#define TASK_TYPE_COMMON (1<<2)
#define TASK_TYPE_VISUAL (1<<3)
#define TASK_TYPE_CUSTOM (1<<4)

//Types of sabotages.
#define SABOTAGE_REACTORS 0
#define SABOTAGE_FIXLIGHTS 1
#define SABOTAGE_COMMUNICATIONS 2
#define SABOTAGE_DEPLETION 3

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

#define SOUND_ALARM "amongus/alarm.wav"
#define SOUND_BODYFOUND "amongus/bodyfound.wav"
#define SOUND_DOOR_CLOSE "amongus/door_close.wav"
#define SOUND_DOOR_OPEN "amongus/door_open.wav"
#define SOUND_EJECT_TEXT "amongus/eject_text.wav"
#define SOUND_NOTIFICATION "amongus/notification.wav"
#define SOUND_PANEL_CLOSE "amongus/panel_close.wav"
#define SOUND_PANEL_OPEN "amongus/panel_open.wav"
#define SOUND_ROUNDSTART "amongus/roundstart.wav"
#define SOUND_SABOTAGE "amongus/sabotage.wav"
#define SOUND_TASK_COMPLETE "amongus/task_complete.wav"
#define SOUND_TASK_INPROGRESS "amongus/task_inprogress.wav"
#define SOUND_UI_HOVER "amongus/ui_hover.wav"
#define SOUND_UI_SELECT "amongus/ui_select.wav"
#define SOUND_VICTORY_CREW "amongus/victory_crew.wav"
#define SOUND_VICTORY_DISCONNECT "amongus/victory_disconnect.wav"
#define SOUND_VICTORY_IMPOSTER "amongus/victory_impostor.wav"
#define SOUND_VOTE_TIMER "amongus/vote_timer.wav"
#define SOUND_VOTE_CONFIRM "amongus/votescreen_avote.wav"
#define SOUND_VOTE_LOCKIN "amongus/votescreen_lockin.wav"

#define SOUND_DISCONNECT "amongus/disconnect.wav"
#define SOUND_IMPOSTER_DEATHMUSIC "amongus/imposter_deathmusic.wav"
#define SOUND_IMPOSTER_KILL "amongus/impostor_kill.wav"
#define SOUND_SPAWN "amongus/spawn.wav"
#define SOUND_VENT_MOVE1 "amongus/vent_move1.wav"
#define SOUND_VENT_MOVE2 "amongus/vent_move2.wav"
#define SOUND_VENT_MOVE3 "amongus/vent_move3.wav"
#define SOUND_VENT_OPEN "amongus/vent_open.wav"

#define FFADE_IN	0x0001			// Just here so we don't pass 0 into the function
#define FFADE_OUT	0x0002			// Fade out (not in)
#define FFADE_MODULATE	0x0004		// Modulate (don't blend)
#define FFADE_STAYOUT	0x0008		// ignores the duration, stays faded out until new ScreenFade message received
#define FFADE_PURGE	0x0010			// Purges all other fades, replacing them with this one

#define TASK_SPRITE "sprites/obj_icons/warning_highlight"

#define SYSTEM_UI_MESSAGE "ui/system_message_alert.wav"

/*****************************/
//Includes

#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <colors>
#include <tf2-amongus>

#include <customkeyvalues>
#include <tf2attributes>
#include <navmesh>
#include <tf2items>

/*****************************/
//ConVars

ConVar convar_Required_Players;
ConVar convar_TopDownView;
ConVar convar_Chat_Gag;

ConVar convar_Time_Setup;
ConVar convar_Time_Round;

ConVar convar_Hud;
ConVar convar_Hud_Position;
ConVar convar_Hud_Color;

ConVar convar_Sabotages_Cooldown;
ConVar convar_Sabotages_Cooldown_Doors;

ConVar convar_VotePercentage_Ejections;

ConVar convar_Engine_RespawnWaveTime;

ConVar convar_Fade_Dur;
ConVar convar_Fade_Hold;

ConVar convar_EurekaEffectTele;

/*****************************/
//Forwards

GlobalForward g_Forward_OnGameSettingsLoaded;
GlobalForward g_Forward_OnGameSettingsSaveClient;
GlobalForward g_Forward_OnGameSettingsLoadClient;

GlobalForward g_Forward_OnRoleAssignedPost;
GlobalForward g_Forward_OnColorSetPost;
GlobalForward g_Forward_OnTaskStartedPost;
GlobalForward g_Forward_OnTaskCompletedPost;
GlobalForward g_Forward_OnSabotageStartedPost;
GlobalForward g_Forward_OnSabotageSuccessPost;
GlobalForward g_Forward_OnSabotageFailurePost;
GlobalForward g_Forward_OnVentingStartPost;
GlobalForward g_Forward_OnVentingSwitchPost;
GlobalForward g_Forward_OnVentingEndPost;

/*****************************/
//Globals

bool g_Late;
bool g_BetweenRounds;
ArrayList g_Reconnects;

Handle g_Hud;

int g_LastButtons[MAXPLAYERS + 1];

StringMap g_GameSettings;
ArrayList g_CleanEntities;
StringMap g_AreaNames;

int g_GameOwner = -1;
char g_UpdatingGameSetting[MAXPLAYERS + 1][32];

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

	int nearaction;
	int nearsabotage;

	int voted_for;
	int voted_to;

	bool scanning;

	ArrayList tasks;
	StringMap tasks_steps;
	StringMap tasks_completed;
	int neartask;

	bool lockout;
	ArrayList lockouts;

	bool random;
	char randomchosen[64];

	bool intgen;
	int intgend;
	char intgens[256];

	int taskticks;
	Handle doingtask;
	int progresstask;
	int progresstaskpart;

	int camera;

	Handle map;

	bool editingmarks;
	char paintmarks[64];

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

		this.nearaction = -1;
		this.nearsabotage = -1;

		this.voted_for = -1;
		this.voted_to = 0;

		this.scanning = false;

		this.tasks = new ArrayList();
		this.tasks_steps = new StringMap();
		this.tasks_completed = new StringMap();
		this.neartask = -1;

		this.lockout = false;
		this.lockouts = new ArrayList();

		this.random = false;
		this.randomchosen[0] = '\0';

		this.intgen = false;
		this.intgend = -1;
		this.intgens[0] = '\0';

		this.taskticks = 0;
		this.doingtask = null;
		this.progresstask = -1;
		this.progresstaskpart = -1;

		this.camera = -1;

		this.map = null;

		this.editingmarks = false;
		this.paintmarks[0] = '\0';
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

		this.nearaction = -1;
		this.nearsabotage = -1;

		this.voted_for = -1;
		this.voted_to = 0;

		this.scanning = false;

		delete this.tasks;
		delete this.tasks_steps;
		delete this.tasks_completed;
		this.neartask = -1;

		this.lockout = false;
		delete this.lockouts;

		this.random = false;
		this.randomchosen[0] = '\0';

		this.intgen = false;
		this.intgend = -1;
		this.intgens[0] = '\0';

		this.taskticks = 0;
		StopTimer(this.doingtask);
		this.progresstask = -1;
		this.progresstaskpart = -1;

		this.camera = -1;

		StopTimer(this.map);

		this.editingmarks = false;
		this.paintmarks[0] = '\0';
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

enum struct Match
{
	int meeting_time;
	Handle meeting;
	int total_meetings;
	float last_meeting;

	int tasks_current;
	int tasks_goal;

	bool intro;
}

Match g_Match;

int g_Camera[MAXPLAYERS + 1];

int g_FogController_Crewmates;
int g_FogController_Imposters;
float g_FogDistance = 300.0;

bool g_IsSabotageActive;
int g_DelaySabotage = -1;
int g_ReactorsTime ;
Handle g_Reactors;
int g_ReactorStamp = -1;
int g_ReactorExclude = -1;
bool g_LightsOff;
bool g_DisableCommunications;
int g_O2Time;
Handle g_O2;
int g_DelayDoors = -1;
Handle g_LockDoors;

bool g_IsDead[MAXPLAYERS + 1];

enum TaskType
{
	TaskType_Single,	//Tasks which are by themselves and are simple to complete.
	TaskType_Map,		//Task maps are lists of instructions with multiple parts that act as 1 task.
	TaskType_Part		//Task parts go hand in hand with task maps as the actual parts.
}

enum struct Task
{
	//int entity;
	int entityref;
	char display[64];
	TaskType tasktype;
	int type;
	float origin[3];
	int sprite;

	void Add(int entity, const char[] display, TaskType tasktype, int type, float origin[3])
	{
		//this.entity = entity;
		this.entityref = EntIndexToEntRef(entity);
		strcopy(this.display, sizeof(Task::display), display);
		this.tasktype = tasktype;
		this.type = type;
		for (int i = 0; i < 3; i++)
			this.origin[i] = origin[i];
		this.sprite = -1;
	}

	void Clear()
	{
		//this.entity = -1;
		this.entityref = INVALID_ENT_REFERENCE;
		this.display[0] = '\0';
		this.tasktype = TaskType_Single;
		this.type = 0;
		for (int i = 0; i < 3; i++)
			this.origin[i] = 0.0;
		this.KillSprite();
	}

	void CreateSprite()
	{
		int entity = EntRefToEntIndex(this.entityref);

		if (!IsValidEntity(entity))
			return;
		
		this.KillSprite();
		this.sprite = CreateSprite(entity, TASK_SPRITE, view_as<float>({0.0, 0.0, 0.0}));

		if (IsValidEntity(this.sprite))
			SDKHook(this.sprite, SDKHook_SetTransmit, OnTaskSpriteTransmit);
	}

	void KillSprite()
	{
		if (this.sprite > 0 && IsValidEntity(this.sprite))
			AcceptEntityInput(this.sprite, "kill");
		
		this.sprite = -1;
	}
}

Task g_Tasks[256];
int g_TotalTasks;

float g_flTrackNavAreaNextThink;
int g_iPathLaserModelIndex = -1;

float g_TEParticleDelay;

int g_CurrentAd;

ArrayList g_PlayerCommands;
StringMap g_PlayerCommandDescriptions;
ArrayList g_AdminCommands;
StringMap g_AdminCommandDescriptions;

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
#include "mode/timers.sp"

/*****************************/
//Plugin Info
public Plugin myinfo = 
{
	name = PLUGIN_NAME, 
	author = "Drixevel", 
	description = PLUGIN_DESCRIPTION, 
	version = PLUGIN_VERSION, 
	url = "https://drixevel.dev/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("tf2-amongus");

	//Natives
	CreateNative("GameSettings.Parse", Native_GameSettings_Parse);
	CreateNative("GameSettings.GetInt", Native_GameSettings_GetInt);
	CreateNative("GameSettings.SetInt", Native_GameSettings_SetInt);
	CreateNative("GameSettings.GetFloat", Native_GameSettings_GetFloat);
	CreateNative("GameSettings.SetFloat", Native_GameSettings_SetFloat);
	CreateNative("GameSettings.GetString", Native_GameSettings_GetString);
	CreateNative("GameSettings.SetString", Native_GameSettings_SetString);
	CreateNative("GameSettings.GetBool", Native_GameSettings_GetBool);
	CreateNative("GameSettings.SetBool", Native_GameSettings_SetBool);
	CreateNative("GameSettings.SaveClient", Native_GameSettings_SaveClient);
	CreateNative("GameSettings.LoadClient", Native_GameSettings_LoadClient);

	//Forwards
	g_Forward_OnGameSettingsLoaded = new GlobalForward("GameSettings_OnParsed", ET_Ignore);
	g_Forward_OnGameSettingsSaveClient = new GlobalForward("GameSettings_OnSaveClient", ET_Ignore, Param_Cell);
	g_Forward_OnGameSettingsLoadClient = new GlobalForward("GameSettings_OnLoadClient", ET_Ignore, Param_Cell);

	g_Forward_OnRoleAssignedPost = new GlobalForward("AmongUs_OnRoleAssigned", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnColorSetPost = new GlobalForward("AmongUs_OnColorSet", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnTaskStartedPost = new GlobalForward("AmongUs_OnTaskStarted", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_Forward_OnTaskCompletedPost = new GlobalForward("AmongUs_OnTaskCompleted", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnSabotageStartedPost = new GlobalForward("AmongUs_OnSabotageStarted", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnSabotageSuccessPost = new GlobalForward("AmongUs_OnSabotageSuccess", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnSabotageFailurePost = new GlobalForward("AmongUs_OnSabotageFailure", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnVentingStartPost = new GlobalForward("AmongUs_OnVentingStart", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnVentingSwitchPost = new GlobalForward("AmongUs_OnVentingSwitch", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnVentingEndPost = new GlobalForward("AmongUs_OnVentingEnd", ET_Ignore, Param_Cell, Param_Cell);

	g_Late = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("amongus.phrases");

	CSetPrefix("{black}[{ghostwhite}Among Us{black}]");
	CSetHighlight("{crimson}");
	CSetHighlight2("{darkorchid}");

	CreateConVar("sm_amongus_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, FCVAR_NOTIFY|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_DONTRECORD);

	convar_Required_Players = CreateConVar("sm_amongus_required_players", "3", "How many players should be required for the gamemode to start?", FCVAR_NOTIFY, true, 0.0);
	convar_TopDownView = CreateConVar("sm_amongus_topdownview", "0", "Should players by default be in a top down view?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Chat_Gag = CreateConVar("sm_amongus_chat_gag", "0", "Should players be gagged during the match outside of meetings?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Time_Setup = CreateConVar("sm_amongus_timer_setup", "30", "What should the setup time be for matches?", FCVAR_NOTIFY, true, 0.0);
	convar_Time_Round = CreateConVar("sm_amongus_timer_round", "3600", "What should the round time be for matches?", FCVAR_NOTIFY, true, 0.0);
	convar_Hud = CreateConVar("sm_amongus_hud", "1", "Should the global hud be enabled or disabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Hud_Position = CreateConVar("sm_amongus_hud_position", "0.0 0.0", "Where should the hud be on screen?", FCVAR_NOTIFY);
	convar_Hud_Color = CreateConVar("sm_amongus_hud_color", "255 255 255 255", "What should the text color for the hud be?", FCVAR_NOTIFY);
	convar_Sabotages_Cooldown = CreateConVar("sm_amongus_sabotages_cooldown", "30", "How long in seconds should Sabotages be on cooldown?", FCVAR_NOTIFY, true, 0.0);
	convar_Sabotages_Cooldown_Doors = CreateConVar("sm_amongus_sabotages_cooldown_doors", "16", "How long in seconds should the Doors Sabotage be on cooldown?", FCVAR_NOTIFY, true, 0.0);
	convar_VotePercentage_Ejections = CreateConVar("sm_amongus_vote_percentage_ejections", "0.75", "What percentage between 0.0 and 1.0 should votes be required to eject players?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	convar_Fade_Dur = CreateConVar("sm_amongus_sabotage_fade_dur", "100", "What should the default fade duration be for sabotage sirens?", FCVAR_NOTIFY, true, 0.0);
	convar_Fade_Hold = CreateConVar("sm_amongus_sabotage_fade_hold", "100", "What should the default fade hold time be for sabotage sirens?", FCVAR_NOTIFY, true, 0.0);
	convar_EurekaEffectTele = CreateConVar("sm_amongus_eureka_effect_tele", "0", "Should players be allowed to teleport using the Eureka Effect?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig();

	convar_TopDownView.AddChangeHook(OnConVarChange);
	convar_Time_Setup.AddChangeHook(OnConVarChange);
	convar_Time_Round.AddChangeHook(OnConVarChange);
	convar_Hud.AddChangeHook(OnConVarChange);
	convar_Hud_Position.AddChangeHook(OnConVarChange);
	convar_Hud_Color.AddChangeHook(OnConVarChange);

	convar_Engine_RespawnWaveTime = FindConVar("mp_respawnwavetime");

	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeathPre, EventHookMode_Pre);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("post_inventory_application", Event_OnPostInventoryApplication);
	HookEvent("teamplay_round_start", Event_OnRoundStart);
	HookEvent("teamplay_round_win", Event_OnRoundWin);
	HookEvent("teamplay_broadcast_audio", Event_OnBroadcastAudio, EventHookMode_Pre);

	HookUserMessage(GetUserMessageId("VGUIMenu"), OnVGUIMenu, true);

	AddCommandListener(Listener_VoiceMenu, "voicemenu");
	AddCommandListener(Listener_Kill, "kill");
	AddCommandListener(Listener_Kill, "explode");

	HookEntityOutput("logic_relay", "OnTrigger", OnLogicRelayTriggered);

	//Stores commands in arrays for menus to access a list.
	g_PlayerCommands = new ArrayList(ByteCountToCells(64));
	g_PlayerCommandDescriptions = new StringMap();
	g_AdminCommands = new ArrayList(ByteCountToCells(64));
	g_AdminCommandDescriptions = new StringMap();

	RegConsoleCmdEx("sm_mainmenu", Command_MainMenu, "Displays the main menu of the mode to players.");
	RegConsoleCmdEx("sm_commands", Command_Commands, "Shows all available player commands.");
	RegConsoleCmdEx("sm_admincommands", Command_AdminCommands, "Shows all available admin commands.");
	RegConsoleCmdEx("sm_colors", Command_Colors, "Displays the list of available colors which you can pick.");
	RegConsoleCmdEx("sm_role", Command_Role, "Displays what your current role is in chat.");
	RegConsoleCmdEx("sm_gamesettings", Command_GameSettings, "Allows for the game settings to be changed by admins or the game owner.");
	RegConsoleCmdEx("sm_owner", Command_Owner, "Displays who the current game owner is in chat.");
	RegConsoleCmdEx("sm_voting", Command_Voting, "Displays the voting menu during meetings.");
	RegConsoleCmdEx("sm_start", Command_Start, "Start the match during the lobby automatically.");

	RegAdminCmdEx("sm_reloadcolors", Command_ReloadColors, ADMFLAG_GENERIC, "Reload available colors players can use.");
	RegAdminCmdEx("sm_setrole", Command_SetRole, ADMFLAG_GENERIC, "Sets a specific player to a specific role.");
	RegAdminCmdEx("sm_setowner", Command_SetOwner, ADMFLAG_GENERIC, "Sets a specific player to own the match.");
	RegAdminCmdEx("sm_removeowner", Command_RemoveOwner, ADMFLAG_GENERIC, "Removes the current owner if there is one.");
	RegAdminCmdEx("sm_respawn", Command_Respawn, ADMFLAG_SLAY, "Respawn all players who are actively dead on teams.");
	RegAdminCmdEx("sm_eject", Command_Eject, ADMFLAG_SLAY, "Eject players from the map and out of the match.");
	RegAdminCmdEx("sm_imposters", Command_ListImposters, ADMFLAG_SLAY, "List the current imposters in the match.");
	RegAdminCmdEx("sm_listimposters", Command_ListImposters, ADMFLAG_SLAY, "List the current imposters in the match.");
	RegAdminCmdEx("sm_mark", Command_Mark, ADMFLAG_SLAY, "Mark certain nav areas as certain names to show in the HUD.");
	RegAdminCmdEx("sm_savemarks", Command_SaveMarks, ADMFLAG_SLAY, "Save all marks to a data file to be used later.");
	RegAdminCmdEx("sm_cameras", Command_Cameras, ADMFLAG_SLAY, "Shows what cameras are available on the map.");
	RegAdminCmdEx("sm_givetask", Command_GiveTask, ADMFLAG_GENERIC, "Give a player a certain task to do.");
	RegAdminCmdEx("sm_assigntask", Command_AssignTask, ADMFLAG_SLAY, "Assign certain tasks to players.");
	RegAdminCmdEx("sm_editmarks", Command_EditMarks, ADMFLAG_SLAY, "Opens up the marks editor.");
	RegAdminCmdEx("sm_paintmarks", Command_PaintMarks, ADMFLAG_SLAY, "Paint marks based on where the players moving.");
	RegAdminCmdEx("sm_playintro", Command_PlayIntro, ADMFLAG_SLAY, "Plays the introduction to matches.");

	//Stores all game settings.
	g_GameSettings = new StringMap();

	//Entity classnames present in this array will be automatically deleted on creation.
	g_CleanEntities = new ArrayList(ByteCountToCells(32));
	g_CleanEntities.PushString("tf_ammo_pack");
	g_CleanEntities.PushString("halloween_souls_pack");

	//Cache area names to show in the HUD based on Navmesh ID.
	g_AreaNames = new StringMap();

	g_Hud = CreateHudSynchronizer();

	g_Reconnects = new ArrayList();

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
		
	if (g_Late)
	{
		//Parse all available tasks on the map.
		ParseTasks();

		TF2_CreateTimer(convar_Time_Setup.IntValue, convar_Time_Round.IntValue);

		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && !IsFakeClient(i))
				SendHud(i);
	}

	TriggerTimer(CreateTimer(3600.0, Timer_ShowAd, _, TIMER_REPEAT), true);
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		if (!IsFakeClient(i))
			ClearSyncHud(i, g_Hud);

		RemoveGhost(i);
	}

	for (int i = 0; i < g_TotalTasks; i++)
		g_Tasks[i].KillSprite();
	
	if (g_FogController_Crewmates > 0)
		AcceptEntityInput(g_FogController_Crewmates, "Kill");
	
	if (g_FogController_Imposters > 0)
		AcceptEntityInput(g_FogController_Imposters, "Kill");
}

public void OnMapStart()
{
	//Parse the marks for this map on load.
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));

	LoadMarks(sMap);

	/////
	//Precache Files

	char sBuffer[PLATFORM_MAX_PATH];
	FormatEx(sBuffer, sizeof(sBuffer), "%s.vmt", TASK_SPRITE);
	PrecacheGeneric(sBuffer, true);
	FormatEx(sBuffer, sizeof(sBuffer), "%s.vtf", TASK_SPRITE);
	PrecacheGeneric(sBuffer, true);

	PrecacheSound ("ambient_mp3/alarms/doomsday_lift_alarm.mp3"); //Used when finding a body for an emergency meeting.

	PrecacheSound("doors/vent_open2.wav");	//Played whenever a player is finished venting.
	PrecacheSound("doors/vent_open3.wav");	//Played whenever a player starts venting or moves to a different vent.

	PrecacheSound(SYSTEM_UI_MESSAGE);

	HandleSound(SOUND_ALARM);
	HandleSound(SOUND_BODYFOUND);
	HandleSound(SOUND_ROUNDSTART);
	HandleSound(SOUND_SABOTAGE);
	HandleSound(SOUND_TASK_COMPLETE);
	HandleSound(SOUND_TASK_INPROGRESS);
	HandleSound(SOUND_VICTORY_CREW);
	HandleSound(SOUND_VICTORY_IMPOSTER);
	HandleSound(SOUND_VOTE_CONFIRM);
	HandleSound(SOUND_DISCONNECT);
	HandleSound(SOUND_IMPOSTER_DEATHMUSIC);
	HandleSound(SOUND_IMPOSTER_KILL);
	HandleSound(SOUND_SPAWN);
	HandleSound(SOUND_VENT_MOVE1);
	HandleSound(SOUND_VENT_MOVE2);
	HandleSound(SOUND_VENT_MOVE3);
	HandleSound(SOUND_VENT_OPEN);

	/////
	//Fog Controllers

	//Setup the fog controller to control vision.
	g_FogController_Crewmates = CreateEntityByName("env_fog_controller");
	
	DispatchKeyValue(g_FogController_Crewmates, "targetname", "fog_crewmates");
	DispatchKeyValue(g_FogController_Crewmates, "fogblend", "0");
	DispatchKeyValue(g_FogController_Crewmates, "fogcolor", "0 0 0");
	DispatchKeyValue(g_FogController_Crewmates, "fogcolor2", "0 0 0");
	DispatchKeyValueFloat(g_FogController_Crewmates, "fogstart", g_FogDistance * GetGameSetting_Float("crewmate_vision"));
	DispatchKeyValueFloat(g_FogController_Crewmates, "fogend", (g_FogDistance * 2) * GetGameSetting_Float("crewmate_vision"));
	DispatchKeyValueFloat(g_FogController_Crewmates, "fogmaxdensity", 0.95);
	DispatchSpawn(g_FogController_Crewmates);

	AcceptEntityInput(g_FogController_Crewmates, "TurnOff");

	g_FogController_Imposters = CreateEntityByName("env_fog_controller");
	
	DispatchKeyValue(g_FogController_Imposters, "targetname", "fog_imposters");
	DispatchKeyValue(g_FogController_Imposters, "fogblend", "0");
	DispatchKeyValue(g_FogController_Imposters, "fogcolor", "0 0 0");
	DispatchKeyValue(g_FogController_Imposters, "fogcolor2", "0 0 0");
	DispatchKeyValueFloat(g_FogController_Imposters, "fogstart", g_FogDistance * GetGameSetting_Float("imposter_vision"));
	DispatchKeyValueFloat(g_FogController_Imposters, "fogend", (g_FogDistance * 2) * GetGameSetting_Float("imposter_vision"));
	DispatchKeyValueFloat(g_FogController_Imposters, "fogmaxdensity", 0.95);
	DispatchSpawn(g_FogController_Imposters);

	AcceptEntityInput(g_FogController_Imposters, "TurnOff");

	g_flTrackNavAreaNextThink = 0.0;
	g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");

	g_TEParticleDelay = 0.0;
}

public void OnMapEnd()
{
	g_LockDoors = null;
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
	else if (convar == convar_TopDownView)
	{
		if (StrEqual(newValue, "1", false))
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
					CreateCamera(i);
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
					DestroyCamera(i);
		}
	}
}

public void OnConfigsExecuted()
{
	convar_Engine_RespawnWaveTime.Flags &= ~FCVAR_NOTIFY;
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
	else if (StrEqual(sCommand, "build", false) && !TF2_IsInSetup() && g_Player[client].role == Role_Imposter)
	{
		char sArg1[16];
		GetCmdArg(1, sArg1, sizeof(sArg1));

		char sArg2[16];
		GetCmdArg(2, sArg2, sizeof(sArg2));

		//Sentry
		if (StrEqual(sArg1, "2", false) && StrEqual(sArg2, "0", false))
			StartSabotage(client, SABOTAGE_REACTORS);

		//Dispenser
		if (StrEqual(sArg1, "0", false) && StrEqual(sArg2, "0", false))
			StartSabotage(client, SABOTAGE_FIXLIGHTS);

		//Entrance
		if (StrEqual(sArg1, "1", false) && StrEqual(sArg2, "0", false))
			StartSabotage(client, SABOTAGE_COMMUNICATIONS);

		//Exit
		if (StrEqual(sArg1, "1", false) && StrEqual(sArg2, "1", false))
			StartSabotage(client, SABOTAGE_DEPLETION);
	}
	else if (!convar_EurekaEffectTele.BoolValue && StrEqual(sCommand, "eureka_teleport", false))
	{
		SendDenyMessage(client, "%T", "error eureka teleport blocked", client);
		return Plugin_Stop;
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
	SDKHook(client, SDKHook_PreThink, OnPreThink);
	SDKHook(client, SDKHook_SetTransmit, OnSetTransmit);

	QueryClientConVar(client, "cl_downloadfilter", OnParseDownloadFilter);
}

public void OnParseDownloadFilter(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any value)
{
	if (!StrEqual(cvarValue, "all", false))
	{
		EmitSoundToClient(client, SYSTEM_UI_MESSAGE);
		SetHudTextParams(-1.0, -1.0, 10.0, 255, 0, 0, 255);
		ShowHudText(client, -1, "Please reconnect with your downloads filter set to ALL.");
	}
}

public void OnClientDisconnect(int client)
{
	EmitSoundToAll(SOUND_DISCONNECT, client);
	
	//If the owner of the game disconnects then free up the slot.
	if (client == g_GameOwner)
	{
		g_GameOwner = -1;
		ParseGameSettings();
		SendHudToAll();
	}

	if (!TF2_IsInSetup())
	{
		g_Reconnects.Push(GetSteamAccountID(client));

		int imposters;
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && IsPlayerAlive(i) && g_Player[i].role == Role_Imposter)
				imposters++;
		
		if (imposters < 1)
		{
			ForceWin();
			CPrintToChatAll("%t", "imposters disconnected");
		}

		int crewmates;
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && IsPlayerAlive(i) && g_Player[i].role != Role_Imposter)
				crewmates++;
		
		if (crewmates < 1)
		{
			ForceWin(true);
			CPrintToChatAll("%t", "crewmates disconnected");
		}
	}
}

public void OnClientDisconnect_Post(int client)
{
	g_Player[client].Clear();
	g_Camera[client] = 0;
	g_IsDead[client] = false;
	g_LastButtons[client] = 0;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (TF2_IsInSetup())
		return Plugin_Continue;
	
	int button;
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		button = (1 << i);
		
		if ((buttons & button))
			if (!(g_LastButtons[client] & button))
				OnButtonPress(client, button);
	}
	
	g_LastButtons[client] = buttons;

	float targetorigin[3];
	switch (g_Player[client].role)
	{
		case Role_Crewmate:
		{
			if (IsPlayerAlive(client) && !TF2_IsInSetup() && g_Match.meeting == null && !g_IsDead[client])
			{
				float origin[3];
				GetClientAbsOrigin(client, origin);

				int entity = -1; char sName[32];
				while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != -1)
				{
					GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

					if (StrContains(sName, "sabotage", false) != 0)
						continue;

					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetorigin);

					if (GetVectorDistance(origin, targetorigin) > 100.0)
					{
						if (g_Player[client].nearsabotage == entity)
						{
							g_Player[client].nearsabotage = -1;
							PrintCenterText(client, "");
						}
					}
					else if (g_Player[client].nearsabotage == -1)
					{
						char sType[64];
						GetCustomKeyValue(entity, "type", sType, sizeof(sType));

						if (StrContains(sType, "meltdown", false) == 0 && g_Reactors == null)
							continue;
						
						if (StrContains(sType, "communications", false) == 0 && !g_DisableCommunications)
							continue;
						
						if (StrContains(sType, "oxygen", false) == 0 && g_O2 == null)
							continue;

						if (StrContains(sType, "lights", false) == 0 && !g_LightsOff)
							continue;
						
						g_Player[client].nearsabotage = entity;

						char sDisplay[64];
						GetCustomKeyValue(entity, "display", sDisplay, sizeof(sDisplay));

						PrintCenterText(client, "Near Sabotage: %s (Press MEDIC! to fix)", sDisplay);
					}
				}
			}
		}

		case Role_Imposter:
		{
			if (IsPlayerAlive(client) && !TF2_IsInSetup() && g_Match.meeting == null && !g_IsDead[client])
			{
				float origin[3];
				GetClientAbsOrigin(client, origin);

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
						PrintCenterText(client, "Near Target: %N (Press MEDIC! to MURDER!)", i);
					}
				}

				if (g_Player[client].venting)
					PrintCenterText(client, "Press MEDIC! to exit vent.");
				else
				{
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

							char sDisplay[256];
							GetCustomKeyValue(entity, "display", sDisplay, sizeof(sDisplay));
							
							PrintCenterText(client, "Near Vent: %s (Press MEDIC! to vent)", sDisplay);
						}
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

		if (!g_IsDead[client])
		{
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
					PrintCenterText(client, "Near Body: %N (Press MEDIC! to call a meeting)", i);
				}
			}

			int entity = -1; char sName[32];
			while ((entity = FindEntityByClassname(entity, "*")) != -1)
			{ 	
				GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

				if (StrContains(sName, "action", false) != 0)
					continue;
				
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin2);

				if (GetVectorDistance(origin, origin2) > 100.0)
				{
					if (g_Player[client].nearaction == entity)
					{
						g_Player[client].nearaction = -1;
						PrintCenterText(client, "");
					}
				}
				else if (g_Player[client].nearaction == -1)
				{
					g_Player[client].nearaction = entity;

					char sDisplay[256];
					GetCustomKeyValue(entity, "display", sDisplay, sizeof(sDisplay));
					
					PrintCenterText(client, "Near Action: %s (Press MEDIC! to interact)", sDisplay);
				}
			}
		}
	}

	/////
	//Tasks
	if (IsPlayerAlive(client) && g_Match.meeting == null)
	{
		float origin[3];
		GetClientEyePosition(client, origin);
		
		for (int i = 0; i < g_TotalTasks; i++)
		{
			if (g_Tasks[i].tasktype == TaskType_Map)
				continue;

			if (GetVectorDistance(origin, g_Tasks[i].origin) > 100.0)
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
				PrintCenterText(client, "Near Task: %s (Press MEDIC! to interact)", g_Tasks[i].display);
			}
		}
	}

	return Plugin_Continue;
}

void OnButtonPress(int client, int button)
{
	if ((button & IN_RELOAD) == IN_RELOAD)
	{
		if (IsPlayerAlive(client) && g_Player[client].role == Role_Imposter && GetActiveWeaponIndex(client) == 25)
		{
			if (g_DelayDoors != -1 && g_DelayDoors > GetTime())
			{
				SendDenyMessage(client, "%T", "error time lock all doors", client, (g_DelayDoors - GetTime()));
				return;
			}
			
			//g_DelayDoors = GetTime() + convar_Sabotages_Cooldown_Doors.IntValue;

			//EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3");
			//CPrintToChat(client, "Door is now locked for 10 seconds!");

			float origin[3];
			GetClientAbsOrigin(client, origin);

			int entity = -1; float origin2[3]; int locked = INVALID_ENT_REFERENCE; int locked2 = INVALID_ENT_REFERENCE;
			while ((entity = FindEntityByClassname(entity, "func_door")) != -1)
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin2);

				if (GetVectorDistance(origin, origin2) <= 200.0)
				{
					AcceptEntityInput(entity, "Close");
					AcceptEntityInput(entity, "Lock");

					if (locked == INVALID_ENT_REFERENCE)
						locked = EntIndexToEntRef(entity);
					else if (locked2 == INVALID_ENT_REFERENCE)
						locked2 = EntIndexToEntRef(entity);
					
					if (locked != INVALID_ENT_REFERENCE && locked2 != INVALID_ENT_REFERENCE)
						break;
				}
			}
			
			if (locked != INVALID_ENT_REFERENCE && locked2 != INVALID_ENT_REFERENCE)
			{
				g_DelayDoors = GetTime() + convar_Sabotages_Cooldown_Doors.IntValue;
				CPrintToChat(client, "%T", "door is locked", client);
				StopTimer(g_LockDoors);

				DataPack pack;
				g_LockDoors = CreateDataTimer(10.0, Timer_OpenDoor, pack, TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteCell(locked);
				pack.WriteCell(locked2);

				TF2_EquipWeaponSlot(client, TFWeaponSlot_Melee);
			}
		}
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

	Call_StartForward(g_Forward_OnColorSetPost);
	Call_PushCell(client);
	Call_PushCell(color);
	Call_Finish();
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
		FormatEx(sOwner, MAX_NAME_LENGTH + 32, " (GM: %N)", g_GameOwner);

	//Mode Name
	Format(sHud, sizeof(sHud), "%s[Mode] Among Us%s", sHud, sOwner);

	//Role
	if (!TF2_IsInSetup())
	{
		char sRole[32];
		GetRoleName(g_Player[client].role, sRole, sizeof(sRole));

		Format(sHud, sizeof(sHud), "%s\nRole: %s", sHud, sRole);
	}

	//Tasks
	if (HasTasks(client) && !g_DisableCommunications)
	{
		Format(sHud, sizeof(sHud), "%s\n--%sTasks-- (%i/%i)", sHud, g_Player[client].role == Role_Imposter ? "Fake " : "", g_Match.tasks_current, g_Match.tasks_goal);

		for (int i = 0; i < g_Player[client].tasks.Length; i++)
		{
			int task = g_Player[client].tasks.Get(i);
			TaskType type = g_Tasks[task].tasktype;

			Format(sHud, sizeof(sHud), "%s\n%s", sHud, g_Tasks[task].display);

			if (type == TaskType_Map)
			{
				int current = GetTaskStep(client, task);
				int total = GetTaskMapParts(task);

				Format(sHud, sizeof(sHud), "%s(%i/%i)", sHud, current, total);
			}
			
			if (IsTaskCompleted(client, task))
				StrCat(sHud, sizeof(sHud), "✓");
		}
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
	if (g_BetweenRounds || TF2_IsInSetup() || g_Player[client].camera != -1 || g_Match.intro)
		return Plugin_Stop;
	
	if (g_Player[client].neardeath != -1 && !g_IsDead[client])
	{
		g_Player[client].neardeath = -1;
		CallMeeting(client);
	}
	else if (g_Player[client].target > 0 && g_Player[client].target <= MaxClients && !g_IsDead[client])
	{
		if (g_Player[client].lastkill > 0 && g_Player[client].lastkill > GetGameTime())
		{
			SendDenyMessage(client, "%T", "error time execution", client, (g_Player[client].lastkill - GetGameTime()));
			return Plugin_Stop;
		}

		SDKHooks_TakeDamage(g_Player[client].target, 0, client, 99999.0, DMG_SLASH);
		g_Player[client].target = -1;
		g_Player[client].lastkill = GetGameTime() + GetGameSetting_Float("kill_cooldown");
		PrintCenterText(client, "");
	}
	else if (g_Player[client].nearvent != -1 && g_Player[client].role == Role_Imposter && !g_IsDead[client])
	{
		if (g_Player[client].venting)
			StopVenting(client, g_Player[client].nearvent);
		else
			StartVenting(client, g_Player[client].nearvent);
	}
	else if (g_Player[client].nearaction != -1)
	{
		int entity = g_Player[client].nearaction;

		char sType[64];
		GetCustomKeyValue(entity, "type", sType, sizeof(sType));

		if (StrContains(sType, "meeting", false) == 0)
		{
			if (g_Reactors != null || g_LightsOff || g_DisableCommunications || g_O2 != null)
			{
				SendDenyMessage(client, "%T", "error no meeting while sabotage", client);
				return Plugin_Stop;
			}
			
			int max = GetGameSetting_Int("emergency_meetings");

			if (max > 0 && g_Match.total_meetings >= max)
			{
				SendDenyMessage(client, "%T", "error maximum emergencies reached", client);
				return Plugin_Stop;
			}
			
			CallMeeting(client, true);
			g_Player[client].nearaction = -1;
		}
		else if (StrContains(sType, "cameras", false) == 0)
		{
			SetEntityMoveType(client, MOVETYPE_OBSERVER);
			OpenCamerasMenu(client);
		}
		else if (StrContains(sType, "map", false) == 0)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
			OpenMap(client, true);
		}
		else
		{
			SendDenyMessage(client, "%T", "error action disabled", client);
		}
	}
	else if (g_Player[client].nearsabotage != -1 && !g_IsDead[client])
	{
		int entity = g_Player[client].nearsabotage;

		char sType[64];
		GetCustomKeyValue(entity, "type", sType, sizeof(sType));

		if (StrContains(sType, "meltdown", false) == 0 && g_Reactors != null)
		{
			int time = GetTime();

			//Neither reactor has been accessed.
			if (g_ReactorStamp == -1)
			{
				g_ReactorStamp = time + 2;	//Save a timestamp and increment 2 seconds to check for the other.
				g_ReactorExclude = client;	//Save the current client so they can't just spam interacting with 1 terminal to fix it.
				return Plugin_Stop;
			}
			else if (g_ReactorExclude == client) //Stop the client from interacting again unless the timestamp is reset.
				return Plugin_Stop;
			else if (g_ReactorStamp < time) //A new client has accessed the other terminal but it's too late so reset.
			{
				g_ReactorStamp = -1;
				g_ReactorExclude = -1;
				TF2_PlayDenySound(client);
				return Plugin_Stop;
			}

			g_ReactorStamp = -1;
			g_ReactorExclude = -1;
			g_ReactorsTime = 0;
			StopTimer(g_Reactors);
			CPrintToChatAll("%t", "reactor meltdown stopped", client);
			g_IsSabotageActive = false;

			Call_StartForward(g_Forward_OnSabotageFailurePost);
			Call_PushCell(client);
			Call_PushCell(SABOTAGE_REACTORS);
			Call_Finish();
		}
		else if (StrContains(sType, "communications", false) == 0 && g_DisableCommunications)
		{
			g_DisableCommunications = false;
			SendHudToAll();
			CPrintToChatAll("%t", "communications fixed", client);
			g_IsSabotageActive = false;
		}
		else if (StrContains(sType, "oxygen", false) == 0 && g_O2 != null)
		{
			g_O2Time = 0;
			StopTimer(g_O2);
			CPrintToChatAll("%t", "o2 fixed", client);
			g_IsSabotageActive = false;

			Call_StartForward(g_Forward_OnSabotageFailurePost);
			Call_PushCell(client);
			Call_PushCell(SABOTAGE_DEPLETION);
			Call_Finish();
		}
		else if (StrContains(sType, "lights", false) == 0 && g_LightsOff)
		{
			g_LightsOff = false;
			CPrintToChatAll("%t", "lights fixed", client);
			
			float fog = GetGameSetting_Float("crewmate_vision");

			if (fog < 0.1)
				fog = 0.1;
			
			DispatchKeyValueFloat(g_FogController_Crewmates, "fogstart", g_FogDistance * fog);
			DispatchKeyValueFloat(g_FogController_Crewmates, "fogend", (g_FogDistance * 2) * fog);
			g_IsSabotageActive = false;
		}
	}
	else if (g_Player[client].neartask != -1 && g_Player[client].doingtask == null && !TF2_IsInSetup())
	{
		int task = g_Player[client].neartask;
		int entity = EntRefToEntIndex(g_Tasks[task].entityref);

		if (!IsValidEntity(entity) || !HasEntProp(entity, Prop_Send, "m_vecOrigin"))
			return Plugin_Stop;

		switch (g_Tasks[task].tasktype)
		{
			case TaskType_Single:
			{
				if (IsTaskAssigned(client, task) && !IsTaskCompleted(client, task))
				{
					int time;

					if ((g_Tasks[task].type & TASK_TYPE_LONG) == TASK_TYPE_LONG)
						time = 10;
					else if ((g_Tasks[task].type & TASK_TYPE_SHORT) == TASK_TYPE_SHORT)
						time = 5;
					else if ((g_Tasks[task].type & TASK_TYPE_COMMON) == TASK_TYPE_COMMON)
						time = 5;		
					
					//This is considered a task AND an action so we just do a hacky update.
					if (StrEqual(g_Tasks[task].display, "Submit Scan", false))
					{
						SetEntityMoveType(client, MOVETYPE_NONE);

						float origin[3];
						GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
						origin[2] += 5.0;
						TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);

						g_Player[client].scanning = true;
					}

					g_Player[client].taskticks = time;
					g_Player[client].progresstask = task;
					StopTimer(g_Player[client].doingtask);
					g_Player[client].doingtask = CreateTimer(1.0, Timer_DoingTask, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

					Call_StartForward(g_Forward_OnTaskStartedPost);
					Call_PushCell(client);
					Call_PushCell(g_Player[client].progresstask);
					Call_PushCell(g_Player[client].progresstaskpart);
					Call_Finish();

					EmitSoundToClient(client, SOUND_TASK_INPROGRESS);
				}
				else
					SendDenyMessage(client, "%T", "error not assigned task", client);
			}

			case TaskType_Part:
			{
				if (g_Player[client].lockouts.FindValue(task) != -1)
					return Plugin_Stop;
				
				char sLink[64];
				GetCustomKeyValue(entity, "link", sLink, sizeof(sLink));
				
				bool discovered;
				for (int i = 0; i < g_Player[client].tasks.Length; i++)
				{
					int taskmap = g_Player[client].tasks.Get(i);

					if (g_Tasks[taskmap].tasktype != TaskType_Map)
						continue;
				
					char sLookup[512];
					Format(sLookup, sizeof(sLookup), "part %i", GetTaskStep(client, taskmap) + 1);

					int entity2 = EntRefToEntIndex(g_Tasks[taskmap].entityref);

					if (!IsValidEntity(entity2))
						continue;

					char sPart[512];
					GetCustomKeyValue(entity2, sLookup, sPart, sizeof(sPart));

					int pos;
					if ((pos = StrContains(sPart, "{", false)) != -1 && g_Player[client].intgend == -1)
					{
						char sWork[256];
						strcopy(sWork, sizeof(sWork), sPart);

						StripCharactersPre(sWork, sizeof(sWork), pos+1);
						pos = StrContains(sWork, "}", false);
						StripCharactersPost(sWork, pos);

						char sRandom[2][16];
						ExplodeString(sWork, ",", sRandom, 2, 16);

						FormatEx(g_Player[client].intgens, 256, "{%s,%s}", sRandom[0], sRandom[1]);

						int randomvalue = GetRandomInt(StringToInt(sRandom[0]), StringToInt(sRandom[1]));

						g_Player[client].intgend = randomvalue;
					}

					if (g_Player[client].intgend != -1)
					{
						char sFUUUUUCK[64];
						IntToString(g_Player[client].intgend, sFUUUUUCK, sizeof(sFUUUUUCK));

						ReplaceString(sPart, sizeof(sPart), g_Player[client].intgens, sFUUUUUCK);
					}
					
					if (StrContains(sPart, sLink, false) != -1)
					{
						if (strlen(g_Player[client].randomchosen) > 0  && !StrEqual(sLink, g_Player[client].randomchosen, false))
						{
							SendDenyMessage(client, "%T", "error not assigned task", client);
							return Plugin_Stop;
						}
						
						g_Player[client].randomchosen[0] = '\0';
						
						int time;

						if ((g_Tasks[taskmap].type & TASK_TYPE_LONG) == TASK_TYPE_LONG)
							time = 10;
						else if ((g_Tasks[taskmap].type & TASK_TYPE_SHORT) == TASK_TYPE_SHORT)
							time = 5;
						else if ((g_Tasks[taskmap].type & TASK_TYPE_COMMON) == TASK_TYPE_COMMON)
							time = 5;

						g_Player[client].taskticks = time;
						g_Player[client].progresstask = taskmap;
						g_Player[client].progresstaskpart = task;
						StopTimer(g_Player[client].doingtask);
						g_Player[client].doingtask = CreateTimer(1.0, Timer_DoingTask, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

						Call_StartForward(g_Forward_OnTaskStartedPost);
						Call_PushCell(client);
						Call_PushCell(g_Player[client].progresstask);
						Call_PushCell(g_Player[client].progresstaskpart);
						Call_Finish();

						discovered = true;
					}
				}

				if (!discovered)
					CPrintToChat(client, "%T", "not assigned task", client);
				else
					EmitSoundToClient(client, SOUND_TASK_INPROGRESS);
			}
		}
	}

	return Plugin_Stop;
}

public Action Listener_Kill(int client, const char[] command, int argc)
{
	return Plugin_Stop;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	SDKHook(entity, SDKHook_Spawn, OnEntitySpawn);

	if (StrEqual(classname, "trigger_multiple", false))
	{
		SDKHook(entity, SDKHook_StartTouch, OnTriggerStartTouch);
		SDKHook(entity, SDKHook_Touch, OnTriggerTouch);
		SDKHook(entity, SDKHook_EndTouch, OnTriggerEndTouch);
	}

	if (g_Late)
		OnEntitySpawn(entity);
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (!convar_Chat_Gag.BoolValue)
		return Plugin_Continue;
	
	if (CheckCommandAccess(client, "", ADMFLAG_GENERIC, true))
		return Plugin_Continue;
	
	if (TF2_IsInSetup())
		return Plugin_Continue;
	
	if (g_Match.meeting != null)
		return Plugin_Continue;
	
	SendDenyMessage(client, "%T", "error not allowed to type", client);
	return Plugin_Stop;
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
		SaveGameSettings(client);

		g_UpdatingGameSetting[client][0] = '\0';
		OpenSettingsMenu(client);
	}
}

public void OnGameFrame()
{
	//Get the current amount of players on a team in the server.
	int count = GetTotalPlayers();
	int required = convar_Required_Players.IntValue;

	//If it's during the round and there's less than 2 players on the server then end the round since this mode requires X players to play.
	if (!TF2_IsInSetup() && count <= required && !g_BetweenRounds)
	{
		//g_BetweenRounds = true;
		//TF2_ForceWin(TFTeam_Unassigned);
	}

	//If there's less than X players then make sure the timer's paused and send a hud message saying the mode requires X players to play.
	if (count < required)
	{
		if (!TF2_IsTimerPaused())
			TF2_PauseTimer();
		
		PrintCenterTextAll("%i players required to start.", required);
	}
	else if (count >= required && TF2_IsTimerPaused()) //If there's more than X players and the timer's paused then unpause it.
		TF2_ResumeTimer();
	
	//Check if the current amount of tasks completed is more than or equal to the goal.
	//If the current tasks amount has met the tasks goal then end the round and give the victory the the non-imposters.
	if (g_Match.tasks_goal > 0 && g_Match.tasks_current >= g_Match.tasks_goal && !g_BetweenRounds)
	{
		g_BetweenRounds = true;

		ForceWin();
		CPrintToChatAll("%t", "all tasks completed");
	}

	if (GetGameTime() >= g_flTrackNavAreaNextThink)
	{
		g_flTrackNavAreaNextThink = GetGameTime() + 0.1;

		static const int DefaultAreaColor[] = { 255, 0, 0, 255 };
		static const int FocusedAreaColor[] = { 255, 255, 0, 255 };
		static const int MarkedAreaColor[] = { 0, 255, 0, 255 };

		for (int client = 1; client <= MaxClients; client++)
		{
			if (!IsClientInGame(client))
				continue;
			
			if (g_Player[client].editingmarks)
			{
				float flEyePos[3], flEyeDir[3], flEndPos[3];
				GetClientEyePosition(client, flEyePos);
				GetClientEyeAngles(client, flEyeDir);
				GetAngleVectors(flEyeDir, flEyeDir, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(flEyeDir, flEyeDir);
				ScaleVector(flEyeDir, 1000.0);
				AddVectors(flEyePos, flEyeDir, flEndPos);
				
				Handle hTrace = TR_TraceRayFilterEx(flEyePos, flEndPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, TraceRayDontHitEntity, client);
				
				TR_GetEndPosition(flEndPos, hTrace);
				delete hTrace;

				CNavArea area = NavMesh_GetNearestArea(flEndPos);
				
				if (area == INVALID_NAV_AREA)
					continue;
				
				DrawNavArea(client, area, FocusedAreaColor, MarkedAreaColor);

				if (strlen(g_Player[client].paintmarks) > 0)
				{
					char sID[16];
					IntToString(area.ID, sID, sizeof(sID));
					g_AreaNames.SetString(sID, g_Player[client].paintmarks);
				}

				ArrayList connections = new ArrayList();
				area.GetAdjacentList(NAV_DIR_COUNT, connections);

				for (int i = 0; i < connections.Length; i++)
					DrawNavArea(client, connections.Get(i), DefaultAreaColor, MarkedAreaColor);	

				delete connections;
			}
		}
	}

	if (GetGameTime() >= g_TEParticleDelay)
	{
		g_TEParticleDelay = GetGameTime() + 10.0;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || IsFakeClient(i))
				continue;
			
			for (int x = 0; x < g_Player[i].tasks.Length; x++)
			{
				int task = g_Player[i].tasks.Get(x);

				if (g_Tasks[task].tasktype == TaskType_Single)
				{
					if (IsTaskCompleted(i, task))
						continue;
					
					int entity = EntRefToEntIndex(g_Tasks[task].entityref);

					if (!IsValidEntity(entity) || !HasEntProp(entity, Prop_Send, "m_vecOrigin"))
						continue;

					float origin[3];
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
					origin[2] += 10.0;

					TF2_CreateAnnotation(i, x, origin, g_Tasks[task].display, 10.0, "vo/null.wav");
				}
			}
		}
	}
}

public bool TraceRayDontHitEntity(int entity,int mask, any data)
{
	if (entity == data)
		return false;
	
	return true;
}

void DrawNavArea(int client, CNavArea area, const int color[4], const int marked[4], float duration=0.15) 
{
	if (!IsClientInGame(client) || area == INVALID_NAV_AREA)
		return;
	
	char sID[16];
	IntToString(area.ID, sID, sizeof(sID));
	
	char sName[64];
	g_AreaNames.GetString(sID, sName, sizeof(sName));

	bool ismarked;
	if (strlen(sName) > 0 && StrEqual(g_Player[client].paintmarks, sName, false))
		ismarked = true;

	float from[3], to[3];
	area.GetCorner(NAV_CORNER_NORTH_WEST, from);
	area.GetCorner(NAV_CORNER_NORTH_EAST, to);
	from[2] += 2; to[2] += 2;

	TE_SetupBeamPoints(from, to, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, duration, 1.0, 1.0, 0, 0.0, ismarked ? marked : color, 1);
	TE_SendToClient(client);

	area.GetCorner(NAV_CORNER_NORTH_EAST, from);
	area.GetCorner(NAV_CORNER_SOUTH_EAST, to);
	from[2] += 2; to[2] += 2;

	TE_SetupBeamPoints(from, to, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, duration, 1.0, 1.0, 0, 0.0, ismarked ? marked : color, 1);
	TE_SendToClient(client);

	area.GetCorner(NAV_CORNER_SOUTH_EAST, from);
	area.GetCorner(NAV_CORNER_SOUTH_WEST, to);
	from[2] += 2; to[2] += 2;

	TE_SetupBeamPoints(from, to, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, duration, 1.0, 1.0, 0, 0.0, ismarked ? marked : color, 1);
	TE_SendToClient(client);

	area.GetCorner(NAV_CORNER_SOUTH_WEST, from);
	area.GetCorner(NAV_CORNER_NORTH_WEST, to);
	from[2] += 2; to[2] += 2;

	TE_SetupBeamPoints(from, to, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, duration, 1.0, 1.0, 0, 0.0, ismarked ? marked : color, 1);
	TE_SendToClient(client);
}

void CallMeeting(int client = -1, bool button = false)
{
	if (g_Match.last_meeting > 0 && g_Match.last_meeting > GetGameTime())
	{
		SendDenyMessage(client, "%T", "error time meeting wait", client, (g_Match.last_meeting - GetGameTime()));
		return;
	}

	if (client > 0)
	{
		if (button)
			CPrintToChatAll("%t", "has called a meeting", client);
		else
			CPrintToChatAll("%t", "has found a body", client);
	}

	EmitSoundToAll(button ? SOUND_ALARM : SOUND_BODYFOUND);
	
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

	//EmitSoundToAll("ambient_mp3/alarms/doomsday_lift_alarm.mp3");
	UnmuteAllClients();

	TriggerRelay("meeting_button_lock");

	TriggerRelay("lobby_doors_close");
	TriggerRelay("lobby_doors_lock");

	g_Match.meeting_time = GetGameSetting_Int("discussion_time");
	StopTimer(g_Match.meeting);
	g_Match.meeting = CreateTimer(1.0, Timer_StartVoting, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	g_Match.total_meetings++;

	AcceptEntityInput(g_FogController_Crewmates, "TurnOff");
	AcceptEntityInput(g_FogController_Imposters, "TurnOff");
}

void EjectPlayer(int client)
{
	int eject_point = FindEntityByName("eject_tele", "info_teleport_destination");

	if (!IsValidEntity(eject_point))
		return;
	
	int eject_camera = FindEntityByName("eject_cam", "point_viewcontrol");

	if (IsValidEntity(eject_camera))
	{
		DispatchKeyValue(eject_camera, "spawnflags", "12");

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || i == client)
				continue;
			
			AcceptEntityInput(eject_camera, "Enable", i);
		}
	}
	
	//Mark the player as ejected.
	g_Player[client].ejected = true;

	float origin[3];
	GetEntPropVector(eject_point, Prop_Send, "m_vecOrigin", origin);

	float angles[3];
	GetEntPropVector(eject_point, Prop_Send, "m_angRotation", angles);

	//Temporary coordinates until better logic is setup with the map.
	TeleportEntity(client, origin, angles, view_as<float>({0.0, 0.0, 0.0}));

	//Create The timer so we know they're gonna be dead after a bit of being ejected.
	StopTimer(g_Player[client].ejectedtimer);
	g_Player[client].ejectedtimer = CreateTimer(10.0, Timer_Suicide, GetClientUserId(client));
}

void StartVenting(int client, int vent)
{
	g_Player[client].venting = true;

	TF2_HidePlayer(client);
	SetEntityMoveType(client, MOVETYPE_NONE);
	//SetEntProp(client, Prop_Send, "m_iHideHUD", 0);

	TF2_SetThirdPerson(client);
	//EmitSoundToClient(client, "doors/vent_open3.wav", SOUND_FROM_PLAYER, SNDCHAN_REPLACE, SNDLEVEL_NONE, SND_CHANGEVOL, 0.75);
	EmitSoundToClient(client, SOUND_VENT_OPEN);

	OpenVentsMenu(client, vent);

	Call_StartForward(g_Forward_OnVentingStartPost);
	Call_PushCell(client);
	Call_PushCell(vent);
	Call_Finish();
}

void StopVenting(int client, int vent)
{
	g_Player[client].venting = false;

	TF2_ShowPlayer(client);
	SetEntityMoveType(client, MOVETYPE_WALK);
	//SetEntProp(client, Prop_Send, "m_iHideHUD", (1<<6));

	TF2_SetFirstPerson(client);
	EmitSoundToClient(client, "doors/vent_open2.wav", SOUND_FROM_PLAYER, SNDCHAN_REPLACE, SNDLEVEL_NONE, SND_CHANGEVOL, 0.75);

	Call_StartForward(g_Forward_OnVentingEndPost);
	Call_PushCell(client);
	Call_PushCell(vent);
	Call_Finish();
}

public Action OnLogicRelayTriggered(const char[] output, int caller, int activator, float delay)
{
	char sName[32];
	GetEntPropString(caller, Prop_Data, "m_iName", sName, sizeof(sName));

	if (StrEqual(sName, RELAY_MEETING_BUTTON_OPEN, false) && g_Match.meeting == null)
	{
		if (g_BetweenRounds)
			return Plugin_Stop;
		
		if (g_Reactors != null || g_LightsOff || g_DisableCommunications || g_O2 != null)
		{
			SendDenyMessage(activator, "%T", "error no meeting while sabotage", activator);
			return Plugin_Stop;
		}
		
		int max = GetGameSetting_Int("emergency_meetings");

		if (max > 0 && g_Match.total_meetings >= max)
		{
			SendDenyMessage(activator, "%T", "error maximum emergencies reached", activator);
			return Plugin_Stop;
		}

		CallMeeting(activator, true);
	}

	return Plugin_Continue;
}

void OnMatchCompleted(TFTeam team)
{
	g_Reconnects.Clear();
	
	switch (team)
	{
		case TFTeam_Red:
			EmitSoundToAll(SOUND_VICTORY_IMPOSTER);
		case TFTeam_Blue:
			EmitSoundToAll(SOUND_VICTORY_CREW);
	}

	//g_Match.tasks_current = 0;
	//g_Match.tasks_goal = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		g_Player[i].role = Role_Crewmate;
		Call_StartForward(g_Forward_OnRoleAssignedPost);
		Call_PushCell(i);
		Call_PushCell(g_Player[i].role);
		Call_Finish();
		g_Player[i].ejected = false;
		RemoveGhost(i);
		ClearTasks(i);
	}

	for (int i = 0; i < g_TotalTasks; i++)
		g_Tasks[i].KillSprite();

	StopTimer(g_Match.meeting);
	StopTimer(g_LockDoors);

	AcceptEntityInput(g_FogController_Crewmates, "TurnOff");
	AcceptEntityInput(g_FogController_Imposters, "TurnOff");

	g_IsSabotageActive = false;
	g_DelaySabotage = -1;
	g_ReactorsTime = 0;
	StopTimer(g_Reactors);
	g_ReactorStamp = -1;
	g_ReactorExclude = -1;
	g_LightsOff = false;
	g_DisableCommunications = false;
	g_O2Time = 0;
	StopTimer(g_O2);
	g_DelayDoors = -1;
	StopTimer(g_LockDoors);
}

void SaveMarks(const char[] map)
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/amongus/marks/%s.cfg", map);

	KeyValues kv = new KeyValues("marks");
	StringMapSnapshot snap = g_AreaNames.Snapshot();

	for (int i = 0; i < snap.Length; i++)
	{
		int size = snap.KeyBufferSize(i);

		char[] sKey = new char[size];
		snap.GetKey(i, sKey, size);

		char sName[32];
		g_AreaNames.GetString(sKey, sName, sizeof(sName));

		kv.SetString(sKey, sName);
	}

	kv.Rewind();
	kv.ExportToFile(sPath);

	delete kv;
	delete snap;
}

void LoadMarks(const char[] map)
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/amongus/marks/%s.cfg", map);

	g_AreaNames.Clear();

	KeyValues kv = new KeyValues("marks");

	if (kv.ImportFromFile(sPath) && kv.GotoFirstSubKey(false))
	{
		do
		{
			char sID[16];
			kv.GetSectionName(sID, sizeof(sID));

			char sName[32];
			kv.GetString(NULL_STRING, sName, sizeof(sName));

			g_AreaNames.SetString(sID, sName);
		}
		while (kv.GotoNextKey(false));
	}

	delete kv;
	LogMessage("%i marks parsed successfully for map: %s", g_AreaNames.Size, map);
}

void StartSabotage(int client, int sabotage)
{
	if (g_IsSabotageActive)
	{
		TF2_PlayDenySound(client);
		return;
	}
	
	if (g_DelaySabotage != -1 && g_DelaySabotage > GetTime())
	{
		SendDenyMessage(client, "%T", "error time sabotage cooldown", client, (g_DelaySabotage - GetTime()));
		return;
	}
	
	g_IsSabotageActive = true;
	g_DelaySabotage = GetTime() + convar_Sabotages_Cooldown.IntValue;

	//EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3");

	switch (sabotage)
	{
		case SABOTAGE_REACTORS:
		{
			CPrintToChatAll("%t", "reactors under meltdown");

			g_ReactorsTime = 30;
			StopTimer(g_Reactors);
			g_Reactors = CreateTimer(1.5, Timer_ReactorTick, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}

		case SABOTAGE_FIXLIGHTS:
		{
			CPrintToChatAll("%t", "lights are off");
			g_LightsOff = true;

			float fog = GetGameSetting_Float("crewmate_vision");

			if (fog < 0.1)
				fog = 0.1;

			DispatchKeyValueFloat(g_FogController_Crewmates, "fogstart", 5.0 * fog);
			DispatchKeyValueFloat(g_FogController_Crewmates, "fogend", (5.0 * 2) * fog);
		}

		case SABOTAGE_COMMUNICATIONS:
		{
			CPrintToChatAll("%t", "communications disabled");
			g_DisableCommunications = true;
			SendHudToAll();
		}

		case SABOTAGE_DEPLETION:
		{
			CPrintToChatAll("%t", "o2 depleted");

			g_O2Time = 30;
			StopTimer(g_O2);
			g_O2 = CreateTimer(1.5, Timer_O2Tick, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	TF2_EquipWeaponSlot(client, TFWeaponSlot_Melee);

	Call_StartForward(g_Forward_OnSabotageStartedPost);
	Call_PushCell(client);
	Call_PushCell(sabotage);
	Call_Finish();
}

public void TF2_OnWaitingForPlayersEnd()
{
	//Auto start the setup timer on waiting for players end.
	if (GetTotalPlayers() > 0)
		TF2_CreateTimer(convar_Time_Setup.IntValue, convar_Time_Round.IntValue);
}

void ParseTasks()
{
	int entity = -1; char sName[32];
	while ((entity = FindEntityByClassname(entity, "*")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

		if (StrContains(sName, "task", false) != 0)
			continue;
		
		char sDisplay[32];
		GetCustomKeyValue(entity, "display", sDisplay, sizeof(sDisplay));
		
		TaskType tasktype;
		if (StrContains(sName, "task_part", false) == 0)
			tasktype = TaskType_Part;
		else if (StrContains(sName, "task_map", false) == 0)
			tasktype = TaskType_Map;
		else
			tasktype = TaskType_Single;
		
		char sType[32];
		GetCustomKeyValue(entity, "type", sType, sizeof(sType));

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
		
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		
		g_Tasks[g_TotalTasks].Add(entity, sDisplay, tasktype, type, origin);
		g_TotalTasks++;
	}

	LogMessage("%i task entities parsed successfully.", g_TotalTasks);
}