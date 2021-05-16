/* SM Includes */
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.1"
#define UPDATE_URL "https://sys.froidgaming.net/DetectOS/updatefile.txt"

#include "files/globals.sp"

public Plugin myinfo =
{
    name = "[API] Detect OS",
	author = "GoD-Tony, Drixevel, FroidGaming.net",
	description = "Determines the OS of a player.",
    version = VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=218691"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bLateLoad = late;
	g_Forward_OnParseOS = CreateGlobalForward("OnParseOS", ET_Ignore, Param_Cell, Param_Cell);
	return APLRes_Success;
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_printos", Command_PrintOS, "Check All Players OS", ADMFLAG_ROOT);

	Handle hConfig = LoadGameConfigFile("detect_os.games");

	if (hConfig == null)
		SetFailState("Failed to find gamedata file: detect_os.games.txt");

	g_OSData[OS_Windows].bOSLoaded = GameConfGetKeyValue(hConfig, "Convar_Windows", g_OSData[OS_Windows].iOS, sizeof(g_OSData[].iOS));
	g_OSData[OS_Linux].bOSLoaded = GameConfGetKeyValue(hConfig, "Convar_Linux", g_OSData[OS_Linux].iOS, sizeof(g_OSData[].iOS));
	g_OSData[OS_Mac].bOSLoaded = GameConfGetKeyValue(hConfig, "Convar_Mac", g_OSData[OS_Mac].iOS, sizeof(g_OSData[].iOS));

	delete hConfig;

	if (g_bLateLoad)
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i))
				OnClientPutInServer(i);
}

public void OnClientPutInServer(int client)
{
	if (IsFakeClient(client))
		return;

	int serial = GetClientSerial(client);

	if (g_OSData[OS_Windows].bOSLoaded)
		QueryClientConVar(client, g_OSData[OS_Windows].iOS, OnCvarCheck, serial);

	if (g_OSData[OS_Linux].bOSLoaded)
		QueryClientConVar(client, g_OSData[OS_Linux].iOS, OnCvarCheck, serial);

	if (g_OSData[OS_Mac].bOSLoaded)
		QueryClientConVar(client, g_OSData[OS_Mac].iOS, OnCvarCheck, serial);
}

public void OnClientDisconnect_Post(int iClient)
{
	g_PlayerData[iClient].Reset();
}

public void OnCvarCheck(QueryCookie cookie, int iClient, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any serial)
{
	if (result == ConVarQuery_NotFound || GetClientFromSerial(serial) != iClient || !IsClientInGame(iClient))
		return;

	if (StrEqual(cvarName, g_OSData[OS_Windows].iOS))
		g_PlayerData[iClient].iOS = OS_Windows;
	else if (StrEqual(cvarName, g_OSData[OS_Linux].iOS))
		g_PlayerData[iClient].iOS = OS_Linux;
	else if (StrEqual(cvarName, g_OSData[OS_Mac].iOS))
		g_PlayerData[iClient].iOS = OS_Mac;

	Call_StartForward(g_Forward_OnParseOS);
	Call_PushCell(iClient);
	Call_PushCell(g_PlayerData[iClient].iOS);
	Call_Finish();
}

public Action Command_PrintOS(int iClient, int args)
{
	PrintToConsole(iClient, "%32s OS", "Client");

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
			continue;

		switch (g_PlayerData[iClient].iOS)
		{
			case OS_Windows:
				PrintToConsole(iClient, "%32N Windows", i);
			case OS_Linux:
				PrintToConsole(iClient, "%32N Linux", i);
			case OS_Mac:
				PrintToConsole(iClient, "%32N Mac", i);
			default:
				PrintToConsole(iClient, "%32N Unknown", i);
		}
	}

	return Plugin_Handled;
}
