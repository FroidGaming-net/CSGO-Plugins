#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1"
#define UPDATE_URL "https://sys.froidgaming.net/FroidJoin/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/commands.sp"
#include "files/menus.sp"
#include "files/events.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Join",
	author = "FroidGaming.net",
	description = "VIP Features to Replace Player.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	event.BroadcastDisabled = true;
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(iClient)) {
		char sReason[128];
        event.GetString("reason", sReason, sizeof(sReason));
        PrintToChatAll("%N left the game (%s)", iClient, sReason);
	}
    return Plugin_Continue;
}