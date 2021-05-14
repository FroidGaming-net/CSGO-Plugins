/* SM Includes */
#include <sourcemod>
#include <multicolors>
#include <discord_extended>
#include <hotguard>
#undef REQUIRE_PLUGIN
#include <updater>
#include <sourcebanspp>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.4"
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

public void HG_WhenPlayerPunished(int iClient, int iTime, const char[] szReason)
{
    // Discord
    Discord_StartMessage();
    Discord_SetUsername("FroidGaming.net");
    Discord_SetTitle(NULL_STRING, "★ AC LOG ★");
    /// Content
    char szBody[3][1048];
    GetClientAuthId(iClient, AuthId_SteamID64, szBody[0], sizeof(szBody[]));
    GetClientName(iClient, szBody[1], sizeof(szBody[]));
    GetClientAuthId(iClient, AuthId_Steam2, szBody[2], sizeof(szBody[]));
    EscapeString(szBody[1], sizeof(szBody[]));

    Format(szBody[0], sizeof(szBody[]), "» [%s](https://steamcommunity.com/profiles/%s/) (%s)", szBody[1], szBody[0], szBody[2]);
    Discord_AddField("• Player :", szBody[0], false);

    Format(szBody[0], sizeof(szBody[]), "» %s", szReason);
    Discord_AddField("• Reason :", szBody[0], false);

    FormatEx(szBody[0], sizeof(szBody[]), "» Ping [in : %i ms <> out : %i ms] | Choke [in : %i <> out : %i] | Loss [in : %i <> out : %i]", RoundFloat(GetClientAvgLatency(iClient, NetFlow_Incoming) * 1000.0), RoundFloat(GetClientAvgLatency(iClient, NetFlow_Outgoing) * 1000.0), RoundFloat(GetClientAvgChoke(iClient, NetFlow_Incoming) * 100.0), RoundFloat(GetClientAvgChoke(iClient, NetFlow_Outgoing) * 100.0), RoundFloat(GetClientAvgLoss(iClient, NetFlow_Incoming) * 100.0), RoundFloat(GetClientAvgLoss(iClient, NetFlow_Outgoing) * 100.0));
    Discord_AddField("• Data :", szBody[0], false);

    FormatEx(szBody[0], sizeof(szBody[]), "» <@&583584442287652876>");
    Discord_AddField("• Tags :", szBody[0], false);
    /// Content
    Discord_EndMessage("anticheat", true);
    /// Discord
}

void EscapeString(char[] string, int maxlen)
{
	ReplaceString(string, maxlen, "@", "＠");
	ReplaceString(string, maxlen, "'", "\'");
	ReplaceString(string, maxlen, "\"", "＂");
}