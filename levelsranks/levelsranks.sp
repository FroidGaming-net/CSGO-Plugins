/***************************************************************************
****
****		Date of creation :			November 27, 2014
****		Date of official release :	April 12, 2015
****		Last update :				November 15, 2019
****
****************************************************************************
****
****		Authors:
****
****		RoadSide Romeo
****		( main development v1.0 - v3.0)
****
****		Wend4r
****		( main development v3.1)
****
****		Development assistance:
****
****		https://github.com/levelsranks/levels-ranks-core/graphs/contributors
****
***************************************************************************/

#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <profiler>
#include <ripext>
#undef REQUIRE_PLUGIN
#include <updater>

#if SOURCEMOD_V_MINOR < 10
	#error This plugin can only compile on SourceMod 1.10.
#endif

#pragma newdecls required
#pragma tabsize 4

#include <lvl_ranks>

#if !defined SPPP_COMPILER
	#define decl static
#endif

#if !defined PLUGIN_INT_VERSION || PLUGIN_INT_VERSION != 03010600
	#error This plugin can only compile on lvl_ranks.inc v3.1.6.
#endif

#define PLUGIN_NAME "Levels Ranks"
#define PLUGIN_AUTHORS "RoadSide Romeo & Wend4r"
#define PLUGIN_URL "https://github.com/levelsranks/levels-ranks-core"
#define UPDATE_URL "https://sys.froidgaming.net/levelsranks/updatefile.txt"

HTTPClient httpClient;
ConVar g_cHostname = null;

#include "levels_ranks/defines.sp"

enum struct LR_PlayerInfo
{
	bool bHaveBomb;
	bool bInitialized;

	int  iAccountID;
	int  iStats[LR_StatsType];
	int  iSessionStats[LR_StatsType];
	int  iRoundExp;
	int  iKillStreak;

	// Put it in players.sp and recreate the logic from TODO.
}

any             g_Settings[LR_SettingType],
                g_SettingsStats[LR_SettingStatsType];

bool            g_bCoreIsLoaded,
                g_bAllowStatistic,
                g_bDatabaseSQLite;

int             g_iBonus[10], 		// Special_Bonuses from settings_stats.ini .
                g_iDBCountPlayers;

char            g_sPluginName[] = PLUGIN_NAME,
                g_sPluginTitle[64],
                g_sTableName[32],
                g_sSoundUp[PLATFORM_MAX_PATH],
                g_sSoundDown[PLATFORM_MAX_PATH];

LR_PlayerInfo   g_iPlayerInfo[MAXPLAYERS + 1],
                g_iInfoNULL;		// What?

GlobalForward   g_hForward_OnCoreIsReady;

PrivateForward  g_hForward_Hook[LR_HookType],
                g_hForward_CreatedMenu[LR_MenuType],
                g_hForward_SelectedMenu[LR_MenuType];

EngineVersion   g_iEngine;		// Init in api.sp

ArrayList       g_hRankNames,
                g_hRankExp;

Cookie          g_hLastResetMyStats;

Database        g_hDatabase;

#include "levels_ranks/settings.sp"
#include "levels_ranks/database.sp"
#include "levels_ranks/commands.sp"
#include "levels_ranks/menus.sp"
#include "levels_ranks/custom_functions.sp"
#include "levels_ranks/events.sp"
#include "levels_ranks/api.sp"

