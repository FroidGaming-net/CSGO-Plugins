/* SM Includes */
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.6"
#define UPDATE_URL "https://sys.froidgaming.net/GeoIP2/updatefile.txt"


public Plugin myinfo =
{
  name = "[API] GeoIP2 Updater",
  author = "FroidGaming.net",
  description = "GeoIP2 Updater.",
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