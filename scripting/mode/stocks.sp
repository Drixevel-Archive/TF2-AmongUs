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
// stock void TF2_GlowEnts(const char[] classname, int color[4], const char[] name = "")
// {
// 	int entity = -1; char sName[64];
// 	while ((entity = FindEntityByClassname(entity, classname)) != -1)
// 	{
// 		if (strlen(name) > 0)
// 		{
// 			GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

// 			if (StrContains(sName, name, false) == -1)
// 				continue;
// 		}

// 		if (entity > MaxClients && g_GlowEnt[entity] > MaxClients)
// 			AcceptEntityInput(g_GlowEnt[entity], "Kill");

// 		g_GlowEnt[entity] = TF2_CreateGlow(entity, color);
// 	}
// }

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

stock void RotateYaw(float angles[3], float degree)
{
	float direction[3], normal[3];
	GetAngleVectors(angles, direction, NULL_VECTOR, normal);

	float sin = Sine(degree * 0.01745328);     // Pi/180
	float cos = Cosine(degree * 0.01745328);
	float a = normal[0] * sin;
	float b = normal[1] * sin;
	float c = normal[2] * sin;
	float x = direction[2] * b + direction[0] * cos - direction[1] * c;
	float y = direction[0] * c + direction[1] * cos - direction[2] * a;
	float z = direction[1] * a + direction[2] * cos - direction[0] * b;
	direction[0] = x; direction[1] = y; direction[2] = z;

	GetVectorAngles(direction, angles);

	float up[3];
	GetVectorVectors(direction, NULL_VECTOR, up);

	float roll = GetAngleBetweenVectors(up, normal, direction);
	angles[2] += roll;
}

stock float GetAngleBetweenVectors(const float vector1[3], const float vector2[3], const float direction[3])
{
	float direction_n[3];
	NormalizeVector(direction, direction_n);
	
	float vector1_n[3];
	NormalizeVector(vector1, vector1_n);
	
	float vector2_n[3];
	NormalizeVector(vector2, vector2_n);
	float degree = ArcCosine(GetVectorDotProduct(vector1_n, vector2_n)) * 57.29577951;   // 180/Pi
    
	float cross[3];
	GetVectorCrossProduct(vector1_n, vector2_n, cross);
	
	if (GetVectorDotProduct(cross, direction_n) < 0.0)
		degree *= -1.0;

	return degree;
}

stock void TF2_SetThirdPerson(int client)
{
	SetVariantInt(1);
	AcceptEntityInput(client, "SetForcedTauntCam");
}

stock void TF2_SetFirstPerson(int client)
{
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");
}

stock void TF2_HidePlayer(int client)
{
	SetEntityRenderMode(client, RENDER_NONE);

	int entity = -1;
	while((entity = FindEntityByClassname(entity, "tf_*")) != -1)
		if (HasEntProp(entity, Prop_Send, "m_hOwnerEntity") && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
			SetEntityRenderMode(entity, RENDER_NONE);
}

stock void TF2_ShowPlayer(int client)
{
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);

	int entity = -1;
	while((entity = FindEntityByClassname(entity, "tf_*")) != -1)
		if (HasEntProp(entity, Prop_Send, "m_hOwnerEntity") && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
			SetEntityRenderMode(entity, RENDER_NORMAL);
}

stock void TF2_Particle(char[] name, float origin[3], int entity = -1, float angles[3] = {0.0, 0.0, 0.0}, bool resetparticles = false)
{
	int tblidx = FindStringTable("ParticleEffectNames");

	char tmp[256];
	int stridx = INVALID_STRING_INDEX;

	for (int i = 0; i < GetStringTableNumStrings(tblidx); i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if (StrEqual(tmp, name, false))
		{
			stridx = i;
			break;
		}
	}

	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	TE_WriteNum("entindex", entity);
	TE_WriteNum("m_iAttachType", 5);
	TE_WriteNum("m_bResetParticles", resetparticles);
	TE_SendToAll();
}

stock int CreateParticle(const char[] name, float origin[3], float time = 0.0, float angles[3] = {0.0, 0.0, 0.0}, float offsets[3] = {0.0, 0.0, 0.0})
{
	if (strlen(name) == 0)
		return -1;

	origin[0] += offsets[0];
	origin[1] += offsets[1];
	origin[2] += offsets[2];

	int entity = CreateEntityByName("info_particle_system");

	if (IsValidEntity(entity))
	{
		DispatchKeyValueVector(entity, "origin", origin);
		DispatchKeyValueVector(entity, "angles", angles);
		DispatchKeyValue(entity, "effect_name", name);

		DispatchSpawn(entity);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "Start");

		if (time > 0.0)
		{
			char output[64];
			Format(output, sizeof(output), "OnUser1 !self:kill::%.1f:1", time);
			SetVariantString(output);
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser1");
		}
	}

	return entity;
}