public Plugin myinfo =
{
	name = "[" ... PLUGIN_NAME ... "] Core",
	author = PLUGIN_AUTHORS,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnPluginStart()
{
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations(g_iEngine == Engine_SourceSDK2006 ? "lr_core_old.phrases" : "lr_core.phrases");
	LoadTranslations("lr_core_ranks.phrases");

	RegConsoleCmd("sm_rank", Call_MainMenu, "Opens the statistics menu");
	RegConsoleCmd("sm_lvl", Call_MainMenu, "Opens the statistics menu");
	RegConsoleCmd("sm_mm", Call_MainMenu, "Opens the statistics menu");
	RegAdminCmd("sm_lvl_reload", Call_ReloadSettings, ADMFLAG_ROOT, "Reloads core and module configuration files");
	RegConsoleCmd("sm_resetrank", Call_ResetRank, "Resets your own rank");

	HookEvents();
	SetSettings();
	ConnectDB();

	httpClient = new HTTPClient("https://froidgaming.net");
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

public void OnConfigsExecuted()
{
    g_cHostname = FindConVar("hostname");
}

public void OnMapStart()
{
	if(g_Settings[LR_IsLevelSound])
	{
		static char sSoundPath[PLATFORM_MAX_PATH + 6] = "sound/";

		strcopy(sSoundPath[6], sizeof(g_sSoundUp), g_sSoundUp);
		AddFileToDownloadsTable(sSoundPath);

		strcopy(sSoundPath[6], sizeof(g_sSoundDown), g_sSoundDown);
		AddFileToDownloadsTable(sSoundPath);

		PrecacheSound(g_sSoundUp);
		PrecacheSound(g_sSoundDown);
	}

	OnCleanDB();
}

public void OnPluginEnd()
{
	for(int i = GetMaxPlayers(); --i;)
	{
		if(g_iPlayerInfo[i].bInitialized)
		{
			SaveDataPlayer(i, true);
		}
	}
}

void ResetMenu(int iClient)
{
	if(CheckCommandAccess(iClient, "sm_levelsranks_premiumplus", ADMFLAG_CUSTOM6))
	{
		decl char sText[192];

		Menu hMenu = new Menu(ResetMenu_Callback);

		hMenu.SetTitle("%s | %T\n ", g_sPluginTitle, "MyStatsResetInfo", iClient);

		FormatEx(sText, sizeof(sText), "%T", "Yes", iClient);
		hMenu.AddItem("yes", sText);

		FormatEx(sText, sizeof(sText), "%T", "No", iClient);
		hMenu.AddItem("no", sText);

		hMenu.ExitButton = false;
		hMenu.Display(iClient, MENU_TIME_FOREVER);
	}else{
		LR_PrintMessage(iClient, true, false, "{LIGHTBLUE}!resetrank {DEFAULT}Only can be used by Premium+. Buy Premium+ Now! @ {LIGHTBLUE}froidgaming.net");
	}
}

int ResetMenu_Callback(Menu hMenu, MenuAction mAction, int iClient, int itemNum)
{
    if (mAction == MenuAction_Select) {
        char info[20];
        GetMenuItem(hMenu, itemNum, info, sizeof(info));
        if (StrEqual(info, "yes")) {
			char sAuthID[32];
			GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));

			char sUrl[128];
			Format(sUrl, sizeof(sUrl), "api/resetrank/%s", sAuthID);

			char sHostname[64];
			g_cHostname.GetString(sHostname, sizeof(sHostname));

			JSONObject payload = new JSONObject();
			if(StrContains(sHostname, "PUG") > -1){
				payload.SetString("mode", "pug");
			}else if(StrContains(sHostname, "Retakes") > -1){
				payload.SetString("mode", "retakes");
			}else if(StrContains(sHostname, "Executes") > -1){
				payload.SetString("mode", "executes");
			}else if(StrContains(sHostname, "FFA") > -1){
				payload.SetString("mode", "ffa");
			}else if(StrContains(sHostname, "Arena") > -1){
				payload.SetString("mode", "arena");
			}else if(StrContains(sHostname, "AWP") > -1){
				payload.SetString("mode", "awp");
			}
			httpClient.Put(sUrl, payload, ResetClientRank, GetClientUserId(iClient));

			delete payload;
        } else if(StrEqual(info, "no")) {
			LR_PrintMessage(iClient, true, false, "{DEFAULT}Cancelled!");
		}
    } else if (mAction == MenuAction_End) {
		delete hMenu;
	}
}

void ResetClientRank(HTTPResponse response, any value)
{
	int iClient = GetClientOfUserId(value);

	if (!IsClientInGame(iClient)) {
        return;
    }

	if (response.Status != HTTPStatus_OK) {
        LR_PrintMessage(iClient, true, false, "Failed to retrieve data from FroidAPI. Please try again!");
		LogError("Failed to retrieve data from FroidAPI [Action : resetrank].");
        return;
    }

    if (response.Data == null) {
        LR_PrintMessage(iClient, true, false, "Invalid JSON response from FroidAPI. Please try again!");
		LogError("Invalid JSON response from FroidAPI [Action : resetrank].");
        return;
    }

	JSONObject jsondata = view_as<JSONObject>(response.Data);

	bool bStatus = jsondata.GetBool("status");
	if(bStatus){
		char sAuthID[64];
		GetClientAuthId(iClient, AuthId_Steam2, sAuthID, sizeof(sAuthID));

		char sBuffer[256];
		ResetPlayerStats(iClient);
		CallForward_OnResetPlayerStats(iClient, g_iPlayerInfo[iClient].iAccountID);
		Format(sBuffer, sizeof(sBuffer), SQL_UPDATE_RESET_DATA, g_sTableName, sAuthID);
		g_hDatabase.Query(SQL_Callback, sBuffer, 0);

		LR_PrintMessage(iClient, true, false, "The rank has been reset");
	}else{
		char sMsg[256];
		jsondata.GetString("message", sMsg, sizeof(sMsg));
		LR_PrintMessage(iClient, true, false, sMsg);
	}
	delete jsondata;
}
