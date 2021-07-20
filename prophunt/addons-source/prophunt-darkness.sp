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

float g_fFogStartDistance;
float g_fFogEndDistance;
float g_fFogDensity;

float g_fFogStartDistanceStep;
float g_fFogEndDistanceStep;
float g_fFogDensityStep;

float g_fFogStartTime;

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

	Fog_Start();
}

public void OnMapStart()
{
	Fog_Reset();
	Fog_Start();
	PH_RegisterShopItem("Reset Darkness", CS_TEAM_CT, 100, 3, 110, false);
}

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	Fog_Start();

	return Plugin_Continue;
}

public Action Timer_Fog(Handle timer, any data)
{
	Fog_Update();

	return Plugin_Continue;
}

void Fog_Reset()
{
	g_fFogStartDistance = g_cvFogStartDistance1.FloatValue;
	g_fFogEndDistance = g_cvFogEndDistance1.FloatValue;
	g_fFogDensity = g_cvFogDensity1.FloatValue;

	Fog_Update();

	if(g_hTimer_Fog != null)
	{
		delete g_hTimer_Fog;
		g_hTimer_Fog = null;
	}
}

void Fog_Start()
{
	Fog_Reset();
	Fog_Update();

	g_fFogStartTime = GetGameTime();

	g_hTimer_Fog = CreateTimer(g_cvFogUpdateInterval.FloatValue, Timer_Fog, 0, TIMER_REPEAT);

	g_fFogStartDistanceStep = (g_cvFogUpdateInterval.FloatValue / g_cvTime.FloatValue) * (g_cvFogStartDistance1.FloatValue - g_cvFogStartDistance2.FloatValue);
	g_fFogEndDistanceStep = (g_cvFogUpdateInterval.FloatValue / g_cvTime.FloatValue) * (g_cvFogEndDistance1.FloatValue - g_cvFogEndDistance2.FloatValue);
	g_fFogDensityStep = (g_cvFogUpdateInterval.FloatValue / g_cvTime.FloatValue) * (g_cvFogDensity2.FloatValue - g_cvFogDensity1.FloatValue);
}

void Fog_Update()
{
	g_iFogController = FindEntityByClassname(-1, "env_fog_controller");

	if(g_cvTimeWait.FloatValue < GetGameTime() - g_fFogStartTime)
	{
		// Start distance
		if(g_fFogStartDistance > g_cvFogStartDistance2.FloatValue)
			g_fFogStartDistance -= g_fFogStartDistanceStep;

		if(g_fFogStartDistance < g_cvFogStartDistance2.FloatValue)
			g_fFogStartDistance = g_cvFogStartDistance2.FloatValue;

		// End distance
		if(g_fFogEndDistance > g_cvFogEndDistance2.FloatValue)
			g_fFogEndDistance -= g_fFogEndDistanceStep;

		if(g_fFogEndDistance < g_cvFogEndDistance2.FloatValue)
			g_fFogEndDistance = g_cvFogEndDistance2.FloatValue;

		// Density
		if(g_fFogDensity < g_cvFogDensity2.FloatValue)
			g_fFogDensity += g_fFogDensityStep;

		if(g_fFogDensity >= g_cvFogDensity2.FloatValue)
			g_fFogDensity = g_cvFogDensity2.FloatValue;
	}

	if(!g_cvFogEnable.BoolValue)
		return;

	// Fog controller

	if(g_iFogController != -1)
	{
		DispatchKeyValue(g_iFogController, "fogenable", "1");
		DispatchKeyValue(g_iFogController, "fogblend",  "0");

		DispatchKeyValueFloat(g_iFogController, "fogstart", g_fFogStartDistance);
		DispatchKeyValueFloat(g_iFogController, "fogend", g_fFogEndDistance);
		DispatchKeyValueFloat(g_iFogController, "fogmaxdensity", g_fFogDensity);

		char sColor[128];

		Format(sColor, sizeof(sColor), "%d %d %d", g_cvColor1[0].IntValue, g_cvColor1[1].IntValue, g_cvColor1[2].IntValue);
		DispatchKeyValue(g_iFogController, "fogcolor", sColor);

		Format(sColor, sizeof(sColor), "%d %d %d", g_cvColor2[0].IntValue, g_cvColor2[1].IntValue, g_cvColor2[2].IntValue);
		DispatchKeyValue(g_iFogController, "fogcolor2", sColor);

		AcceptEntityInput(g_iFogController, "TurnOn");
	}
}