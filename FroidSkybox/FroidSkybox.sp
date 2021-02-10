/* SM Includes */
#include <sourcemod>
#include <ripext>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidSkybox/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"
#include "files/commands.sp"
#include "files/menus.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
    name = "[FroidApp] Skybox",
    author = "FroidGaming.net",
    description = "Skybox Management.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_sky", Call_MenuSkybox);
	RegConsoleCmd("sm_skybox", Call_MenuSkybox);
	RegConsoleCmd("sm_skyboxs", Call_MenuSkybox);

    g_cSkyName = FindConVar("sv_skyname");

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
			if (g_PlayerData[i].iSkyboxLoaded == -1) {
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

    // API
    char sAuthID[64], sUrl[128];
    GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
    Format(sUrl, sizeof(sUrl), "api/skybox/%s", sAuthID);

    httpClient.Get(sUrl, OnGetSkybox, GetClientUserId(iClient));
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    // Update Skybox
	if(g_PlayerData[iClient].iSkyboxLoaded == 1)
	{
		char sAuthID[64], sUrl[128];
		GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
		Format(sUrl, sizeof(sUrl), "api/skybox/%s", sAuthID);

		JSONObject jsondata = new JSONObject();
        jsondata.SetString("skybox", g_PlayerData[iClient].sSkybox);
		httpClient.Put(sUrl, jsondata, OnUpdateSkybox);

		delete jsondata;
	}

    g_PlayerData[iClient].Reset();
}