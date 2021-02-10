/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <dhooks>
#include <ripext>
#include <geoip>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidHats/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"
#include "files/commands.sp"
#include "files/menus.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Hats",
	author = "FroidGaming.net",
	description = "CS:GO Hat or Mask models.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_hats", Call_MenuHats);
	RegConsoleCmd("sm_hat", Call_MenuHats);
	RegConsoleCmd("sm_mask", Call_MenuHats);
	RegConsoleCmd("sm_masks", Call_MenuHats);

    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("player_team", Event_PlayerDeath, EventHookMode_Pre);
    HookEvent("player_spawn", Event_PlayerSpawn);

    mp_forcecamera = FindConVar("mp_forcecamera");

    Handle hGameConf;
	
	hGameConf = LoadGameConfigFile("sdktools.games");
	if (hGameConf == INVALID_HANDLE) {
        SetFailState("Gamedata file sdktools.games.txt is missing.");
    }

	int iOffset = GameConfGetOffset(hGameConf, "SetEntityModel");
	CloseHandle(hGameConf);
	if (iOffset == -1) {
        SetFailState("Gamedata is missing the \"SetEntityModel\" offset.");
    }
		
	hSetModel = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, SetModel);
	DHookAddParam(hSetModel, HookParamType_CharPtr);

    httpClient = new HTTPClient("https://froidgaming.net");

	reloadPlugins();
    CreateTimer(30.0, Timer_Repeat, _, TIMER_REPEAT);

	if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
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
			if (g_PlayerData[i].iHatLoaded == -1) {
                FroidVIP_OnClientLoadedPost(i);
			}
        }
    }
}

/// Reload Detected
public void reloadPlugins() {
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
            OnClientPutInServer(i);
			OnClientPostAdminCheck(i);
            FroidVIP_OnClientLoadedPost(i);
		}
	}
}

public void OnClientPutInServer(int iClient)
{
	if(IsValidClient(iClient))
	{
		DHookEntity(hSetModel, true, iClient);
	}
}

public void OnClientPostAdminCheck(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();

    // GeoIP
    char sIP[64], sCountryCode[3];
    GetClientIP(iClient, sIP, sizeof(sIP));
    GeoipCode2(sIP, sCountryCode);
    Format(g_PlayerData[iClient].sCountryCode, sizeof(g_PlayerData[].sCountryCode), sCountryCode);
}

public void FroidVIP_OnClientLoadedPost(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
        return;
    }

    // API
	char sAuthID[64], sUrl[128];
	GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
	Format(sUrl, sizeof(sUrl), "api/hats/%s", sAuthID);
	httpClient.Get(sUrl, OnGetHat, GetClientUserId(iClient));
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

	// Update Hats
	if(g_PlayerData[iClient].iHatLoaded == 1)
	{
		char sAuthID[64], sUrl[128];
		GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
		Format(sUrl, sizeof(sUrl), "api/hats/%s", sAuthID);

		JSONObject jsondata = new JSONObject();
        jsondata.SetInt("hat_id", g_PlayerData[iClient].iHatNumber);
		httpClient.Put(sUrl, jsondata, OnUpdateHats);

		delete jsondata;
	}

	g_PlayerData[iClient].Reset();
}

public Action Event_PlayerSpawn(Handle hEvent, char[] sName, bool bDontBroadcast)
{	
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(IsValidClient(iClient))
	{
		if(g_PlayerData[iClient].bViewing)
		{
			g_PlayerData[iClient].bViewing = false;
			SetThirdPersonView(iClient, false);
		}
		hTimers[iClient] = CreateTimer(2.5, ReHats, iClient);
	}

    return Plugin_Continue;
}

public Action Event_PlayerDeath(Handle hEvent, char[] sName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(IsValidClient(iClient))
	{
		if(hTimers[iClient] != INVALID_HANDLE)
		{
			KillTimer(hTimers[iClient]);
			hTimers[iClient] = INVALID_HANDLE;
		}
		if(g_PlayerData[iClient].bViewing)
		{
			g_PlayerData[iClient].bViewing = false;
			SetThirdPersonView(iClient, false);
		}
		RemoveHat(iClient);
	}

    return Plugin_Continue;
}