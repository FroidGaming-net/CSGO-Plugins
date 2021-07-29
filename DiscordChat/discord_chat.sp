/* SM Includes */
#include <sourcemod>
#include <cstrike>
#include <discord_extended>
#include <geoip>
#include <Source-Chat-Relay>
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

    CreateTimer(10.0, Timer_Setting);

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

public Action Timer_Setting(Handle hTimer)
{
	g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));
}

public Action SCR_OnMessageReceive(const char[] sEntityName, IdentificationType iIDType, const char[] sID, char[] sClientName, char[] sMessage)
{
    // Format Message
    char sData[1024];
    FormatEx(sData, sizeof(sData), "**[ANNOUNCEMENT] %s :** %s", sClientName, sMessage);

	// Send to Discord
	DiscordMessage(sData);
}

public void OnMapStart()
{
    // Hostname
	g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));

	// Map Name
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));

    // Format Message
    char sData[1024];
	FormatEx(sData, sizeof(sData), "**------------ Map Started - %s ------------**", sMap);

	// Send to Discord
	DiscordMessage(sData);
}

public void OnMapEnd()
{
    // Hostname
	g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));

	// Map Name
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));

    // Format Message
    char sData[1024];
	FormatEx(sData, sizeof(sData), "**------------ Map Ended - %s ------------**", sMap);

	// Send to Discord
	DiscordMessage(sData);
}

public void OnClientPostAdminCheck(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    // Steam Name
	char sName[128];
	GetClientName(iClient, sName, sizeof(sName));

	// SteamID64
	char sAuthID[64];
	GetClientAuthId(iClient, AuthId_Steam2, sAuthID, sizeof(sAuthID));

    // GeoIP
    char sIP[64], sCountry[64];
    GetClientIP(iClient, sIP, sizeof(sIP));
    GeoipCountry(sIP, sCountry, sizeof(sCountry));

    // Format Message
    char sData[1024];
	FormatEx(sData, sizeof(sData), "**------------ Player Connected - %s (%s) from %s (%s) ------------**", sName, sAuthID, sCountry, sIP);

	// Send to Discord
	DiscordMessage(sData);
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    // Steam Name
	char sName[128];
	GetClientName(iClient, sName, sizeof(sName));

	// SteamID64
	char sAuthID[64];
	GetClientAuthId(iClient, AuthId_Steam2, sAuthID, sizeof(sAuthID));

    // GeoIP
    char sIP[64], sCountry[64];
    GetClientIP(iClient, sIP, sizeof(sIP));
    GeoipCountry(sIP, sCountry, sizeof(sCountry));

    // Format Message
    char sData[1024];
	FormatEx(sData, sizeof(sData), "**------------ Player Disconnected - %s (%s) from %s (%s) ------------**", sName, sAuthID, sCountry, sIP);

	// Send to Discord
	DiscordMessage(sData);
}

public Action Say_Event(int iClient, const char[] sCmd, int iArgc)
{
    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

    // Steam Name
	char sName[128];
	GetClientName(iClient, sName, sizeof(sName));

	// SteamID64
	char sAuthID[64];
	GetClientAuthId(iClient, AuthId_Steam2, sAuthID, sizeof(sAuthID));

	// Message
	char sMsg[255];
	GetCmdArgString(sMsg, sizeof(sMsg));
	StripQuotes(sMsg);

	if (strlen(sMsg) <= 0) {
		return Plugin_Continue;
	}

    // Format Message
    char sData[1024];
    FormatEx(sData, sizeof(sData), "**[%s] (%s All) %s :** %s", sAuthID, GetClientTeamName(iClient), sName, sMsg);

	// Send to Discord
	DiscordMessage(sData);

	return Plugin_Continue;
}

public Action SayTeam_Event(int iClient, const char[] sCmd, int iArgc)
{
    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

    // Steam Name
	char sName[128];
	GetClientName(iClient, sName, sizeof(sName));

	// SteamID64
	char sAuthID[64];
	GetClientAuthId(iClient, AuthId_Steam2, sAuthID, sizeof(sAuthID));

	// Message
	char sMsg[255];
	GetCmdArgString(sMsg, sizeof(sMsg));
	StripQuotes(sMsg);

	if (strlen(sMsg) <= 0) {
		return Plugin_Continue;
	}

    // Format Message
    char sData[1024];
    FormatEx(sData, sizeof(sData), "**[%s] (%s Team) %s :** %s", sAuthID, GetClientTeamName(iClient), sName, sMsg);

	// Send to Discord
	DiscordMessage(sData);

	return Plugin_Continue;
}

