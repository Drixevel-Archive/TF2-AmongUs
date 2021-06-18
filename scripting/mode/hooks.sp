/*****************************/
//Hooks

/////
//OnTakeDamage
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{

	return Plugin_Continue;
}

public void OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{

}

public Action OnEntitySpawn(int entity)
{
	char classname[32];
	GetEntityClassname(entity, classname, sizeof(classname));

	if (g_CleanEntities.FindString(classname) != -1)
		return Plugin_Stop;
	
	return Plugin_Continue;
}