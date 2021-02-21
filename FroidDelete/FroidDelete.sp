/* SM Includes */
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.2.2"
#define UPDATE_URL "https://sys.froidgaming.net/FroidDelete/updatefile.txt"

#include "files/globals.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Deleter",
	author = "FroidGaming.net",
	description = "Delete Unnecessary Files.",
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

public void OnConfigsExecuted()
{
	g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));

	if (StrContains(g_sHostname, "PUG") > -1 || StrContains(g_sHostname, "5v5") > -1 || StrContains(g_sHostname, "Retakes") > -1 || StrContains(g_sHostname, "Executes") > -1 || StrContains(g_sHostname, "AWP") > -1 || StrContains(g_sHostname, "Arena") > -1) {
		/// BOT
		if (FileExists("botchatter.db")) {
			DeleteFile("botchatter.db");
		}

		if (FileExists("botprofile.db")) {
			DeleteFile("botprofile.db");
		}

		if (FileExists("botprofilecoop.db")) {
			DeleteFile("botprofilecoop.db");
		}
	}
}

// Old Method
// public void OnMapStart()
// {
//     /// Warmup Script
//     if (FileExists("/scripts/vscripts/warmup/warmup_teleport.nut")) {
// 		DeleteFile("/scripts/vscripts/warmup/warmup_teleport.nut");
// 	}

// 	if (FileExists("/scripts/vscripts/warmup/warmup_arena.nut")) {
// 		DeleteFile("/scripts/vscripts/warmup/warmup_arena.nut");
// 	}
// }

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "logic_script", true) || StrEqual(classname, "trigger_multiple", true))
	{
		SDKHook(entity, SDKHook_Spawn, SDK_OnEntitySpawn);
	}
}

public void SDK_OnEntitySpawn(int entity)
{
	if (entity < 0)
	{
		entity = EntRefToEntIndex(entity);
		if (entity == INVALID_ENT_REFERENCE)
		{
			return;
		}
	}

	char scripts[256];
	GetEntPropString(entity, Prop_Data, "m_iszVScripts", scripts, sizeof(scripts));

	// remove this entity
	if (StrEqual(scripts, "warmup/warmup_arena.nut", true) || StrEqual(scripts, "warmup/warmup_teleport.nut", true))
	{
		DispatchKeyValue(entity, "vscripts", "");
		DispatchKeyValue(entity, "targetname", "");
	}
}