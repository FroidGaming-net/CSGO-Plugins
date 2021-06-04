/* SM Includes */
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <multicolors>
#include <autoexecconfig>
#undef REQUIRE_PLUGIN
#include <retakes>
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1.1"
#define UPDATE_URL "https://sys.froidgaming.net/AntiAFK-Retakes/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/convars.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[Anti-AFK] Retakes",
	author = "FroidGaming.net",
	description = "Anti-AFK.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	AutoExecConfig_SetFile("antiafk_retakes");

	g_cvCheckInterval = AutoExecConfig_CreateConVar("afk_check_interval", "1.0", "Check interval");
    g_cvCheckInterval.AddChangeHook(OnConVarChanged);

	g_cvAfkState[0] = AutoExecConfig_CreateConVar("afk_state_1", "4.0", "Amount of time the player was not moving to enable AFK state 1");
    g_cvAfkState[0].AddChangeHook(OnConVarChanged);
	g_cvAfkState[1] = AutoExecConfig_CreateConVar("afk_state_2", "8.0", "Amount of time the player was not moving to enable AFK state 2");
    g_cvAfkState[1].AddChangeHook(OnConVarChanged);
	g_cvAfkState[2] = AutoExecConfig_CreateConVar("afk_state_3", "14.0", "Amount of time the player was not moving to enable AFK state 3");
    g_cvAfkState[2].AddChangeHook(OnConVarChanged);
	g_cvAfkState[3] = AutoExecConfig_CreateConVar("afk_state_4", "16.0", "Amount of time the player was not moving to enable AFK state 4");
    g_cvAfkState[3].AddChangeHook(OnConVarChanged);

	g_cvDropBomb = AutoExecConfig_CreateConVar("afk_drop_bomb", "1", "AFK state from where to drop bomb (0: Disabled; 1 to 4)");
    g_cvDropBomb.AddChangeHook(OnConVarChanged);

	g_cvMidgame = AutoExecConfig_CreateConVar("afk_midgame", "30.0", "Time from freezetime end to enable afk_midgame_multi");
    g_cvMidgame.AddChangeHook(OnConVarChanged);
	g_cvMidgameMult = AutoExecConfig_CreateConVar("afk_midgame_multi", "1.0", "0.5: Midgame let you be afk for double amount of time");
    g_cvMidgameMult.AddChangeHook(OnConVarChanged);

	g_cvKick = AutoExecConfig_CreateConVar("afk_kick", "4", "AFK state from where to kick the player (0: Disabled; 1 to 4)");
    g_cvKick.AddChangeHook(OnConVarChanged);

	g_cvSpec = AutoExecConfig_CreateConVar("afk_spec", "0", "AFK state from where to move the player to spectators (0: Disabled; 1 to 4)");
    g_cvSpec.AddChangeHook(OnConVarChanged);

	g_cvTeam = AutoExecConfig_CreateConVar("afk_team", "0", "2: Check only Ts, 3: Check only CTs");
    g_cvTeam.AddChangeHook(OnConVarChanged);

	g_cvDebug = AutoExecConfig_CreateConVar("afk_debug", "0", "1: Enabled 0: Disabled");
    g_cvDebug.AddChangeHook(OnConVarChanged);

	AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();

	HookEvent("player_spawn", Event_Spawn);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_freeze_end", Event_RoundFreezeEnd);
	HookEvent("round_end", Event_RoundEnd);
	HookEventEx("cs_win_panel_match", cs_win_panel_match);

	CreateTimer(g_cvCheckInterval.FloatValue, Timer_Check, g_cvCheckInterval.FloatValue, TIMER_REPEAT);

	reloadPlugins();

	if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

/// Reload Detected
public void reloadPlugins()
{
	for (int iClient = 1; iClient < MAXPLAYERS; iClient++) {
		if (IsClientInGame(iClient)) {
			OnClientPutInServer(iClient);
		}
	}
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "updater", false)) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public void OnMapStart()
{
	g_fRoundStart = -1.0;
	g_bWinPanel = false;
}

