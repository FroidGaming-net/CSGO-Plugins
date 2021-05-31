#include <sourcemod>
#include <retakesandexecutes>
#include <retakes>
#include <sdktools>
#include <cstrike>
#undef REQUIRE_PLUGIN
#include <updater>

/* SM Includes */
#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.4.3"
#define UPDATE_URL "https://sys.froidgaming.net/FroidDefuse/updatefile.txt"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
    name = "[FroidApp] Instant Defuse",
    author = "FroidGaming.net",
    description = "Retakes Instant Defuse.",
  	version = VERSION,
  	url = "https://froidgaming.net"
}

public void OnPluginStart()
{
    HookEvent("bomb_begindefuse", Event_BombBeginDefuse, EventHookMode_Post);
    HookEvent("bomb_planted", Event_BombPlanted, EventHookMode_Pre);
    HookEvent("molotov_detonate", Event_MolotovDetonate);
    HookEvent("hegrenade_detonate", Event_AttemptInstantDefuse, EventHookMode_Post);

    HookEvent("player_death", Event_AttemptInstantDefuse, EventHookMode_PostNoCopy);
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);

    // Added the forwards to allow other plugins to call this one.
    fw_OnInstantDefusePre = CreateGlobalForward("FroidDefuse_OnInstantDefusePre", ET_Event, Param_Cell, Param_Cell);
    fw_OnInstantDefusePost = CreateGlobalForward("FroidDefuse_OnInstantDefusePost", ET_Ignore, Param_Cell, Param_Cell);

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

public void OnMapStart()
{
	g_bHasDefuseKitTeam = false;
    hTimer_MolotovThreatEnd = null;
}

public void OnMapEnd()
{
	g_bHasDefuseKitTeam = false;
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	g_bAlreadyComplete = false;
	g_bWouldMakeIt = false;

	if (hTimer_MolotovThreatEnd != null)
	{
		delete hTimer_MolotovThreatEnd;
	}
}

public Action Event_BombPlanted(Handle event, const char[] name, bool dontBroadcast)
{
    g_c4PlantTime = GetGameTime();
}

public Action Event_BombBeginDefuse(Handle event, const char[] name, bool dontBroadcast)
{
	if (g_bAlreadyComplete)
	{
		return Plugin_Handled;
	}

	RequestFrame(Event_BombBeginDefusePlusFrame, GetEventInt(event, "userid"));

	return Plugin_Continue;
}

public void Event_BombBeginDefusePlusFrame(int userId)
{
	g_bWouldMakeIt = false;

	int client = GetClientOfUserId(userId);

	if (IsValidClient(client))
    {
    	AttemptInstantDefuse(client);
    }
}

public Action Event_RoundFreezeEnd(Handle event, const char[] name, bool dontBroadcast)
{
	g_bHasDefuseKitTeam = false;
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			if (HasDefuseKit(i)) {
				g_bHasDefuseKitTeam = true;
			}
		}
	}
}


void AttemptInstantDefuse(int client, int exemptNade = 0)
{
	if (g_bAlreadyComplete || !GetEntProp(client, Prop_Send, "m_bIsDefusing") || HasAlivePlayer(CS_TEAM_T))
	{
		return;
	}

	int StartEnt = MaxClients + 1;

	int c4 = FindEntityByClassname(StartEnt, "planted_c4");

	if (c4 == -1)
	{
	    return;
	}

	bool hasDefuseKitTeam = false;

	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			if (HasDefuseKit(i)) {
				hasDefuseKitTeam = true;
			}
		}
	}

	bool hasDefuseKit = HasDefuseKit(client);

	float c4TimeLeft = GetConVarFloat(FindConVar("mp_c4timer")) - (GetGameTime() - g_c4PlantTime);

	if (!g_bWouldMakeIt)
	{
		g_bWouldMakeIt = (c4TimeLeft >= 10.0 && !hasDefuseKit) || (c4TimeLeft >= 5.0 && hasDefuseKit);
	}

	if (!g_bWouldMakeIt)
	{
		if (hasDefuseKitTeam == true && hasDefuseKit == false) {
			return;
		}

		if (g_bHasDefuseKitTeam == true && hasDefuseKit == false) {
			return;
		}

		if (!OnInstandDefusePre(client, c4))
		{
			return;
		}

		Retakes_MessageToAll("There were %.1f seconds left of the bomb. Terrorists win.", c4TimeLeft);

		g_bAlreadyComplete = true;

		// Force Terrorist win because they do not have enough time to defuse the bomb.
		EndRound(CS_TEAM_T);

		return;
	}
	else if (GetEntityFlags(client) && !FL_ONGROUND)
	{
		return;
	}

	int ent;
	if ((ent = FindEntityByClassname(StartEnt, "hegrenade_projectile")) != -1 || (ent = FindEntityByClassname(StartEnt, "molotov_projectile")) != -1)
	{
	    if (ent != exemptNade)
	    {
			Retakes_MessageToAll("There is an active grenade somewhere. Good luck defusing!");

			return;
	    }
	}
	else if (hTimer_MolotovThreatEnd != null)
	{
		Retakes_MessageToAll("There is a molotov close to the bomb. Good luck defusing!");

		return;
	}

	if (!OnInstandDefusePre(client, c4))
	{
		return;
	}

	Retakes_MessageToAll("There were %.1f seconds left of the bomb. Counter Terrorists win.", c4TimeLeft);

	g_bAlreadyComplete = true;

	Retakes_SetRoundPoints(client, Retakes_GetRoundPoints(client)+50);

	EndRound(CS_TEAM_CT);

	OnInstantDefusePost(client, c4);
}

public Action Event_AttemptInstantDefuse(Handle event, const char[] name, bool dontBroadcast)
{
    int defuser = GetDefusingPlayer();

    int ent = 0;

    if (StrContains(name, "detonate") != -1 && defuser != 0)
    {
        ent = GetEventInt(event, "entityid");

        AttemptInstantDefuse(defuser, ent);
    }
}

public Action Event_MolotovDetonate(Handle event, const char[] name, bool dontBroadcast)
{
    float Origin[3];
    Origin[0] = GetEventFloat(event, "x");
    Origin[1] = GetEventFloat(event, "y");
    Origin[2] = GetEventFloat(event, "z");

    int c4 = FindEntityByClassname(MaxClients + 1, "planted_c4");

    if (c4 == -1)
    {
        return;
    }

    float C4Origin[3];
    GetEntPropVector(c4, Prop_Data, "m_vecOrigin", C4Origin);

    if (GetVectorDistance(Origin, C4Origin, false) > 150)
    {
        return;
    }

    if (hTimer_MolotovThreatEnd != null)
    {
        delete hTimer_MolotovThreatEnd;
    }

    hTimer_MolotovThreatEnd = CreateTimer(7.0, Timer_MolotovThreatEnd, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_MolotovThreatEnd(Handle timer)
{
    hTimer_MolotovThreatEnd = null;

    int defuser = GetDefusingPlayer();

    if (defuser != 0)
    {
        AttemptInstantDefuse(defuser);
    }
}