#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <sourcebanspp>
#include <teasyftp>
#include <discord_extended>
#include <multicolors>
#include <froidmatch>

#undef REQUIRE_EXTENSIONS
#include <bzip2>

#undef REQUIRE_PLUGIN
#include <pugsetup>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 0

#define PLUGIN_VERSION "1.0.1"

ConVar g_cHostname = null;
char g_sHostname[64];

char g_cServerIP[40];
char g_cStatus[1024];
char g_cLines[3][100];
char g_cIPs[8][50];

char g_cServerPort[2][100];
char g_cPort[16];

#define URL_DOWNLOAD "https://cdn.froidgaming.xyz/demo"
char demoname[512] = "No Demo";
char demoname_upload[512] = "No Demo";
char demoname_download[512] = "No Demo";

Handle db;

int g_iBzip2 = 9;
char g_sDemoPath[PLATFORM_MAX_PATH];
bool g_bRecording = false;

public Plugin myinfo =
{
	name = "FroidMatch",
	author = "FroidGaming.net"
}

ConVar g_hTvEnabled = null;
ConVar g_hAutoRecord = null;
ConVar g_hMinPlayersStart = null;
ConVar g_hIgnoreBots = null;
ConVar g_hTimeStart = null;
ConVar g_hTimeStop = null;
ConVar g_hFinishMap = null;
ConVar g_hDemoPath = null;

bool g_bIsRecording = false;
bool g_bIsManual = false;

public void OnPluginStart()
{
    char buffer[1024];

	if ((db = SQL_Connect("sql_matches", true, buffer, sizeof(buffer))) == null)
	{
		SetFailState(buffer);
	}

	HookEventEx("cs_win_panel_match", cs_win_panel_match);

	CreateConVar("sm_autorecord_version", PLUGIN_VERSION, "FroidGaming Match plugin version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	g_hAutoRecord = CreateConVar("sm_autorecord_enable", "1", "Enable automatic recording", _, true, 0.0, true, 1.0);
	g_hMinPlayersStart = CreateConVar("sm_autorecord_minplayers", "4", "Minimum players on server to start recording", _, true, 0.0);
	g_hIgnoreBots = CreateConVar("sm_autorecord_ignorebots", "1", "Ignore bots in the player count", _, true, 0.0, true, 1.0);
	g_hTimeStart = CreateConVar("sm_autorecord_timestart", "-1", "Hour in the day to start recording (0-23, -1 disables)");
	g_hTimeStop = CreateConVar("sm_autorecord_timestop", "-1", "Hour in the day to stop recording (0-23, -1 disables)");
	g_hFinishMap = CreateConVar("sm_autorecord_finishmap", "1", "If 1, continue recording until the map ends", _, true, 0.0, true, 1.0);
	g_hDemoPath = CreateConVar("sm_autorecord_path", "demos", "Path to store recorded demos");

	AutoExecConfig(true, "autorecorder");

	RegAdminCmd("sm_record", Command_Record, ADMFLAG_KICK, "Starts a SourceTV demo");
	RegAdminCmd("sm_stoprecord", Command_StopRecord, ADMFLAG_KICK, "Stops the current SourceTV demo");
	RegConsoleCmd("sm_demo", Command_Demo, "Starts a SourceTV demo");

	g_hTvEnabled = FindConVar("tv_enable");

	char sPath[PLATFORM_MAX_PATH];
	g_hDemoPath.GetString(sPath, sizeof(sPath));
	if(!DirExists(sPath))
	{
		InitDirectory(sPath);
	}

	g_hMinPlayersStart.AddChangeHook(OnConVarChanged);
	g_hIgnoreBots.AddChangeHook(OnConVarChanged);
	g_hTimeStart.AddChangeHook(OnConVarChanged);
	g_hTimeStop.AddChangeHook(OnConVarChanged);
	g_hDemoPath.AddChangeHook(OnConVarChanged);

	CreateTimer(30.0, Timer_CheckStatus, _, TIMER_REPEAT);

	StopRecord();
	CheckStatus();

	AddCommandListener(CommandListener_Record, "tv_record");
	AddCommandListener(CommandListener_StopRecord, "tv_stoprecord");
	AddCommandListener(CommandListener_StopRecord, "tv_stop");
	CreateTimer(10.0, Timer_Setting);
}

public Action Timer_Setting(Handle hTimer)
{
	g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));

	ServerCommandEx(g_cStatus, sizeof(g_cStatus), "status");
	ExplodeString(g_cStatus, "\n", g_cLines, sizeof(g_cLines), sizeof(g_cLines[]));
	ExplodeString(g_cLines[2], " ", g_cIPs, sizeof(g_cIPs), sizeof(g_cIPs[]));
	strcopy(g_cServerIP, sizeof(g_cServerIP), g_cIPs[7]);
	ReplaceString(g_cServerIP, sizeof(g_cServerIP), ")", "");

	ExplodeString(g_cIPs[3], ":", g_cServerPort, sizeof(g_cServerPort), sizeof(g_cServerPort[]));
	strcopy(g_cPort, sizeof(g_cPort), g_cServerPort[1]);
}

