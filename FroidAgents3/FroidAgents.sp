/* SM Includes */
#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>
#include <sdktools_functions>
#include <PTaH>
#include <ripext>
#include <eItems>
#include <multicolors>
#include <geoip>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

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

static const char sCEconEntity[] = "CEconEntity";

public void OnPluginStart()
{
	RegConsoleCmd("sm_agent", Call_MenuAgents);
	RegConsoleCmd("sm_agents", Call_MenuAgents);
	RegConsoleCmd("sm_operator", Call_MenuAgents);
	RegConsoleCmd("sm_operators", Call_MenuAgents);
	RegConsoleCmd("sm_sff", Call_MenuAgents);

	HookEvent("player_spawn", Event_PlayerSpawn);

	PTaH(PTaH_InventoryUpdatePost, Hook, OnInventoryUpdatePost);

	m_Item = FindSendPropInfo(sCEconEntity, "m_Item");
	m_iItemDefinitionIndex = FindSendPropInfo(sCEconEntity, "m_iItemDefinitionIndex") - m_Item;
	GameData hGameData = new GameData("agent_chooser.game.csgo");

	if(!hGameData)
	{
		SetFailState("Couldn't find \"agent_chooser.game.csgo.txt\" gamedata");
	}

	// m_LoadoutItems = hGameData.GetOffset("CCSPlayerInventory::m_LoadoutItems");		// Clear agent item id - not work!!!

	StartPrepSDKCall(SDKCall_Raw);		// CPlayerInventory
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SetDefaultEquippedDefinitionItemBySlot");		// void
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);		// int iClass
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);		// int iSlot
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);		// unsigned __int16 iDefIndex

	if(!(g_hSetDefaultEquippedDefinitionItemBySlot = EndPrepSDKCall()))
	{
		SetFailState("Failed to get \"SetDefaultEquippedDefinitionItemBySlot\" function");
	}

	hGameData.Close();

	httpClient = new HTTPClient("https://froidgaming.net");

	reloadPlugins();

	if (eItems_AreItemsSynced()) {
		eItems_OnItemsSynced();
	}

    CreateTimer(30.0, Timer_Repeat, _, TIMER_REPEAT);

	if (LibraryExists("updater")) {
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

public void eItems_OnItemsSynced()
{
    g_iAgentsCount = eItems_GetAgentsCount();
}

public void OnClientPostAdminCheck(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

	g_PlayerData[iClient].Reset();
	g_PlayerData[iClient].pInventory = PTaH_GetPlayerInventory(iClient);

	// GeoIP
    char sIP[64], sCountryCode[3];
    GetClientIP(iClient, sIP, sizeof(sIP));
    GeoipCode2(sIP, sCountryCode);
    Format(g_PlayerData[iClient].sCountryCode, sizeof(g_PlayerData[].sCountryCode), sCountryCode);
	
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
	if (g_PlayerData[iClient].iAgentLoaded == 1) {
		char sAuthID[64], sUrl[128];
		GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
		Format(sUrl, sizeof(sUrl), "api/agent/%s", sAuthID);

		JSONObject jsondata = new JSONObject();
		jsondata.SetInt("t_agent", g_PlayerData[iClient].iAgent[0]);
		jsondata.SetInt("ct_agent", g_PlayerData[iClient].iAgent[1]);
		httpClient.Put(sUrl, jsondata, OnUpdateAgent);

		delete jsondata;
	}

	g_PlayerData[iClient].Reset();
}

void OnInventoryUpdatePost(int iClient, CCSPlayerInventory pInventory)
{
	g_PlayerData[iClient].SetAgentSkin(iClient, CS_TEAM_T);
	g_PlayerData[iClient].SetAgentSkin(iClient, CS_TEAM_CT);
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsValidClient(iClient)) {
		int iTeam = event.GetInt("teamnum");
		
		if(iTeam < 2) {
			g_PlayerData[iClient].pInventory = PTaH_GetPlayerInventory(iClient);
		}
    }

	return Plugin_Continue;
}