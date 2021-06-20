#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

#define PLUGIN_AUTHOR "RumbleFrog, SourceBans++ Dev Team"
#define PLUGIN_VERSION "1.7.0"
#define BASE_URL "http://ip-api.com"

#include <sourcemod>
#include <sourcebanspp>
#include <discord_extended>
#include <geoip>
#include <sdktools>
#include <multicolors>
#include <ripext>
#undef REQUIRE_PLUGIN
#include <froidmatch>

#pragma newdecls required

#define Chat_Prefix "[{lightblue}SourceBans++{default}] "

enum
{
	Cooldown = 0,
	MinLen,
	Settings_Count
};

ConVar Convars[Settings_Count];

bool bInReason[MAXPLAYERS + 1];

int iMinLen = 10
	, iTargetCache[MAXPLAYERS + 1];

float fCooldown = 60.0
	, fNextUse[MAXPLAYERS + 1];

ConVar g_cHostname = null;
char g_sHostname[64];
char g_sCountryCode[3], g_sIP[50];

public Plugin myinfo =
{
	name = "SourceBans++ Report Plugin",
	author = PLUGIN_AUTHOR,
	description = "Adds ability for player to report offending players",
	version = PLUGIN_VERSION,
	url = "https://sbpp.github.io"
};

public void OnPluginStart()
{
	g_cHostname = FindConVar("hostname");

	CreateConVar("sbpp_report_version", PLUGIN_VERSION, "SBPP Report Version", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);

	Convars[Cooldown] = CreateConVar("sbpp_report_cooldown", "60.0", "Cooldown in seconds between per report per user", FCVAR_NONE, true, 0.0, false);
	Convars[MinLen] = CreateConVar("sbpp_report_minlen", "10", "Minimum reason length", FCVAR_NONE, true, 0.0, false);

	LoadTranslations("sbpp_report.phrases");

	RegConsoleCmd("sm_report", CmdReport, "Initialize Report");

	Convars[Cooldown].AddChangeHook(OnConvarChanged);
	Convars[MinLen].AddChangeHook(OnConvarChanged);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("GetDemoName");
    return APLRes_Success;
}

public void OnClientPutInServer(int iClient)
{
	if(IsValidClient(iClient))
	{
		ResetInReason(iClient);
		fNextUse[iClient] = 0.0;
	}
}

public void OnClientDisconnect(int iClient)
{
	if(IsValidClient(iClient))
	{
		ResetInReason(iClient);
		fNextUse[iClient] = 0.0;
	}
}

public Action CmdReport(int iClient, int iArgs)
{
	if(IsValidClient(iClient))
	{
		if(OnCooldown(iClient))
		{
			CPrintToChat(iClient, "%s%T", Chat_Prefix, "In Cooldown", iClient, GetRemainingTime(iClient));
		}else{
			Menu hMenu = new Menu(ReportMenu_Callback, MenuAction_Select);
			hMenu.SetTitle("★ Choose a report type ★");
			hMenu.AddItem("player", "• Player •");
			hMenu.AddItem("server", "• Server •");
			hMenu.Display(iClient, MENU_TIME_FOREVER);
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public int ReportMenu_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
			char sInfo[30];

			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));
			if(StrEqual(sInfo, "player"))
			{
				PlayerMenu(iClient);
			}else if (StrEqual(sInfo, "server"))
			{
				ServerMenu(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

public void PlayerMenu(int iClient)
{
	if (!IsValidClient(iClient))
		return;

	Menu PList = new Menu(PlayerMenu_Callback);

	char sName[MAX_NAME_LENGTH], sIndex[4];

	PList.SetTitle("★ Choose a report reason ★");
	for (int i = 0; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || i == iClient)
			continue;

		Format(sName, sizeof(sName), "» %N", i);
		IntToString(i, sIndex, sizeof(sIndex));

		PList.AddItem(sIndex, sName);
	}
	PList.ExitBackButton = true;
	PList.Display(iClient, MENU_TIME_FOREVER);
}

public int PlayerMenu_Callback(Menu menu, MenuAction action, int iClient, int iItem)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sIndex[4];

			menu.GetItem(iItem, sIndex, sizeof sIndex);

			iTargetCache[iClient] = StringToInt(sIndex);

			bInReason[iClient] = true;

			GetClientIP(iClient, g_sIP, sizeof(g_sIP));
			GeoipCode2(g_sIP, g_sCountryCode);

			if(StrEqual(g_sCountryCode, "ID")){
				CPrintToChat(iClient, "%s Silahkan ketik {purple}alasan{default} laporan kamu atau ketik {lightred}cancel{default} untuk membatalkan!", Chat_Prefix);
			}else{
				CPrintToChat(iClient, "%s Please enter {purple}the reason{default} for the report or {lightred}cancel{default} to cancel!", Chat_Prefix);
			}
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(iClient) && iItem == MenuCancel_ExitBack)
			{
				CmdReport(iClient, 0);
			}
		}
		case MenuAction_End:
			delete menu;
	}
}

