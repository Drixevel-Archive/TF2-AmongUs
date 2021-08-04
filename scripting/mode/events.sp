/*****************************/
//Events

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);

	if (IsClientInGame(client) && IsPlayerAlive(client))
		EmitSoundToAll(SOUND_SPAWN, client);

	RemoveGhost(client);

	if (convar_TopDownView.BoolValue)
		CreateCamera(client);

	int entity = -1; float origin1[3]; float origin2[3]; float angles[3];
	while ((entity = FindEntityByClassname(entity, "info_player_teamspawn")) != -1)
	{
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin1);

		int count;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i))
			{
				GetClientAbsOrigin(i, origin2);

				if (GetVectorDistance(origin1, origin2) <= 50.0)
					count++;
			}
		}

		if (count < 1)
		{
			GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
			GetGroundCoordinates(origin1, origin1);
			TeleportEntity(client, origin1, angles, NULL_VECTOR);
		}
	}

	//Make sure they're not marked as ejected if they spawn or are respawned.
	g_Player[client].ejected = false;

	if (!IsFakeClient(client))	
		CreateTimer(0.2, Timer_SendHud, userid, TIMER_FLAG_NO_MAPCHANGE);

	TF2_EquipWeaponSlot(client, TFWeaponSlot_Melee);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Grenade);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Building);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);

	//If a player is joining the server and they don't have a color, make sure they do.
	if (g_Player[client].color == NO_COLOR)
		AssignColor(client);
	
	SetPlayerSpeed(client);
	SetColor(client, g_Player[client].color);

	//Make sure the HUD is active during the lobby phase.
	//SetEntProp(client, Prop_Send, "m_iHideHUD", TF2_IsInSetup() ? 0 : (1<<6));
}

public Action Event_OnPlayerDeathPre(Event event, const char[] name, bool dontBroadcast)
{	
	//Defaults to true so the killfeed is OFF.
	bool hidefeed = true;
	
	//Actively hide the feed from this specific client.
	event.BroadcastDisabled = hidefeed;
}

public void Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);

	if (convar_TopDownView.BoolValue)
		DestroyCamera(client);
	
	if (TF2_IsInSetup())
		return;
	
	//We wait 0.2 seconds here because it's required for the ragdoll to spawn after a player dies.
	CreateTimer(0.2, Timer_CreateDeadBody, userid, TIMER_FLAG_NO_MAPCHANGE);

	//We wait 0.2 seconds after the player dies to check who's alive and who's dead for round win conditions.
	CreateTimer(0.2, Timer_CheckAlivePlayers);

	//We respawn the player after a bit so we can set them as a ghost.
	CreateTimer(0.4, Timer_RespawnPlayer, userid, TIMER_FLAG_NO_MAPCHANGE);

	int attacker;
	if ((attacker = GetClientOfUserId(event.GetInt("attacker"))) > 0 && IsClientInGame(attacker) && IsPlayerAlive(attacker) && !IsFakeClient(attacker) && g_Player[attacker].role == Role_Imposter)
		EmitSoundToClient(attacker, SOUND_IMPOSTER_KILL);
}

public void Event_OnPostInventoryApplication(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	// TODO: The weapon still refreshes when you touch a resupply cabinet, happens naturally I guess.
	if (TF2_GetActiveSlot(client) != TFWeaponSlot_Melee)
		TF2_EquipWeaponSlot(client, TFWeaponSlot_Melee);
	
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Grenade);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Building);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);

	//broken attribute
	TF2Attrib_SetByName(client, "mod see enemy health", 1.0);

	//broken attribute
	int melee = -1;
	if ((melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee)) != -1)
		TF2Attrib_SetByName(melee, "mod see enemy health", 1.0);
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_BetweenRounds = false;

	//Parse all available tasks on the map.
	CreateTimer(0.2, Timer_ParseTasks, _, TIMER_FLAG_NO_MAPCHANGE);

	//Makes sure the lobby is locked whenever we're waiting for players to join.
	if (TF2_IsWaitingForPlayers())
	{
		//Close and lock the doors during the waiting period.
		TriggerRelay(RELAY_LOBBY_DOORS_CLOSE);
		TriggerRelay(RELAY_LOBBY_DOORS_LOCK);

		//Lock the meeting button so it can't be used during the waiting period.
		TriggerRelay(RELAY_MEETING_BUTTON_LOCK);

		return;
	}

	TF2_CreateTimer(convar_Time_Setup.IntValue, convar_Time_Round.IntValue);

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			SendHud(i);
}

public void Event_OnRoundWin(Event event, const char[] name, bool dontBroadcast)
{
	g_BetweenRounds = true;

	OnMatchCompleted(view_as<TFTeam>(event.GetInt("team")));
}

public Action Event_OnBroadcastAudio(Event event, const char[] name, bool dontBroadcast)
{
	char strAudio[40];
	event.GetString("sound", strAudio, sizeof(strAudio));

	if (strncmp(strAudio, "Game.Your", 9) == 0)
		return Plugin_Handled;
	else if(strcmp(strAudio, "Game.Stalemate") == 0)
		return Plugin_Handled;

	return Plugin_Continue;
}