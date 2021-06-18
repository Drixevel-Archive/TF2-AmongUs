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

	char sName[128];
	GetEntPropString(target, Prop_Data, "m_iName", sName, sizeof(sName));

	if (strlen(sName) == 0)
	{
		Format(sName, sizeof(sName), "%s%i", sClassname, target);
		DispatchKeyValue(target, "targetname", sName);
	}
	else
	{
		Format(sName, sizeof(sName), "%s%i", sName, target);
		DispatchKeyValue(target, "targetname", sName);
	}

	int glow = CreateEntityByName("tf_glow");

	if (IsValidEntity(glow))
	{
		char sGlow[64];
		Format(sGlow, sizeof(sGlow), "%i %i %i %i", color[0], color[1], color[2], color[3]);

		DispatchKeyValue(glow, "target", sName);
		DispatchKeyValue(glow, "Mode", "1"); //Mode is currently broken.
		DispatchKeyValue(glow, "GlowColor", sGlow);
		DispatchSpawn(glow);
		
		SetVariantString("!activator");
		AcceptEntityInput(glow, "SetParent", target, glow);

		AcceptEntityInput(glow, "Enable");
	}

	return glow;
}

stock void TF2_ForceWin(TFTeam team = TFTeam_Unassigned)
{
	int flags = GetCommandFlags("mp_forcewin");
	SetCommandFlags("mp_forcewin", flags &= ~FCVAR_CHEAT);
	ServerCommand("mp_forcewin %i", view_as<int>(team));
	SetCommandFlags("mp_forcewin", flags);
}

#define RAG_GIBBED			(1<<0)
#define RAG_BURNING			(1<<1)
#define RAG_ELECTROCUTED	(1<<2)
#define RAG_FEIGNDEATH		(1<<3)
#define RAG_WASDISGUISED	(1<<4)
#define RAG_BECOMEASH		(1<<5)
#define RAG_ONGROUND		(1<<6)
#define RAG_CLOAKED			(1<<7)
#define RAG_GOLDEN			(1<<8)
#define RAG_ICE				(1<<9)
#define RAG_CRITONHARDCRIT	(1<<10)
#define RAG_HIGHVELOCITY	(1<<11)
#define RAG_NOHEAD			(1<<12)
#define RAG_NOTORSO			(1<<13)
#define RAG_NOHANDS			(1<<14)

