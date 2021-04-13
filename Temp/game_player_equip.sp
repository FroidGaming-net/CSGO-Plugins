#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

#define VERSION 	"1.1.1"

public Plugin myinfo =
{
	name = "Game_Player_Equip Fix",
	author = "Mitch",
	description = "Fixes player stripping.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    HookEvent("round_start", Event_RoundStart);
}

public void OnMapStart()
{
	int iEntity = -1;
	while ((iEntity = FindEntityByClassname(iEntity, "game_player_equip")) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(iEntity, "Kill");
	}
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    int iEntity = -1;
	while ((iEntity = FindEntityByClassname(iEntity, "game_player_equip")) != INVALID_ENT_REFERENCE) {
		AcceptEntityInput(iEntity, "Kill");
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if(StrEqual(classname, "game_player_equip", false)){
		SDKHook(entity, SDKHook_Spawn, Hook_OnEntitySpawn);
	}
}

public Action Hook_OnEntitySpawn(int entity)
{
	if (!(GetEntProp(entity, Prop_Data, "m_spawnflags") & 1))
	{
		SetEntProp(entity, Prop_Data, "m_spawnflags", GetEntProp(entity, Prop_Data, "m_spawnflags") | 2);
	}

	return Plugin_Continue;
}