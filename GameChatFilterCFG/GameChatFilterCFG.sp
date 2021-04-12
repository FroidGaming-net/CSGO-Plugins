/* SM Includes */
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.2"
#define UPDATE_URL "https://sys.froidgaming.net/GameChatFilterCFG/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

public Plugin myinfo =
{
	name = "[GameChatFilter] Config Updater",
	author = "FroidGaming.net",
	description = "Auto update config for GameChatFilter.",
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