#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include <csgocolors>
#include <prophunt>
#include <emitsoundany>
#include <speedrules>

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopIngameClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1))

#define LoopIngamePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && !IsFakeClient(%1))

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
	name = "Prophunt Ultimate",
	author = ".#Zipcore",
	description = "Transforms a hider into a demon.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

ConVar g_cvPrice1;
ConVar g_cvPrice2;
ConVar g_cvPrice3;
ConVar g_cvTime1;
ConVar g_cvTime2;
ConVar g_cvTime3;
ConVar g_cvUltimateHealth1;
ConVar g_cvUltimateHealth2;
ConVar g_cvUltimateHealth3;
ConVar g_cvUltimateHealthMax;
ConVar g_cvSpeedPriority;
ConVar g_cvSpeed1;
ConVar g_cvSpeed2;
ConVar g_cvSpeed3;

char g_sndUltimate[255] = "phx/ultimate.mp3";

#define MODEL_1 "models/player/custom_player/kodua/eliminator/eliminator.mdl"
#define MODEL_2 "models/player/custom_player/kodua/ffs/fev_failed_subj.mdl"
#define MODEL_3 "models/player/custom_player/kodua/doom2016/hellknight.mdl"

int g_iIsUltimate[MAXPLAYERS+1];

/* Offsets */
int g_oHelmet = -1;

public void OnPluginStart()
{
	g_oHelmet = FindSendPropInfo("CCSPlayer", "m_bHasHelmet");

	g_cvPrice1 = CreateConVar("ph_ultimate_price1", "0", "Price for hiders a Level 1 Demon.");
	g_cvPrice2 = CreateConVar("ph_ultimate_price2", "420", "Price for hiders a Level 2 Demon.");
	g_cvPrice3 = CreateConVar("ph_ultimate_price3", "666", "Price for hiders a Level 3 Demon.");
	g_cvTime1 = CreateConVar("ph_ultimate_unlock1", "180.0", "Time to wait before you can buy a Level 1 Demon.");
	g_cvTime2 = CreateConVar("ph_ultimate_unlock2", "185.0", "Time to wait before you can buy a Level 2 Demon.");
	g_cvTime3 = CreateConVar("ph_ultimate_unlock3", "190.0", "Time to wait before you can buy a Level 3 Demon.");
	g_cvUltimateHealth1 = CreateConVar("ph_ultimate_hp1", "100", "Give HP to this amound when transforming to a Level 1 Demon.");
	g_cvUltimateHealth2 = CreateConVar("ph_ultimate_hp2", "250", "Give HP to this amound when transforming to a Level 2 Demon.");
	g_cvUltimateHealth3 = CreateConVar("ph_ultimate_hp3", "250", "Give HP to this amound when transforming to a Level 3 Demon.");
	g_cvUltimateHealthMax = CreateConVar("ph_ultimate_hp_max", "500", "Max amount of HP a demon can have.");
	g_cvSpeedPriority = CreateConVar("ph_speed_priority", "10", "Priority used by speedrules.");
	g_cvSpeed1 = CreateConVar("ph_speed1", "1.1", "Base speed of a Level 1 Demon.");
	g_cvSpeed2 = CreateConVar("ph_speed2", "1.3", "Base speed of a Level 2 Demon.");
	g_cvSpeed3 = CreateConVar("ph_speed3", "1.5", "Base speed of a Level 3 Demon.");

	AutoExecConfig(true, "prophunt-ultimate");

	CreateTimer(0.5, Timer_Check, _ , TIMER_REPEAT);
}

public void PH_OnHiderSpawn(int iClient)
{
	g_iIsUltimate[iClient] = 0;

	if(!IsModelPrecached(MODEL_1))
		PrecacheModel(MODEL_1);
	SetEntityModel(iClient, MODEL_1); // Set player model already to ultimate model since he is invisible and can see his own shadow :3
}