public int GetConVarValueInt(const char[] sConVar) {
    Handle hConVar = FindConVar(sConVar);
    int iResult = GetConVarInt(hConVar);
    CloseHandle(hConVar);
    return iResult;
}

public void OnMapStart()
{
	Format(demoname, sizeof(demoname), "No Demo");
	Format(demoname_download, sizeof(demoname_download), "No Demo");
	if(GetConVarValueInt("tv_enable") != 1) {
		SetFailState("SourceTV System is disabled. You don't need this plugin.");
		return;
	}

	g_bRecording = false;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("GetDemoName", Native_GetDemoName);
	return APLRes_Success;
}

public int Native_GetDemoName(Handle plugin, int numParams)
{
	int len = GetNativeCell(2);
	SetNativeString(1, demoname_download, len, false);
	return;
}

public Action CommandListener_Record(int client, const char[] command, int argc) {
	if(g_bRecording)return;

	GetCmdArg(1, g_sDemoPath, sizeof(g_sDemoPath));

	if(!StrEqual(g_sDemoPath, "")) {
		g_bRecording = true;
	}

	// Append missing .dem
	if(strlen(g_sDemoPath) < 4 || strncmp(g_sDemoPath[strlen(g_sDemoPath)-4], ".dem", 4, false) != 0) {
		Format(g_sDemoPath, sizeof(g_sDemoPath), "%s.dem", g_sDemoPath);
	}
}

public Action CommandListener_StopRecord(int client, const char[] command, int argc) {
	if(g_bRecording) {
		Handle hDataPack = CreateDataPack();
		CreateDataTimer(5.0, Timer_UploadDemo, hDataPack);
		WritePackString(hDataPack, g_sDemoPath);

		Format(g_sDemoPath, sizeof(g_sDemoPath), "");
	}

	g_bRecording = false;
}

public Action Timer_UploadDemo(Handle timer, Handle hDataPack) {
	ResetPack(hDataPack);

	char sDemoPath[PLATFORM_MAX_PATH];
	ReadPackString(hDataPack, sDemoPath, sizeof(sDemoPath));

	if(g_iBzip2 > 0 && g_iBzip2 < 10 && LibraryExists("bzip2")) {
		char sBzipPath[PLATFORM_MAX_PATH];
		Format(sBzipPath, sizeof(sBzipPath), "%s.bz2", sDemoPath);
		BZ2_CompressFile(sDemoPath, sBzipPath, g_iBzip2, CompressionComplete);
	} else {
		EasyFTP_UploadFile("demos", sDemoPath, "/", UploadComplete);
	}
}

public int CompressionComplete(BZ_Error iError, char[] inFile, char[] outFile, any data) {
	if(iError == BZ_OK) {
		LogMessage("%s compressed to %s", inFile, outFile);
		EasyFTP_UploadFile("demos", outFile, "/", UploadComplete);
	} else {
		LogBZ2Error(iError);
		EasyFTP_UploadFile("demos", inFile, "/", UploadComplete);
	}
}

public int UploadComplete(const char[] sTarget, const char[] sLocalFile, const char[] sRemoteFile, int iErrorCode, any data) {
	if(iErrorCode == 0) {
        char buffer[512];

        Transaction txn = SQL_CreateTransaction();
        Format(buffer, sizeof(buffer), "UPDATE sql_matches_scoretotal SET demo = '%s' WHERE ip = '%s:%s' ORDER BY `match_id` DESC LIMIT 1;", demoname_upload, g_cServerIP, g_cPort);
		SQL_AddQuery(txn, buffer);
        SQL_ExecuteTransaction(db, txn);

		DeleteFile(sLocalFile);
		if(StrEqual(sLocalFile[strlen(sLocalFile)-4], ".bz2")) {
			char sLocalNoCompressFile[PLATFORM_MAX_PATH];
			strcopy(sLocalNoCompressFile, strlen(sLocalFile)-3, sLocalFile);
			DeleteFile(sLocalNoCompressFile);
		}
	}else{
		DeleteFile(sLocalFile);
		if(StrEqual(sLocalFile[strlen(sLocalFile)-4], ".bz2")) {
			char sLocalNoCompressFile[PLATFORM_MAX_PATH];
			strcopy(sLocalNoCompressFile, strlen(sLocalFile)-3, sLocalFile);
			DeleteFile(sLocalNoCompressFile);
		}
	}

	for(int client = 1; client <= MaxClients; client++) {
		if(IsClientInGame(client) && GetAdminFlag(GetUserAdmin(client), Admin_Reservation)) {
			if(iErrorCode == 0) {
				PrintToChat(client, "[SourceTV] Demo uploaded successfully");
			} else {
				PrintToChat(client, "[SourceTV] Failed uploading demo file. Check the server log files.");
			}
		}
	}
}

