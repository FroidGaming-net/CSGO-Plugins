/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <ripext>
#include <geoip>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidEmoji/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"
#define MAX_ICONS 128

#include "files/globals.sp"
#include "files/client.sp"
#include "files/API.sp"
#include "files/commands.sp"
#include "files/menus.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Scoreboard Emoji's",
	author = "FroidGaming.net",
	description = "Scoreboard Emoji's.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    m_iOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
    BuildPath(Path_SM, m_sFilePath, sizeof(m_sFilePath), "configs/level_icons.cfg");

    RegConsoleCmd("sm_emoji", Call_MenuEmojis);
	RegConsoleCmd("sm_emojis", Call_MenuEmojis);
	RegConsoleCmd("sm_icon", Call_MenuEmojis);
	RegConsoleCmd("sm_icons", Call_MenuEmojis);

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
			if (g_PlayerData[i].iEmojiLoaded == -1) {
                FroidVIP_OnClientLoadedPost(i);
			}
        }
    }
}

/// Reload Detected
public void reloadPlugins() {
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			OnClientPostAdminCheck(i);
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

public void FroidVIP_OnClientLoadedPost(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    if (!CheckCommandAccess(iClient, "sm_froidapp_premium_plus", ADMFLAG_CUSTOM6)) {
        return;
    }

    // API
	char sAuthID[64], sUrl[128];
	GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
	Format(sUrl, sizeof(sUrl), "api/emojis/%s", sAuthID);
	httpClient.Get(sUrl, OnGetEmoji, GetClientUserId(iClient));
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

	// Update Emojis
	if(g_PlayerData[iClient].iEmojiLoaded == 1)
	{
		char sAuthID[64], sUrl[128];
		GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
		Format(sUrl, sizeof(sUrl), "api/emojis/%s", sAuthID);

		JSONObject jsondata = new JSONObject();
        jsondata.SetInt("emoji_id", g_PlayerData[iClient].iEmojiData);
		httpClient.Put(sUrl, jsondata, OnUpdateEmoji);

		delete jsondata;
	}

	g_PlayerData[iClient].Reset();
}

public void OnMapStart()
{
    char sBuffer[PLATFORM_MAX_PATH];

    SDKHook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);

    KeyValues kv = CreateKeyValues("LevelIcons");
    FileToKeyValues(kv, m_sFilePath);

    if (!KvGotoFirstSubKey(kv)) {
        return;
    }

    g_iLevelIcons = 0;

    do {
        KvGetString(kv, "name", g_LevelIcons[g_iLevelIcons].sName, sizeof(g_LevelIcons[].sName));

        g_LevelIcons[g_iLevelIcons].iIconIndex = KvGetNum(kv, "index");
        g_iLevelIcons++;
    } while (KvGotoNextKey(kv));
    kv.Close();

    for (int i = 0; i < g_iLevelIcons; ++i) {
		FormatEx(sBuffer, sizeof(sBuffer), "materials/panorama/images/icons/xp/level%i.png", g_LevelIcons[i].iIconIndex);
		AddFileToDownloadsTable(sBuffer);
	}
}

public void OnThinkPost(int m_iEntity)
{
	int m_iLevelTemp[MAXPLAYERS+1] = 0;
	GetEntDataArray(m_iEntity, m_iOffset, m_iLevelTemp, MAXPLAYERS+1);

	for (int i = 1; i <= MaxClients; i++) {
		if (g_PlayerData[i].iEmojiData > 0) {
			if (g_PlayerData[i].iEmojiData != m_iLevelTemp[i]) {
				SetEntData(m_iEntity, m_iOffset + (i * 4), g_PlayerData[i].iEmojiData);
			}
		}
	}
}