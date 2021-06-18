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

public Action Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
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