void EscapeStringAllowAt(char[] string, int maxlen)
{
	ReplaceString(string, maxlen, "@", "＠");
	ReplaceString(string, maxlen, "'", "\'");
	ReplaceString(string, maxlen, "\"", "＂");
}

public void SBPP_OnBanPlayer(int admin, int iClient, int time, const char[] sReason){
	char sMapName[64];
	GetCurrentMap(sMapName, sizeof(sMapName));
	/// Discord
	Discord_StartMessage();
	Discord_SetUsername("FroidGaming.net");
	Discord_SetTitle(NULL_STRING, "★ Ban Details ★");

	/// Content
	char szBody[3][1048];
	GetClientName(iClient, szBody[0], sizeof(szBody[]));
	GetClientAuthId(iClient, AuthId_SteamID64, szBody[1], sizeof(szBody[]));
	GetClientAuthId(iClient, AuthId_Engine, szBody[2], sizeof(szBody[]));
	EscapeStringAllowAt(szBody[1], sizeof(szBody[]));

	if(StrContains(demoname_download, "No Demo") > -1){
		Format(demoname_download, sizeof(demoname_download), "Demo Unavailable");
	}else{
		Format(demoname_download, sizeof(demoname_download), "[Click Here](%s)", demoname_download);
	}

	Format(szBody[0], sizeof(szBody[]), "» [%s](https://steamcommunity.com/profiles/%s/) (%s)", szBody[0], szBody[1], szBody[2]);
	Discord_AddField("• Player :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %s", sReason);
	Discord_AddField("• Reason :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %s", sMapName);
	Discord_AddField("• Map :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %d", GetRoundCount());
	Discord_AddField("• Round :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %s", demoname_download);
	Discord_AddField("• Demo :", szBody[0], false);

	Format(szBody[0], sizeof(szBody[]), "» %s", g_sHostname);
	Discord_AddField("• Server :", szBody[0], false);

	FormatEx(szBody[0], sizeof(szBody[]), "» <@&583584442287652876>");
	Discord_AddField("• Tags :", szBody[0], false);
	/// Content
	Discord_EndMessage("ban_logger", true);
	/// Discord
}

