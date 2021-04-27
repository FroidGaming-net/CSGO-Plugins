/* SM Includes */
#include <sourcemod>
#include <cstrike>
#include <discord_extended>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"
#define UPDATE_URL "https://sys.froidgaming.net/DiscordChat/updatefile.txt"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[Discord] Chat Module",
	author = "FroidGaming.net",
	description = "Chat Module.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    g_cHostname = FindConVar("hostname");

    AddCommandListener(Say_Event, "say");
    AddCommandListener(SayTeam_Event, "say_team");

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

public Action Say_Event(int iClient, const char[] sCmd, int iArgc)
{
    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

	char    sMsg[255],
            sAuthID[64],
            sName[128],
            sTeam[10];

	GetCmdArgString(sMsg, sizeof(sMsg));
	StripQuotes(sMsg);
	GetClientAuthId(iClient, AuthId_Steam2, sAuthID, sizeof(sAuthID));
	GetClientName(iClient, sName, sizeof(sName));

    if(GetClientTeam(iClient) == CS_TEAM_CT){
        sTeam = "CT";
    }else if(GetClientTeam(iClient) == CS_TEAM_T){
        sTeam = "T";
    }else if(GetClientTeam(iClient) == CS_TEAM_SPECTATOR){
        sTeam = "Spectator";
    }else if(GetClientTeam(iClient) == CS_TEAM_NONE){
        sTeam = "Ghost";
    }

	DiscordMessage(sAuthID, sName, sMsg, false, sTeam);

	return Plugin_Continue;
}

public Action SayTeam_Event(int iClient, const char[] sCmd, int iArgc)
{
    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

	char    sMsg[255],
            sAuthID[64],
            sName[128],
            sTeam[10];

	GetCmdArgString(sMsg, sizeof(sMsg));
	StripQuotes(sMsg);
	GetClientAuthId(iClient, AuthId_Steam2, sAuthID, sizeof(sAuthID));
	GetClientName(iClient, sName, sizeof(sName));

    if(GetClientTeam(iClient) == CS_TEAM_CT){
        sTeam = "CT";
    }else if(GetClientTeam(iClient) == CS_TEAM_T){
        sTeam = "T";
    }else if(GetClientTeam(iClient) == CS_TEAM_SPECTATOR){
        sTeam = "Spectator";
    }else if(GetClientTeam(iClient) == CS_TEAM_NONE){
        sTeam = "Ghost";
    }

	DiscordMessage(sAuthID, sName, sMsg, true, sTeam);

	return Plugin_Continue;
}

void DiscordMessage(const char[] strAuthID, const char[] strName, const char[] strMessage, bool bTeamChat = false, const char[] strTeam)
{
    char    sHostname[64],
            sNewMessage[1024];

	g_cHostname.GetString(sHostname, sizeof(sHostname));
	EscapeString(sHostname, sizeof(sHostname));

    if(bTeamChat)
	{
		FormatEx(sNewMessage, sizeof(sNewMessage), "**[%s] (%s Team) %s :** %s", strAuthID, strTeam, strName, strMessage);
	}else{
		FormatEx(sNewMessage, sizeof(sNewMessage), "**[%s] (%s All) %s :** %s", strAuthID, strTeam, strName, strMessage);
	}

    EscapeString(sNewMessage, sizeof(sNewMessage));

    Discord_StartMessage();
    Discord_SetUsername("FroidGaming.net");
    Discord_SetContent(sNewMessage);
    if(StrContains(sHostname, "PUG #1 | ID") > -1 || StrContains(sHostname, "PUG #1 | SEA") > -1){
        Discord_EndMessage("idpug1", true);
    }else if(StrContains(sHostname, "PUG #2 | ID") > -1 || StrContains(sHostname, "PUG #2 | SEA") > -1){
        Discord_EndMessage("idpug2", true);
    }else if(StrContains(sHostname, "PUG #3 | ID") > -1 || StrContains(sHostname, "PUG #3 | SEA") > -1){
        Discord_EndMessage("idpug3", true);
    }else if(StrContains(sHostname, "PUG #4 | ID") > -1 || StrContains(sHostname, "PUG #4 | SEA") > -1){
        Discord_EndMessage("idpug4", true);
    }else if(StrContains(sHostname, "PUG #5 | ID") > -1 || StrContains(sHostname, "PUG #5 | SEA") > -1){
        Discord_EndMessage("idpug5", true);
    }else if(StrContains(sHostname, "PUG #6 | ID") > -1 || StrContains(sHostname, "PUG #6 | SEA") > -1){
        Discord_EndMessage("idpug6", true);
    }else if(StrContains(sHostname, "Retakes #1 | ID") > -1 || StrContains(sHostname, "Retakes #1 | SEA") > -1){
        Discord_EndMessage("idretakes1", true);
    }else if(StrContains(sHostname, "Retakes #2 | ID") > -1 || StrContains(sHostname, "Retakes #2 | SEA") > -1){
        Discord_EndMessage("idretakes2", true);
    }else if(StrContains(sHostname, "Retakes #3 | ID") > -1 || StrContains(sHostname, "Retakes #3 | SEA") > -1){
        Discord_EndMessage("idretakes3", true);
    }else if(StrContains(sHostname, "Retakes #4 | ID") > -1 || StrContains(sHostname, "Retakes #4 | SEA") > -1){
        Discord_EndMessage("idretakes4", true);
    }else if(StrContains(sHostname, "Retakes #5 | ID") > -1 || StrContains(sHostname, "Retakes #5 | SEA") > -1){
        Discord_EndMessage("idretakes5", true);
    }else if(StrContains(sHostname, "Retakes #6 | ID") > -1 || StrContains(sHostname, "Retakes #6 | SEA") > -1){
        Discord_EndMessage("idretakes6", true);
    }else if(StrContains(sHostname, "Arena 1v1 | ID") > -1 || StrContains(sHostname, "Arena 1v1 | SEA") > -1){
        Discord_EndMessage("idarena1v1", true);
    }else if(StrContains(sHostname, "Retakes #1 | SG") > -1){
        Discord_EndMessage("sgretakes1", true);
    }else if(StrContains(sHostname, "Retakes #2 | SG") > -1){
        Discord_EndMessage("sgretakes2", true);
    }else if(StrContains(sHostname, "Retakes #3 | SG") > -1){
        Discord_EndMessage("sgretakes3", true);
    }else if(StrContains(sHostname, "Retakes #4 | SG") > -1){
        Discord_EndMessage("sgretakes4", true);
    }else if(StrContains(sHostname, "PUG #1 | SG") > -1){
        Discord_EndMessage("sgpug1", true);
    }else if(StrContains(sHostname, "PUG #2 | SG") > -1){
        Discord_EndMessage("sgpug2", true);
    }else if(StrContains(sHostname, "PUG #3 | SG") > -1){
        Discord_EndMessage("sgpug3", true);
    }else if(StrContains(sHostname, "PUG #4 | SG") > -1){
        Discord_EndMessage("sgpug4", true);
    }else if(StrContains(sHostname, "FFA Deathmatch #1 | ID") > -1 || StrContains(sHostname, "FFA Deathmatch #1 | SEA") > -1){
        Discord_EndMessage("idffa", true);
    }else if(StrContains(sHostname, "Practice Mode #1 | ID") > -1 || StrContains(sHostname, "Practice Mode #1 | SEA") > -1){
        Discord_EndMessage("idpractice", true);
    }else{
        Discord_EndMessage("default", true);
    }
}