public void PH_OnSeekerSpawn(int iClient)
{
	g_iIsUltimate[iClient] = 0;
}

public Action Timer_Check(Handle timer, any data)
{
	UpdateSeekerVision();

	return Plugin_Continue;
}

#define ULTIMATE_NAME_1 "Ultimate: Lvl. 1"
#define ULTIMATE_NAME_2 "Ultimate: Lvl. 2"
#define ULTIMATE_NAME_3 "Ultimate: Lvl. 3"

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "prophunt"))
	{
		PH_RegisterShopItem(ULTIMATE_NAME_3, CS_TEAM_T, g_cvPrice3.IntValue, 1, g_cvTime3.IntValue, false);
		PH_RegisterShopItem(ULTIMATE_NAME_2, CS_TEAM_T, g_cvPrice2.IntValue, 1, g_cvTime2.IntValue, false);
		PH_RegisterShopItem(ULTIMATE_NAME_1, CS_TEAM_T, g_cvPrice1.IntValue, 1, g_cvTime1.IntValue, false);
	}
}

public void OnMapStart()
{
	PH_RegisterShopItem(ULTIMATE_NAME_3, CS_TEAM_T, g_cvPrice3.IntValue, 1, g_cvTime3.IntValue, false);
	PH_RegisterShopItem(ULTIMATE_NAME_2, CS_TEAM_T, g_cvPrice2.IntValue, 1, g_cvTime2.IntValue, false);
	PH_RegisterShopItem(ULTIMATE_NAME_1, CS_TEAM_T, g_cvPrice1.IntValue, 1, g_cvTime1.IntValue, false);

	PrecacheModel(MODEL_1);
	PrecacheModel(MODEL_2);
	PrecacheModel(MODEL_3);

	PrepareSound(g_sndUltimate);
}

void DisableUltimateItems(int iClient)
{
	PH_DisableShopItem(ULTIMATE_NAME_1, iClient);
	PH_DisableShopItem(ULTIMATE_NAME_2, iClient);
	PH_DisableShopItem(ULTIMATE_NAME_3, iClient);
	PH_DisableShopItem("Heal", iClient);
	PH_DisableShopItem("Decoy", iClient);
	PH_DisableShopItem("Change Model (Random)", iClient);
	PH_DisableShopItem("Freeze Height Limit Upgrade", iClient);
}

public Action PH_OnBuyShopItem(int iClient, char[] sName, int &iPoints)
{
	if(StrEqual(sName, ULTIMATE_NAME_1))
		return Plugin_Handled;
	else if(StrEqual(sName, ULTIMATE_NAME_2))
		return Plugin_Handled;
	else if(StrEqual(sName, ULTIMATE_NAME_3))
		return Plugin_Handled;

	return Plugin_Continue;
}

public void PH_OnBuyShopItemPost(int iClient, char[] sName, int iPoints)
{
	if(StrEqual(sName, ULTIMATE_NAME_1))
		SetUltimate(iClient, 1)
	else if(StrEqual(sName, ULTIMATE_NAME_2))
		SetUltimate(iClient, 2);
	else if(StrEqual(sName, ULTIMATE_NAME_3))
		SetUltimate(iClient, 3);
}

