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
#define VERSION "1.1.2"
#define UPDATE_URL "https://sys.froidgaming.net/FroidName/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/custom_functions.sp"
#include "files/API.sp"

public Plugin myinfo =
{
    name = "[FroidApp] Name Filter",
    author = "FroidGaming.net",
    description = "Name Filter.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    httpClient = new HTTPClient("https://froidgaming.net");

    HookEvent("player_changename", Event_OnPlayerChangeNamePost, EventHookMode_Post);
	HookEvent("player_changename", Event_OnPlayerChangeNamePre, EventHookMode_Pre);
    HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Post);

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

public bool OnClientConnect(int iClient, char[] sRejectmsg, int iMaxlen)
{
    if (!IsFakeClient(iClient)) {
        int iPosition;
		bool bFixName = false;
		char sPlayerName[MAX_NAME_LENGTH], sTemp[5], sFixedName[MAX_NAME_LENGTH];
        GetClientName(iClient, sPlayerName, sizeof(sPlayerName));

        while (sPlayerName[iPosition] != 0 && iPosition < sizeof(sPlayerName)) {
			int iByte = IsCharMB(sPlayerName[iPosition]);

			if (!iByte) {
                iByte = 1;
            }

			Format(sTemp, iByte + 1, "%s", sPlayerName[iPosition]);

			if (iByte < 4) {
                StrCat(sFixedName, sizeof(sFixedName), sTemp);
            } else if (iByte >= 4) {
                bFixName = true;
            }

			iPosition += iByte;
		}

		if (bFixName) {
			SetClientInfo(iClient, "name", sFixedName);
			g_PlayerData[iClient].bBlockMessage = true;
		}
    }
    return true;
}

public Action Event_OnPlayerTeam(Handle hEvent, char[] sName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if (IsValidClient(iClient) && g_PlayerData[iClient].bBlockMessage) {
		char sPlayerName[MAX_NAME_LENGTH];
		GetClientName(iClient, sPlayerName, sizeof(sPlayerName));

        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            CPrintToChat(iClient, "%s Kamu tidak dapat menggunakan nickname itu! Mohon ganti nickname kamu...", PREFIX);
        } else {
            CPrintToChat(iClient, "%s You cant use that nickname! Please change your nickname...", PREFIX);
        }

        g_PlayerData[iClient].bBlockMessage = false;
	}
}

public Action Event_OnPlayerChangeNamePre(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

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

        if (g_PlayerData[iClient].bBlockMessage) {
            SetEventBroadcast(hEvent, true);
            return Plugin_Changed;
        }

        g_PlayerData[iClient].bBlockMessage = false;
    }

    return Plugin_Continue;
}

public Action Event_OnPlayerChangeNamePost(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

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

        int iPosition;
		bool bFixName = false;
		char sNewName[MAX_NAME_LENGTH], sTemp[5], sFixedName[MAX_NAME_LENGTH];
		GetEventString(hEvent, "newname", sNewName, MAX_NAME_LENGTH);
		while (sNewName[iPosition] != 0 && iPosition < sizeof(sNewName)) {
			int iByte = IsCharMB(sNewName[iPosition]);

			if (!iByte) {
                iByte = 1;
            }

			Format(sTemp, iByte + 1, "%s", sNewName[iPosition]);

			if (iByte < 4) {
                StrCat(sFixedName, sizeof(sFixedName), sTemp);
            } else if(iByte >= 4) {
                bFixName = true;
            }

			iPosition += iByte;
		}

		if (bFixName) {
			g_PlayerData[iClient].bBlockMessage = true;
			SetClientInfo(iClient, "name", sFixedName);
			SetEntPropString(iClient, Prop_Data, "m_szNetname", sFixedName);
			if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
                CPrintToChat(iClient, "%s Kamu tidak dapat menggunakan nickname itu! Mohon ganti nickname kamu...", PREFIX);
            } else {
                CPrintToChat(iClient, "%s You cant use that nickname! Please change your nickname...", PREFIX);
            }
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