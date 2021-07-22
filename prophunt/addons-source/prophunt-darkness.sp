#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include <csgocolors>
#include <prophunt>

#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
	name = "Prophunt Darkness",
	author = ".#Zipcore",
	description = "Adds darkness effect which slowly becomes stronger during the round.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

ConVar g_cvFogEnable;

ConVar g_cvFogStartDistance1;
ConVar g_cvFogEndDistance1;
ConVar g_cvFogDensity1;

ConVar g_cvFogStartDistance2;
ConVar g_cvFogEndDistance2;
ConVar g_cvFogDensity2;

ConVar g_cvTime;
ConVar g_cvTimeWait;
ConVar g_cvFogUpdateInterval;

ConVar g_cvColor1[3];
ConVar g_cvColor2[3];

int g_iFogController = -1;

Handle g_hTimer_Fog = null;

float g_fFogStartDistance[MAXPLAYERS + 1];
float g_fFogEndDistance[MAXPLAYERS + 1];
float g_fFogDensity[MAXPLAYERS + 1];

float g_fFogStartDistanceStep[MAXPLAYERS + 1];
float g_fFogEndDistanceStep[MAXPLAYERS + 1];
float g_fFogDensityStep[MAXPLAYERS + 1];

float g_fFogStartTime[MAXPLAYERS + 1];
// bool g_bShowFog[MAXPLAYERS + 1] = false;

#define DARKNESS "Reset Darkness"

public void OnPluginStart()
{
	CreateConVar("ph_darkness_version", PLUGIN_VERSION, "Version of this plugin.");

	g_cvFogEnable = CreateConVar("ph_darkness_enable", "1", "Enables this plugin");

	g_cvFogStartDistance1 = CreateConVar("ph_darkness_start1", "800.0", "Default start distance");
	g_cvFogEndDistance1 = CreateConVar("ph_darkness_end1", "1400.0", "Default end distance");
	g_cvFogDensity1 = CreateConVar("ph_darkness_density1", "0.75", "Default density");

	g_cvFogStartDistance2 = CreateConVar("ph_darkness_start2", "275.0", "Min start distance");
	g_cvFogEndDistance2 = CreateConVar("ph_darkness_end2", "420.0", "Min end distance");
	g_cvFogDensity2 = CreateConVar("ph_darkness_density2", "0.9999", "Max density");

	g_cvTime = CreateConVar("ph_darkness_time", "100.0", "Duration until full effect strength is reached");
	g_cvTimeWait = CreateConVar("ph_darkness_time_wait", "120.0", "Time to wait before effect starts");
	g_cvFogUpdateInterval = CreateConVar("ph_darkness_update", "0.5", "How often to update the fog effect");

	g_cvColor1[0] = CreateConVar("ph_darkness_color1_r", "0", "Primary fog color red", _, true, 0.0, true, 255.0);
	g_cvColor1[1] = CreateConVar("ph_darkness_color1_g", "0", "Primary fog color green", _, true, 0.0, true, 255.0);
	g_cvColor1[2] = CreateConVar("ph_darkness_color1_b", "0", "Primary fog color blue", _, true, 0.0, true, 255.0);

	g_cvColor2[0] = CreateConVar("ph_darkness_color2_r", "0", "Secondary fog color red", _, true, 0.0, true, 255.0);
	g_cvColor2[1] = CreateConVar("ph_darkness_color2_g", "0", "Secondary fog color green", _, true, 0.0, true, 255.0);
	g_cvColor2[2] = CreateConVar("ph_darkness_color2_b", "0", "Secondary fog color blue", _, true, 0.0, true, 255.0);

	AutoExecConfig(true, "prophunt-darkness");

	HookEvent("round_start", Event_OnRoundStart);

	OnMapStart();
}

public void OnMapStart()
{
	if(g_hTimer_Fog != null)
	{
		delete g_hTimer_Fog;
		g_hTimer_Fog = null;
	}

	if (g_hTimer_Fog == null) {
		g_hTimer_Fog = CreateTimer(g_cvFogUpdateInterval.FloatValue, Timer_Fog, 0, TIMER_REPEAT);
	}
	PH_RegisterShopItem(DARKNESS, CS_TEAM_CT, 100, 3, 110, false);
}

public Action PH_OnBuyShopItem(int iClient, char[] sName, int &iPoints)
{
	if(StrEqual(sName, DARKNESS)) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void PH_OnBuyShopItemPost(int iClient, char[] sName, int iPoints)
{
	if(StrEqual(sName, DARKNESS)) {
		Fog_Start(iClient);
	}
}

// public void OnClientPutInServer(int iClient)
// {
// 	if (IsFakeClient(iClient)) {
// 		return;
// 	}

// 	if (IsClientSourceTV(iClient)) {
// 		return;
// 	}

// 	SDKHook(iClient, SDKHook_SetTransmit, Hook_SetTransmit);
// 	g_bShowFog[iClient] = false;
// }

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i, true)) {
			Fog_Start(i);
		}
	}

	return Plugin_Continue;
}

public Action Timer_Fog(Handle timer, any data)
{
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i, true)) {
			if (GetClientTeam(i) == CS_TEAM_CT) {
				Fog_Update(i);
			}
		}
	}

	return Plugin_Continue;
}

