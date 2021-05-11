/* SM Includes */
#include <sourcemod>
#include <multicolors>
#include <geoip>
#include <ripext>
#include <SteamWorks>
#include <minrank>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1.5"
#define UPDATE_URL "https://sys.froidgaming.net/FroidTrusted/updatefile.txt"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
    name = "[FroidApp] Trusted Client",
    author = "FroidGaming.net",
    description = "Trusted System.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    httpClient = new HTTPClient("https://froidgaming.net");
    httpClient2 = new HTTPClient("https://api.steampowered.com");
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
            char sAuthID[64], sUrl[128];
            GetClientAuthId(i, AuthId_SteamID64, sAuthID, sizeof(sAuthID));

			if (g_PlayerData[i].iBannedLoaded == -1) {
				Format(sUrl, sizeof(sUrl), "api/banned/%s", sAuthID);
                httpClient.Get(sUrl, OnCheckBanned, GetClientUserId(i));
			} else if (g_PlayerData[i].iFACLoaded == -1) {
				Format(sUrl, sizeof(sUrl), "api/anticheat/%s", sAuthID);
                httpClient.Get(sUrl, OnCheckAntiCheat, GetClientUserId(i));
			} else if (g_PlayerData[i].iHoursLoaded == -1) {
                FormatEx(sUrl, sizeof(sUrl), "IPlayerService/GetOwnedGames/v0001?key=26B12AFA10E748B57D135D055FA98808&steamid=%s&appids_filter[0]=730&format=json", sAuthID);
                httpClient2.Get(sUrl, OnCheckHours, GetClientUserId(i));
			} else if (g_PlayerData[i].iCreatedAtLoaded == -1) {
				FormatEx(sUrl, sizeof(sUrl), "ISteamUser/GetPlayerSummaries/v0002/?key=26B12AFA10E748B57D135D055FA98808&steamids=%s", sAuthID);
                httpClient2.Get(sUrl, OnCheckCreateAt, GetClientUserId(i));
			// } else if (g_PlayerData[i].iLevelLoaded == -1) {
                // FormatEx(sUrl, sizeof(sUrl), "IPlayerService/GetSteamLevel/v1/?key=26B12AFA10E748B57D135D055FA98808&steamid=%s", sAuthID);
                // httpClient2.Get(sUrl, OnCheckLevel, GetClientUserId(i));
			} else if (g_PlayerData[i].iPlayerDataLoaded == -1) {
                Format(sUrl, sizeof(sUrl), "api/player/%s", sAuthID);
                httpClient.Get(sUrl, OnCheckPlayerData, GetClientUserId(i));
			}
        }
    }
}

/// Reload Detected
public void reloadPlugins() {
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			FroidVIP_OnClientLoadedPost(i);
		}
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

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();
}

// Same as OnClientPostAdminCheck
public void FroidVIP_OnClientLoadedPost(int iClient)
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

    // Function Variable
    char sAuthID[64], sUrl[128];
    GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
    // End Variable

    /// Check Players
    // Jika server full dan bukan VIP maka di Kick
    if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
        if (GetInGameClientCount2() > GetMaxHumanPlayers()) {
            if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
                KickClient(iClient, "Server Penuh, Beli Premium Plus @ froidgaming.net");
            }else{
                KickClient(iClient, "Server Full, Buy Premium Plus @ froidgaming.net");
            }
        }
    }

    // 1. Check Banned (Current)
    // 2. Check FACEIT AC (Done)
    // 3. Check Game Hours (Done)
    // 4. Check CreatedAt (Done)

    // Banned Check
    Format(sUrl, sizeof(sUrl), "api/banned/%s", sAuthID);
    httpClient.Get(sUrl, OnCheckBanned, GetClientUserId(iClient));
    /// End Banned Check

    CreateTimer(30.0, Timer_DelayJoin, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
    /// END Check Playes
}

Action Timer_DelayJoin(Handle timer, any data)
{
	int iClient = GetClientOfUserId(data);

    if (IsValidClient(iClient)) {

        // Function Variable
        char sAuthID[64], sUrl[128];
        GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
        // End Variable

        Format(sUrl, sizeof(sUrl), "api/player/%s", sAuthID);
        httpClient.Get(sUrl, OnCheckPlayerData, GetClientUserId(iClient));
    }
}