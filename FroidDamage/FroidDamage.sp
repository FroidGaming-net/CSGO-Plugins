/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <sourcebanspp>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1"
#define UPDATE_URL "https://sys.froidgaming.net/FroidDamage/updatefile.txt"

#include "files/globals.sp"
#include "files/client.sp"

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
    reloadPlugins();

	if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public void OnPluginEnd() {
    for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			OnClientDisconnect(i);
		}
    }
}

/// Reload Detected
public void reloadPlugins() {
	for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			OnClientPutInServer(i);
		}
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
            if (iDamagetype != 32) {
                char sWeapon[255];
                GetClientWeapon(iAttacker, sWeapon, sizeof(sWeapon));
                if (StrContains(sWeapon, "knife") != -1 || StrContains(sWeapon, "taser") != -1 || StrContains(sWeapon, "bayonet") != -1) {
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
            g_PlayerData[iAttacker].iTeamDamage = g_PlayerData[iAttacker].iTeamDamage + RoundToNearest(fDamage);

            if (g_PlayerData[iAttacker].iTeamDamage >= 30 && g_PlayerData[iAttacker].iTeamDamage < 250) {
                CPrintToChat(iAttacker, "{darkred}WARNING: You will be banned from the server if you attack your teammate!!!");
            }

            if (g_PlayerData[iAttacker].iTeamDamage >= 150) {
                if (g_PlayerData[iAttacker].iBanned == 0) {
                    g_PlayerData[iAttacker].iBanned = 1;
                    SBPP_BanPlayer(0, iAttacker, 180, "Griefing Attack Teammate");
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
                }
            }
		}
	}
}