public void OnMapEnd()
{
	g_bWinPanel = false;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public void cs_win_panel_match(Handle event, const char[] eventname, bool dontBroadcast)
{
	g_bWinPanel = true;
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
	for (int iClient = 1; iClient < MAXPLAYERS; iClient++) {
		if (IsClientInGame(iClient)) {
			g_fLastTime[iClient] = GetGameTime();
		}
	}

	g_fRoundStart = GetGameTime();

	bEnable = true;
	return Plugin_Continue;
}

public void FroidPlant_OnForceEndFreezeTime()
{
	for (int iClient = 1; iClient < MAXPLAYERS; iClient++) {
		if (IsClientInGame(iClient)) {
			if (g_cvDebug.IntValue == 1) {
				if (CheckCommandAccess(iClient, "sm_froidapp_root", ADMFLAG_ROOT)) {
					PrintToConsole(iClient, "[Anti-AFK] Triggered FroidPlant_OnForceEndFreezeTime");
				}
			}
		}
	}

	for (int iClient = 1; iClient < MAXPLAYERS; iClient++) {
		if (IsClientInGame(iClient)) {
			g_fLastTime[iClient] = GetGameTime();
		}
	}

	g_fRoundStart = GetGameTime();

	bEnable = true;
}

public Action OnWeaponCanUse(int iClient, int iWeapon)
{
	if (!bEnable) {
		return Plugin_Continue;
	}

	char sWeapon[32];
	GetEntityClassname(iWeapon, sWeapon, sizeof(sWeapon));

	if(g_iAfkstate[iClient] != -1 && StrEqual(sWeapon, "weapon_c4")) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &impulse, float vel[3], float angles[3])
{
	if (!IsSafeToCheck()) {
		return Plugin_Continue;
	}

	if (!IsPlayerAlive(iClient)) {
		return Plugin_Continue;
	}

	if (!bEnable || iButtons > 0 || vel[0] != 0 || vel[1] != 0 || GetVectorDistance(angles, g_fLastAngle[iClient]) > 0.1) {
		g_fLastTime[iClient] = GetGameTime();
	}

	g_fLastAngle[iClient] = angles;

	return Plugin_Continue;
}

public Action Event_Spawn(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsSafeToCheck()) {
		return Plugin_Continue;
	}

	g_fLastTime[GetClientOfUserId(GetEventInt(event, "userid"))] = GetGameTime();

	return Plugin_Continue;
}

public Action Timer_Check(Handle timer, any data)
{
	if (!IsSafeToCheck()) {
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient < MAXPLAYERS; iClient++) {
		if (IsClientInGame(iClient) && IsPlayerAlive(iClient)) {
			if (g_cvDebug.IntValue == 1) {
				if (CheckCommandAccess(iClient, "sm_froidapp_root", ADMFLAG_ROOT)) {
					PrintToConsole(iClient, "[Anti-AFK] Timer_Check");
				}
			}

			if (g_cvTeam.IntValue > 1 && GetClientTeam(iClient) != g_cvTeam.IntValue) {
				continue;
			}

			g_iAfkstate[iClient] = GetAfkState(iClient);

			if (g_iAfkstate[iClient] == -1) {
				continue;
			}

			if (g_cvDropBomb.IntValue > 0 && g_cvDropBomb.IntValue <= g_iAfkstate[iClient]+1) {
				Dropbomb(iClient);
			}

			if (g_cvKick.IntValue > 0 && g_cvKick.IntValue <= g_iAfkstate[iClient]+1)
			{
				CPrintToChatAll("%s {lightred}%N{default} got kicked for being AFK too long.", PREFIX, iClient);
				KickClient(iClient, "AFK too long");
				continue;
			}

			if (g_cvSpec.IntValue > 0 && g_cvSpec.IntValue <= g_iAfkstate[iClient]+1)
			{
				CPrintToChatAll("%s {lightred}%N{default} got moved to spectators for being AFK too long.", PREFIX, iClient);
				ChangeClientTeam(iClient, 1);
				continue;
			}
		}
	}

	if (g_cvCheckInterval.FloatValue != data) {
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

	if (bMidgame) {
		fAfkTime *= g_cvMidgameMult.FloatValue;
	}

	int iAfkState = -1;

	for (int i = 0; i < 4; i++)
	{
		if(fAfkTime >= g_cvAfkState[i].FloatValue)
			iAfkState = i;
	}

	if (g_cvDebug.IntValue == 1) {
		if (CheckCommandAccess(iClient, "sm_froidapp_root", ADMFLAG_ROOT)) {
			PrintToConsole(iClient, "[Anti-AFK] AFK-State : %i | AFK-Time : %f", iAfkState, fAfkTime);
		}
	}

	return iAfkState;
}

void Dropbomb(int iClient)
{
	int iWeapon = GetPlayerWeaponSlot(iClient, CS_SLOT_C4);

	if (iWeapon <= 0) {
		return;
	}

	CS_DropWeapon(iClient, iWeapon, true);

	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			if (GetClientTeam(i) != CS_TEAM_T) {
				continue;
			}

			if (iClient == i) {
				CPrintToChat(i, "%s {default} You dropped the bomb.", PREFIX);
			} else {
				CPrintToChat(i, "%s {lightred}%N{default} has dropped the bomb.", PREFIX, iClient);
			}
		}
	}
}