#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include <csgocolors>
#include <prophunt>
#include <emitsoundany>
#include <soundlib>
#include <speedrules>

#define PLUGIN_VERSION "1.0"

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopIngameClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1))

#define LoopIngamePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && !IsFakeClient(%1))

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

public Plugin myinfo =
{
	name = "Prophunt - Smoke",
	author = ".#Zipcore",
	description = "Lets a hider emit poisonous smoke.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

ConVar g_cvPrice;
ConVar g_cvSort;
ConVar g_cvUnlock;
ConVar g_cvPoisonPrice;
ConVar g_cvPoisonSort;
ConVar g_cvPoisonUnlock;

ConVar g_cvRangeMin;
ConVar g_cvRangeMax;
ConVar g_cvRangeStackMax;

ConVar g_cvDamageMin;
ConVar g_cvDamageMax;

ConVar g_cvCoughSlow;
ConVar g_cvCoughSlowPriority;

ConVar g_cvInterval;

char g_sndSmokeEmit[255] = "phx/smoke_emit.mp3";

char g_sndCough[3][255] = {
	"phx/cough_0.mp3",
	"phx/cough_1.mp3",
	"phx/cough_2.mp3"
};

Handle g_OnSmokeHitSeeker;

float g_fCoughLength[3];

bool g_bSmokeUpgrade[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_OnSmokeHitSeeker = CreateGlobalForward("PH_OnSmokeHitSeeker", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell, Param_Cell);

	RegPluginLibrary("prophunt-smoke");

	return APLRes_Success;
}

public void OnPluginStart()
{
	g_cvPrice = CreateConVar("ph_smoke_price", "100", "Price for smoke effect.");
	g_cvSort = CreateConVar("ph_smoke_sort", "10", "Price for smoke effect.");
	g_cvUnlock = CreateConVar("ph_smoke_unlock", "50", "Price for smoke effect.");

	g_cvPoisonPrice = CreateConVar("ph_smoke_poison_price", "250", "Price to buy poisonous smoke upgrade.");
	g_cvPoisonSort = CreateConVar("ph_smoke_poison_sort", "3", "Price to buy poisonous smoke upgrade.");
	g_cvPoisonUnlock = CreateConVar("ph_smoke_poison_unlock", "90", "Price to buy poisonous smoke upgrade.");

	g_cvRangeMin = CreateConVar("ph_smoke_range_min", "160.0", ".");
	g_cvRangeMax = CreateConVar("ph_smoke_range_max", "280.0", ".");
	g_cvRangeStackMax = CreateConVar("ph_smoke_stack_max", "7", ".");

	g_cvDamageMin = CreateConVar("ph_smoke_damage_min", "1", "Min damage at max range.");
	g_cvDamageMax = CreateConVar("ph_smoke_damage_max", "7", "Max damage at min range or closer.");

	g_cvInterval = CreateConVar("ph_smoke_damage_min", "0.5", "Check interval for smoke damage.");

	g_cvCoughSlow = CreateConVar("ph_smoke_cough_slow", "0.3", "How much to slow during seeker cough.");
	g_cvCoughSlowPriority = CreateConVar("ph_smoke_cough_slow_priority", "10", "Priority used by speedrules.");

	AutoExecConfig(true, "prophunt-smoke");

	HookEvent("player_spawn", Event_OnPlayerSpawn);
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "prophunt"))
	{
		PH_RegisterShopItem("Smoke", CS_TEAM_T, g_cvPrice.IntValue, g_cvSort.IntValue, g_cvUnlock.IntValue, false);
		PH_RegisterShopItem("Poisonous Smoke Upgrade", CS_TEAM_T, g_cvPoisonPrice.IntValue, g_cvPoisonSort.IntValue, g_cvPoisonUnlock.IntValue, false);
	}
}

