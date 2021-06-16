/*****************************/
//Pragma
#pragma semicolon 1
#pragma newdecls required

/*****************************/
//Defines
#define PLUGIN_NAME "[Mode] Among Us"
#define PLUGIN_DESCRIPTION "A mode which replicates the Among Us game."
#define PLUGIN_VERSION "1.0.0"

/*****************************/
//Includes
#include <sourcemod>

#include "mode/commands.sp"
#include "mode/events.sp"
#include "mode/natives.sp"
#include "mode/stocks.sp"

/*****************************/
//ConVars

/*****************************/
//Globals

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
	HookUserMessage(GetUserMessageId("VGUIMenu"), OnVGUIMenu, true);
}

public Action OnVGUIMenu(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) 
{
	char sMSG[12];
	BfReadString(msg, sMSG, sizeof(sMSG));

	//PrintToServer(sMSG);

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