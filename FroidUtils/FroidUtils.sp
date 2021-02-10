/* SM Includes */
#include <sourcemod>
#include <cstrike>
#include <multicolors>
#include <geoip>
#undef REQUIRE_PLUGIN
#include <updater>
#include <pugsetup>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidUtils/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/commands.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Custom Utils",
	author = "FroidGaming.net",
	description = "Custom Utils.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    PlayerCooldown = new StringMap();

    if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }

    CreateTimer(10.0, Timer_Setting);
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public Action Timer_Setting(Handle hTimer)
{
    g_cServerName = FindConVar("hostname");
    g_cServerName.GetString(g_sServerName, sizeof(g_sServerName));

    if(StrContains(g_sServerName, "PUG") > -1 || StrContains(g_sServerName, "5v5") > -1){
        RegConsoleCmd("sm_start", Command_Start, "Forcestart PUG");
        AddCommandListener(altJoin, "jointeam");
        // CreateTimer(120.0, Timer_Repeat, _, TIMER_REPEAT);
    } else if (StrContains(g_sServerName, "AWP") > -1) {
        AddCommandListener(altJoin, "jointeam");
        // CreateTimer(120.0, Timer_Repeat, _, TIMER_REPEAT);
    }
}

public void FroidJoin_OnClientReplaced(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].iReplaced = 1;
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
    for (int iClient = 1; iClient < MAXPLAYERS; iClient++) {
		if (IsValidClient(iClient)) {
            if (g_PlayerData[iClient].iVIPLoaded == 1) {
                if (GetClientTeam(iClient) == CS_TEAM_SPECTATOR) {
                    if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
                        if (PugSetup_GetGameState() == GameState_Live) {
                            if (g_PlayerData[iClient].iReplaced == 0) {
                                g_PlayerData[iClient].iRoundSpectator++;
                                if (g_PlayerData[iClient].iRoundSpectator >= 2) {
                                    if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
                                        KickClient(iClient, "Kamu tidak bisa masuk Spectator saat PUG sudah LIVE! Kamu hanya bisa masuk Spectator saat WARMUP atau beli Premium/Premium Plus sekarang juga di froidgaming.net/store");
                                    } else {
                                        KickClient(iClient, "You can't join Spectator when PUG is LIVE! You can only join Spectator during WARMUP or buy Premium/Premium Plus now at froidgaming.net/store");
                                    }
                                }
                            }
                        }
                    }
                } else if (GetClientTeam(iClient) == CS_TEAM_NONE) {
                    g_PlayerData[iClient].iRoundGhost++;
                    if (g_PlayerData[iClient].iRoundGhost >= 2) {
                        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
                            KickClient(iClient, "Kamu tidak bisa menjadi Ghost (Unassigned Team)");
                        }else{
                            KickClient(iClient, "You can't become Ghost (Unassigned Team)");
                        }
                    }
                }
            }
		}
	}
}

// public Action Timer_Repeat(Handle hTimer)
// {
//     for (int iClient = 1; iClient < MAXPLAYERS; iClient++) {
// 		if (IsValidClient(iClient)) {
//             if (g_PlayerData[iClient].iVIPLoaded == 1) {
//                 if (GetClientTeam(iClient) == CS_TEAM_SPECTATOR) {
//                     if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
//                         if (PugSetup_GetGameState() == GameState_Live) {
//                             if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
//                                 KickClient(iClient, "Kamu tidak bisa masuk Spectator saat PUG sudah LIVE! Kamu hanya bisa masuk Spectator saat WARMUP atau beli Premium/Premium Plus sekarang juga di froidgaming.net/store");
//                             } else {
//                                 KickClient(iClient, "You can't join Spectator when PUG is LIVE! You can only join Spectator during WARMUP or buy Premium/Premium Plus now at froidgaming.net/store");
//                             }
//                         }
//                     }
//                 } else if (GetClientTeam(iClient) == CS_TEAM_NONE) {
//                     if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
//                         KickClient(iClient, "Kamu tidak bisa menjadi Ghost (Unassigned Team)");
//                     }else{
//                         KickClient(iClient, "You can't become Ghost (Unassigned Team)");
//                     }
//                 }
//             }
// 		}
// 	}
// }

