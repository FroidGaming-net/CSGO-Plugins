/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <ripext>
#include <executes>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1"
#define UPDATE_URL "https://sys.froidgaming.net/executes_weapons/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"
#include "files/commands.sp"
#include "files/menus.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Executes Weapons",
	author = "FroidGaming.net",
	description = "Executes Weapons Management.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_weapon", Call_MenuWeapon);
	RegConsoleCmd("sm_awp", Call_MenuWeapon);
	RegConsoleCmd("sm_sniper", Call_MenuWeapon);
	RegConsoleCmd("sm_snipers", Call_MenuWeapon);


    HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);

    httpClient = new HTTPClient("https://froidgaming.net");

    reloadPlugins();
    CreateTimer(30.0, Timer_Repeat, _, TIMER_REPEAT);

	if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }

    ConVar cRestartGame = FindConVar("mp_restartgame");
	if (cRestartGame != INVALID_HANDLE) {
        HookConVarChange(cRestartGame, OnConVarChanged);
    }
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

/// Auto retry
public Action Timer_Repeat(Handle hTimer)
{
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			if (g_PlayerData[i].iWeaponsLoaded == -1) {
				OnClientPostAdminCheck(i);
			}
        }
    }
}

/// Reload Detected
public void reloadPlugins() {
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			OnClientPostAdminCheck(i);
		}
	}
}

public void OnConVarChanged(ConVar convar, char[] oldValue, char[] newValue)
{
	OnMapStart();
}

public void OnMapStart()
{
	g_iRounds_Pistol = 0;
	g_iRounds_Force = 0;
}

public void OnMapEnd()
{
	g_iRounds_Pistol = 0;
	g_iRounds_Force = 0;
}

public void OnClientPostAdminCheck(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();

    // API
	char sAuthID[64], sUrl[128];
	GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
	Format(sUrl, sizeof(sUrl), "api/retakes/%s", sAuthID);
	httpClient.Get(sUrl, OnGetWeapon, GetClientUserId(iClient));
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    // Update Guns
	if(g_PlayerData[iClient].iWeaponsLoaded == 1)
	{
        char sAuthID[64], sUrl[128];
		GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
		Format(sUrl, sizeof(sUrl), "api/retakes/%s", sAuthID);

        JSONObject jsondata = new JSONObject();
        jsondata.SetString("pistolround_ct", g_PlayerData[iClient].sPistolRound_CT);
        jsondata.SetString("primary_ct", g_PlayerData[iClient].sPrimary_CT);
        jsondata.SetString("secondary_ct", g_PlayerData[iClient].sSecondary_CT);
        jsondata.SetString("smg_ct", g_PlayerData[iClient].sSMG_CT);
        jsondata.SetInt("awp_ct", view_as<int>(g_PlayerData[iClient].bAWP_CT));
        jsondata.SetInt("scout_ct", view_as<int>(g_PlayerData[iClient].bScout_CT));

        jsondata.SetString("pistolround_t", g_PlayerData[iClient].sPistolRound_T);
        jsondata.SetString("primary_t", g_PlayerData[iClient].sPrimary_T);
        jsondata.SetString("secondary_t", g_PlayerData[iClient].sSecondary_T);
        jsondata.SetString("smg_t", g_PlayerData[iClient].sSMG_T);
        jsondata.SetInt("awp_t", view_as<int>(g_PlayerData[iClient].bAWP_T));
        jsondata.SetInt("scout_t", view_as<int>(g_PlayerData[iClient].bScout_T));

        httpClient.Put(sUrl, jsondata, OnUpdateWeapon);

		delete jsondata;
    }

    g_PlayerData[iClient].Reset();
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if (!Executes_Live())
    {
        return;
    }

    if(Executes_GetNumActivePlayers() < 4)
	{
		return;
	}

    if (g_iRounds_Pistol < PISTOL_ROUND_TOTAL) {
        g_iRounds_Pistol++;

        SetRoundType(PISTOL_ROUND);
    } else if (g_iRounds_Force < FORCE_ROUND_TOTAL) {
        g_iRounds_Force++;

        SetRoundType(FORCE_ROUND);
    } else {
        SetRoundType(FULL_ROUND);
    }
}