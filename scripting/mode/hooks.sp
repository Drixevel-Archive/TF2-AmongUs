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
	
	if (g_Camera[client] != 0)
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);

		float ceiling[3];
		ceiling = pos;
		ceiling[2] += 64;
		ceiling[2] = GetCeilingCoordinates(client, ceiling);
		TeleportEntity(g_Camera[client], ceiling, NULL_VECTOR, NULL_VECTOR);
	}
	
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
			else
				TF2_SendKey(client, "Unknown Location");
		}
		else
			TF2_SendKey(client, "Unknown Location");
	}
	
	//Handle the ejection moving logic.
	//TODO: Make this use the actual map logic.
	if (g_Player[client].ejected)
	{
		float origin[3];
		GetClientAbsOrigin(client, origin);
		origin[0] -= 3.0;
		origin[2] += 0.1;

		float vecAngles[3];
		GetClientAbsAngles(client, vecAngles);
		RotateYaw(vecAngles, 10.0);

		TeleportEntity(client, origin, vecAngles, NULL_VECTOR);
	}

	//While scanning, we want to display a circle around them.
	if (g_Player[client].scanning)
	{
		float origin[3];
		GetClientAbsOrigin(client, origin);
		TF2_Particle("ping_circle", origin);
	}

	return Plugin_Continue;
}

public Action OnSetTransmit(int entity, int client)
{
	//If both players are dead then let them see each other.
	if (g_IsDead[entity] && g_IsDead[client])
		return Plugin_Continue;
	
	//If the player seeing the other player isn't dead but the other player is dead then stop the transmission.
	if (!g_IsDead[entity] && g_IsDead[client])
		return Plugin_Continue;
	
	//If the player seeing the other player is dead and the other player isn't dead then continue the transmission.
	if (g_IsDead[entity] && !g_IsDead[client])
		return Plugin_Stop;

	//Make sure if the checks above fail, we still let people be seen otherwise lag could happen.
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