public void OnMapStart()
{
	PH_RegisterShopItem("Smoke", CS_TEAM_T, g_cvPrice.IntValue, g_cvSort.IntValue, g_cvUnlock.IntValue, false);
	PH_RegisterShopItem("Poisonous Smoke Upgrade", CS_TEAM_T, g_cvPoisonPrice.IntValue, g_cvPoisonSort.IntValue, g_cvPoisonUnlock.IntValue, false);

	PrepareSound(g_sndSmokeEmit);

	for (int i = 0; i < 3; i++)
	{
		PrepareSound(g_sndCough[i]);
		g_fCoughLength[i] = GetSoundLengthEx(g_sndCough[i]);
	}
}

public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

	g_bSmokeUpgrade[iClient] = false;

	return Plugin_Continue;
}

public Action PH_OnBuyShopItem(int iClient, char[] sName, int &iPoints)
{
	if(StrEqual(sName, "Smoke"))
		return Plugin_Handled;
	else if(StrEqual(sName, "Poisonous Smoke Upgrade"))
		return Plugin_Handled;

	return Plugin_Continue;
}

public void PH_OnBuyShopItemPost(int iClient, char[] sName, int iPoints)
{
	if(StrEqual(sName, "Smoke"))
	{
		SetSmoke(iClient, g_bSmokeUpgrade[iClient]);
	}
	else if(StrEqual(sName, "Poisonous Smoke Upgrade"))
	{
		g_bSmokeUpgrade[iClient] = true;
		PH_DisableShopItem("Poisonous Smoke Upgrade", iClient);
	}
}

