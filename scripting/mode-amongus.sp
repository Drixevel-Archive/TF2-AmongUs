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

}