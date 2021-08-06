/* SM Includes */
#include <sourcemod>
#include <retakes>
#include <sdktools>
#include <geoip>
#include <cstrike>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.7.6"
#define UPDATE_URL "https://sys.froidgaming.net/FroidPlant/updatefile.txt"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
    name = "[FroidApp] Retakes Fast Bomb Plant",
    author = "FroidGaming.net",
    description = "Retakes Fast Bomb Plant.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    PlayerConnect = new StringMap();

    HookEvent("bomb_beginplant", Event_BombBeginPlant);
    HookEvent("bomb_planted", Event_BombPlanted, EventHookMode_Pre);

	g_hForward_OnForceEndFreezeTime = CreateGlobalForward("FroidPlant_OnForceEndFreezeTime", ET_Event, Param_Cell);

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

public void OnAllPluginsLoaded()
{
	DisablePlugin("retakes_autoplant");
}

/// Reload Detected
public void reloadPlugins() {
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			OnClientPostAdminCheck(i);
		}
	}
}

public void OnMapStart()
{
    PlayerConnect.Clear();
}

public void OnMapEnd()
{
    PlayerConnect.Clear();
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

    int iCooldown;
    char sAuthID[64];
    GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
    if (PlayerConnect.GetValue(sAuthID, iCooldown)) {
        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
            KickClient(iClient, "Kamu tidak diizinkan untuk masuk! Mohon tunggu map berikutnya atau masuk ke server retakes kami yang lain.");
        }else{
            KickClient(iClient, "You`r not allowed to connect! Please wait for the next map or connect to our other retakes server.");
        }
        return;
    }
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

	g_PlayerData[iClient].Reset();
}

public void Event_BombBeginPlant(Event event, const char[] name, bool dontBroadcast)
{
    if (!Retakes_Live()) {
        return;
    }

    int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

    if (!IsValidClient(iClient)) {
        return;
    }

    CreateTimer(0.0, Timer_DelayPlant, GetClientUserId(iClient));
}

public Action Timer_DelayPlant(Handle timer, any data)
{
    if (!Retakes_Live()) {
        return;
    }

	int iClient = GetClientOfUserId(data);

	if (!IsValidClient(iClient)) {
        return;
    }

    // Retakes C4 Site
    char sBombsite[8];
    sBombsite = (Retakes_GetCurrrentBombsite() == BombsiteA) ? "A" : "B";

    // Current C4 Site
    float fPos[3];
    GetClientAbsOrigin(iClient, fPos);
    if (GetBombSite(fPos) == BOMBSITE_A) {
        if (StrEqual(sBombsite, "B", false)) {
            ForcePlayerSuicide(iClient);
        }
    } else {
        if (StrEqual(sBombsite, "A", false)) {
		    ForcePlayerSuicide(iClient);
        }
    }

    if (IsPlayerAlive(iClient)) {
        int iC4 = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
        char sClassname[64];
	    GetEntityClassname(iC4, sClassname, sizeof(sClassname));
        if (StrEqual(sClassname, "weapon_c4", false)) {
            SetEntPropFloat(iC4, Prop_Send, "m_fArmedTime", GetGameTime());
        }
    }
}

public void Event_BombPlanted(Event event, const char[] name, bool dontBroadcast)
{
    if (!Retakes_Live()) {
        return;
    }

    for (int i = 1; i <= MaxClients; i++) {
        if (IsValidClient(i)) {
            Retakes_SetRoundPoints(i, 0);
        }
    }
    GameRules_SetProp("m_bFreezePeriod", false);

    // Global Forward
    Call_StartForward(g_hForward_OnForceEndFreezeTime);
    Call_Finish();
}

public void Retakes_OnFailToPlant(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].iFailedToPlant++;
    SendPlayerToSpectators(iClient);

    if (g_PlayerData[iClient].iFailedToPlant >= 3) {
        int iCooldown;
        char sAuthID[64];
        GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
        if (!PlayerConnect.GetValue(sAuthID, iCooldown)) {
            PlayerConnect.SetValue(sAuthID, 1);
        }

        Retakes_MessageToAll("%N was kicked for fail to plant 3 times.", iClient);
		KickClient(iClient, "You'r not plant the bomb 3 times");
    }
}