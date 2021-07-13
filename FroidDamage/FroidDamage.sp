/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <multicolors>
#include <discord_extended>
#undef REQUIRE_PLUGIN
#include <sourcebanspp>
#include <updater>
#include <froidmatch>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.2.6"
#define UPDATE_URL "https://sys.froidgaming.net/FroidDamage/updatefile.txt"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Damage",
	author = "FroidGaming.net",
	description = "Friendly Fire Damage and Auto Ban if too much damage to teammate.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	g_cHostname = FindConVar("hostname");
    HookEvent("announce_phase_end", Event_HalfTime);
    HookEvent("round_prestart", Event_PreRoundStart);
	HookEventEx("cs_win_panel_match", cs_win_panel_match);

    reloadPlugins();

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

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("GetDemoName");
    return APLRes_Success;
}

public void OnPluginEnd()
{
    for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			OnClientDisconnect(i);
		}
    }
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

public void OnMapStart()
{
    g_bHalfTime = false;
    g_iRoundCount = 0;
}

public void OnMapEnd()
{
    g_bHalfTime = false;
    g_iRoundCount = 0;
}

public Action Event_HalfTime(Event event, const char[] name, bool dontBroadcast)
{
    g_bHalfTime = true;
}

public void cs_win_panel_match(Handle event, const char[] eventname, bool dontBroadcast)
{
	g_bHalfTime = true;
}

public Action Event_PreRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_bHalfTime = false;
    g_iRoundCount++;

    if (g_iRoundCount >= 4) {
        g_iRoundCount = 0;
        ResetRoundTeamDamage();
    }
}

public void OnClientPutInServer(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();

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

    SDKUnhook(iClient, SDKHook_OnTakeDamage, OnTakeDamage);
    SDKUnhook(iClient, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
    SDKUnhook(iClient, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

public Action OnTakeDamage(int iClient, int &iAttacker, int &iInflictor, float &fDamage, int &iDamagetype)
{
	if (iClient != iAttacker && IsValidClient(iAttacker)) {
		if (GetClientTeam(iClient) == GetClientTeam(iAttacker)) {
            SetEntPropVector(iClient, Prop_Send, "m_aimPunchAngle", NULL_VECTOR);
            SetEntPropVector(iClient, Prop_Send, "m_aimPunchAngleVel", NULL_VECTOR);
            if (iDamagetype != 32) {
                char sWeapon[255];
                GetClientWeapon(iAttacker, sWeapon, sizeof(sWeapon));
                if (StrContains(sWeapon, "knife") != -1 || StrContains(sWeapon, "taser") != -1 || StrContains(sWeapon, "bayonet") != -1) {
                    g_PlayerData[iClient].fStamina = GetEntPropFloat(iClient, Prop_Send, "m_flStamina");
                    fDamage = 0.0;

                    return Plugin_Changed;
                } else if (iDamagetype == 4098 || iDamagetype == 1073745922) {
                    if (g_bHalfTime == true) {
                        return Plugin_Continue;
                    }

                    if (IsWarmup()) {
                        return Plugin_Continue;
                    }

                    if (StrContains(sWeapon, "weapon_awp") == -1 && StrContains(sWeapon, "weapon_g3sg1") == -1 && StrContains(sWeapon, "weapon_scar20") == -1) {
                        g_PlayerData[iAttacker].iRoundTeamDamage = g_PlayerData[iAttacker].iRoundTeamDamage + RoundToNearest(fDamage);
                        SendDiscord(iAttacker, iClient, RoundToNearest(fDamage), sWeapon);
                    }

                    CPrintToChat(iAttacker, "{darkred}WARNING: You will be banned from the server if you attack your teammate!!!");
                    g_PlayerData[iClient].fStamina = GetEntPropFloat(iClient, Prop_Send, "m_flStamina");
                    fDamage = 0.0;

                    return Plugin_Changed;
                }
            }
		}
	}

	return Plugin_Continue;
}

public Action OnTakeDamageAlive(int iClient, int &iAttacker, int &iInflictor, float &fDamage, int &iDamagetype)
{
    if (iClient != iAttacker && IsValidClient(iAttacker)) {
        if (GetClientTeam(iClient) == GetClientTeam(iAttacker)) {
            if (g_bHalfTime == true) {
                return Plugin_Continue;
            }

            SendDiscord(iAttacker, iClient, RoundToNearest(fDamage), "Grenades");

            g_PlayerData[iAttacker].iTeamDamage = g_PlayerData[iAttacker].iTeamDamage + RoundToNearest(fDamage);

            if (g_PlayerData[iAttacker].iTeamDamage >= 5 && g_PlayerData[iAttacker].iTeamDamage < 150) {
                CPrintToChat(iAttacker, "{darkred}WARNING: You will be banned from the server if you attack your teammate!!!");
            }

            if (g_PlayerData[iAttacker].iTeamDamage >= 150) {
                if (g_PlayerData[iAttacker].iBanned == 0) {
                    g_PlayerData[iAttacker].iBanned = 1;
                    SBPP_BanPlayer(0, iAttacker, 180, "Griefing Attack Teammate");
                }
            }

            if (g_PlayerData[iAttacker].iRoundTeamDamage >= 1000) {
                if (g_PlayerData[iAttacker].iBanned == 0) {
                    g_PlayerData[iAttacker].iBanned = 1;
                    SBPP_BanPlayer(0, iAttacker, 180, "Griefing Attack Teammate [2]");
                }
            }
        }
    }

    return Plugin_Continue;
}

public void OnTakeDamagePost(int iClient, int iAttacker, int iInflictor, float fDamage, int iDamagetype)
{
	if (iClient != iAttacker && IsValidClient(iAttacker)){
		if (GetClientTeam(iClient) == GetClientTeam(iAttacker)) {
            if (iDamagetype != 32) {
                char sWeapon[255];
                GetClientWeapon(iAttacker, sWeapon, sizeof(sWeapon));
                if (StrContains(sWeapon, "knife") != -1 || StrContains(sWeapon, "taser") != -1 || StrContains(sWeapon, "bayonet") != -1) {
                    SetEntPropFloat(iClient, Prop_Send, "m_flVelocityModifier", 1.0);
                    SetEntPropFloat(iClient, Prop_Send, "m_flStamina", g_PlayerData[iClient].fStamina);
                } else if (iDamagetype == 4098 || iDamagetype == 1073745922) {
                    SetEntPropFloat(iClient, Prop_Send, "m_flVelocityModifier", 1.0);
                    SetEntPropFloat(iClient, Prop_Send, "m_flStamina", g_PlayerData[iClient].fStamina);
                }
            }
		}
	}
}