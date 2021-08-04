/*****************************/
//Game Logic

stock int TF2_GetTimer()
{
	int entity = FindEntityByClassname(-1, "team_round_timer");

	if (!IsValidEntity(entity))
		entity = CreateEntityByName("team_round_timer");
	
	return entity;
}

stock int TF2_CreateTimer(int setup_time, int round_time)
{
	int entity = TF2_GetTimer();

	GameRules_SetProp("m_bInSetup", true);
	
	HookSingleEntityOutput(entity, "On5MinRemain", Timer_On5MinRemain);
	HookSingleEntityOutput(entity, "On4MinRemain", Timer_On4MinRemain);
	HookSingleEntityOutput(entity, "On3MinRemain", Timer_On3MinRemain);
	HookSingleEntityOutput(entity, "On2MinRemain", Timer_On2MinRemain);
	HookSingleEntityOutput(entity, "On1MinRemain", Timer_On1MinRemain);
	HookSingleEntityOutput(entity, "On30SecRemain", Timer_On30SecRemain);
	HookSingleEntityOutput(entity, "On10SecRemain", Timer_On10SecRemain);
	HookSingleEntityOutput(entity, "On5SecRemain", Timer_On5SecRemain);
	HookSingleEntityOutput(entity, "On4SecRemain", Timer_On4SecRemain);
	HookSingleEntityOutput(entity, "On3SecRemain", Timer_On3SecRemain);
	HookSingleEntityOutput(entity, "On2SecRemain", Timer_On2SecRemain);
	HookSingleEntityOutput(entity, "On1SecRemain", Timer_On1SecRemain);
	HookSingleEntityOutput(entity, "OnRoundStart", Timer_OnRoundStart);
	HookSingleEntityOutput(entity, "OnFinished", Timer_OnFinished);
	HookSingleEntityOutput(entity, "OnSetupStart", Timer_OnSetupStart);
	HookSingleEntityOutput(entity, "OnSetupFinished", Timer_OnSetupFinished);
	
	char sSetup[32];
	IntToString(setup_time + 1, sSetup, sizeof(sSetup));
	
	char sRound[32];
	IntToString(round_time + 1, sRound, sizeof(sRound));
	
	DispatchKeyValue(entity, "reset_time", "1");
	DispatchKeyValue(entity, "show_time_remaining", "1");
	DispatchKeyValue(entity, "setup_length", sSetup);
	DispatchKeyValue(entity, "timer_length", sRound);
	DispatchKeyValue(entity, "auto_countdown", "1");
	DispatchSpawn(entity);

	AcceptEntityInput(entity, "Enable");
	AcceptEntityInput(entity, "Resume");

	SetVariantInt(1);
	AcceptEntityInput(entity, "ShowInHUD");

	return entity;
}

stock void TF2_ShowTimer(bool resume = false)
{
	int entity = TF2_GetTimer();
	
	SetVariantInt(1);
	AcceptEntityInput(entity, "ShowInHUD");

	if (resume)
		TF2_EnableTimer();
}

stock void TF2_HideTimer(bool stop = false)
{
	int entity = TF2_GetTimer();
	
	SetVariantInt(0);
	AcceptEntityInput(entity, "ShowInHUD");

	if (stop)
		TF2_DisableTimer();
}

stock void TF2_SetTimer(bool enabled)
{
	int entity = TF2_GetTimer();
	AcceptEntityInput(entity, enabled ? "Enable" : "Disable");
}

stock void TF2_EnableTimer()
{
	int entity = TF2_GetTimer();
	AcceptEntityInput(entity, "Enable");
}

stock void TF2_DisableTimer()
{
	int entity = TF2_GetTimer();
	AcceptEntityInput(entity, "Disable");
}

stock void TF2_SetSetupTime(int value)
{
	int entity = TF2_GetTimer();
	SetVariantInt(value);
	AcceptEntityInput(entity, "SetSetupTime");
}

stock void TF2_SetTime(int value)
{
	int entity = TF2_GetTimer();
	SetVariantInt(value);
	AcceptEntityInput(entity, "SetTime");
}

stock bool TF2_IsInSetup()
{
	//Easy way to test functionality during the lobby phase where usually players shouldn't have access to it.
	#if defined DEBUG
	int fuck = 1; //TODO: Find a better solution to the error that the setup GameProp return can't be reached if debug is active.
	if (fuck != 0)
		return false;
	#endif

	return view_as<bool>(GameRules_GetProp("m_bInSetup"));
}

stock bool TF2_IsTimerPaused()
{
	int entity = TF2_GetTimer();
	return view_as<bool>(GetEntProp(entity, Prop_Send, "m_bTimerPaused"));
}

stock void TF2_PauseTimer()
{
	int entity = TF2_GetTimer();
	AcceptEntityInput(entity, "Pause");
}

stock void TF2_ResumeTimer()
{
	int entity = TF2_GetTimer();
	AcceptEntityInput(entity, "Resume");
}

/*****************************/
//Ent Outputs

public void Timer_On5MinRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On4MinRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On3MinRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On2MinRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On1MinRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On30SecRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On10SecRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On5SecRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On4SecRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On3SecRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On2SecRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_On1SecRemain(const char[] output, int caller, int activator, float delay)
{

}