public void cs_win_panel_match(Handle event, const char[] eventname, bool dontBroadcast)
{
	CreateTimer(0.1, delay, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action delay(Handle timer)
{
	Transaction txn = SQL_CreateTransaction();

	char mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));

	char teamname1[64];
	char teamname2[64];

	GetConVarString(FindConVar("mp_teamname_1"), teamname1, sizeof(teamname1));
	GetConVarString(FindConVar("mp_teamname_2"), teamname2, sizeof(teamname2));

	char buffer[512];
	char GameMode[32];
	g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));

    if(StrContains(g_sHostname, "Retakes") > -1){
		FormatEx(GameMode, sizeof(GameMode), "retakes");
    }else if(StrContains(g_sHostname, "PUG") > -1){
		FormatEx(GameMode, sizeof(GameMode), "pug");
	}else if(StrContains(g_sHostname, "Executes") > -1){
		FormatEx(GameMode, sizeof(GameMode), "executes");
	}else if(StrContains(g_sHostname, "Arena 1v1") > -1){
		FormatEx(GameMode, sizeof(GameMode), "1v1");
	}else if(StrContains(g_sHostname, "5v5") > -1){
		FormatEx(GameMode, sizeof(GameMode), "pug");
    }else if(StrContains(g_sHostname, "AWP") > -1){
		FormatEx(GameMode, sizeof(GameMode), "awp");
    }else{
		FormatEx(GameMode, sizeof(GameMode), "unknown");
	}
	Format(buffer, sizeof(buffer), "INSERT INTO sql_matches_scoretotal (team_0, team_1, team_2, team_3, teamname_1, teamname_2, map, type, ip) VALUES (0, 0, 0, 0, '%s', '%s', '%s', '%s', '%s:%s');", teamname1, teamname2, mapname, GameMode, g_cServerIP, g_cPort);
	SQL_AddQuery(txn, buffer);

	int ent = MaxClients+1;

	while ((ent = FindEntityByClassname(ent, "cs_team_manager")) != -1)
	{
		Format(buffer, sizeof(buffer), "UPDATE sql_matches_scoretotal SET team_%i = %i WHERE ip = '%s:%s' AND match_id = LAST_INSERT_ID();", GetEntProp(ent, Prop_Send, "m_iTeamNum"), GetEntProp(ent, Prop_Send, "m_scoreTotal"), g_cServerIP, g_cPort);
		SQL_AddQuery(txn, buffer);
	}

	char name[MAX_NAME_LENGTH];
	char steamid64[64];

	int m_iTeam;
	int m_bAlive;
	int m_iPing;
	int m_iAccount;
	int m_iKills;
	int m_iAssists;
	int m_iDeaths;
	int m_iMVPs;
	int m_iScore;

	if ((ent = FindEntityByClassname(-1, "cs_player_manager")) != -1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
			{
				continue;
			}

			m_iTeam = GetEntProp(ent, Prop_Send, "m_iTeam", _, i);
			m_bAlive = GetEntProp(ent, Prop_Send, "m_bAlive", _, i);
			m_iPing = GetEntProp(ent, Prop_Send, "m_iPing", _, i);
			m_iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			m_iKills = GetEntProp(ent, Prop_Send, "m_iKills", _, i);
			m_iAssists = GetEntProp(ent, Prop_Send, "m_iAssists", _, i);
			m_iDeaths = GetEntProp(ent, Prop_Send, "m_iDeaths", _, i);
			m_iMVPs = GetEntProp(ent, Prop_Send, "m_iMVPs", _, i);
			m_iScore = GetEntProp(ent, Prop_Send, "m_iScore", _, i);

			Format(name, MAX_NAME_LENGTH, "%N", i);
			SQL_EscapeString(db, name, name, sizeof(name));

			if (!GetClientAuthId(i, AuthId_SteamID64, steamid64, sizeof(steamid64)))
			{
				steamid64[0] = '\0';
			}

			Format(buffer, sizeof(buffer), "INSERT INTO sql_matches");
			Format(buffer, sizeof(buffer), "%s (match_id, team, alive, ping, name, account, kills, assists, deaths, mvps, score, steamid64)", buffer);
			Format(buffer, sizeof(buffer), "%s VALUES (LAST_INSERT_ID(), '%i', '%i', '%i', '%s', '%i', '%i', '%i', '%i', '%i', '%i', '%s');", buffer, m_iTeam, m_bAlive, m_iPing, name, m_iAccount, m_iKills, m_iAssists, m_iDeaths, m_iMVPs, m_iScore, steamid64);
			SQL_AddQuery(txn, buffer);
		}
	}

	SQL_ExecuteTransaction(db, txn);

}

public void onSuccess(Database database, any data, int numQueries, Handle[] results, any[] bufferData)
{
	PrintToServer("onSuccess");
}

public void onError(Database database, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	PrintToServer("onError");
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char [] newValue)
{
	if(convar == g_hDemoPath)
	{
		if(!DirExists(newValue))
		{
			InitDirectory(newValue);
		}
	}
	else
	{
		CheckStatus();
	}
}

public void OnMapEnd()
{
	if(g_bIsRecording)
	{
		Format(demoname_upload, sizeof(demoname_upload), demoname);
		Format(demoname, sizeof(demoname), "No Demo");
		Format(demoname_download, sizeof(demoname_download), "No Demo");
		StopRecord();
		g_bIsManual = false;
	}
}

public void OnClientPutInServer(int client)
{
	CheckStatus();
}

public void OnClientDisconnect_Post(int client)
{
	CheckStatus();
}

public Action Timer_CheckStatus(Handle timer)
{
	CheckStatus();
}

public Action Command_Demo(int client, int args)
{
	if(IsValidClient(client))
	{
		CPrintToChat(client, "[{lightblue}FroidGaming.net{default}] Download : {darkred}%s", demoname_download);
	}
	return Plugin_Handled;
}

public Action Command_Record(int client, int args)
{
	if(g_bIsRecording)
	{
		ReplyToCommand(client, "[SM] SourceTV is already recording!");
		return Plugin_Handled;
	}

	StartRecord();
	g_bIsManual = true;

	ReplyToCommand(client, "[SM] SourceTV is now recording...");

	return Plugin_Handled;
}

