/* SM Includes */
#include <sourcemod>
#include <geoip>
#include <ripext>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.2"
#define UPDATE_URL "https://sys.froidgaming.net/FroidVeteran/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Veteran Players",
	author = "FroidGaming.net",
	description = "Veteran Players.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    CreateTimer(30.0, Timer_Repeat, _, TIMER_REPEAT);

    if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public Action Timer_Repeat(Handle hTimer)
{
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			if (g_PlayerData[i].iPlayersLoaded == -1) {
                OnClientPostAdminCheck(i);
			}
        }
    }
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "updater")) {
        Updater_AddPlugin(UPDATE_URL);
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

    // API
	char sAuthID[64], sUrl[256];
	GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
    Format(sUrl, sizeof(sUrl), "%s/api/profile/%s/rank/pug", BASE_URL, sAuthID);
    HTTPRequest request = new HTTPRequest(sUrl);
	request.Get(OnGetExp, GetClientUserId(iClient));
}

void OnCheckPlayer(int iClient)
{
    if (g_PlayerData[iClient].iEXP < 1800) {
        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            KickClient(iClient, "Kamu membutuhkan minimal 1800 EXP (DMG) untuk bermain di server ini.\nEXP Kamu sekarang : %i EXP\nKamu masih bisa bermain di PUG 1, PUG 2 dan PUG 3", g_PlayerData[iClient].iEXP);
        } else {
            KickClient(iClient, "You need minimum 1800 EXP (DMG) to play on this server.\nYour current EXP : %I EXP\nYou can still play on PUG 1, PUG 2 and PUG 3", g_PlayerData[iClient].iEXP);
        }
    }
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();
}