/* SM Includes */
#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1.3"
#define UPDATE_URL "https://sys.froidgaming.net/FroidCvar/updatefile.txt"

#include "files/globals.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Cvar Enforcer",
	author = "FroidGaming.net",
	description = "Cvar Enforcer.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    g_Cvar_AllowVotes = FindConVar("sv_allow_votes");
    g_Cvar_Occlude = FindConVar("sv_occlude_players");
    g_Cvar_LoserBonus = FindConVar("cash_team_bonus_shorthanded");
    g_Cvar_Damage1 = FindConVar("ff_damage_bullet_penetration");
    g_Cvar_Damage2 = FindConVar("ff_damage_reduction_bullets");
    g_Cvar_Damage3 = FindConVar("ff_damage_reduction_grenade");
    g_Cvar_Damage4 = FindConVar("ff_damage_reduction_grenade_self");
    g_Cvar_Damage5 = FindConVar("ff_damage_reduction_other");
    g_Cvar_FriendlyFire = FindConVar("mp_friendlyfire");
    g_Cvar_GrenadeRadio = FindConVar("sv_ignoregrenaderadio");
    g_Cvar_PlayerCash = FindConVar("mp_playercashawards");
    g_Cvar_TeamCash = FindConVar("mp_teamcashawards");
    g_Cvar_IgnoreWin = FindConVar("mp_ignore_round_win_conditions");
    g_Cvar_WarmupPeriod = FindConVar("mp_do_warmup_period");
    g_Cvar_BotChatter = FindConVar("bot_chatter");
    g_Cvar_MaxRounds = FindConVar("mp_maxrounds");
    g_Cvar_RoundTime = FindConVar("mp_roundtime");
    g_Cvar_RoundTimeHostage = FindConVar("mp_roundtime_hostage");
    g_Cvar_RoundTimeDefuse = FindConVar("mp_roundtime_defuse");
    g_Cvar_WarmupTime = FindConVar("mp_warmuptime");
    g_Cvar_SolidTeam = FindConVar("mp_solid_teammates");
    g_Cvar_Radar = FindConVar("sv_disable_radar");
    g_Cvar_DamageInfo = FindConVar("sv_damage_print_enable");

    CreateTimer(60.0, Timer_Repeat, _, TIMER_REPEAT);

    if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }

    CreateTimer(10.0, Timer_Setting, _, TIMER_REPEAT);
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public Action Timer_Repeat(Handle hTimer)
{
    ServerCommand("removeid 1; removeip 1");
}

public void OnMapStart()
{
    GameRules_SetProp("m_bIsValveDS", 1);
}

public Action Timer_Setting(Handle hTimer)
{
    g_cServerName = FindConVar("hostname");
    g_cServerName.GetString(g_sServerName, sizeof(g_sServerName));

    // All Servers
    SetConVarInt(g_Cvar_AllowVotes, 0, true);
    SetConVarInt(g_Cvar_Occlude, 1, true);
    SetConVarInt(g_Cvar_LoserBonus, 0, true);

    // PUG / 5v5 / Retakes / Executes
    if(StrContains(g_sServerName, "PUG") > -1 || StrContains(g_sServerName, "Retakes") > -1 || StrContains(g_sServerName, "5v5") > -1 || StrContains(g_sServerName, "Executes") > -1){
        if(StrContains(g_sServerName, "Retakes") > -1 || StrContains(g_sServerName, "Executes") > -1){
            SetConVarInt(g_Cvar_LoserBonus, 0);
        }

        SetConVarInt(g_Cvar_FriendlyFire, 1, true);
        SetConVarInt(g_Cvar_Damage1, 0, true);
        SetConVarFloat(g_Cvar_Damage2, 0.0, true);
        SetConVarFloat(g_Cvar_Damage3, 0.85, true);
        SetConVarInt(g_Cvar_Damage4, 1, true);
        SetConVarFloat(g_Cvar_Damage5, 0.4, true);
        SetConVarInt(g_Cvar_DamageInfo, 0, true);
    }

    // Practice
    if(StrContains(g_sServerName, "Practice") > -1){
        SetConVarInt(g_Cvar_FriendlyFire, 1, true);
        SetConVarInt(g_Cvar_GrenadeRadio, 1, true);
        SetConVarInt(g_Cvar_PlayerCash, 0, true);
        SetConVarInt(g_Cvar_TeamCash, 0, true);
    }

    // FFA Deathmatch
    if(StrContains(g_sServerName, "Deathmatch") > -1){
        SetConVarInt(g_Cvar_FriendlyFire, 1, true);
        SetConVarInt(g_Cvar_IgnoreWin, 0, true);
        SetConVarInt(g_Cvar_WarmupPeriod, 0, true);
        SetConVarString(g_Cvar_BotChatter, "off", true);
        SetConVarInt(g_Cvar_MaxRounds, 99999, true);
        SetConVarInt(g_Cvar_RoundTime, 99999, true);
        SetConVarInt(g_Cvar_RoundTimeHostage, 99999, true);
        SetConVarInt(g_Cvar_RoundTimeDefuse, 99999, true);
        SetConVarInt(g_Cvar_WarmupTime, 5, true);
        SetConVarInt(g_Cvar_SolidTeam, 1, true);
    }
    // FFA Deathmatch
    if(StrContains(g_sServerName, "AWP") > -1){
        SetConVarInt(g_Cvar_FriendlyFire, 0, true);
    }

    // Multi1v1
    if(StrContains(g_sServerName, "Arena") > -1){
        SetConVarInt(g_Cvar_Radar, 1);
    }
}