stock int TF2_SpawnRagdoll(int client, float destruct = 10.0, int flags = 0, float vel[3] = NULL_VECTOR)
{
	int ragdoll = CreateEntityByName("tf_ragdoll");

	if (IsValidEntity(ragdoll))
	{
		float vecOrigin[3];
		GetClientAbsOrigin(client, vecOrigin);

		float vecAngles[3];
		GetClientAbsAngles(client, vecAngles);

		TeleportEntity(ragdoll, vecOrigin, vecAngles, NULL_VECTOR);

		//TODO: Figure out how to make ragdolls colored.
		//SetEntityRenderMode(ragdoll, RENDER_TRANSCOLOR);
		//SetEntityRenderColor(ragdoll, 255, 255, 255, 255);

		SetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex", client);
		SetEntProp(ragdoll, Prop_Send, "m_iTeam", GetClientTeam(client));
		SetEntProp(ragdoll, Prop_Send, "m_iClass", view_as<int>(TF2_GetPlayerClass(client)));
		SetEntProp(ragdoll, Prop_Send, "m_nForceBone", 1);
		SetEntProp(ragdoll, Prop_Send, "m_iDamageCustom", TF_CUSTOM_TAUNT_ENGINEER_SMASH);
		
		SetEntProp(ragdoll, Prop_Send, "m_bGib", (flags & RAG_GIBBED) == RAG_GIBBED);
		SetEntProp(ragdoll, Prop_Send, "m_bBurning", (flags & RAG_BURNING) == RAG_BURNING);
		SetEntProp(ragdoll, Prop_Send, "m_bElectrocuted", (flags & RAG_ELECTROCUTED) == RAG_ELECTROCUTED);
		SetEntProp(ragdoll, Prop_Send, "m_bFeignDeath", (flags & RAG_FEIGNDEATH) == RAG_FEIGNDEATH);
		SetEntProp(ragdoll, Prop_Send, "m_bWasDisguised", (flags & RAG_WASDISGUISED) == RAG_WASDISGUISED);
		SetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh", (flags & RAG_BECOMEASH) == RAG_BECOMEASH);
		SetEntProp(ragdoll, Prop_Send, "m_bOnGround", (flags & RAG_ONGROUND) == RAG_ONGROUND);
		SetEntProp(ragdoll, Prop_Send, "m_bCloaked", (flags & RAG_CLOAKED) == RAG_CLOAKED);
		SetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll", (flags & RAG_GOLDEN) == RAG_GOLDEN);
		SetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll", (flags & RAG_ICE) == RAG_ICE);
		SetEntProp(ragdoll, Prop_Send, "m_bCritOnHardHit", (flags & RAG_CRITONHARDCRIT) == RAG_CRITONHARDCRIT);
		
		SetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", vecOrigin);
		SetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", vel);
		SetEntPropVector(ragdoll, Prop_Send, "m_vecForce", vel);
		
		if ((flags & RAG_HIGHVELOCITY) == RAG_HIGHVELOCITY)
		{
			//from Rowedahelicon
			float HighVel[3];
			HighVel[0] = -180000.552734;
			HighVel[1] = -1800.552734;
			HighVel[2] = 800000.552734; //Muhahahahaha
			
			SetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", HighVel);
			SetEntPropVector(ragdoll, Prop_Send, "m_vecForce", HighVel);
		}
		
		//Makes sure the ragdoll isn't malformed on spawn.
		SetEntPropFloat(ragdoll, Prop_Send, "m_flHeadScale", (flags & RAG_NOHEAD) == RAG_NOHEAD ? 0.0 : 1.0);
		SetEntPropFloat(ragdoll, Prop_Send, "m_flTorsoScale", (flags & RAG_NOTORSO) == RAG_NOTORSO ? 0.0 : 1.0);
		SetEntPropFloat(ragdoll, Prop_Send, "m_flHandScale", (flags & RAG_NOHANDS) == RAG_NOHANDS ? 0.0 : 1.0);
		
		DispatchSpawn(ragdoll);
		ActivateEntity(ragdoll);
		
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ragdoll, 0);
		
		if (destruct > 0.0)
		{
			char output[64];
			Format(output, sizeof(output), "OnUser1 !self:kill::%.1f:1", destruct);

			SetVariantString(output);
			AcceptEntityInput(ragdoll, "AddOutput");
			AcceptEntityInput(ragdoll, "FireUser1");
		}
	}

	return ragdoll;
}

stock bool TF2_IsWaitingForPlayers()
{
	return view_as<bool>(GameRules_GetProp("m_bInWaitingForPlayers"));
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

		if (entity > MaxClients && g_GlowEnt[entity] > MaxClients)
			AcceptEntityInput(g_GlowEnt[entity], "Kill");

		g_GlowEnt[entity] = TF2_CreateGlow(entity, color);
	}
}

stock int GetRandomClient(bool ingame = true, bool alive = true, bool ignore_bots = true, int team = -1)
{
	int[] clients = new int[MaxClients];
	int amount;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (ingame && !IsClientInGame(i))
			continue;
		
		if (alive && !IsPlayerAlive(i))
			continue;

		if (ignore_bots && IsFakeClient(i))
			continue;

		if (team > -1 && team != GetClientTeam(i))
			continue;

		clients[amount++] = i;
	}
	
	if (amount < 1)
		return -1;

	return clients[GetRandomInt(0, amount - 1)];
}

stock int GetTotalPlayers()
{
	int count;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		count++;
	}

	return count;
}

stock int GetTotalAlivePlayers()
{
	int count;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		count++;
	}

	return count;
}

stock bool IsAdmin(int client)
{
	return CheckCommandAccess(client, "", ADMFLAG_GENERIC, true);
}

stock bool StopTimer(Handle& timer)
{
	if (timer != null)
	{
		KillTimer(timer);
		timer = null;
		return true;
	}

	return false;
}

stock float GetVotePercent(int votes, int totalVotes)
{
	return float(votes) / float(totalVotes);
}