Action altJoin(int iClient, const char[] sCommand, int iArgc)
{
    if(!IsValidClient(iClient))
	{
		return Plugin_Continue;
	}

    char sArg[8];
	GetCmdArg(1, sArg, sizeof(sArg));
	int iTeamJoin = StringToInt(sArg);
	int iTeamLeave = GetClientTeam(iClient);

    // #define CS_TEAM_NONE        0   /**< No team yet. */
    // #define CS_TEAM_SPECTATOR   1   /**< Spectators. */
    // #define CS_TEAM_T           2   /**< Terrorists. */
    // #define CS_TEAM_CT          3   /**< Counter-Terrorists. */
    if (iTeamLeave == iTeamJoin) {
        return Plugin_Continue;
    } else {
        if (CheckCommandAccess(iClient, "sm_froidapp_admin", ADMFLAG_GENERIC) && iTeamJoin == CS_TEAM_SPECTATOR) {
            return Plugin_Continue;
        } else if ((iTeamLeave == CS_TEAM_CT && iTeamJoin == CS_TEAM_SPECTATOR) || (iTeamLeave == CS_TEAM_T && iTeamJoin == CS_TEAM_SPECTATOR)) {
            if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
				CPrintToChat(iClient, "%s {default}Kamu tidak dapat pindah ke {lightred}Spectator{default}.", PREFIX);
			} else {
				CPrintToChat(iClient, "%s {default}You can't change team to {lightred}Spectator{default}.", PREFIX);
			}

            return Plugin_Handled;

        } else if ((iTeamLeave == CS_TEAM_CT && iTeamJoin == CS_TEAM_T) || (iTeamLeave == CS_TEAM_T && iTeamJoin == CS_TEAM_CT)) {
            if (CheckCommandAccess(iClient, "sm_froidapp_admin", ADMFLAG_GENERIC)) {
				return Plugin_Continue;
			} else {
                int iCooldown;
                char sAuthID[64];
                GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
                if (PlayerCooldown.GetValue(sAuthID, iCooldown)) {
                    if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Mohon tunggu selama 2 menit.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Please wait for 2 minutes.", PREFIX);
					}

                    return Plugin_Handled;
                } else {
                    PlayerCooldown.SetValue(sAuthID, 1);
                    CreateTimer(120.0, Timer_RemoveCooldown, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);

                    return Plugin_Continue;
                }
            }
        } else if ((iTeamLeave == CS_TEAM_NONE && iTeamLeave == CS_TEAM_SPECTATOR)) {
            if (PugSetup_GetGameState() == GameState_Live) {
				CreateTimer(20.0, Timer_DelayJoin, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
			} else {
				return Plugin_Continue;
			}
        }
    }

    return Plugin_Continue;
}

Action Timer_RemoveCooldown(Handle timer, any data)
{
	int iClient = GetClientOfUserId(data);

    if (IsValidClient(iClient)) {
        char sAuthID[64];
        GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
        PlayerCooldown.Remove(sAuthID);
    }
}

Action Timer_DelayJoin(Handle timer, any data)
{
	int iClient = GetClientOfUserId(data);

    if (IsValidClient(iClient)) {
        if(g_PlayerData[iClient].iVIPLoaded == 0) {
            CreateTimer(20.0, Timer_DelayJoin, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
        } else {
            if (GetClientTeam(iClient) == CS_TEAM_SPECTATOR) {
                if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
                    if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
						KickClient(iClient, "Kamu tidak bisa masuk Spectator saat PUG sudah LIVE! Kamu hanya bisa masuk Spectator saat WARMUP atau beli Premium/Premium Plus sekarang juga di froidgaming.net/store");
					}else{
						KickClient(iClient, "You can't join Spectator when PUG is LIVE! You can only join Spectator during WARMUP or buy Premium/Premium Plus now at froidgaming.net/store");
					}
                }
            }
        }
    }
}

public void OnMapStart()
{
	PlayerCooldown.Clear();
}

public void OnMapEnd()
{
	PlayerCooldown.Clear();
}

public void OnClientPostAdminCheck(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }
    
    g_PlayerData[iClient].Reset();

    // GeoIP
    char sIP[64], sCountryCode[3];
    GetClientIP(iClient, sIP, sizeof(sIP));
    GeoipCode2(sIP, sCountryCode);
    Format(g_PlayerData[iClient].sCountryCode, sizeof(g_PlayerData[].sCountryCode), sCountryCode);
}

public void FroidVIP_OnClientLoadedPost(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].iVIPLoaded = 1;
}

public void OnClientDisconnect(int iClient)
{
    if (!IsValidClient(iClient)) {
        return;
    }

    g_PlayerData[iClient].Reset();
}

stock bool IsWarmup()
{
	return view_as<bool>(GameRules_GetProp("m_bWarmupPeriod"));
}