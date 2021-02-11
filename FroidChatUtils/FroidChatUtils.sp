/* SM Includes */
#include <sourcemod>
#include <multicolors>
#include <cstrike>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1"
#define UPDATE_URL "https://sys.froidgaming.net/FroidChatUtils/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

public Plugin myinfo =
{
	name = "[FroidApp] Chat Utils",
	author = "FroidGaming.net",
	description = "Chat Utils.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	AddCommandListener(OnSay, "say");
    AddCommandListener(OnSay, "say_team");
}

Action OnSay(int iClient, const char[] sCommand, int iArgs)
{
    if (IsValidClient(iClient)) {
        char sText[4096];
        GetCmdArgString(sText, sizeof(sText));
        StripQuotes(sText);

        if (GetClientTeam(iClient) == CS_TEAM_NONE) {
            return Plugin_Handled;
        }

        if (StrContains(sText, "discord.") > -1) {
		    return Plugin_Handled;
	    }

        if (StrContains(sText, "facebook.") > -1) {
		    return Plugin_Handled;
	    }

        if (StrContains(sText, "twitter.") > -1) {
		    return Plugin_Handled;
	    }

        if (StrContains(sText, "instagram.") > -1) {
		    return Plugin_Handled;
	    }

        if (StrContains(sText, "!report") > -1) {
            return Plugin_Handled;
        }

        if (StrEqual(sText, "!discord")) {
            CPrintToChat(iClient, "%s {default}Discord : {lightred}https://discord.gg/juZphVD", PREFIX);
        } else if (StrEqual(sText, "!website")) {
            CPrintToChat(iClient, "%s {default}Web : {lightred}froidgaming.net", PREFIX);
        } else if (StrEqual(sText, "!web")) {
            CPrintToChat(iClient, "%s {default}Web : {lightred}froidgaming.net", PREFIX);
        } else if (StrEqual(sText, "!store")) {
            CPrintToChat(iClient, "%s {default}Web : {lightred}froidgaming.net/store", PREFIX);
        }
    }

    return Plugin_Continue;
}

stock bool IsValidClient(int client, bool alive = false)
{
    return (0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)));
}