public void Timer_OnRoundStart(const char[] output, int caller, int activator, float delay)
{
	EmitSoundToAll(SOUND_ROUNDSTART);

	for (int i = 1; i <= MaxClients; i++)
	{
		g_Player[i].showdeath = false;
		g_Player[i].deathorigin[0] = 0.0;
		g_Player[i].deathorigin[1] = 0.0;
		g_Player[i].deathorigin[2] = 0.0;
	}

	g_Match.tasks_current = 0;
	g_Match.total_meetings = 0;

	//Assign random players as Imposter and other roles automatically.
	int amount = GetGameSetting_Int("imposters");
	int current;
	int total = GetTotalPlayers();

	//If there isn't enough players, lets make sure the while look doesn't timeout.
	if (amount > total)
		amount = total;
	
	int failsafe; char sImposters[255]; bool first = true;
	while (amount > current && failsafe < 50)
	{
		failsafe++;

		int client = FindNewImposter();

		if (client < 1)
			continue;

		g_Player[client].role = Role_Imposter;
		SendHud(client);
		CPrintToChat(client, "%T", "imposter gained", client);
		TF2_GiveItem(client, "tf_weapon_pda_engineer_build", 25, TF2Quality_Vintage, 1);

		if (first)
		{
			first = false;
			Format(sImposters, sizeof(sImposters), "%s%N", sImposters, client);
		}
		else
			Format(sImposters, sizeof(sImposters), "%s, %N", sImposters, client);

		current++;
	}

	//Tell other imposters who the other imposters are in chat.
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i) && g_Player[i].role == Role_Imposter)
			CPrintToChat(i, "%T", "list imposters", i, sImposters);
	
	//Handle fog controllers being set properly for certain roles.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		if (g_Player[i].role == Role_Imposter)
			SetVariantString("fog_imposters");
		else
			SetVariantString("fog_crewmates");
		
		AcceptEntityInput(i, "SetFogController");
	}

	//Make sure all clients are muted whenever the round starts.
	MuteAllClients();

	//Set the fog controllers to have their set distances based on settings.
	float fog;

	fog = GetGameSetting_Float("crewmate_vision");

	if (fog < 0.1)
		fog = 0.1;
	
	DispatchKeyValueFloat(g_FogController_Crewmates, "fogstart", (g_FogDistance * 1.25) * fog);
	DispatchKeyValueFloat(g_FogController_Crewmates, "fogend", (g_FogDistance * 2) * fog);

	fog = GetGameSetting_Float("imposter_vision");

	if (fog < 0.1)
		fog = 0.1;
	
	DispatchKeyValueFloat(g_FogController_Imposters, "fogstart", (g_FogDistance * 1.25) * fog);
	DispatchKeyValueFloat(g_FogController_Imposters, "fogend", (g_FogDistance * 2) * fog);

	//Turn on the fog controllers.
	AcceptEntityInput(g_FogController_Crewmates, "TurnOn");
	AcceptEntityInput(g_FogController_Imposters, "TurnOn");

	/////
	//Tasks

	// for (int i = 0; i < g_TotalTasks; i++)
	// 	g_Tasks[i].CreateSprite();

	//Pull the amount of certain tasks to give players based on game settings.
	int long = GetGameSetting_Int("long_tasks");
	int short = GetGameSetting_Int("short_tasks");
	int common = GetGameSetting_Int("common_tasks");

	//All players should get the same common tasks.
	int tasks[256] = {-1, ...};
	for (int i = 0; i < common; i++)
		tasks[i] = GetRandomTask(TASK_TYPE_COMMON);
	
	//Make sure that for new rounds, no tasks are completed so far from previous rounds.
	g_Match.tasks_goal = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;
		
		for (int x = 0; x < long; x++)
			AssignRandomTask(i, TASK_TYPE_LONG);
		
		for (int x = 0; x < short; x++)
			AssignRandomTask(i, TASK_TYPE_SHORT);
		
		for (int x = 0; x < common; x++)
			if (tasks[x] != -1)
				AssignTask(i, tasks[x]);
		
		if (g_Player[i].role != Role_Imposter)
			g_Match.tasks_goal += (long + short + common);
	}

	//Send the hud to all players.
	SendHudToAll();

	//Disable the misc hud elements that aren't needed during the match.
	//for (int i = 1; i <= MaxClients; i++)
	//	if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
	//		SetEntProp(i, Prop_Send, "m_iHideHUD", (1<<6));
}

public void Timer_OnFinished(const char[] output, int caller, int activator, float delay)
{
	OnMatchCompleted(TFTeam_Spectator);
}

public void Timer_OnSetupStart(const char[] output, int caller, int activator, float delay)
{
	GameRules_SetProp("m_bInSetup", true);

	//Respawn all players on the map on setup so they're in the lobby.
	TF2_RespawnAll();

	//Close and lock the doors during the lobby phase.
	TriggerRelay(RELAY_LOBBY_DOORS_CLOSE);
	TriggerRelay(RELAY_LOBBY_DOORS_LOCK);

	//Lock the meeting button so it can't be used during the lobby phase.
	TriggerRelay(RELAY_MEETING_BUTTON_LOCK);

	//Ensure that all clients are unmuted during the setup phase.
	UnmuteAllClients();

	//Lets find a random owner to start off the lobby.
	CreateTimer(2.0, Timer_PickRandomOwner, _, TIMER_FLAG_NO_MAPCHANGE);

	convar_Engine_RespawnWaveTime.IntValue = 1;
}

public void Timer_OnSetupFinished(const char[] output, int caller, int activator, float delay)
{
	GameRules_SetProp("m_bInSetup", false);

	//Unlock and open the doors whenever the lobby phase is finished.
	TriggerRelay(RELAY_LOBBY_DOORS_UNLOCK);
	TriggerRelay(RELAY_LOBBY_DOORS_OPEN);

	//Unlock the meeting button so it can be used during the round.
	TriggerRelay(RELAY_MEETING_BUTTON_UNLOCK);

	convar_Engine_RespawnWaveTime.IntValue = 999999;
}