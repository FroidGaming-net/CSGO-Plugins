/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.1"
#define UPDATE_URL "https://sys.froidgaming.net/FroidPractice/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/client.sp"
#include "files/globals.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Practice Mode",
	author = "FroidGaming.net",
	description = "Practice Mode Utils.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn);

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

public void OnClientPostAdminCheck(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

	if (!IsValidClient(iClient)) {
		return Plugin_Continue;
	}

    FakeClientCommand(iClient, "say .god");

	if (g_PlayerData[iClient].bNoFlash == false) {
		FakeClientCommand(iClient, "say .noflash");
		g_PlayerData[iClient].bNoFlash = true;
	}
	CPrintToChat(iClient, "%s {lightred}God Mode {default}and {lightred}No Flash Mode {default}Enabled Automatically.", PREFIX);
    return Plugin_Continue;
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &impulse, float vel[3], float angles[3])
{
	if (!IsValidClient(iClient)) {
		return Plugin_Continue;
	}

	impulse = 0;
    return Plugin_Continue;
}