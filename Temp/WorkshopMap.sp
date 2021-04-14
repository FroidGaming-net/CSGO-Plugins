#include <sourcemod>
#include <SteamWorks>

#pragma semicolon 1
#pragma newdecls required

char g_sMapName[128];
// ConVar cGOTV = null;

public Plugin myinfo = {
    name = "Server Browser - Mapname Stripper",
    author = "Techno",
    description = "Strips the workshop string from map names",
    version = "1.0.0",
    url = "https://tech-no.me"
};

public void OnConfigsExecuted()
{
    // cGOTV = FindConVar("tv_enable");
}

public void OnMapStart()
{
    GetCurrentMap(g_sMapName, sizeof(g_sMapName));
    GetMapDisplayName(g_sMapName, g_sMapName, sizeof(g_sMapName));
}

public void OnGameFrame()
{
    // int iPlayers = cGOTV.BoolValue == true ? GetClientCount(true)-1 : GetClientCount(true);
    // if (iPlayers >= 1) {
        SteamWorks_SetMapName("a");
    // }
}