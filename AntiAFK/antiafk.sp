/* SM Includes */
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <csgocolors>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.1"
#define UPDATE_URL "https://sys.froidgaming.net/AntiAFK/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[Anti-AFK] Core",
	author = "FroidGaming.net",
	description = "Anti-AFK.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	g_cvCheckInterval = CreateConVar("afk_check_interval", "1.0", "Check interval");
	g_cvBeaconInterval = CreateConVar("afk_beacon_interval", "2.0", "Beacon interval");
	g_cvSlapInterval = CreateConVar("afk_slap_interval", "2.5", "Slap interval");

	g_cvAfkState[0] = CreateConVar("afk_state_1", "8.0", "Amount of time the player was not moving to enable AFK state 1");
	g_cvAfkState[1] = CreateConVar("afk_state_2", "14.0", "Amount of time the player was not moving to enable AFK state 2");
	g_cvAfkState[2] = CreateConVar("afk_state_3", "16.0", "Amount of time the player was not moving to enable AFK state 3");
	g_cvAfkState[3] = CreateConVar("afk_state_4", "20.0", "Amount of time the player was not moving to enable AFK state 4");

	g_cvSlap[0] = CreateConVar("afk_slap_1", "-1", "Amount of damage to deal for being afk state 1 (-1: Do nothing; 0: Effect only)");
	g_cvSlap[1] = CreateConVar("afk_slap_2", "-1", "Amount of damage to deal for being afk state 2 (-1: Do nothing; 0: Effect only)");
	g_cvSlap[2] = CreateConVar("afk_slap_3", "-1", "Amount of damage to deal for being afk state 3 (-1: Do nothing; 0: Effect only)");
	g_cvSlap[3] = CreateConVar("afk_slap_4", "-1", "Amount of damage to deal for being afk state 4 (-1: Do nothing; 0: Effect only)");

	g_cvIgnite = CreateConVar("afk_ignite", "0", "Min afk state to enable ignite (0: Disabled; 1 to 4)");
	g_cvBeacon = CreateConVar("afk_beacon", "0", "Min afk state to enable beacon (0: Disabled; 1 to 4)");
	g_cvDropBomb = CreateConVar("afk_drop_bomb", "1", "AFK state from where to drop bomb (0: Disabled; 1 to 4)");

	g_cvMidgame = CreateConVar("afk_midgame", "30.0", "Time from freezetime end to enable afk_midgame_multi");
	g_cvMidgameMult = CreateConVar("afk_midgame_multi", "1.0", "0.5: Midgame let you be afk for double amount of time.");

	g_cvKick = CreateConVar("afk_kick", "4", "AFK state from where to kick the player (0: Disabled; 1 to 4)");

	g_cvSpec = CreateConVar("afk_spec", "0", "AFK state from where to move the player to spectators (0: Disabled; 1 to 4)");

	g_cvTeam = CreateConVar("afk_team", "0", "2: Check only Ts, 3: Check only CTs");

	AutoExecConfig(true, "antiafk");

	HookEvent("player_spawn", Event_Spawn);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_freeze_end", Event_RoundFreezeEnd);
	HookEvent("round_end", Event_RoundEnd);

	CreateTimer(g_cvCheckInterval.FloatValue, Timer_Check, g_cvCheckInterval.FloatValue, TIMER_REPEAT );

	reloadPlugins();

	if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

