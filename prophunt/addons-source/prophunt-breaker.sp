/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"


public Plugin myinfo =
{
  name = "Prophunt Breaker",
  author = "RoyZ, Modified by FroidGaming.net",
  description = "Break windows/glasses and open all the door in Prophunt",
  version = VERSION,
  url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    HookEvent("round_start", Event_OnRoundStart, EventHookMode_Pre);
}

public void Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    char currentMap[PLATFORM_MAX_PATH];
    GetCurrentMap(currentMap, sizeof(currentMap));

    int ent = -1;

    while ((ent = FindEntityByClassname(ent, "func_breakable")) != -1)
    {
        AcceptEntityInput(ent, "Break");
    }
    while ((ent = FindEntityByClassname(ent, "func_breakable_surf")) != -1)
    {
        AcceptEntityInput(ent, "Break");
    }

    while ((ent = FindEntityByClassname(ent, "prop_door_rotating")) != -1)
    {
        AcceptEntityInput(ent, "open");
    }

    if (StrContains(currentMap, "de_nuke", false) == 0)
    {
        while ((ent = FindEntityByClassname(ent, "func_button")) != -1)
        {
            AcceptEntityInput(ent, "Kill");
        }
    }

    if (StrContains(currentMap, "de_vertigo", false) == 0 || StrContains(currentMap, "de_cache", false) == 0 || StrContains(currentMap, "de_nuke", false) == 0)
    {
        while ((ent = FindEntityByClassname(ent, "prop_dynamic")) != -1)
        {
            AcceptEntityInput(ent, "Break");
        }
    }

    if (StrContains(currentMap, "de_mirage", false) == -1)
    {
        while ((ent = FindEntityByClassname(ent, "prop.breakable.01")) != -1)
        {
            AcceptEntityInput(ent, "break");
        }
        while ((ent = FindEntityByClassname(ent, "prop.breakable.02")) != -1)
        {
            AcceptEntityInput(ent, "break");
        }
    }
}