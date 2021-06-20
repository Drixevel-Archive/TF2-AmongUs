/*****************************/
//Hooks

/////
//OnTakeDamage
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	damage = 0.0;
	return Plugin_Changed;
}

public void OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{

}

public Action OnPreThink(int client)
{
	if (!IsClientInGame(client))
		return Plugin_Continue;
	
	if (IsPlayerAlive(client) && NavMesh_Exists())
	{
		float origin[3];
		GetClientAbsOrigin(client, origin);

		CNavArea area = NavMesh_GetNearestArea(origin, true, 10000.0, false, true, -2);

		if (area != INVALID_NAV_AREA)
		{
			char sID[16];
			IntToString(area.ID, sID, sizeof(sID));

			char sName[64];
			g_AreaNames.GetString(sID, sName, sizeof(sName));

			if (strlen(sName) > 0)
				TF2_SendKey(client, sName);
		}
		else
			TF2_SendKey(client, "Unknown Location");
	}

	return Plugin_Continue;
}

public Action OnEntitySpawn(int entity)
{
	char classname[32];
	GetEntityClassname(entity, classname, sizeof(classname));

	if (g_CleanEntities.FindString(classname) != -1)
		return Plugin_Stop;
	
	return Plugin_Continue;
}