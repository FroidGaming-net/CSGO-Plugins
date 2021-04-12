#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define VERSION 	"1.1.1"

public Plugin myinfo =
{
	name = "Game_Player_Equip Fix",
	author = "Mitch",
	description = "Fixes player stripping.",
	version = VERSION,
	url = "https://froidgaming.net"
};

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
        SetEntProp(entity, Prop_Data, "m_spawnflags", GetEntProp(entity, Prop_Data, "m_spawnflags") | 1);
    }
}