public void ServerMenu(int iClient)
{
    Menu hMenu = new Menu(ServerMenu_Callback);
    hMenu.SetTitle("★ Choose a report reason ★");
	hMenu.AddItem("fpsdp", "» Server FPS Drop");
	hMenu.AddItem("crash", "» Server Crashing");
	hMenu.AddItem("svvar", "» High SV/Var");
	hMenu.AddItem("sloss", "» High Ping/Loss");
	hMenu.AddItem("skins", "» Skins not loading");
	hMenu.AddItem("ranks", "» Rank not showing");
	hMenu.AddItem("mapss", "» Map not changing");
	hMenu.AddItem("spawn", "» Spawn location bug");
	hMenu.ExitBackButton = true;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int ServerMenu_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
			char sInfo[30], sIP[64], sUrl[256];

			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));
			GetClientIP(iClient, sIP, sizeof(sIP));

			DataPack pack = new DataPack();
			pack.WriteCell(GetClientUserId(iClient));
			pack.WriteString(sInfo);
			Format(sUrl, sizeof(sUrl), "%s/json/%s", BASE_URL, sIP);
			HTTPRequest request = new HTTPRequest(sUrl);
			request.Get(OnGetReport, pack);
			AddCooldown(iClient);
			CPrintToChat(iClient, "%s%T", Chat_Prefix, "Report Sent", iClient);
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(iClient) && iSlot == MenuCancel_ExitBack)
			{
				CmdReport(iClient, 0);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void OnGetReport(HTTPResponse response, DataPack pack)
{
    pack.Reset();
    int iClient = GetClientOfUserId(pack.ReadCell());
	char sInfo[30];
    pack.ReadString(sInfo, sizeof(sInfo));
    CloseHandle(pack);

    if (IsValidClient(iClient)){
        if (response.Status != HTTPStatus_OK) {
            PrintToServer("[OnGetReport] Failed to retrieve response from FroidAPI");
            LogError("[OnGetReport] HTTPStatus_OK failed [1]");
            return;
        }
        if (response.Data == null) {
            PrintToServer("[OnGetReport] Invalid JSON Response");
            LogError("[OnGetReport] Invalid JSON Response [1]");
            return;
        }
		char 	sAuthid[32],
				sMapName[64],
				sIP[1024],
				sStatus[30],
				sReason[1024];

        JSONObject json1 = view_as<JSONObject>(response.Data);
		json1.GetString("status", sStatus, sizeof(sStatus));
        if(StrEqual(sStatus, "success")){
			char 	sCountry[64],
					sRegion[30],
					sCity[30],
					sASN[100],
					sIP_Temp[64];
            json1.GetString("country", sCountry, sizeof(sCountry));
			json1.GetString("regionName", sRegion, sizeof(sRegion));
			json1.GetString("city", sCity, sizeof(sCity));
			json1.GetString("as", sASN, sizeof(sASN));
			GetClientIP(iClient, sIP_Temp, sizeof(sIP_Temp));
			Format(sIP, sizeof(sIP), "%s | %s | %s | %s | %s", sIP_Temp, sCountry, sRegion, sCity, sASN);
        }else if(StrEqual(sStatus, "fail")){
            GetClientIP(iClient, sIP, sizeof(sIP));
        }else{
            GetClientIP(iClient, sIP, sizeof(sIP));
        }

		if(StrEqual(sInfo, "svvar"))
		{
			FormatEx(sReason, sizeof(sReason), "High SV/Var values");
		}else if (StrEqual(sInfo, "sloss"))
		{
			FormatEx(sReason, sizeof(sReason), "High Ping/Loss");
		}else if (StrEqual(sInfo, "skins"))
		{
			FormatEx(sReason, sizeof(sReason), "Skins not loading");
		}else if (StrEqual(sInfo, "ranks"))
		{
			FormatEx(sReason, sizeof(sReason), "Rank not showing");
		}else if (StrEqual(sInfo, "mapss"))
		{
			FormatEx(sReason, sizeof(sReason), "Map not changing");
		}else if (StrEqual(sInfo, "spawn"))
		{
			FormatEx(sReason, sizeof(sReason), "Spawn location bug");
		}else if (StrEqual(sInfo, "crash"))
		{
			FormatEx(sReason, sizeof(sReason), "Server crashing");
		}else if (StrEqual(sInfo, "fpsdp"))
		{
			FormatEx(sReason, sizeof(sReason), "Server FPS Drop");
		}

		GetClientAuthId(iClient, AuthId_Steam2, sAuthid, sizeof(sAuthid));
		GetCurrentMap(sMapName, sizeof(sMapName));
		g_cHostname = FindConVar("hostname");
		g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));

		// Discord
		Discord_StartMessage();
		Discord_SetUsername("FroidGaming.net");
		Discord_SetTitle(NULL_STRING, "★ Server Report ★");
		/// Content
		char szBody[2][1048];
		GetClientAuthId(iClient, AuthId_SteamID64, szBody[0], sizeof(szBody[]));
		GetClientName(iClient, szBody[1], sizeof(szBody[]));
		EscapeString(szBody[1], sizeof(szBody[]));

		Format(szBody[0], sizeof(szBody[]), "» [%s](https://steamcommunity.com/profiles/%s/) (%s)", szBody[1], szBody[0], sAuthid);
		Discord_AddField("• Player :", szBody[0], false);

		Format(szBody[0], sizeof(szBody[]), "» %s", sReason);
		Discord_AddField("• Reason :", szBody[0], false);

		Format(szBody[0], sizeof(szBody[]), "» %s", sMapName);
		Discord_AddField("• Map :", szBody[0], false);

		Format(szBody[0], sizeof(szBody[]), "» %s", sIP);
		Discord_AddField("• IP Address :", szBody[0], false);

		Format(szBody[0], sizeof(szBody[]), "» %s", g_sHostname);
		Discord_AddField("• Server :", szBody[0], false);

		FormatEx(szBody[0], sizeof(szBody[]), "» Ping [in : %i ms <> out : %i ms] | Choke [in : %i <> out : %i] | Loss [in : %i <> out : %i]", RoundFloat(GetClientAvgLatency(iClient, NetFlow_Incoming) * 1000.0), RoundFloat(GetClientAvgLatency(iClient, NetFlow_Outgoing) * 1000.0), RoundFloat(GetClientAvgChoke(iClient, NetFlow_Incoming) * 100.0), RoundFloat(GetClientAvgChoke(iClient, NetFlow_Outgoing) * 100.0), RoundFloat(GetClientAvgLoss(iClient, NetFlow_Incoming) * 100.0), RoundFloat(GetClientAvgLoss(iClient, NetFlow_Outgoing) * 100.0));
		Discord_AddField("• Data :", szBody[0], false);

		FormatEx(szBody[0], sizeof(szBody[]), "» <@&583584442287652876>");
		Discord_AddField("• Tags :", szBody[0], false);
		/// Content
		Discord_EndMessage("report_server", true);
		/// Discord

        delete json1;
        return;
    }
}

