/* SM Includes */
#include <sourcemod>
#include <PTaH>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1.4"
#define UPDATE_URL "https://sys.froidgaming.net/FroidBlock/updatefile.txt"

ConVar g_cHostname;
char g_sHostname[64];

#include "files/client.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Block Commands",
	author = "FroidGaming.net",
	description = "Block Commands Management.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    PTaH(PTaH_ConsolePrintPre, Hook, ConsolePrint);
	PTaH(PTaH_ExecuteStringCommandPre, Hook, ExecuteStringCommand);

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

public void OnConfigsExecuted() {
	CreateTimer(10.0, Timer_Setting);
}

public Action Timer_Setting(Handle hTimer)
{
	g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));


    /// Block
	if (StrContains(g_sHostname, "SURF") == -1){
		AddCommandListener(Command_Block, "kill");
	}
	AddCommandListener(Command_Block, "killvector");
    AddCommandListener(Command_Block, "killserver");
	AddCommandListener(Command_Block, "explode");
    AddCommandListener(Command_Block, "explodevector");
	AddCommandListener(Command_Block, "demos");
	AddCommandListener(Command_Block, "ping");

	AddCommandListener(Command_Block, "ent_create");
    AddCommandListener(Command_Block, "ent_fire");
    AddCommandListener(Command_Block, "ent_teleport");
	AddCommandListener(Command_Block, "prop_physics_create");
	AddCommandListener(Command_Block, "prop_dynamic_create");
	AddCommandListener(Command_Block, "give");
	AddCommandListener(Command_Block, "impulse");
	AddCommandListener(Command_Block, "gods");
	AddCommandListener(Command_Block, "sv_rethrow_last_grenade");

	AddCommandListener(Command_Block, "getout");
	AddCommandListener(Command_Block, "sorry");
	AddCommandListener(PlayerRadio, "playerradio");
	/// Block
}

public Action PlayerRadio(int iClient, const char[] sCommand, int iArgc)
{
	if (!IsClientValid(iClient)) {
        return Plugin_Continue;
    }

    if (iClient > 0 && iArgc == 2) {
        char sBuffer[10];
        GetCmdArg(1, sBuffer, sizeof(sBuffer));

        if(StrEqual(sBuffer, "deathcry", false))
        {
            return Plugin_Handled;
        }
    }

    return Plugin_Continue;
}

public Action Command_Block(int iClient, const char[] sCommand, int iArgc)
{
    return Plugin_Handled;
}

public Action ConsolePrint(int iClient, char message[512])
{
	if (iClient == 0) {
        return Plugin_Continue;
    }

	if (IsClientValid(iClient) && GetUserFlagBits(iClient) & ADMFLAG_ROOT) {
        return Plugin_Continue;
    }

	if (StrContains(message, ".smx\" ") != -1) {
        return Plugin_Handled;
    } else if(StrContains(message, "To see more, type \"sm plugins", false) != -1 || StrContains(message, "To see more, type \"sm exts", false) != -1) {
		return Plugin_Handled;
	}

	return Plugin_Continue;

}

public Action ExecuteStringCommand(int iClient, char message[512])
{
	if (iClient == 0) {
        return Plugin_Continue;
    }

	static char sMessage[512];
	sMessage = message;
	TrimString(sMessage);

	if (IsClientValid(iClient) && GetUserFlagBits(iClient) & ADMFLAG_ROOT) {
        return Plugin_Continue;
    }

	if(StrContains(sMessage, "sm ") == 0 || StrEqual(sMessage, "sm", false))
	{
		return Plugin_Handled;
	}

	if(StrContains(sMessage, "meta ") == 0 || StrEqual(sMessage, "meta", false))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}