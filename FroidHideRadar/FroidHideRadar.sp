/* SM Includes */
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1"
#define UPDATE_URL "https://sys.froidgaming.net/FroidHideRadar/updatefile.txt"

#include "files/globals.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Hide Radar",
	description = "Hides Radar Always",
	author = "FroidGaming.net",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	g_cRadar = FindConVar("sv_disable_radar");

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

public void OnPlayerRunCmdPost(int iClient, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if(!IsFakeClient(iClient))
	{
		if(tickcount % 32 == 0)
		{
			QueryClientConVar(iClient, "sv_disable_radar", QueryClientConVarCallback);
		}
	}
}

public void QueryClientConVarCallback(QueryCookie sCookie, int iClient, ConVarQueryResult sResult, const char[] sCvarName, const char[] sCvarValue)
{
    if(strcmp(sCvarValue, "1") )
    {
        g_cRadar.ReplicateToClient(iClient, "1");
    }
}