stock bool GetGroundCoordinates(float start[3], float buffer[3], float distance = 0.0)
{
	Handle trace = TR_TraceRayFilterEx(start, view_as<float>({90.0, 0.0, 0.0}), MASK_SOLID_BRUSHONLY, RayType_Infinite, ___TraceEntityFilter_NoPlayers);

	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(buffer, trace);
		delete trace;
		
		return (distance > 0.0 && start[2] - buffer[2] > distance);
	}

	delete trace;
	return false;
}

float GetCeilingCoordinates(int target, float vecOrigin[3])
{
	float vecPos[3];
	Handle trace = TR_TraceRayFilterEx(vecOrigin, view_as<float>({-90.0, 0.0, 0.0}), CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, TraceEntityFilterPlayer, target);

	if (TR_DidHit(trace))
		TR_GetEndPosition(vecPos, trace);

	delete trace;
	return vecPos[2];
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask, any client)
{
    return !(entity == client);
}

public bool ___TraceEntityFilter_NoPlayers(int entity, int contentsMask, any data)
{
	return entity != data && entity > MaxClients;
}

stock void TF2_PlayDenySound(int client)
{
	EmitGameSoundToClient(client, "Player.DenyWeaponSelection");
}

stock void SendDenyMessage(int client, char[] format, any ...)
{
	TF2_PlayDenySound(client);

	char sBuffer[255];
	VFormat(sBuffer, sizeof(sBuffer), format, 3);

	CPrintToChat(client, sBuffer);
}

stock void TF2Attrib_ApplyMoveSpeedBonus(int client, float value)
{
	TF2Attrib_SetByName(client, "move speed bonus", 1.0 + value);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.0);
}

stock void TF2Attrib_RemoveMoveSpeedBonus(int client)
{
	TF2Attrib_RemoveByName(client, "move speed bonus");
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.0);
}

stock void TF2Attrib_ApplyMoveSpeedPenalty(int client, float value)
{
	TF2Attrib_SetByName(client, "move speed penalty", 1.0 - value);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.0);
}

stock void TF2Attrib_RemoveMoveSpeedPenalty(int client)
{
	TF2Attrib_RemoveByName(client, "move speed penalty");
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.0);
}

stock bool ChangeClientTeam_Alive(int client, int team)
{
	if (client == 0 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) || team < 2 || team > 3)
		return false;

	int lifestate = GetEntProp(client, Prop_Send, "m_lifeState");
	SetEntProp(client, Prop_Send, "m_lifeState", 2);
	ChangeClientTeam(client, team);
	SetEntProp(client, Prop_Send, "m_lifeState", lifestate);
	
	return true;
}

stock void TF2_SendKey(int client, const char[] buffer, any...)
{
	char sBuffer[253];
	VFormat(sBuffer, sizeof(sBuffer), buffer, 3);

	Handle hint = StartMessageOne("KeyHintText", client);
	BfWriteByte(hint, 1);
	BfWriteString(hint, sBuffer);
	EndMessage();
}

stock int GetMenuInt(Menu menu, const char[] id, int defaultvalue = 0)
{
	char info[128]; char data[128];
	for (int i = 0; i < menu.ItemCount; i++)
		if (menu.GetItem(i, info, sizeof(info), _, data, sizeof(data)) && StrEqual(info, id))
			return StringToInt(data);
	
	return defaultvalue;
}

stock bool PushMenuInt(Menu menu, const char[] id, int value)
{
	char sBuffer[128];
	IntToString(value, sBuffer, sizeof(sBuffer));
	return menu.AddItem(id, sBuffer, ITEMDRAW_IGNORE);
}

enum TF2Quality {
	TF2Quality_Normal = 0, // 0
	TF2Quality_Rarity1,
	TF2Quality_Genuine = 1,
	TF2Quality_Rarity2,
	TF2Quality_Vintage,
	TF2Quality_Rarity3,
	TF2Quality_Rarity4,
	TF2Quality_Unusual = 5,
	TF2Quality_Unique,
	TF2Quality_Community,
	TF2Quality_Developer,
	TF2Quality_Selfmade,
	TF2Quality_Customized, // 10
	TF2Quality_Strange,
	TF2Quality_Completed,
	TF2Quality_Haunted,
	TF2Quality_ToborA
};