void Fog_Reset(int iClient)
{
	g_fFogStartDistance[iClient] = g_cvFogStartDistance1.FloatValue;
	g_fFogEndDistance[iClient] = g_cvFogEndDistance1.FloatValue;
	g_fFogDensity[iClient] = g_cvFogDensity1.FloatValue;

	Fog_Update(iClient);
}

void Fog_Start(int iClient)
{
	Fog_Reset(iClient);
	Fog_Update(iClient);

	// g_bShowFog[iClient] = false;
	g_fFogStartTime[iClient] = GetGameTime();

	g_fFogStartDistanceStep[iClient] = (g_cvFogUpdateInterval.FloatValue / g_cvTime.FloatValue) * (g_cvFogStartDistance1.FloatValue - g_cvFogStartDistance2.FloatValue);
	g_fFogEndDistanceStep[iClient] = (g_cvFogUpdateInterval.FloatValue / g_cvTime.FloatValue) * (g_cvFogEndDistance1.FloatValue - g_cvFogEndDistance2.FloatValue);
	g_fFogDensityStep[iClient] = (g_cvFogUpdateInterval.FloatValue / g_cvTime.FloatValue) * (g_cvFogDensity2.FloatValue - g_cvFogDensity1.FloatValue);
}

void Fog_Update(int iClient)
{
	if (!g_cvFogEnable.BoolValue) {
		return;
	}

	if (g_cvTimeWait.FloatValue < GetGameTime() - g_fFogStartTime[iClient]) {
		PrintToChatAll("Darkness Start");
		// if (g_bShowFog[iClient] == false) {
		// 	PrintToChatAll("Set ShowFog to True");
		// 	g_bShowFog[iClient] = true;
		// }
		// Start distance
		if(g_fFogStartDistance[iClient] > g_cvFogStartDistance2.FloatValue)
			g_fFogStartDistance[iClient] -= g_fFogStartDistanceStep[iClient];

		if(g_fFogStartDistance[iClient] < g_cvFogStartDistance2.FloatValue)
			g_fFogStartDistance[iClient] = g_cvFogStartDistance2.FloatValue;

		// End distance
		if(g_fFogEndDistance[iClient] > g_cvFogEndDistance2.FloatValue)
			g_fFogEndDistance[iClient] -= g_fFogEndDistanceStep[iClient];

		if(g_fFogEndDistance[iClient] < g_cvFogEndDistance2.FloatValue)
			g_fFogEndDistance[iClient] = g_cvFogEndDistance2.FloatValue;

		// Density
		if(g_fFogDensity[iClient] < g_cvFogDensity2.FloatValue)
			g_fFogDensity[iClient] += g_fFogDensityStep[iClient];

		if(g_fFogDensity[iClient] >= g_cvFogDensity2.FloatValue)
			g_fFogDensity[iClient] = g_cvFogDensity2.FloatValue;

		// Fog controller
		PrintToChatAll("Create Entity");

		g_iFogController = CreateEntityByName("env_fog_controller");
		if(IsValidEntity(g_iFogController))
		{
			AcceptEntityInput(g_iFogController, "kill");
			PrintToChatAll("Entity Valid / Updated");
			DispatchKeyValue(g_iFogController, "targetname", "personalFog");
			DispatchKeyValue(g_iFogController, "fogenable", "1");
			DispatchKeyValue(g_iFogController, "fogblend",  "0");
			DispatchKeyValue(g_iFogController, "spawnflags", "1");

			DispatchKeyValueFloat(g_iFogController, "fogstart", g_fFogStartDistance[iClient]);
			DispatchKeyValueFloat(g_iFogController, "fogend", g_fFogEndDistance[iClient]);
			DispatchKeyValueFloat(g_iFogController, "fogmaxdensity", g_fFogDensity[iClient]);

			char sColor[128];

			Format(sColor, sizeof(sColor), "%d %d %d", g_cvColor1[0].IntValue, g_cvColor1[1].IntValue, g_cvColor1[2].IntValue);
			DispatchKeyValue(g_iFogController, "fogcolor", sColor);

			Format(sColor, sizeof(sColor), "%d %d %d", g_cvColor2[0].IntValue, g_cvColor2[1].IntValue, g_cvColor2[2].IntValue);
			DispatchKeyValue(g_iFogController, "fogcolor2", sColor);

			DispatchSpawn(g_iFogController);

			AcceptEntityInput(g_iFogController, "TurnOn");
		}

		if (IsValidClient(iClient, true)) {
			if (GetClientTeam(iClient) == CS_TEAM_CT) {
				PrintToChatAll("Set to Client");
				SetVariantString("personalFog");
				AcceptEntityInput(iClient, "SetFogController");
			}
		}
	}
	// SDKHook(g_iFogController, SDKHook_SetTransmit, Hook_SetTransmit);
}

// public Action Hook_SetTransmit(int iEntity, int iClient)
// {
// 	if (GetEdictFlags(g_iFogController) & FL_EDICT_ALWAYS) {
// 		SetEdictFlags(g_iFogController, GetEdictFlags(g_iFogController) ^ FL_EDICT_ALWAYS);
// 	}

// 	if(g_bShowFog[iClient]) {
// 		return Plugin_Handled;
// 	}

// 	return Plugin_Continue;
// }

stock bool IsValidClient(int client, bool alive = false)
{
    return (0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)));
}