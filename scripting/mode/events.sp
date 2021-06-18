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