/* SM Includes */
#include <sourcemod>
#include <multicolors>
#include <geoip>
#include <ripext>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"

public Plugin myinfo =
{
    name = "[FroidPrivate] Trusted Client",
    author = "FroidGaming.net",
    description = "Trusted System.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    reloadPlugins();
    CreateTimer(30.0, Timer_Repeat, _, TIMER_REPEAT);
}

/// Auto retry
public Action Timer_Repeat(Handle hTimer)
{
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
            char sAuthID[64], sUrl[512];
            GetClientAuthId(i, AuthId_SteamID64, sAuthID, sizeof(sAuthID));

			if (g_PlayerData[i].iFACLoaded == -1) {
                Format(sUrl, sizeof(sUrl), "%s/api/anticheat2/%s", BASE_URL, sAuthID);
                HTTPRequest request = new HTTPRequest(sUrl);
                request.Get(OnCheckAntiCheat, GetClientUserId(i));
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

public void OnClientPostAdminCheck(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();

    char sAuthID[64], sUrl[512];
    GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
    Format(sUrl, sizeof(sUrl), "%s/api/anticheat2/%s", BASE_URL, sAuthID);
    HTTPRequest request = new HTTPRequest(sUrl);
    request.Get(OnCheckAntiCheat, GetClientUserId(iClient));
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();
}