bool SetSmoke(int iClient, bool dmg)
{
	float fPos[3];
	GetClientAbsOrigin(iClient, fPos);

	int iEntity = CreateEntityByName("light_dynamic");
	if (iEntity != -1)
	{
		char sBuffer[64];
		Format(sBuffer, sizeof(sBuffer), "smokelight_%d", iEntity);
		DispatchKeyValue(iEntity,"targetname", sBuffer);
		Format(sBuffer, sizeof(sBuffer), "%f %f %f", fPos[0], fPos[1], fPos[2]);
		DispatchKeyValue(iEntity, "origin", sBuffer);
		DispatchKeyValue(iEntity, "iEntity", "-90 0 0");
		DispatchKeyValue(iEntity, "pitch","-90");
		DispatchKeyValue(iEntity, "distance","256");
		DispatchKeyValue(iEntity, "spotlight_radius","0");
		DispatchKeyValue(iEntity, "brightness","0");
		DispatchKeyValue(iEntity, "style","6");
		DispatchKeyValue(iEntity, "spawnflags","1");
		DispatchSpawn(iEntity);
		AcceptEntityInput(iEntity, "DisableShadow");
		SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", iClient);

		TeleportEntity(iEntity, fPos, NULL_VECTOR, NULL_VECTOR);

		RemoveEntityEx(iEntity, 14.0);

		if(dmg)
			CreateTimer(g_cvInterval.FloatValue, Timer_CheckDamage, EntIndexToEntRef(iEntity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	EmitAmbientSoundAny(g_sndSmokeEmit, fPos, _, 120);

	fPos[2] += 16.0;
	CreateSmoke(fPos);

	return true;
}

int CreateSmoke(float fPos[3])
{
	int iEntity = CreateEntityByName("smokegrenade_projectile");
	TeleportEntity(iEntity, fPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iEntity);
	SetEntProp(iEntity, Prop_Send, "m_nSmokeEffectTickBegin", GetGameTickCount());
	RemoveEntityEx(iEntity, 0.1);

	return iEntity;
}

public Action Timer_CheckDamage(Handle timer, any entityref)
{
	int iEntity = EntRefToEntIndex(entityref);
	if(iEntity == INVALID_ENT_REFERENCE)
		return Plugin_Stop;

	// Don't do anything, if the client who's thrown the grenade left.
	int iClient = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
	if(!iClient)
		return Plugin_Stop;

	if(!Client_IsValid(iClient))
		return Plugin_Stop;

	static int iStack[MAXPLAYERS + 1];
	static int iNextSound[MAXPLAYERS + 1];

	int iCount;

	LoopClients(iTarget)
	{
		if(!IsClientInGame(iTarget) || !IsPlayerAlive(iTarget) || GetClientTeam(iTarget) != CS_TEAM_CT)
		{
			iStack[iTarget] = 0;
			iNextSound[iTarget] = 0;
			continue;
		}

		float fDistance = Entity_GetDistance(iEntity, iTarget);
		int iDmg = GetDamageByRange(fDistance, g_cvDamageMin.IntValue, g_cvDamageMax.IntValue, g_cvRangeMin.FloatValue, g_cvRangeMax.FloatValue);

		if(iDmg > 0)
			iStack[iTarget] += iDmg;
		else if(iStack[iTarget] > 0)
			iDmg = 1;

		if(iStack[iTarget] < 0)
		{
			iStack[iTarget] = 0;
			iNextSound[iTarget] = 0;
			continue;
		}

		if(iStack[iTarget] > g_cvRangeStackMax.IntValue)
			iStack[iTarget] = g_cvRangeStackMax.IntValue;

		iStack[iTarget]--;

		Call_StartForward(g_OnSmokeHitSeeker);
		Call_PushCell(iTarget);
		Call_PushCell(iClient);
		Call_PushCell(iDmg);
		Call_PushFloat(fDistance);
		Call_PushCell(iStack[iTarget]);
		Call_PushCell(iEntity);
		Call_Finish();

		DealDamage(iTarget, iDmg, iClient, DMG_POISON, "weapon_smokegrenade");

		int iTime = GetTime();

		if(iDmg > 0 && iNextSound[iTarget] < iTime)
		{
			int iRandom = GetRandomInt(0, 2);
			iNextSound[iTarget] = iTime + RoundToFloor(g_fCoughLength[iRandom]/2.0);

			if(g_cvCoughSlow.FloatValue > 0.0)
				SpeedRules_ClientAdd(iClient, "cough", SR_Sub, g_cvCoughSlow.FloatValue, g_fCoughLength[iRandom]/2.0, g_cvCoughSlowPriority.IntValue);

			float fPos[3];
			GetClientAbsOrigin(iTarget, fPos);
			fPos[2] += GetRandomFloat(0.1, 8.0);
			fPos[2] += GetRandomFloat(0.1, 8.0);
			fPos[2] += GetRandomFloat(0.1, 8.0);

			PlaySoundWithSpeakerEx(iTarget, g_sndCough[iRandom], fPos);

			iClient++;
		}
	}

	PH_GivePoints(iClient, float(iCount));

	return Plugin_Continue;
}

stock void RemoveEntityEx(int iEntity, float time = 0.0)
{
	if (time == 0.0)
	{
		if (IsValidEntity(iEntity))
		{
			char edictname[32];
			GetEdictClassname(iEntity, edictname, 32);

			if (!StrEqual(edictname, "player"))
				AcceptEntityInput(iEntity, "kill");
		}
	}
	else if(time > 0.0)
		CreateTimer(time, RemoveEntityTimer, EntIndexToEntRef(iEntity), TIMER_FLAG_NO_MAPCHANGE);
}

public Action RemoveEntityTimer(Handle Timer, any entityRef)
{
	int entity = EntRefToEntIndex(entityRef);
	if (entity != INVALID_ENT_REFERENCE)
		RemoveEntity(entity); // RemoveEntity(...) is capable of handling references

	return (Plugin_Stop);
}

stock int GetDamageByRange(float distance, int minDmg, int maxDmg, float startRange, float maxRange)
{
	if(distance > maxRange)
		return 0;

	if(distance < startRange)
		return maxDmg;

	int diffDmg = maxDmg - minDmg;

	if(diffDmg <= 0)
		return minDmg;

	return minDmg + RoundToFloor(float(diffDmg) * (1.0 - (distance - startRange) / (maxRange - startRange)));
}

stock void DealDamage(int nClientVictim, int nDamage, int nClientAttacker = 0, int nDamageType = DMG_GENERIC, char[] sWeapon = "")
{
	if(	nClientVictim > 0 &&
			IsValidEntity(nClientVictim) &&
			IsClientInGame(nClientVictim) &&
			IsPlayerAlive(nClientVictim) &&
			nDamage > 0)
	{
		int EntityPointHurt = CreateEntityByName("point_hurt");
		if(EntityPointHurt != 0)
		{
			char sDamage[16];
			IntToString(nDamage, sDamage, sizeof(sDamage));

			char sDamageType[32];
			IntToString(nDamageType, sDamageType, sizeof(sDamageType));

			DispatchKeyValue(nClientVictim,			"targetname",		"war3_hurtme");
			DispatchKeyValue(EntityPointHurt,		"DamageTarget",	"war3_hurtme");
			DispatchKeyValue(EntityPointHurt,		"Damage",				sDamage);
			DispatchKeyValue(EntityPointHurt,		"DamageType",		sDamageType);
			if(!StrEqual(sWeapon, ""))
				DispatchKeyValue(EntityPointHurt,	"classname",		sWeapon);
			DispatchSpawn(EntityPointHurt);
			AcceptEntityInput(EntityPointHurt,	"Hurt",					(nClientAttacker != 0) ? nClientAttacker : -1);
			DispatchKeyValue(EntityPointHurt,		"classname",		"point_hurt");
			DispatchKeyValue(nClientVictim,			"targetname",		"war3_donthurtme");

			RemoveEdict(EntityPointHurt);
		}
	}
}

stock void PlaySoundWithSpeakerEx(int iClient, char[] soundPath, float fPos[3], int sndCh = SNDCHAN_AUTO, int sndLvl = SNDLEVEL_NORMAL, int sndFlags = SND_NOFLAGS, float sndVol = SNDVOL_NORMAL, int sndPitch = SNDPITCH_NORMAL)
{
	float fLength = GetSoundLengthEx(soundPath) + 1.0;

	int iEntity = SpawnSpeakerEntity(fPos, fLength);

	if(iClient != 0)
	{
		char sClient[16];
		Format(sClient, 16, "client%d", iClient);
		DispatchKeyValue(iClient, "targetname", sClient);

		SetVariantString(sClient);
		AcceptEntityInput(iEntity, "SetParent", iEntity, iEntity, 0);
	}

	EmitSoundToAllAny(soundPath, iEntity, sndCh, sndLvl, sndFlags, sndVol, sndPitch, iEntity, fPos, NULL_VECTOR, true);
}

float GetSoundLengthEx(char[] path)
{
	Handle hFile = OpenSoundFile(path);

	float fLength;
	if(hFile != INVALID_HANDLE)
	{
		fLength = GetSoundLengthFloat(hFile);
		delete hFile;
	}

	return fLength;
}

stock int SpawnSpeakerEntity(float fPos[3], float ttl)
{
	int iEntity = CreateEntityByName("prop_physics_override");

	if(!IsModelPrecached("models/error.mdl"))
		PrecacheModel("models/error.mdl");
	SetEntityModel(iEntity, "models/error.mdl");
	SetEntityRenderMode(iEntity, RENDER_NONE);
	if(iEntity != -1)
	{
		TeleportEntity(iEntity, fPos, NULL_VECTOR, NULL_VECTOR);
		RemoveEntityEx(iEntity, ttl);
	}

	return iEntity;
}

stock void PrepareSound(char[] sound)
{
	char fileSound[PLATFORM_MAX_PATH];
	FormatEx(fileSound, PLATFORM_MAX_PATH, "sound/%s", sound);

	if (FileExists(fileSound, false))
	{
		PrecacheSoundAny(sound, true);
		AddFileToDownloadsTable(fileSound);
	}
	else if(FileExists(fileSound, true))
		PrecacheSound(sound, true);
	else LogMessage("PropHuntX-Demons: File Not Found: %s", fileSound);
}