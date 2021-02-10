/* SM Includes */
#include <sourcemod>
#include <geoip>
#include <ripext>
#include <sdktools>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidName/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/custom_functions.sp"
#include "files/API.sp"

public Plugin myinfo =
{
    name = "[FroidApp] Chat",
    author = "FroidGaming.net",
    description = "Chat Management.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    httpClient = new HTTPClient("https://froidgaming.net");

    HookEvent("player_changename", Event_OnPlayerNameChanged);

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
public void reloadPlugins()
{
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

    if (!CheckCommandAccess(iClient, "sm_froidapp_root", ADMFLAG_ROOT)) {
        Format(g_PlayerData[iClient].sName, sizeof(g_PlayerData[].sName), "%N", iClient);

        DataPack pack = new DataPack();
        pack.WriteCell(GetClientUserId(iClient));

        JSONObject jsondata = new JSONObject();
        jsondata.SetString("clantag", g_PlayerData[iClient].sName);
        httpClient.Post("api/chat", jsondata, OnCheckName, pack);
        delete jsondata;
    }

}

public Action Event_OnPlayerNameChanged(Event event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

    if (IsValidClient(iClient)) {
        if (!CheckCommandAccess(iClient, "sm_froidapp_root", ADMFLAG_ROOT)) {
            Format(g_PlayerData[iClient].sName, sizeof(g_PlayerData[].sName), "%N", iClient);

            DataPack pack = new DataPack();
            pack.WriteCell(GetClientUserId(iClient));

            JSONObject jsondata = new JSONObject();
            jsondata.SetString("clantag", g_PlayerData[iClient].sName);
            httpClient.Post("api/chat", jsondata, OnCheckName, pack);
            delete jsondata;
        }
    }

    return Plugin_Continue;
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();
}