stock int TF2_GiveItem(int client, char[] classname, int index, TF2Quality quality = TF2Quality_Normal, int level = 0, const char[] attributes = "")
{
	char sClass[64];
	strcopy(sClass, sizeof(sClass), classname);
	
	if (StrContains(sClass, "saxxy", false) != -1)
	{
		switch (TF2_GetPlayerClass(client))
		{
			case TFClass_Scout: strcopy(sClass, sizeof(sClass), "tf_weapon_bat");
			case TFClass_Sniper: strcopy(sClass, sizeof(sClass), "tf_weapon_club");
			case TFClass_Soldier: strcopy(sClass, sizeof(sClass), "tf_weapon_shovel");
			case TFClass_DemoMan: strcopy(sClass, sizeof(sClass), "tf_weapon_bottle");
			case TFClass_Engineer: strcopy(sClass, sizeof(sClass), "tf_weapon_wrench");
			case TFClass_Pyro: strcopy(sClass, sizeof(sClass), "tf_weapon_fireaxe");
			case TFClass_Heavy: strcopy(sClass, sizeof(sClass), "tf_weapon_fists");
			case TFClass_Spy: strcopy(sClass, sizeof(sClass), "tf_weapon_knife");
			case TFClass_Medic: strcopy(sClass, sizeof(sClass), "tf_weapon_bonesaw");
		}
	}
	else if (StrContains(sClass, "shotgun", false) != -1)
	{
		switch (TF2_GetPlayerClass(client))
		{
			case TFClass_Soldier: strcopy(sClass, sizeof(sClass), "tf_weapon_shotgun_soldier");
			case TFClass_Pyro: strcopy(sClass, sizeof(sClass), "tf_weapon_shotgun_pyro");
			case TFClass_Heavy: strcopy(sClass, sizeof(sClass), "tf_weapon_shotgun_hwg");
			case TFClass_Engineer: strcopy(sClass, sizeof(sClass), "tf_weapon_shotgun_primary");
		}
	}
	
	Handle item = TF2Items_CreateItem(PRESERVE_ATTRIBUTES | FORCE_GENERATION);	//Keep reserve attributes otherwise random issues will occur... including crashes.
	TF2Items_SetClassname(item, sClass);
	TF2Items_SetItemIndex(item, index);
	TF2Items_SetQuality(item, view_as<int>(quality));
	TF2Items_SetLevel(item, level);
	
	char sAttrs[32][32];
	int count = ExplodeString(attributes, " ; ", sAttrs, 32, 32);
	
	if (count > 1)
	{
		TF2Items_SetNumAttributes(item, count / 2);
		
		int i2;
		for (int i = 0; i < count; i += 2)
		{
			TF2Items_SetAttribute(item, i2, StringToInt(sAttrs[i]), StringToFloat(sAttrs[i + 1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(item, 0);

	int weapon = TF2Items_GiveNamedItem(client, item);
	delete item;
	
	if (StrEqual(sClass, "tf_weapon_builder", false) || StrEqual(sClass, "tf_weapon_sapper", false))
	{
		SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
		SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
	}
	
	if (StrContains(sClass, "tf_weapon_", false) == 0)
		EquipPlayerWeapon(client, weapon);
	
	return weapon;
}

stock int GetActiveWeaponIndex(int client)
{
	if (client == 0 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) || !HasEntProp(client, Prop_Send, "m_hActiveWeapon"))
		return -1;
	
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if (!IsValidEntity(weapon))
		return -1;
	
	return GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
}

stock void StripCharactersPre(char[] buffer, int size, int position)
{
	strcopy(buffer, size, buffer[position]);
}

stock void StripCharactersPost(char[] buffer, int position)
{
	buffer[position] = '\0';
}

stock int FindEntityByName(const char[] name, const char[] classname = "*")
{
	int entity = -1; char temp[256];
	while ((entity = FindEntityByClassname(entity, classname)) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", temp, sizeof(temp));
		
		if (StrEqual(temp, name, false))
			return entity;
	}
	
	return entity;
}

stock void HandleSound(const char[] sound, bool download = true)
{
	PrecacheSound(sound);

	if (!download)
		return;

	char sDownload[PLATFORM_MAX_PATH];
	FormatEx(sDownload, sizeof(sDownload), "sound/%s", sound);

	AddFileToDownloadsTable(sDownload);
}
stock void ScreenFadeAll(int duration = 4, int hold_time = 4, int flag = FFADE_IN, int colors[4] = {255, 255, 255, 255}, bool reliable = true)
{
	bool pb = GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf;
	Handle userMessage;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
			continue;
		
		userMessage = StartMessageOne("Fade", i, (reliable ? USERMSG_RELIABLE : 0));

		if (userMessage == null)
			continue;

		if (pb)
		{
			PbSetInt(userMessage, "duration", duration);
			PbSetInt(userMessage, "hold_time", hold_time);
			PbSetInt(userMessage, "flags", flag);
			PbSetColor(userMessage, "clr", colors);
		}
		else
		{
			BfWriteShort(userMessage, duration);
			BfWriteShort(userMessage, hold_time);
			BfWriteShort(userMessage, flag);
			BfWriteByte(userMessage, colors[0]);
			BfWriteByte(userMessage, colors[1]);
			BfWriteByte(userMessage, colors[2]);
			BfWriteByte(userMessage, colors[3]);
		}
		
		EndMessage();
	}
}