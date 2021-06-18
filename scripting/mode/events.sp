/*****************************/
//Events

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

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
}

public void NextFrame_CreateDeadBody(any userid)
{
	int client;
	if ((client = GetClientOfUserId(userid)) > 0 && IsClientInGame(client) && IsPlayerAlive(client))
		TF2_SpawnRagdoll(client, 99999.0, RAG_NOHEAD | RAG_NOTORSO);
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

	CPrintToChatAll("Mode: Setting up Round...");
	TF2_CreateTimer(convar_Time_Setup.IntValue, convar_Time_Round.IntValue);

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			SendHud(i);
}