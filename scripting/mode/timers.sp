/*****************************/
//Timers

public Action Timer_OpenDoor(Handle timer, DataPack pack)
{
	pack.Reset();

	int locked = pack.ReadCell();
	int locked2 = pack.ReadCell();

	int entity = -1;

	if ((entity = EntRefToEntIndex(locked)) != -1)
		AcceptEntityInput(entity, "Unlock");
	
	entity = -1;
	if ((entity = EntRefToEntIndex(locked2)) != -1)
		AcceptEntityInput(entity, "Unlock");

	g_LockDoors = null;
	g_IsSabotageActive = false;
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
		SetEntityMoveType(client, MOVETYPE_WALK);
	}

	PrintHintText(client, "Task Completed.");
	g_Player[client].doingtask = null;

	return Plugin_Stop;
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
				CPrintToChatAll("{H1}%N {default}has been ejected! They were %s{default}an Imposter!", i, g_Player[i].role != Role_Imposter ? "{H2}NOT " : "");
			else
				CPrintToChatAll("{H1}%N {default}has been ejected!", i);
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
			SetEntityMoveType(i, MOVETYPE_WALK);

	MuteAllClients();

	AcceptEntityInput(g_FogController_Crewmates, "TurnOn");
	AcceptEntityInput(g_FogController_Imposters, "TurnOn");

	g_Match.meeting = null;
	return Plugin_Stop;
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

public Action Timer_ReactorTick(Handle timer, any data)
{
	g_ReactorsTime--;

	if (g_ReactorsTime > 0)
	{
		PrintHintTextToAll("Reactor Meltdown in %i", g_ReactorsTime);
		return Plugin_Continue;
	}

	ForceWin(true);

	g_ReactorStamp = -1;
	g_ReactorExclude = -1;
	g_ReactorsTime = 0;
	g_Reactors = null;

	g_IsSabotageActive = false;

	return Plugin_Stop;
}

public Action Timer_O2Tick(Handle timer, any data)
{
	g_O2Time--;

	if (g_O2Time > 0)
	{
		PrintHintTextToAll("O2 Depletion in %i", g_O2Time);
		return Plugin_Continue;
	}

	ForceWin(true);

	g_O2Time = 0;
	g_O2 = null;

	g_IsSabotageActive = false;

	return Plugin_Stop;
}

public Action Timer_SendHud(Handle timer, any data)
{
	int client;
	if ((client = GetClientOfUserId(data)) > 0 && IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
		SendHud(client);
}

public Action Timer_CreateDeadBody(Handle timer, any userid)
{
	int client;
	if ((client = GetClientOfUserId(userid)) > 0 && IsClientInGame(client))
	{
		TF2_SpawnRagdoll(client, 99999.0, RAG_NOHEAD | RAG_NOTORSO);
		
		//Cache their death location and allow it to be discovered.
		GetClientAbsOrigin(client, g_Player[client].deathorigin);
		g_Player[client].showdeath = true;
	}
}

public Action Timer_CheckAlivePlayers(Handle timer)
{
	if (TF2_IsInSetup())
		return Plugin_Continue;
	
	//Get the total amount of crewmates alive.
	int total_crewmates;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i) && g_Player[i].role != Role_Imposter && !g_IsDead[i])
			total_crewmates++;
	
	//If no crewmates are alive then end the round and make Imposters the winner.
	if (total_crewmates < 1)
	{
		ForceWin(true);
		CPrintToChatAll("Imposters are the only ones left, Imposters win!");
	}

	int total_imposters;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i) && g_Player[i].role == Role_Imposter && !g_IsDead[i])
			total_imposters++;
	
	//If no imposters are alive then end the round and make Crewmates the winner.
	if (total_crewmates == total_imposters)
	{
		ForceWin(true);
		CPrintToChatAll("There's an equal amount of crewmates to Imposters, Imposters win!");
	}
	else if (total_imposters < 1)
	{
		ForceWin();
		CPrintToChatAll("There are no more Imposters alive, Crewmates win!");
	}

	return Plugin_Continue;
}

public Action Timer_RespawnPlayer(Handle timer, any data)
{
	int client;
	if ((client = GetClientOfUserId(data)) > 0 && IsClientInGame(client) && !IsPlayerAlive(client))
	{
		TF2_RespawnPlayer(client);
		TeleportEntity(client, g_Player[client].deathorigin, NULL_VECTOR, NULL_VECTOR);
		SetGhost(client);
	}
}