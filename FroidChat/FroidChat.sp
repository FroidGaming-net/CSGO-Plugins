/* SM Includes */
#include <sourcemod>
#include <cstrike>
#include <multicolors>
#include <geoip>
#include <ccprocessor>
#include <ripext>
#undef REQUIRE_PLUGIN
#include <multi1v1>
#include <hl_challenge>
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.3.2"
#define UPDATE_URL "https://sys.froidgaming.net/FroidChat/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"
#include "files/commands.sp"
#include "files/menus.sp"
#include "files/custom_functions.sp"

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
	LoadTranslations("ccproc.phrases");

    RegConsoleCmd("sm_tag", Call_MenuAppearance);
	RegConsoleCmd("sm_tags", Call_MenuAppearance);
	RegConsoleCmd("sm_color", Call_MenuAppearance);
	RegConsoleCmd("sm_colors", Call_MenuAppearance);

    httpClient = new HTTPClient("https://froidgaming.net");

	/// CCP
	char convarName[PLATFORM_MAX_PATH];
    for(int i; i < BIND_MAX; i++) {
        if(indexOfPart(i) == -1) {
            continue;
        }

        FormatBind("level_", i, 'l', convarName, sizeof(convarName));

        // level_:part
        // level_prefixco
        (CreateConVar(convarName, "2", "Priority level", _, true, 1.0)).AddChangeHook(view_as<ConVarChanged>(GetFunctionByName(GetMyHandle(), "levelHandler")));
    }

    AutoExecConfig(true, "FroidChat", "ccprocessor");
	/// CCP

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
			if (g_PlayerData[i].iChatLoaded == -1) {
				OnClientPostAdminCheck(i);
			    FroidVIP_OnClientLoadedPost(i);
			}
        }
    }
}

/// Reload Detected
public void reloadPlugins()
{
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
            OnClientPostAdminCheck(i);
			FroidVIP_OnClientLoadedPost(i);
		}
	}
}

public Action OnClientCommandKeyValues(int client, KeyValues kv)
{
	char sCmd [64];
	if(kv.GetSectionName(sCmd, sizeof(sCmd)) && StrEqual(sCmd, "ClanTagChanged", false))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void OnConfigsExecuted()
{
    g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));
}

public void OnMapStart()
{
    cc_proc_APIHandShake(cc_get_APIKey());

    triggerConVars();
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

public void FroidVIP_OnClientLoadedPost(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
        return;
    }

    // API
	char sAuthID[64], sUrl[128];
	GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
	Format(sUrl, sizeof(sUrl), "api/chat/%s", sAuthID);
	httpClient.Get(sUrl, OnGetChat, GetClientUserId(iClient));
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    // Update Chat
	if(g_PlayerData[iClient].iChatLoaded == 1)
	{
		char sAuthID[64], sUrl[128];
		GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
		Format(sUrl, sizeof(sUrl), "api/chat/%s", sAuthID);

		JSONObject jsondata = new JSONObject();
        jsondata.SetString("namecolor", g_PlayerData[iClient].sName);
        jsondata.SetString("messagecolor", g_PlayerData[iClient].sMessage);
        jsondata.SetString("clantag", g_PlayerData[iClient].sClanTag);
		httpClient.Put(sUrl, jsondata, OnUpdateChat);

		delete jsondata;
	}

    g_PlayerData[iClient].Reset();
}