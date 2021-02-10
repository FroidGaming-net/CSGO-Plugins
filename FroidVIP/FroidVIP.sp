/* SM Includes */
#include <sourcemod>
#include <multicolors>
#include <geoip>
#include <ripext>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidVIP/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"
#include "files/commands.sp"
#include "files/menus.sp"

public Plugin myinfo =
{
    name = "[FroidApp] VIP",
    author = "FroidGaming.net",
    description = "VIP Management.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_premium", Call_MenuPremium);
	RegConsoleCmd("sm_premiums", Call_MenuPremium);
	RegConsoleCmd("sm_vip", Call_MenuPremium);
	RegConsoleCmd("sm_vips", Call_MenuPremium);

    httpClient = new HTTPClient("https://froidgaming.net");
    g_hForward_OnClientLoadedPre = CreateGlobalForward("FroidVIP_OnClientLoadedPre", ET_Event, Param_Cell);
	g_hForward_OnClientLoadedPost = CreateGlobalForward("FroidVIP_OnClientLoadedPost", ET_Event, Param_Cell);

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
			if (g_PlayerData[i].iVipLoaded == -1) {
                if(StrEqual(g_PlayerData[i].sCountryCode, "ID")){
                    CPrintToChat(i, "%s {default}Maaf, sedang terjadi masalah dengan {lightred}Sistem VIP{default} Kami. Mohon tunggu {lightred}30{default} detik lagi!", PREFIX, i);
                    CPrintToChat(i, "%s {default}Jika ini terjadi terus menerus mohon hubungi kami di {lightred}https://discord.io/froidgaming", PREFIX, i);
                } else {
                    CPrintToChat(i, "%s {default}Sorry, there is a problem with our {lightred}VIP System{default}. Please wait for {lightred}30{default} seconds!", PREFIX, i);
                    CPrintToChat(i, "%s {default}If this happens continuously please contact us at {lightred}https://discord.io/froidgaming", PREFIX, i);
                }
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
    char sAuthID[64], sUrl[128];
    GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
    Format(sUrl, sizeof(sUrl), "api/vip/%s", sAuthID);

    httpClient.Get(sUrl, GetVipInfo, GetClientUserId(iClient));
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();
}