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
	CPrintToChatAll("{H2}Lobby{default}: 5 Minutes Remaining");
}

public void Timer_On4MinRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 4 Minutes Remaining");
}

public void Timer_On3MinRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 3 Minutes Remaining");
}

public void Timer_On2MinRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 2 Minutes Remaining");
}

public void Timer_On1MinRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 1 Minute Remaining");
}

public void Timer_On30SecRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 30 Seconds Remaining");
}

public void Timer_On10SecRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 10 Seconds Remaining");
}

public void Timer_On5SecRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 5 Seconds Remaining");
}

public void Timer_On4SecRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 4 Seconds Remaining");
}

public void Timer_On3SecRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 3 Seconds Remaining");
}

public void Timer_On2SecRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 2 Seconds Remaining");
}

public void Timer_On1SecRemain(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H2}Lobby{default}: 1 Second Remaining");
}

public void Timer_OnRoundStart(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H1}Mode{default}: Round Started");

	g_Match.tasks_current = 0;

	/////
	//Setup glows for certain map entities.

	//Give tasks a certain glow.
	if (convar_Setting_ToggleTaskGlows.BoolValue)
		TF2_GlowEnts("*", view_as<int>({255, 255, 255, 200}), "task");
	
	//Assign random players as Imposter and other roles automatically.
	int amount = GetGameSetting_Int("imposters");
	int current;
	int total = GetTotalPlayers();

	//If there isn't enough players, lets make sure the while look doesn't timeout.
	if (amount > total)
		amount = total;
	
	while (amount >= current)
	{
		int client = GetRandomClient();
		g_Player[client].role = Role_Imposter;
		SendHud(client);
		CPrintToChat(client, "You are an IMPOSTER!");
		current++;
	}

	//Assign tasks automatically to players at the start of the round.

	int long = GetGameSetting_Int("long_tasks");
	int short = GetGameSetting_Int("short_tasks");
	int common = GetGameSetting_Int("common_tasks");

	int[] tasks = new int[common];
	for (int i = 0; i < common; i++)
		tasks[i] = GetRandomTask(TASK_TYPE_COMMON);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		for (int x = 0; x < long; x++)
			AssignRandomTask(i, TASK_TYPE_LONG);
		
		for (int x = 0; x < short; x++)
			AssignRandomTask(i, TASK_TYPE_SHORT);
		
		for (int x = 0; x < common; x++)
			AssignTask(i, tasks[i]);
		
		if (g_Player[i].role != Role_Imposter)
			g_Match.tasks_goal += (long + short + common);
	}

	SendHudToAll();

	//Make sure all clients are muted whenever the round starts.
	MuteAllClients();
}

public void Timer_OnFinished(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H1}Mode{default}: Round Finished");

	for (int i = 1; i <= MaxClients; i++)
		g_Player[i].ejected = false;
}

public void Timer_OnSetupStart(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H1}Mode{default}: Setup Started");

	//Respawn all players on the map on setup so they're in the lobby.
	TF2_RespawnAll();

	//Close and lock the doors during the lobby phase.
	TriggerRelay(RELAY_LOBBY_DOORS_CLOSE);
	TriggerRelay(RELAY_LOBBY_DOORS_LOCK);

	//Lock the meeting button so it can't be used during the lobby phase.
	TriggerRelay(RELAY_MEETING_BUTTON_LOCK);

	//Parse the available tasks on the map by parsing entity names and logic.
	ParseTasks();

	//Ensure that all clients are unmuted during the setup phase.
	UnmuteAllClients();
}

public void Timer_OnSetupFinished(const char[] output, int caller, int activator, float delay)
{
	CPrintToChatAll("{H1}Mode{default}: Setup Finished");

	//Unlock and open the doors whenever the lobby phase is finished.
	TriggerRelay(RELAY_LOBBY_DOORS_UNLOCK);
	TriggerRelay(RELAY_LOBBY_DOORS_OPEN);

	//Unlock the meeting button so it can be used during the round.
	TriggerRelay(RELAY_MEETING_BUTTON_UNLOCK);
}