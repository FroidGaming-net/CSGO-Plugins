/* SM Includes */
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1"
#define UPDATE_URL "https://sys.froidgaming.net/FroidWelcome/updatefile.txt"

#include "files/globals.sp"

//Globals
// bool g_bMessagesShown[MAXPLAYERS + 1] = false;

public Plugin myinfo =
{
  name = "[FroidApp] Console Welcome",
  author = "FroidGaming.net",
  description = "Menampilkan pesan selamat datang di console.",
  version = VERSION,
  url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    // HookEvent("player_spawn", Event_OnPlayerSpawn);
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
    cGOTV = FindConVar("tv_enable");
    cServerName = FindConVar("hostname");
}

public void OnClientPutInServer(int iClient)
{
    if (iClient == 0 || IsFakeClient(iClient) || IsClientSourceTV(iClient)) {
        return;
    }

    //Data
    // g_bMessagesShown[iClient] = false;

    //Get Server Name
    char sServerName[64];
    cServerName.GetString(sServerName, sizeof(sServerName));

    if (g_bGetData == false) {
        //Get Server IP and Port
        char Status[1024];
        char Lines[3][100];
        char sTempIP[8][50];
        char sIP[40];

        char sTempPort[2][100];
        char sPort[16];
        ServerCommandEx(Status, sizeof(Status), "status");
        ExplodeString(Status, "\n", Lines, sizeof(Lines), sizeof(Lines[]));
        ExplodeString(Lines[2], " ", sTempIP, sizeof(sTempIP), sizeof(sTempIP[]));
        // IP
        strcopy(sIP, sizeof(sIP), sTempIP[7]);
        ReplaceString(sIP, sizeof(sIP), ")", "");
        Format(g_sIP, sizeof(g_sIP), "%s", sIP);
        // Port
        ExplodeString(sTempIP[3], ":", sTempPort, sizeof(sTempPort), sizeof(sTempPort[]));
        strcopy(sPort, sizeof(sPort), sTempPort[1]);
        Format(g_sPort, sizeof(g_sPort), "%s", sPort);

        g_bGetData = true;
    }

    //Get Current Map
    char sMap[64];
    GetCurrentMap(sMap, sizeof(sMap));

    //Get Current datetime
    char sTime[64];
    FormatTime(sTime, sizeof(sTime), "%I:%M:%S %p %d/%m/%Y %Z", GetTime());

    PrintToConsole(iClient, "                                                                       ");
    PrintToConsole(iClient, "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄");
    PrintToConsole(iClient, "                                                                       ");
    PrintToConsole(iClient, "█░█░█ █▀▀ █░░ █▀▀ █▀█ █▀▄▀█ █▀▀   ▀█▀ █▀█");
    PrintToConsole(iClient, "▀▄▀▄▀ ██▄ █▄▄ █▄▄ █▄█ █░▀░█ ██▄   ░█░ █▄█");
    PrintToConsole(iClient, "                                                                       ");
    PrintToConsole(iClient, "█▀▀ █▀█ █▀█ █ █▀▄ █▀▀ ▄▀█ █▀▄▀█ █ █▄░█ █▀▀ ░ █▄░█ █▀▀ ▀█▀");
    PrintToConsole(iClient, "█▀░ █▀▄ █▄█ █ █▄▀ █▄█ █▀█ █░▀░█ █ █░▀█ █▄█ ▄ █░▀█ ██▄ ░█░");
    PrintToConsole(iClient, "                                                                       ");
    PrintToConsole(iClient, "Server Name: %s", sServerName);
    PrintToConsole(iClient, "Server Address: %s:%s", g_sIP, g_sPort);
    PrintToConsole(iClient, "Current Map: %s", sMap);
    PrintToConsole(iClient, "Current Player Count: %d/%d", cGOTV.BoolValue == true ? GetClientCount(false)-1 : GetClientCount(false), GetMaxHumanPlayers());
    PrintToConsole(iClient, "Server Time: %s", sTime);
    PrintToConsole(iClient, "                                                                       ");
    PrintToConsole(iClient, "Join our discord to suggest features, report bugs/rule breakers and to interact with our community!");
    PrintToConsole(iClient, "Discord: https://discord.io/froidgaming | Website: https://froidgaming.net");
    PrintToConsole(iClient, "                                                                       ");
    PrintToConsole(iClient, "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄");
    PrintToConsole(iClient, "                                                                       ");
}

// public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
// {
// 	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

// 	if (iClient == 0 || IsFakeClient(iClient) || IsClientSourceTV(iClient))
// 	{
// 		return;
// 	}

// 	CreateTimer(0.2, Timer_DelaySpawn, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
// }

// public Action Timer_DelaySpawn(Handle timer, any data)
// {
// 	int iClient = GetClientOfUserId(data);

// 	if (iClient == 0 || !IsPlayerAlive(iClient) || g_bMessagesShown[iClient])
// 	{
// 		return Plugin_Continue;
// 	}

// }