/* SM Includes */
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1"
#define UPDATE_URL "https://sys.froidgaming.net/FroidHideMenu/updatefile.txt"

#include "files/globals.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Hide menu blockers",
	description = "Hides radar and money while the menu is open",
	author = "FroidGaming.net",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	g_cMoney = FindConVar("mp_maxmoney");
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

public void OnClientDisconnect_Post(int iClient)
{
	g_bMenuOpened[iClient] = false;
}

public void OnPlayerRunCmdPost(int iClient, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if(!IsFakeClient(iClient))
	{
		if(tickcount % 32 == 0)
		{
			bool bMenuOpened = GetClientMenu(iClient) != MenuSource_None;

			if(g_bMenuOpened[iClient] != bMenuOpened)
			{
				char sMoney[2] = "1";
				char sRadar[2] = "0";

				if(bMenuOpened)
				{
					sMoney = "0";
					sRadar = "1";
				}

				g_cMoney.ReplicateToClient(iClient, sMoney);
				g_cRadar.ReplicateToClient(iClient, sRadar);

				g_bMenuOpened[iClient] = bMenuOpened;
			}
		}
	}
}