#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include <csgocolors>
#include <soundlib>
#include <emitsoundany>
#include <prophunt>

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define PLUGIN_VERSION "1.0"

float g_fRegen[MAXPLAYERS + 1];
float g_fRegenBonus[MAXPLAYERS + 1];
float g_fBlockRegen[MAXPLAYERS + 1];

float g_fNextFearSound[MAXPLAYERS + 1];

char g_sndFear[255] = "phx/fear.mp3";
float g_fFearLength;

public Plugin myinfo = 
{
	name = "Prophunt - Fear",
	author = ".#Zipcore",
	description = "Overrides classic health manager with a regen system.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

ConVar g_cvSoundHealth;
ConVar g_cvMaxHealth;
ConVar g_cvBlockSuicide;
ConVar g_cvDecoyBlock;
ConVar g_cvSmokeBlock;
ConVar g_cvFireRegen;
ConVar g_cvDamageRegen;

ConVar g_cvBaseAMax;
ConVar g_cvBaseARegen;
ConVar g_cvBaseBMax;
ConVar g_cvBaseBRegen;
ConVar g_cvBaseCMax;
ConVar g_cvBaseCRegen;
	
ConVar g_cvBufferAMin;
ConVar g_cvBufferARegen;
ConVar g_cvBufferATake;
ConVar g_cvBufferBMin;
ConVar g_cvBufferBRegen;
ConVar g_cvBufferBTake;
ConVar g_cvBufferCMin;
ConVar g_cvBufferCRegen;
ConVar g_cvBufferCTake;

public void OnPluginStart()
{
	g_cvSoundHealth = CreateConVar("prophunt_fear_sound_health", "35", "Fear sound is emitted when health falls to or below this value.");
	g_cvMaxHealth = CreateConVar("prophunt_fear_max", "250", "Max health seekers can get by hp regen.");
	g_cvBlockSuicide = CreateConVar("prophunt_fear_block_suicide", "1", "If enabled seekers can't suicide by attacking.");
	g_cvDecoyBlock = CreateConVar("prophunt_fear_decoy_block", "5.0", "How long decoy daamge blocks hp regen.");
	g_cvSmokeBlock = CreateConVar("prophunt_fear_smoke_block", "3.0", "How long decoy daamge blocks hp regen.");
	g_cvFireRegen = CreateConVar("prophunt_fear_fire_regen", "1.0", "How much hp to add to regen buffer when damage is done by fire to hiders.");
	g_cvDamageRegen = CreateConVar("prophunt_fear_damage_regen", "3.0", "Damaged dealt to hiders will be mult. by this value and added to regen buffer.");
	
	g_cvBaseAMax = CreateConVar("prophunt_fear_base_regen_a_max", "100", "Use variant A when health is at below this amount.");
	g_cvBaseARegen = CreateConVar("prophunt_fear_base_regen_a_regen", "0.04", "Regen this amount of health (10 times a second).");
	g_cvBaseBMax = CreateConVar("prophunt_fear_base_regen_b_max", "50", "Use variant B when health is at below this amount.");
	g_cvBaseBRegen = CreateConVar("prophunt_fear_base_regen_b_regen", "0.1337", "Regen this amount of health (10 times a second).");
	g_cvBaseCMax = CreateConVar("prophunt_fear_base_regen_c_max", "25", "Use variant C when health is at below this amount.");
	g_cvBaseCRegen = CreateConVar("prophunt_fear_base_regen_c_regen", "0.25", "Regen this amount of health (10 times a second).");
	
	g_cvBufferAMin = CreateConVar("prophunt_fear_buffer_a_min", "25.0", "Use variant A when buffer is at least this size.");
	g_cvBufferARegen = CreateConVar("prophunt_fear_buffer_a_regen", "0.425", "Regen this amount of health (10 times a second).");
	g_cvBufferATake = CreateConVar("prophunt_fear_buffer_a_take", "1.0", "Decrease buffer by this amount.");
	g_cvBufferBMin = CreateConVar("prophunt_fear_buffer_b_min", "10.0", "Use variant B when buffer is at least this size.");
	g_cvBufferBRegen = CreateConVar("prophunt_fear_buffer_b_regen", "0.235", "Regen this amount of health (10 times a second).");
	g_cvBufferBTake = CreateConVar("prophunt_fear_buffer_b_take", "0.75", "Decrease buffer by this amount.");
	g_cvBufferCMin = CreateConVar("prophunt_fear_buffer_c_min", "0.1", "Use variant C when buffer is at least this size.");
	g_cvBufferCRegen = CreateConVar("prophunt_fear_buffer_c_regen", "0.1", "Regen this amount of health (10 times a second).");
	g_cvBufferCTake = CreateConVar("prophunt_fear_buffer_c_take", "0.1", "Decrease buffer by this amount.");
		
	AutoExecConfig(true, "prophunt-fear");
	
	LoopClients(iClient)
		ResetRegen(iClient);
}

public void OnMapStart()
{
	LoopClients(iClient)
		ResetRegen(iClient);
	
	PrepareSound(g_sndFear);
	g_fFearLength = GetSoundLengthEx(g_sndFear);
		
	CreateTimer(0.1, Timer_Regen, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public void OnClientPutInServer(int iClient)
{
	SDKHook(iClient, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

public void PH_OnHiderSpawn(int iClient)
{
	ResetRegen(iClient);
}

public void PH_OnSeekerSpawn(int iClient)
{
	ResetRegen(iClient);
}

public void PHX_OnDecoyHitSeeker(int seeker, int hider, int damage, float distance, int decoy)
{
	CheckFear(seeker, damage);
	BlockRegen(seeker, g_cvDecoyBlock.FloatValue);
}

public void PHX_OnSmokeHitSeeker(int seeker, int hider, int damage, float distance, int stack, int decoy)
{
	CheckFear(seeker, damage);
	BlockRegen(seeker, g_cvSmokeBlock.FloatValue);
}

public Action Hook_OnTakeDamage(int iClient, int &iAttacker, int &inflictor, float &damage, int &damagetype, int &iWeapon, float damageForce[3], float damagePosition[3])
{
	if(GetClientTeam(iClient) != CS_TEAM_T)
		return Plugin_Continue;
	
	
	if (damagetype & DMG_BURN && iAttacker > 0 && IsClientInGame(iAttacker) && GetClientTeam(iAttacker) == CS_TEAM_CT)
		AddBonusRegen(iAttacker, g_cvFireRegen.FloatValue);
	
	return Plugin_Continue;
}

public void PH_OnSeekerUseWeapon(int iSeeker, int iWeapon, int iWeaponType, int &iTakeHealth)
{
	CheckFear(iSeeker, iTakeHealth);
	
	if(g_cvBlockSuicide.BoolValue && GetClientHealth(iSeeker) - iTakeHealth < 1)
		iTakeHealth = 0; // Seekers don't die for attacking
}

public void PH_OnHiderHit(int iHider, int iSeeker, int iWeapon, bool bLethal, float &fDamage, int &iBonus, int &iTake)
{
	if(iBonus < iTake)
		iBonus = iTake;
	
	// Buff regeneration
	AddBonusRegen(iSeeker, float(iBonus - iTake) * g_cvDamageRegen.FloatValue);
	
	// Block HP manager of our core plugin
	iBonus = 0;
	iTake = 0;
}

void AddBonusRegen(int iClient, float fBonus)
{
	g_fRegenBonus[iClient] += fBonus;
}

public Action Timer_Regen(Handle timer, any data)
{
	LoopAlivePlayers(iClient)
	{
		if(GetClientTeam(iClient) != CS_TEAM_CT)
			continue;
		
		if(g_fBlockRegen[iClient] > GetGameTime())
			continue;
			
		int iHealth = GetClientHealth(iClient);
		int iHealthNew = iHealth;
		
		// Empty second regen buffer
		if(g_fRegenBonus[iClient] > g_cvBufferAMin.FloatValue)
		{
			g_fRegenBonus[iClient] -= g_cvBufferATake.FloatValue;
			g_fRegen[iClient] += g_cvBufferARegen.FloatValue;
		}
		else if(g_fRegenBonus[iClient] > g_cvBufferBMin.FloatValue)
		{
			g_fRegenBonus[iClient] -= g_cvBufferBTake.FloatValue;
			g_fRegen[iClient] += g_cvBufferBRegen.FloatValue;
		}
		else if(g_fRegenBonus[iClient] > g_cvBufferCMin.FloatValue)
		{
			g_fRegenBonus[iClient] -= g_cvBufferCTake.FloatValue;
			g_fRegen[iClient] += g_cvBufferCRegen.FloatValue;
		}

		// No health regen above this
		if (iHealth >= g_cvBaseAMax.IntValue && g_fRegenBonus[iClient] <= 0.0)
		{
			g_fRegen[iClient] = 0.0;
			continue;
		}
		
		// Basic Regen
		if(iHealth < g_cvBaseCMax.IntValue)
			g_fRegen[iClient] += g_cvBaseCRegen.FloatValue;
		else if(iHealth < g_cvBaseBMax.IntValue)
			g_fRegen[iClient] += g_cvBaseBRegen.FloatValue;
		else g_fRegen[iClient] += g_cvBaseARegen.FloatValue;
		
		while(g_fRegen[iClient] > 1.0)
		{
			g_fRegen[iClient] -= 1.0;
			iHealthNew += 1;
		}
		
		if(iHealthNew > g_cvMaxHealth.IntValue)
			iHealthNew = g_cvMaxHealth.IntValue;
		
		if(iHealthNew > iHealth)
			SetEntityHealth(iClient, iHealthNew);
		else(CheckFear(iClient, 0));
	}
	
	return Plugin_Continue;
}

void BlockRegen(int iClient, float fTime)
{
	float fBlockTime = GetGameTime() + fTime;
	
	if(g_fBlockRegen[iClient] < fBlockTime)
		g_fBlockRegen[iClient] = fBlockTime;
}

void CheckFear(int iClient, int iTakeHealth)
{
	int iNewHealth = GetClientHealth(iClient) - iTakeHealth;
	
	if(g_cvSoundHealth.FloatValue <= iNewHealth)
		return;
	
	// Dead af :D
	if(1 > iNewHealth)
		return;
	
	if(GetGameTime() < g_fNextFearSound[iClient])
		return;
	
	float fPos2[3];
	GetClientEyePosition(iClient, fPos2);
	PlaySoundWithSpeakerEx(iClient, g_sndFear, fPos2);
	
	// Cooldown
	g_fNextFearSound[iClient] = GetGameTime() + g_fFearLength + GetRandomFloat(2.0, 5.0);
}

void ResetRegen(int iClient)
{
	float time = GetGameTime();
	g_fNextFearSound[iClient] = time;
	g_fBlockRegen[iClient] = time;
	g_fRegen[iClient] = 0.0;
	g_fRegenBonus[iClient] = 0.0;
}

stock void PlaySoundWithSpeakerEx(int iClient, char[] soundPath, float fPos[3], int sndCh = SNDCHAN_AUTO, int sndLvl = SNDLEVEL_NORMAL, int sndFlags = SND_NOFLAGS, float sndVol = SNDVOL_NORMAL, int sndPitch = SNDPITCH_NORMAL)
{
	Handle hFile = OpenSoundFile(soundPath);
	
	if (hFile == null)
		return;
	
	float fLength = GetSoundLengthFloat(hFile)+1.0;
	
	delete hFile; 
	
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
		RemoveEntity(iEntity, ttl);
	}
	
	return iEntity;
}

stock void RemoveEntity(int iEntity, float time = 0.0)
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
	else LogMessage("File Not Found: %s", fileSound);
}

float GetSoundLengthEx(char[] path)
{
	Handle hFile = OpenSoundFile(path);
	float fLength = GetSoundLengthFloat(hFile);
	delete hFile;
	
	return fLength;
}