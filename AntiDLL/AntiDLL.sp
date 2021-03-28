/* SM Includes */
#include <sourcemod>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <updater>
#include <sourcebanspp>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.1"
#define UPDATE_URL "https://sys.froidgaming.net/AntiDLL/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

public Plugin myinfo =
{
	name = "[AntiDLL] Core",
	author = "FroidGaming.net",
	description = "AntiDLL Core.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
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

public void AD_OnCheatDetected(const int client)
{
    SBPP_BanPlayer(0, client, 0, "[FroidAC] Cheat Detected");
    PrintToChatAll("%s {lightred}%N{default} Banned by FroidAC", PREFIX);
}