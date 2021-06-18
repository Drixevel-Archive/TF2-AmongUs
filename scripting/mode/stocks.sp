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

stock bool TriggerRelay(const char[] name)
{
	return TriggerEntity(name, "logic_relay");
}

stock bool TriggerEntity(const char[] name, const char[] classname)
{
	int entity = -1; char sName[256]; bool triggered;
	while ((entity = FindEntityByClassname(entity, classname)) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));
		
		if (StrEqual(sName, name, false))
		{
			AcceptEntityInput(entity, "Trigger");
			triggered = true;
		}
	}
	
	return triggered;
}