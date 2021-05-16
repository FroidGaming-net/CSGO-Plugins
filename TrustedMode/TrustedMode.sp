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
  name = "[FroidApp] Trusted Mode",
  author = "FroidGaming.net",
  description = "Check if players running on Trusted Mode or not.",
  version = VERSION,
  url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_trusted", test);
}

public Action test(int iClient, int iArgs)
{
    QueryClientConVar(iClient, "trusted_launch", QueryClientConVarCallback);
    return Plugin_Handled;
}

public void QueryClientConVarCallback(QueryCookie sCookie, int iClient, ConVarQueryResult sResult, const char[] sCvarName, const char[] sCvarValue)
{
    PrintToChatAll("%s", sCvarValue);
}