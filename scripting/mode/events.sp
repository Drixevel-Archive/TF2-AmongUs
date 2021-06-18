/*****************************/
//Events

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

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
		SendHud(client);

	TF2_EquipWeaponSlot(client, TFWeaponSlot_Melee);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Grenade);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Building);
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);

	//If a player is joining the server and they don't have a color, make sure they do.
	if (g_Player[client].color == NO_COLOR)
		AssignColor(client);
}

public Action Event_OnPlayerDeathPre(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	//Defaults to true so the killfeed is OFF.
	bool hidefeed = true;

	//Doesn't matter if people see the kill feed during the lobby phase or Imposters see the kill feed during the match.
	if (TF2_IsInSetup() || g_Player[attacker].role == Role_Imposter)
		hidefeed = false;
	
	//Actively hide the feed from this specific client.
	event.BroadcastDisabled = hidefeed;
}

public void Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	//We wait a frame here because it's required for the ragdoll to spawn after a player dies.
	RequestFrame(NextFrame_CreateDeadBody, event.GetInt("userid"));

	//Get the total amount of crewmates alive.
	int total_crewmates;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i) && g_Player[i].role != Role_Imposter)
			total_crewmates++;
	
	//If no crewmates are alive then end the round and make Imposters the winner.
	//if (total_crewmates < 1)
	//	TF2_ForceWin(TFTeam_Red);

	int total_imposters;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsPlayerAlive(i) && g_Player[i].role == Role_Imposter)
			total_imposters++;
	
	//If no imposters are alive then end the round and make Crewmates the winner.
	//if (total_imposters < 1)
	//	TF2_ForceWin(TFTeam_Blue);
}

public void NextFrame_CreateDeadBody(any userid)
{
	int client;
	if ((client = GetClientOfUserId(userid)) > 0 && IsClientInGame(client))
	{
		TF2_SpawnRagdoll(client, 99999.0, RAG_NOHEAD | RAG_NOTORSO);
		GetClientAbsOrigin(client, g_Player[client].deathorigin);
	}
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
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_BetweenRounds = false;

	//Parse the available tasks on the map by parsing entity names and logic.
	ParseTasks();

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

	CPrintToChatAll("{H1}Mode{default}: Setting up Round...");
	TF2_CreateTimer(convar_Time_Setup.IntValue, convar_Time_Round.IntValue);

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			SendHud(i);
}

public void Event_OnRoundWin(Event event, const char[] name, bool dontBroadcast)
{
	g_BetweenRounds = true;
}