/// Reload Detected
public void reloadPlugins()
{
	LoopIngameClients(iClient)
	{
		OnClientPutInServer(iClient);
	}
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public void OnMapStart()
{
	g_fRoundStart = -1.0;
	g_iBombRing = PrecacheModel(VMT_BOMBRING);
	g_iHalo = PrecacheModel(VMT_HALO);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	g_fRoundStart = -1.0;
	bEnable = false;
	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	g_fRoundStart = -1.0;
	bEnable = false;
	return Plugin_Continue;
}

public Action Event_RoundFreezeEnd(Handle event, const char[] name, bool dontBroadcast)
{
	LoopIngameClients(iClient)
		g_fLastTime[iClient] = GetGameTime();

	g_fRoundStart = GetGameTime();

	bEnable = true;
	return Plugin_Continue;
}

public Action OnWeaponCanUse(int iClient, int iWeapon)
{
	if(!bEnable)
		return Plugin_Continue;

	char sWeapon[32];
	GetEntityClassname(iWeapon, sWeapon, sizeof(sWeapon));

	if(g_iAfkstate[iClient] != -1 && StrEqual(sWeapon, "weapon_c4"))
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &impulse, float vel[3], float angles[3])
{
	if(!IsPlayerAlive(iClient))
		return Plugin_Continue;

	if(!bEnable || iButtons > 0 || vel[0] != 0 || vel[1] != 0 || GetVectorDistance(angles, g_fLastAngle[iClient]) > 0.1)
		g_fLastTime[iClient] = GetGameTime();

	g_fLastAngle[iClient] = angles;

	return Plugin_Continue;
}

public Action Event_Spawn(Handle event, const char[] name, bool dontBroadcast)
{
	g_fLastTime[GetClientOfUserId(GetEventInt(event, "userid"))] = GetGameTime();

	return Plugin_Continue;
}

public Action Timer_Check(Handle timer, any data)
{
	if (IsWarmup()) {
		return Plugin_Continue;
	}

	LoopAlivePlayers(iClient)
	{
		if(g_cvTeam.IntValue > 1 && GetClientTeam(iClient) != g_cvTeam.IntValue)
			continue;

		g_iAfkstate[iClient] = GetAfkState(iClient);

		if(g_iAfkstate[iClient] == -1)
			continue;

		if(g_cvDropBomb.IntValue > 0 && g_cvDropBomb.IntValue <= g_iAfkstate[iClient]+1)
			Dropbomb(iClient);

		if(g_cvKick.IntValue > 0 && g_cvKick.IntValue <= g_iAfkstate[iClient]+1)
		{
			CPrintToChatAll("%s {lightred}%N{default} got kicked for being AFK too long.", PREFIX, iClient);
			KickClient(iClient, "AFK 2 long");
			continue;
		}

		if(g_cvSpec.IntValue > 0 && g_cvSpec.IntValue <= g_iAfkstate[iClient]+1)
		{
			CPrintToChatAll("%s {lightred}%N{default} got moved to spectators for being AFK too long.", PREFIX, iClient);
			ChangeClientTeam(iClient, 1);
			continue;
		}

		if(g_cvBeacon.IntValue > 0 && g_cvBeacon.IntValue <= g_iAfkstate[iClient]+1)
			StartBeacon(iClient);

		if(g_cvSlap[g_iAfkstate[iClient]].IntValue >= 0)
			StartSlapping(iClient);

		if(g_cvIgnite.IntValue > 0 && g_cvIgnite.IntValue <= g_iAfkstate[iClient]+1)
			IgniteEntity(iClient, g_cvCheckInterval.FloatValue);
	}

	if(g_cvCheckInterval.FloatValue != data)
	{
		CreateTimer(g_cvCheckInterval.FloatValue, Timer_Check, g_cvCheckInterval.FloatValue, TIMER_REPEAT);
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

int GetAfkState(int iClient)
{
	float fTime = GetGameTime();

	bool bMidgame = fTime - g_fRoundStart > g_cvMidgame.FloatValue;
	float fAfkTime = fTime - g_fLastTime[iClient];

	if(bMidgame)
		fAfkTime *= g_cvMidgameMult.FloatValue;

	int iAfkState = -1;

	for (int i = 0; i < 4; i++)
	{
		if(fAfkTime >= g_cvAfkState[i].FloatValue)
			iAfkState = i;
	}

	return iAfkState;
}

void StartSlapping(int iClient)
{
	if(g_hSlapTimer[iClient] != null)
		return;

	Slap(iClient);

	g_hSlapTimer[iClient] = CreateTimer(g_cvSlapInterval.FloatValue, Timer_Slap, iClient, TIMER_REPEAT);
}

public Action Timer_Slap(Handle timer, any iClient)
{
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || g_iAfkstate[iClient] == -1 || g_cvSlap[g_iAfkstate[iClient]].IntValue < 0)
	{
		g_hSlapTimer[iClient] = null;
		return Plugin_Stop;
	}

	Slap(iClient);

	return Plugin_Continue;
}

void Slap(int iClient)
{
	SlapPlayer(iClient, g_cvSlap[g_iAfkstate[iClient]].IntValue, true);
}

void StartBeacon(int iClient)
{
	if(g_hBeaconTimer[iClient] != null)
		return;

	Beacon(iClient);

	g_hBeaconTimer[iClient] = CreateTimer(g_cvBeaconInterval.FloatValue, Timer_Beacon, iClient, TIMER_REPEAT);
}

public Action Timer_Beacon(Handle timer, any iClient)
{
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || g_cvBeacon.IntValue > g_iAfkstate[iClient]+1 || g_cvBeacon.IntValue == 0 || g_iAfkstate[iClient] == -1)
	{
		g_hBeaconTimer[iClient] = null;
		return Plugin_Stop;
	}

	Beacon(iClient);

	return Plugin_Continue;
}

void Beacon(int iClient)
{
	float fPos[3];
	GetClientAbsOrigin(iClient, fPos);

	TE_SetupBeamRingPoint(fPos, 10.0, 750.0, g_iBombRing, g_iHalo, 0, 10, 0.6, 10.0, 0.5, {255, 75, 75, 255}, 5, 0);
	TE_SendToAll();
}

void Dropbomb(int iClient)
{
	int iWeapon = GetPlayerWeaponSlot(iClient, CS_SLOT_C4);

	if(iWeapon <= 0)
		return;

	CS_DropWeapon(iClient, iWeapon, true);

	LoopAlivePlayers(i)
	{
		if(GetClientTeam(i) != CS_TEAM_T)
			continue;

		if(iClient != i)
			CPrintToChat(i, "%s {lightred}%N{default} has dropped the bomb.", PREFIX, iClient);
		else CPrintToChat(i, "%s {lightred}%N{default} You dropped the bomb.");
	}
}