public Action OnClientSayCommand(int iClient, const char[] sCommand, const char[] sArgs)
{
	if (!bInReason[iClient])
		return Plugin_Continue;

	if (!IsValidClient(iClient) || (iTargetCache[iClient] != -1 && !IsValidClient(iTargetCache[iClient])))
	{
		ResetInReason(iClient);

		return Plugin_Continue;
	}

	if(StrContains(sArgs, "cancel") > -1)
	{
		CPrintToChat(iClient, "%s%T", Chat_Prefix, "Report Canceled", iClient);

		ResetInReason(iClient);

		return Plugin_Stop;
	}

	if (strlen(sArgs) < iMinLen)
	{
		GetClientIP(iClient, g_sIP, sizeof(g_sIP));
		GeoipCode2(g_sIP, g_sCountryCode);

		if(StrEqual(g_sCountryCode, "ID")){
			CPrintToChat(iClient, "%s Alasan terlalu pendek, jelaskan secara rinci! Tulis ulang secara rinci ya...", Chat_Prefix);
		}else{
			CPrintToChat(iClient, "%s Reason is too short, more details is required! Please rewrite it with more details...", Chat_Prefix);
		}

		return Plugin_Stop;
	}

	SBPP_ReportPlayer(iClient, iTargetCache[iClient], sArgs);

	/// Discord
	Discord_StartMessage();
	Discord_SetUsername("FroidGaming.net");
	Discord_SetTitle(NULL_STRING, "★ Player Report ★");

	// All
	char 	sMapName[64],
			sDemoName[256] = "No Demo",
			szBody[6][1048];
	g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));
	GetCurrentMap(sMapName, sizeof(sMapName));
	GetDemoName(sDemoName, sizeof(sDemoName));
	if(StrContains(sDemoName, "No Demo") > -1){
		Format(sDemoName, sizeof(sDemoName), "Demo Unavailable");
	}else{
		Format(sDemoName, sizeof(sDemoName), "[Click Here](%s)", sDemoName);
	}
	// Client
	GetClientName(iClient, szBody[0], sizeof(szBody[]));
	GetClientAuthId(iClient, AuthId_SteamID64, szBody[1], sizeof(szBody[]));
	GetClientAuthId(iClient, AuthId_Engine, szBody[2], sizeof(szBody[]));
	EscapeString(szBody[0], sizeof(szBody[]));
	// Target
	GetClientName(iTargetCache[iClient], szBody[3], sizeof(szBody[]));
	GetClientAuthId(iTargetCache[iClient], AuthId_SteamID64, szBody[4], sizeof(szBody[]));
	GetClientAuthId(iTargetCache[iClient], AuthId_Engine, szBody[5], sizeof(szBody[]));
	EscapeString(szBody[3], sizeof(szBody[]));

	/// Content
	Format(szBody[0], sizeof(szBody[]), "» [%s](https://steamcommunity.com/profiles/%s/) (%s) has reported [%s](https://steamcommunity.com/profiles/%s/) (%s)", szBody[0], szBody[1], szBody[2], szBody[3], szBody[4], szBody[5]);
	Discord_AddField("• Player :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %s", sArgs);
	Discord_AddField("• Reason :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %s", sMapName);
	Discord_AddField("• Map :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %d", GetRoundCount());
	Discord_AddField("• Round :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %s", sDemoName);
	Discord_AddField("• Demo :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %s", g_sHostname);
	Discord_AddField("• Server :", szBody[0], false);

	FormatEx(szBody[0], sizeof(szBody[]), "» <@&583584442287652876>");
	Discord_AddField("• Tags :", szBody[0], false);
	/// Content
	Discord_EndMessage("report_player", true);
	AddCooldown(iClient);
	/// Discord

	AddCooldown(iClient);

	ResetInReason(iClient);

	return Plugin_Stop;
}

