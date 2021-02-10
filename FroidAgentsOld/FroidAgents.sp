#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <ripext>
#undef REQUIRE_PLUGIN
#include <updater>

/* Plugin Info */
#define VERSION "1.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidAgents/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"
#include "files/commands.sp"
#include "files/menus.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Agents",
	author = "FroidGaming.net",
	description = "All in one Agents Management.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_agent", Call_MenuAgents);
	RegConsoleCmd("sm_agents", Call_MenuAgents);
	RegConsoleCmd("sm_operator", Call_MenuAgents);
	RegConsoleCmd("sm_operators", Call_MenuAgents);
	RegConsoleCmd("sm_sff", Call_MenuAgents);

    HookEvent("player_spawn", Event_PlayerSpawn);

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
			if (g_PlayerData[i].iAgentLoaded == -1) {
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
	Format(sUrl, sizeof(sUrl), "api/agent/%s", sAuthID);
	httpClient.Get(sUrl, OnGetAgent, GetClientUserId(iClient));
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

	// Update Agents
	if(g_PlayerData[iClient].iAgentLoaded == 1)
	{
		char sAuthID[64], sUrl[128];
		GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
		Format(sUrl, sizeof(sUrl), "api/agent/%s", sAuthID);

		JSONObject jsondata = new JSONObject();
		jsondata.SetInt("ct_agent", g_PlayerData[iClient].iAgentCT);
		jsondata.SetInt("t_agent", g_PlayerData[iClient].iAgentT);
		httpClient.Put(sUrl, jsondata, OnUpdateAgent);

		delete jsondata;
	}

	g_PlayerData[iClient].Reset();
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

	char sModel[PLATFORM_MAX_PATH];
	int iTeams = GetClientTeam(iClient);
	if (iTeams == 3) {
		if (!StrEqual(sModel, GetAgentModelFromId(g_PlayerData[iClient].iAgentCT))) {
			if(strlen(GetAgentModelFromId(g_PlayerData[iClient].iAgentCT)) > 1) {
				SetEntityModel(iClient, GetAgentModelFromId(g_PlayerData[iClient].iAgentCT));
			}
		}
	} else if(iTeams == 2) {
		if (!StrEqual(sModel, GetAgentModelFromId(g_PlayerData[iClient].iAgentT))) {
			if(strlen(GetAgentModelFromId(g_PlayerData[iClient].iAgentT)) > 1) {
				SetEntityModel(iClient, GetAgentModelFromId(g_PlayerData[iClient].iAgentT));
			}
		}
	}
	return Plugin_Continue;
}