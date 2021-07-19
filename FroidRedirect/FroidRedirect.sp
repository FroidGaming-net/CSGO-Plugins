/* SM Includes */
#include <sourcemod>
#include <ripext>
#include <redirect_core>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.7"
#define UPDATE_URL "https://sys.froidgaming.net/FroidRedirect/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/commands.sp"
#include "files/menus.sp"
#include "files/API.sp"

public Plugin myinfo =
{
    name = "[FroidApp] Server Redirect",
    author = "FroidGaming.net",
    description = "Server Redirect.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_server", Call_MenuServers);
    RegConsoleCmd("sm_servers", Call_MenuServers);

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