public Action Command_StopRecord(int client, int args)
{
	if(!g_bIsRecording)
	{
		ReplyToCommand(client, "[SM] SourceTV is not recording!");
		return Plugin_Handled;
	}

	StopRecord();

	if(g_bIsManual)
	{
		g_bIsManual = false;
		CheckStatus();
	}

	ReplyToCommand(client, "[SM] Stopped recording.");

	return Plugin_Handled;
}

public Action Timer_Chat(Handle hTimer)
{
    CPrintToChatAll("[{lightblue}FroidGaming.net{default}] {darkred}FroidGaming.net TV{default} is now recording...");
	CPrintToChatAll("[{lightblue}FroidGaming.net{default}] Demo/Replay Download : {darkred}%s", demoname_download);
}

void CheckStatus()
{
	if(g_hAutoRecord.BoolValue && !g_bIsManual)
	{
		int iMinClients = g_hMinPlayersStart.IntValue;

		int iTimeStart = g_hTimeStart.IntValue;
		int iTimeStop = g_hTimeStop.IntValue;
		bool bReverseTimes = (iTimeStart > iTimeStop);

		char sCurrentTime[4];
		FormatTime(sCurrentTime, sizeof(sCurrentTime), "%H", GetTime());
		int iCurrentTime = StringToInt(sCurrentTime);

		g_cHostname = FindConVar("hostname");
		g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));

		if(StrContains(g_sHostname, "PUG") > -1 || StrContains(g_sHostname, "5v5") > -1){
			if(GetPlayerCount() >= iMinClients && PugSetup_IsMatchLive() && (iTimeStart < 0 || (iCurrentTime >= iTimeStart && (bReverseTimes || iCurrentTime < iTimeStop))))
            {
                StartRecord();
            }
            else if(g_bIsRecording && !g_hFinishMap.BoolValue && (iTimeStop < 0 || iCurrentTime >= iTimeStop))
            {
                StopRecord();
            }
		}else{
			if(GetPlayerCount() >= iMinClients && (iTimeStart < 0 || (iCurrentTime >= iTimeStart && (bReverseTimes || iCurrentTime < iTimeStop))))
            {
                StartRecord();
            }
            else if(g_bIsRecording && !g_hFinishMap.BoolValue && (iTimeStop < 0 || iCurrentTime >= iTimeStop))
            {
                StopRecord();
            }
		}
	}
}

int GetPlayerCount()
{
	bool bIgnoreBots = g_hIgnoreBots.BoolValue;

	int iNumPlayers = 0;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i) && (!bIgnoreBots || !IsFakeClient(i)))
		{
			iNumPlayers++;
		}
	}

	if(!bIgnoreBots)
	{
		iNumPlayers--;
	}

	return iNumPlayers;
}

void StartRecord()
{
	if(g_hTvEnabled.BoolValue && !g_bIsRecording)
	{
		char sPath[PLATFORM_MAX_PATH];
		char sTime[16];
		char sMap[32];

		g_hDemoPath.GetString(sPath, sizeof(sPath));
		FormatTime(sTime, sizeof(sTime), "%Y%m%d-%H%M%S", GetTime());
		GetCurrentMap(sMap, sizeof(sMap));

		// replace slashes in map path name with dashes, to prevent fail on workshop maps
		ReplaceString(sMap, sizeof(sMap), "/", "-", false);

		ServerCommand("tv_record \"%s/auto-%s-%s\"", sPath, sTime, sMap);
		g_bIsRecording = true;

		LogMessage("Recording to auto-%s-%s.dem", sTime, sMap);
        Format(demoname, sizeof(demoname), "auto-%s-%s.dem", sTime, sMap);
		Format(demoname_download, sizeof(demoname_download), "%s/auto-%s-%s.dem.bz2", URL_DOWNLOAD, sTime, sMap);
		CreateTimer(30.0, Timer_Chat);
	}
}

void StopRecord()
{
	if(g_hTvEnabled.BoolValue)
	{
		ServerCommand("tv_stoprecord");
		g_bIsRecording = false;
	}
}

void InitDirectory(const char[] sDir)
{
	char sPieces[32][PLATFORM_MAX_PATH];
	char sPath[PLATFORM_MAX_PATH];
	int iNumPieces = ExplodeString(sDir, "/", sPieces, sizeof(sPieces), sizeof(sPieces[]));

	for(int i = 0; i < iNumPieces; i++)
	{
		Format(sPath, sizeof(sPath), "%s/%s", sPath, sPieces[i]);
		if(!DirExists(sPath))
		{
			CreateDirectory(sPath, 509);
		}
	}
}

stock int GetRoundCount()
{
	return GameRules_GetProp("m_totalRoundsPlayed");
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