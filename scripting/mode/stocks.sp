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

stock void TF2_RespawnAll()
{
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && TF2_GetClientTeam(i) > TFTeam_Spectator)
			TF2_RespawnPlayer(i);
}

stock int TF2_CreateGlow(int target, int color[4] = {255, 255, 255, 255})
{
	char sClassname[64];
	GetEntityClassname(target, sClassname, sizeof(sClassname));

	char sTarget[128];
	Format(sTarget, sizeof(sTarget), "%s%i", sClassname, target);
	DispatchKeyValue(target, "targetname", sTarget);

	int glow = CreateEntityByName("tf_glow");

	if (IsValidEntity(glow))
	{
		char sGlow[64];
		Format(sGlow, sizeof(sGlow), "%i %i %i %i", color[0], color[1], color[2], color[3]);

		DispatchKeyValue(glow, "target", sTarget);
		DispatchKeyValue(glow, "Mode", "1"); //Mode is currently broken.
		DispatchKeyValue(glow, "GlowColor", sGlow);
		DispatchSpawn(glow);
		
		SetVariantString("!activator");
		AcceptEntityInput(glow, "SetParent", target, glow);

		AcceptEntityInput(glow, "Enable");
	}

	return glow;
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

//TODO: This can be a better name.
stock void TF2_GlowEnts(const char[] classname, int color[4], const char[] name = "")
{
	int entity = -1; char sName[64];
	while ((entity = FindEntityByClassname(entity, classname)) != -1)
	{
		if (strlen(name) > 0)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

			if (StrContains(sName, name, false) == -1)
				continue;
		}

		TF2_CreateGlow(entity, color);
	}
}