void DiscordMessage(const char[] sData)
{
	Discord_StartMessage();
    Discord_SetUsername("FroidGaming.net");
    Discord_SetContent(sData);
    if(StrContains(g_sHostname, "PUG #1 | ID") > -1 || StrContains(g_sHostname, "PUG #1 | SEA") > -1){
        Discord_BindWebHook("idpug1", "https://discord.com/api/webhooks/593263614014521375/wBS67SxBlnKWuAHGNHFJzVLvH3RH2hS30lklU5PZG-zeCnb6Pa_81dvUBdD-umn4MFWd");
        Discord_EndMessage("idpug1", true);
    }else if(StrContains(g_sHostname, "PUG #2 | ID") > -1 || StrContains(g_sHostname, "PUG #2 | SEA") > -1){
        Discord_BindWebHook("idpug2", "https://discord.com/api/webhooks/593263767807197185/UwDZKCPFzIlJ9zlgBqAVBm__bf4kPFvKBxyOYvSzqnUEB6rnR2wLrHhoRdDxkiUjw8nK");
        Discord_EndMessage("idpug2", true);
    }else if(StrContains(g_sHostname, "PUG #3 | ID") > -1 || StrContains(g_sHostname, "PUG #3 | SEA") > -1){
        Discord_BindWebHook("idpug3", "https://discord.com/api/webhooks/594795768360075291/or0E_ZKKCKqSdlQeZ2NJKyYmlFiUPxd1zmXSnvZXLcTvJaW4_g653Y3xekx4JH8MbksA");
        Discord_EndMessage("idpug3", true);
    }else if(StrContains(g_sHostname, "PUG #4 | ID") > -1 || StrContains(g_sHostname, "PUG #4 | SEA") > -1){
        Discord_BindWebHook("idpug4", "https://discord.com/api/webhooks/594795946915921950/bJk51reEvZczWudMhHj12z0syO9r8c1KwnTzYCmUhA5Y0IZPn98caCoWdpR1ou7fYE7q");
        Discord_EndMessage("idpug4", true);
    }else if(StrContains(g_sHostname, "Retakes #1 | ID") > -1 || StrContains(g_sHostname, "Retakes #1 | SEA") > -1){
        Discord_BindWebHook("idretakes1", "https://discord.com/api/webhooks/593261690397655041/mj_ogKOTCkYXYTi24fcXe2Z8ztOSUNRpsC9BHHO7Ss5wczA7H5vhixN-LGqnP1Oht7Br");
        Discord_EndMessage("idretakes1", true);
    }else if(StrContains(g_sHostname, "Retakes #2 | ID") > -1 || StrContains(g_sHostname, "Retakes #2 | SEA") > -1){
        Discord_BindWebHook("idretakes2", "https://discord.com/api/webhooks/593263063160061952/9Lkpc9U5tbrx4x3zAauQN3oOy9VRXRjL1iAtjoTs3JxMc9PudSiUv_SLe_lhQCQYA7j6");
        Discord_EndMessage("idretakes2", true);
    }else if(StrContains(g_sHostname, "Retakes #3 | ID") > -1 || StrContains(g_sHostname, "Retakes #3 | SEA") > -1){
        Discord_BindWebHook("idretakes3", "https://discord.com/api/webhooks/593263266893922314/zlEuIHhC-raLtidIe4qri3ovETjezrEajjiETOvhoxA8kuu1Yec3RVDzskkR59sIrc9j");
        Discord_EndMessage("idretakes3", true);
    }else if(StrContains(g_sHostname, "Retakes #4 | ID") > -1 || StrContains(g_sHostname, "Retakes #4 | SEA") > -1){
        Discord_BindWebHook("idretakes4", "https://discord.com/api/webhooks/593263430346080256/kUFh9X8YTZLHrX3bKHgOk2oIAtoQ_1rLa1baPb2mwRc4Xd0st2mN_1V0bnLwGMUPCoO3");
        Discord_EndMessage("idretakes4", true);
    }else if(StrContains(g_sHostname, "Arena 1v1 | ID") > -1 || StrContains(g_sHostname, "Arena 1v1 | SEA") > -1){
        Discord_BindWebHook("idarena1v1", "https://discord.com/api/webhooks/593264143239479302/i-zvdhyx39M_gHezxTXPnUrX05wBhmVknPGZONJloV0fp2W-dF6i-pW4IWg1wZVBF1ss");
        Discord_EndMessage("idarena1v1", true);
    }else if(StrContains(g_sHostname, "Retakes #1 | SG") > -1){
        Discord_BindWebHook("sgretakes1", "https://discord.com/api/webhooks/594798563070836747/2FsouFbT85w4bhdgHl1ZsHSZe13ls0LdIW92iVfMDu242yFsQsmBMEr8tjpFxZ6PFON2");
        Discord_EndMessage("sgretakes1", true);
    }else if(StrContains(g_sHostname, "Retakes #2 | SG") > -1){
        Discord_BindWebHook("sgretakes2", "https://discord.com/api/webhooks/594798791408746508/kaZEFMYZCYNedevMYL_BDzoGpecCl5n_da3WIvpOj9iOOxBh-8iB_XUo2g847yUP2Qq9");
        Discord_EndMessage("sgretakes2", true);
    }else if(StrContains(g_sHostname, "PUG #1 | SG") > -1){
        Discord_BindWebHook("sgpug1", "https://discord.com/api/webhooks/643394120781398036/n__HpDFETFyxRvSuYZeP45Pd4Wa4uYSTiVULpfhZEgbxgbxL4FbPwf6DRH4MKGnlwhB9");
        Discord_EndMessage("sgpug1", true);
    }else if(StrContains(g_sHostname, "PUG #2 | SG") > -1){
        Discord_BindWebHook("sgpug2", "https://discord.com/api/webhooks/643394202008551424/f_Dyxj6_7lCMjlA02wwf77hk66v2Y1CF95754jzR_ag2G6eRZ_Z-EecGbiHU3m0GDCb6");
        Discord_EndMessage("sgpug2", true);
    }else if(StrContains(g_sHostname, "Executes #1 | SG") > -1){
        Discord_BindWebHook("sgexecutes", "https://discord.com/api/webhooks/870300855012823040/6-4EDFXOXITpl36f3pv4RMq0bP_xHoKymdOnf_JHTF73wVXSlcK4_hfG7IAoS-t8kVTU");
        Discord_EndMessage("sgexecutes", true);
    }else if(StrContains(g_sHostname, "FFA Deathmatch #1 | ID") > -1 || StrContains(g_sHostname, "FFA Deathmatch #1 | SEA") > -1){
        Discord_BindWebHook("idffa", "https://discord.com/api/webhooks/680758690068168715/dKDG86kqdpNX7UW_B95xJ9fmwXwfe9rrzwMA8d0BNCmnDiW8CzDICjasGTDi0yIMLiLJ");
        Discord_EndMessage("idffa", true);
    }else if(StrContains(g_sHostname, "Practice Mode #1 | ID") > -1 || StrContains(g_sHostname, "Practice Mode #1 | SEA") > -1){
        Discord_BindWebHook("idpractice", "https://discord.com/api/webhooks/836526238754799627/FEkFeZ3dNvafpQabfY4iPPh9LQ2cJFACaXOrPtFhmtyMwmml23efcz0c3W8MlYmoJNxG");
        Discord_EndMessage("idpractice", true);
    }else if(StrContains(g_sHostname, "AWP Bhop #1 | ID") > -1 || StrContains(g_sHostname, "AWP Bhop #1 | SEA") > -1){
        Discord_BindWebHook("idawp", "https://discord.com/api/webhooks/836535022130692116/cTmffa7AqC8On8iJWaxfiEGaka6Egfh9N4HM85Z5IfUWTG0H-GCiDBT9r7VagH8-8jML");
        Discord_EndMessage("idawp", true);
    }else if(StrContains(g_sHostname, "Executes #1 | ID") > -1 || StrContains(g_sHostname, "Executes #1 | SEA") > -1){
        Discord_BindWebHook("idexecutes", "https://discord.com/api/webhooks/836534918828785694/fL2yUzhsH_Q13zoq6CjQB3zQdtTn3MvhQwnmrVFhpE21H5N43efy0WwDCgK6CXGRkZfs");
        Discord_EndMessage("idexecutes", true);
    }else if(StrContains(g_sHostname, "Prophunt / Hide and Seek | ID") > -1 || StrContains(g_sHostname, "Prophunt / Hide and Seek | SEA") > -1){
        Discord_BindWebHook("idexecutes", "https://discord.com/api/webhooks/870301096223051816/lR2hPXslKewHCM0II1MHy0yZPiGY_LdsKEBiBosUpj4ZMNOP0t573HMIKS3H40P5u7kE");
        Discord_EndMessage("idexecutes", true);
    }else if(StrContains(g_sHostname, "Easy Surf [Tier 1/2] | ID") > -1 || StrContains(g_sHostname, "Easy Surf [Tier 1/2] | SEA") > -1){
        Discord_BindWebHook("idsurf", "https://discord.com/api/webhooks/870301349965865013/sO4_YBC_4Io0IPz7BJpjKcy5W7sIIaxfJtJdxuJK0s7aJ4KhIEWYuQ0cBeW181VbjyRv");
        Discord_EndMessage("idsurf", true);
    }else{
        Discord_BindWebHook("default", "https://discord.com/api/webhooks/679217585757356042/zPo3SHka4e-UWFRG0EjGI58Rs6UbNEACEpDa9FRdPWqqyLTdom7DPY84qAry17At1dZC");
        Discord_EndMessage("default", true);
    }
}