public void SBPP_OnReportPlayer(int iReporter, int iTarget, const char[] sReason)
{
	if (!IsValidClient(iReporter))
		return;

	CPrintToChat(iReporter, "%s%T", Chat_Prefix, "Report Sent", iReporter);
}

void ResetInReason(int iClient)
{
	bInReason[iClient] = false;
	iTargetCache[iClient] = -1;
}

void AddCooldown(int iClient)
{
	fNextUse[iClient] = GetGameTime() + fCooldown;
}

bool OnCooldown(int iClient)
{
	return (fNextUse[iClient] - GetGameTime()) > 0.0;
}

float GetRemainingTime(int iClient)
{
	float fOffset = fNextUse[iClient] - GetGameTime();

	if (fOffset > 0.0)
		return fOffset;
	else
		return 0.0;
}

public void OnConvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == Convars[Cooldown])
		fCooldown = Convars[Cooldown].FloatValue;
	else if (convar == Convars[MinLen])
		iMinLen = Convars[MinLen].IntValue;
}

stock bool IsValidClient(int client)
{
	if(client <= 0) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	if(IsFakeClient(client)) return false;
	if(IsClientSourceTV(client)) return false;
	return IsClientInGame(client);
}

stock int GetRoundCount()
{
	return GameRules_GetProp("m_totalRoundsPlayed");
}

void EscapeString(char[] string, int maxlen)
{
	ReplaceString(string, maxlen, "@", "＠");
	ReplaceString(string, maxlen, "'", "\'");
	ReplaceString(string, maxlen, "\"", "＂");
}