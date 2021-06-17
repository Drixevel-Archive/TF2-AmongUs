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