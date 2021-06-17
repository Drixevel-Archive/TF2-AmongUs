/*****************************/
//Stocks

stock void TF2_EquipWeaponSlot(int client, int slot = TFWeaponSlot_Primary)
{
	int weapon = -1;
	if ((weapon = GetPlayerWeaponSlot(client, slot)) != -1)
	{
		char sEntity[64];
		GetEntityClassname(weapon, sEntity, sizeof(sEntity));
		FakeClientCommand(client, "use %s", sEntity);
	}
}

stock int TF2_GetActiveSlot(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if (!IsValidEntity(weapon))
		return -1;
	
	for (int i = 0; i < 5; i++)
		if (GetPlayerWeaponSlot(client, i) == weapon)
			return i;

	return -1;
}