bool SetUltimate(int iClient, int level)
{
	if (!IsPlayerAlive(iClient))
		return false;

	if(GetClientTeam(iClient) != CS_TEAM_T)
		return false;

	g_iIsUltimate[iClient] = level;

	DisableUltimateItems(iClient);

	SetEntityFlags(iClient, GetEntityFlags(iClient)  | FL_ONGROUND); // Fix lag animation

	if(level == 3)
		SetEntityModel(iClient, MODEL_3);
	else if(level == 2)
		SetEntityModel(iClient, MODEL_2);
	else SetEntityModel(iClient, MODEL_1);

	PH_DisableFakeProp(iClient);

	GivePlayerItem(iClient, "weapon_knife");
	GivePlayerItem(iClient, "item_assaultsuit");
	SetEntData(iClient, g_oHelmet, 1);

	int iHealth = GetClientHealth(iClient);
	int iNewHealth = iHealth;
	// Level 3
	if(level == 3)
	{
		iNewHealth += g_cvUltimateHealth3.IntValue;
		GivePlayerItem(iClient, "weapon_taser");
		SpeedRules_ClientAdd(iClient, "ulimate", SR_Base, g_cvSpeed3.FloatValue, -1.0, g_cvSpeedPriority.IntValue);
		SpeedRules_ClientAdd(iClient, "ulimate", SR_Max, g_cvSpeed3.FloatValue, -1.0, g_cvSpeedPriority.IntValue);
	}
	// Level 2
	else if(level == 2)
	{
		iNewHealth += g_cvUltimateHealth2.IntValue;
		SpeedRules_ClientAdd(iClient, "ulimate", SR_Base, g_cvSpeed2.FloatValue, -1.0, g_cvSpeedPriority.IntValue);
		SpeedRules_ClientAdd(iClient, "ulimate", SR_Max, g_cvSpeed2.FloatValue, -1.0, g_cvSpeedPriority.IntValue);
	}
	// Level 1
	else
	{
		iNewHealth += g_cvUltimateHealth1.IntValue;
		SpeedRules_ClientAdd(iClient, "ulimate", SR_Base, g_cvSpeed1.FloatValue, -1.0, g_cvSpeedPriority.IntValue);
		SpeedRules_ClientAdd(iClient, "ulimate", SR_Max, g_cvSpeed1.FloatValue, -1.0, g_cvSpeedPriority.IntValue);
	}

	if(iNewHealth > g_cvUltimateHealthMax.IntValue)
		iNewHealth = g_cvUltimateHealthMax.IntValue;

	SetEntityHealth(iClient, iNewHealth);

	EmitSoundToAllAny(g_sndUltimate, iClient, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS,  SNDVOL_NORMAL,  SNDPITCH_NORMAL, iClient, _,  NULL_VECTOR, true,  0.0);

	return true;
}

public Action PH_OnUpdateSpeed(int iClient, float &speedmul)
{
	if (iClient < 1 || iClient > MaxClients)
		return Plugin_Continue;

	speedmul = 1.5;
	return Plugin_Changed;
}

public Action PH_OnHiderFreeze(int iClient)
{
	// Stop hider from freezing while ultimate
	if(g_iIsUltimate[iClient] > 0)
		return Plugin_Stop;

	return Plugin_Continue;
}

public Action PH_OnTauntPre(int hider, float &soundln)
{
	if(g_iIsUltimate[hider] > 0)
		return Plugin_Stop;

	return Plugin_Continue;
}

public Action PH_OnForceTauntPre(int client, int hider, float &soundln)
{
	if(g_iIsUltimate[hider] > 0)
		return Plugin_Stop;

	return Plugin_Continue;
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

void UpdateSeekerVision()
{
	bool bUltimate;
	LoopAlivePlayers(iClient)
	{
		if(GetClientTeam(iClient) != CS_TEAM_T)
			continue;

		if(g_iIsUltimate[iClient] == 0)
			continue;

		bUltimate = true;
		break;
	}

	LoopIngameClients(iClient)
	{
		if(!IsPlayerAlive(iClient))
			continue;

		if(GetClientTeam(iClient) != CS_TEAM_CT)
			continue;

		/*
		// Ignore seekers in range of their own pentagram
		if(g_iPentagramState[iClient] == 6)
		{
			SetEntPropFloat(iClient, Prop_Send, "m_flDetectedByEnemySensorTime", 0.0);
			continue;
		}
		*/

		// If there is an ultimate give wallhack to all seekers which are not in range of their portal
		SetEntPropFloat(iClient, Prop_Send, "m_flDetectedByEnemySensorTime", !bUltimate ? 0.0 : GetGameTime() + 10.0);
	}
}