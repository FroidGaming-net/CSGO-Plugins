/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <smlib>
#include <cstrike>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidAWP/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/sdkhooks.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[FroidApp] AWP Core",
	author = "FroidGaming.net",
	description = "AWP Core.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_PrePlayerSpawn, EventHookMode_Pre);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_spawn", Event_PostPlayerSpawn, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("round_prestart", Event_PreRoundStart);
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("decoy_started", Event_DecoyStarted, EventHookMode_Pre);

    if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }

    reloadPlugins();
}

/// Reload Detected
public void reloadPlugins()
{
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
            OnClientPutInServer(i);
		}
	}
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public void OnMapStart()
{
    g_iRoundCount = 0;

    char Remove[65];
    for (int i = 64; i <= GetMaxEntities(); i++)
    {
        if(IsValidEdict(i) && IsValidEntity(i))
        {
            GetEdictClassname(i, Remove, sizeof(Remove));
            if(StrEqual("func_buyzone", Remove))
            {
                RemoveEdict(i);
            }
        }
    }
}

public void OnMapEnd()
{
    g_iRoundCount = 0;
}

public void OnClientPutInServer(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();

	SDKHook(iClient, SDKHook_PreThink, PreThink);
    SDKHook(iClient, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(iClient, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
    SDKHook(iClient, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();

    SDKUnhook(iClient, SDKHook_PreThink, PreThink);
    SDKUnhook(iClient, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(iClient, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	SDKUnhook(iClient, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}
public Action Event_PrePlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(event.GetInt("userid"));

    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

    Client_RemoveAllWeapons(iClient);

    return Plugin_Continue;
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(event.GetInt("userid"));

    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

    Client_RemoveAllWeapons(iClient);

    return Plugin_Continue;
}

public Action Event_PostPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(event.GetInt("userid"));

    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

    if(GetClientTeam(iClient) >= CS_TEAM_T) {
        Client_RemoveAllWeapons(iClient);
        GiveWeapon(iClient);
        GivePlayerItem(iClient, "weapon_knife");
    }

    return Plugin_Continue;
}

// public void StripNextTick(int iClient)
// {
//     Client_RemoveAllWeapons(iClient);
//     DataPack pack = new DataPack();
//     CreateDataTimer(0.5, Timer_Weapon, pack);
//     pack.WriteCell(GetClientUserId(iClient));
// }

// public Action Timer_Weapon(Handle hTimer, Handle hDatapack)
// {
//     ResetPack(hDatapack);
//     int iClient = GetClientOfUserId(ReadPackCell(hDatapack));

//     if (!IsValidClient(iClient)) {
//         return;
//     }

//     Client_RemoveAllWeapons(iClient);
//     GiveWeapon(iClient);
//     GivePlayerItem(iClient, "weapon_knife");
// }

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

    RemoveRagdoll(iClient);
    return Plugin_Continue;
}

public Action Event_PreRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_iRoundCount++;

    if (g_iRoundCount == 5) {
        g_iRoundMode = RoundToNearest(GetRandomFloat(1.0, 8.0));
        RandomRound(g_iRoundMode);
    } else {
        EnabledBhop();
    }
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bNades == true)  {
        ServerCommand("sv_infinite_ammo 0");
        g_bNades = false;
    }

    if (g_iRoundCount == 5) {
        g_iRoundCount = 0;
        g_iRoundMode = 0;
    }

    if (g_bNoScope == true)  {
        g_bNoScope = false;
    }

    if (g_bNoKnifeDamage == true)  {
        ServerCommand("sv_infinite_ammo 0");
        g_bNoKnifeDamage = false;
    }

    if (g_bNormalKnifeDamage == true) {
        g_bNormalKnifeDamage = false;
    }
}

public Action Event_DecoyStarted(Event event, const char[] name, bool dontBroadcast)
{
	int entity = event.GetInt("entityid");
	char decoyName[16];
	GetEntPropString(entity, Prop_Data, "m_iName", decoyName, sizeof(decoyName));
	if (!StrEqual(decoyName, "normal", false)) {
        AcceptEntityInput(entity, "Kill");
    }
}