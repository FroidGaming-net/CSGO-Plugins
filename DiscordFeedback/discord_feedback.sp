/* SM Includes */
#include <sourcemod>
#include <discord_extended>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

ConVar hostname = null;

public Plugin myinfo =
{
	name = "[Discord] Feedback",
	author = "FroidGaming.net",
	description = "Send Feedback to Discord.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_feedback", Command_Feedback);

    hostname = FindConVar("hostname");
}

public Action Command_Feedback(int iClient, int iArgs)
{
    if (!IsValidClient(iClient)) {
        return Plugin_Handled;
    }

    if(iArgs == 0)
	{
		CPrintToChat(iClient, "%s Usage: {lightblue}!feedback {default}YOUR FEEDBACK HERE.", PREFIX);
		return Plugin_Handled;
	}

    char argbuff[512];
	GetCmdArgString(argbuff, sizeof(argbuff));

    char szAuth[32];
	GetClientAuthId(iClient, AuthId_Engine, szAuth, sizeof(szAuth));
	
	char sName[64];
	GetClientName(iClient, sName, sizeof(sName));

    char sHostname[64];
    hostname.GetString(sHostname, 64);
    
    char sNewMessage[1024];
    FormatEx(sNewMessage, sizeof(sNewMessage), "**%s** oleh **%s (%s)** di **%s**", argbuff, sName, szAuth, sHostname);
	EscapeStringAllowAt(sNewMessage, sizeof(sNewMessage));

    Discord_StartMessage();
    Discord_SetUsername("FroidGaming.net");
    Discord_SetContent(sNewMessage);
    Discord_EndMessage("feedback", true);

    CPrintToChat(iClient, "%s Thank You!", PREFIX);

    return Plugin_Handled;
}

stock bool IsValidClient(int iClient, bool bAlive = false)
{
	if (iClient >= 1 &&
		iClient <= MaxClients &&
		IsClientConnected(iClient) &&
		IsClientInGame(iClient) &&
		!IsFakeClient(iClient) &&
		(bAlive == false || IsPlayerAlive(iClient)))
	{
		return true;
	}

	return false;
}

void EscapeStringAllowAt(char[] string, int maxlen)
{
	ReplaceString(string, maxlen, "'", "\'");
	ReplaceString(string, maxlen, "\"", "＂");
}