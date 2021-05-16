/* SM Includes */
#include <sourcemod>
#include <geoip>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"
#define UPDATE_URL "https://sys.froidgaming.net/TrustedMode/updatefile.txt"

#include "files/globals.sp"

public Plugin myinfo =
{
    name = "[FroidApp] Trusted Mode",
    author = "FroidGaming.net",
    description = "Check if players running on Trusted Mode or not.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
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

public void OnClientDisconnect(int iClient)
{
    if (IsFakeClient(iClient)) {
		return;
	}

    g_PlayerData[iClient].Reset();
}

public void OnParseOS(int iClient, OS OperatingSystem)
{
    if (IsFakeClient(iClient)) {
		return;
	}

    g_PlayerData[iClient].Reset();

    if (OperatingSystem != OS_Windows) {
        return;
    }

    QueryClientConVar(iClient, "trusted_launch", QueryClientConVarCallback);

    // GeoIP
    char sIP[64], sCountryCode[3];
    GetClientIP(iClient, sIP, sizeof(sIP));
    GeoipCode2(sIP, sCountryCode);
    Format(g_PlayerData[iClient].sCountryCode, sizeof(g_PlayerData[].sCountryCode), sCountryCode);
}

public void QueryClientConVarCallback(QueryCookie sCookie, int iClient, ConVarQueryResult sResult, const char[] sCvarName, const char[] sCvarValue)
{
    if (IsFakeClient(iClient)) {
		return;
	}

    if (StrEqual(sCvarValue, "0", false)) {
        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            KickClient(iClient, "Kamu harus menjalankan CS:GO dalam Trusted Mode");
        } else {
            KickClient(iClient, "You must run CS:GO in Trusted Mode");
        }
    }
}