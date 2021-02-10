/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <multicolors>
#include <geoip>
#undef REQUIRE_PLUGIN
#include <updater>
#include <multi1v1>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidJoin/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/commands.sp"
#include "files/menus.sp"
#include "files/events.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Join",
	author = "FroidGaming.net",
	description = "VIP Features to Replace Player.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_join", Call_MenuJoin);
	RegConsoleCmd("sm_joins", Call_MenuJoin);
	RegConsoleCmd("sm_replace", Call_MenuJoin);
	RegConsoleCmd("sm_replaces", Call_MenuJoin);

    HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);

    PlayerCooldown = new StringMap();
	PlayerDisconnect = new StringMap();

	g_hForward_OnClientReplaced = CreateGlobalForward("FroidJoin_OnClientReplaced", ET_Event, Param_Cell);

	reloadPlugins();

    CreateTimer(10.0, Timer_Setting);

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

/// Reload Detected
public void reloadPlugins() {
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			OnClientPostAdminCheck(i);
		}
	}
}

public Action Timer_Setting(Handle hTimer)
{
    g_cHostname = FindConVar("hostname");
    g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));

    if (StrContains(g_sHostname, "PUG") > -1 || StrContains(g_sHostname, "5v5") > -1) {
		HookEvent("round_start", Event_RoundStartPUG);
	} else if(StrContains(g_sHostname, "AWP") > -1) {
		HookEvent("round_prestart", Event_PreRoundStartAWP, EventHookMode_Pre);
	} else if(StrContains(g_sHostname, "FFA") > -1) {
		CreateTimer(1800.0, Timer_Repeat, _, TIMER_REPEAT);
	}
}

public Action Timer_Repeat(Handle hTimer)
{
	PlayerCooldown.Clear();
	PlayerDisconnect.Clear();
}

public void OnMapStart()
{
	PlayerCooldown.Clear();
	PlayerDisconnect.Clear();
}

public void OnMapEnd()
{
	PlayerCooldown.Clear();
	PlayerDisconnect.Clear();
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

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast) 
{
	event.BroadcastDisabled = true;
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(iClient)) {
		char sReason[128];
        event.GetString("reason", sReason, sizeof(sReason));
        PrintToChatAll("%N left the game (%s)", iClient, sReason);

		int iCooldown;
		char sAuthID[64];
		GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
		if (PlayerCooldown.GetValue(sAuthID, iCooldown)) {
			if (IsClientTimingOut(iClient)) {
				if (!PlayerDisconnect.GetValue(sAuthID, iCooldown)) {
					PlayerDisconnect.SetValue(sAuthID, 1);
					PlayerCooldown.Remove(sAuthID);
				}
			}
		}
	}
    return Plugin_Continue;
}