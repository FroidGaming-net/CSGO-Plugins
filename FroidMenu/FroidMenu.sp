/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <geoip>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1.2"
#define UPDATE_URL "https://sys.froidgaming.net/FroidMenu/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/commands.sp"
#include "files/menus.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Features Menu",
	author = "FroidGaming.net",
	description = "Features Menu.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    // Rules Menu
    RegConsoleCmd("sm_rules", Call_MenuRules);
	RegConsoleCmd("sm_rule", Call_MenuRules);
	RegConsoleCmd("sm_peraturan", Call_MenuRules);

    // Features Menu
    RegConsoleCmd("sm_help", Call_MenuFeatures);
    RegConsoleCmd("sm_helps", Call_MenuFeatures);
	RegConsoleCmd("sm_menu", Call_MenuFeatures);
	RegConsoleCmd("sm_menus", Call_MenuFeatures);
	RegConsoleCmd("buyammo1", Call_MenuFeatures);
	RegConsoleCmd("buyammo2", Call_MenuFeatures);

    reloadPlugins();

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