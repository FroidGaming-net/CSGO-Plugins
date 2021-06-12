/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <csgocolors>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"
#define EVENT_PANEL_SHOW_TIME 6.0

int g_iFreezeTime;
int g_iRoundStart;
int g_iMode = 0;
char g_sMode[128] = "Normal DM";
char SOUND_PATH[255] = "error";

public Plugin myinfo =
{
	name = "[Deathmatch] Config Loader",
	author = "FroidGaming.net",
	description = "Loads Deathmatch configuration files based on Round Timeleft.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public void OnPluginStart()
{
    Handle hCvFreezeTime = FindConVar("mp_freezetime");
    g_iFreezeTime = GetConVarInt(hCvFreezeTime);

    HookEvent("round_start", Event_RoundStart);
}

public void OnMapStart()
{
    CreateTimer(10.0, Timer_Repeat, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
    CreateTimer(240.0, Timer_Repeat2, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action Event_RoundStart( Handle hEvent, const char[] sName, bool dontBroadcast )
{
    g_iMode = 0;
    g_iRoundStart = GetTime();
}

public Action Timer_Repeat(Handle hTimer)
{
    if (IsWarmup()) {
        return;
    }
    int iSecondsTotal = ( GetTotalRoundTime() - GetCurrentRoundTime() );

    int iMinutes = (iSecondsTotal / 60);
    // int iSeconds = iSecondsTotal - (iMinutes * 60);

    // 60 Minutes
    // 60-51 = Normal DM
    // 50-41 = Primary Only
    // 40-35 = Pistol Only
    // 34-31 = Pistol Only Headshot
    // 30-21 = Primary Only
    // 20-11 = Primary Only Headshot
    // 11-1 = Normal DM
    if(iMinutes <= 61 && iMinutes >= 51){
        if (g_iMode != 1) {
            g_iMode = 1;
            ServerCommand("dm_load deathmatch.ini respawn");
            PlaySound();
            Format(g_sMode, sizeof(g_sMode), "Normal DM");
            CreateTimer(10.0, Timer_Repeat2);
        }
    }else if(iMinutes <= 50 && iMinutes >= 41){
        if (g_iMode != 2) {
            g_iMode = 2;
            ServerCommand("dm_load deathmatch_primary.ini respawn");
            PlaySound();
            Format(g_sMode, sizeof(g_sMode), "Primary Weapons Only");
            CreateTimer(10.0, Timer_Repeat2);
        }
    }else if(iMinutes <= 40 && iMinutes >= 35){
        if (g_iMode != 3) {
            g_iMode = 3;
            ServerCommand("dm_load deathmatch_pistol.ini respawn");
            PlaySound();
            Format(g_sMode, sizeof(g_sMode), "Secondary Weapons Only");
            CreateTimer(10.0, Timer_Repeat2);
        }
    }else if(iMinutes <= 34 && iMinutes >= 31){
        if (g_iMode != 4) {
            g_iMode = 4;
            ServerCommand("dm_load deathmatch_pistol_hs.ini respawn");
            PlaySound();
            Format(g_sMode, sizeof(g_sMode), "Secondary Weapons Only [HS Mode]");
            CreateTimer(10.0, Timer_Repeat2);
        }
    }else if(iMinutes <= 30 && iMinutes >= 21){
        if (g_iMode != 5) {
            g_iMode = 5;
            ServerCommand("dm_load deathmatch_primary.ini respawn");
            PlaySound();
            Format(g_sMode, sizeof(g_sMode), "Primary Weapons Only");
            CreateTimer(10.0, Timer_Repeat2);
        }
    }else if(iMinutes <= 20 && iMinutes >= 15){
        if (g_iMode != 6) {
            g_iMode = 6;
            ServerCommand("dm_load deathmatch_primary_hs.ini respawn");
            PlaySound();
            Format(g_sMode, sizeof(g_sMode), "Primary Weapons Only [HS Mode]");
            CreateTimer(10.0, Timer_Repeat2);
        }
    }else if(iMinutes <= 14 && iMinutes >= 11){
        if (g_iMode != 6) {
            g_iMode = 6;
            ServerCommand("dm_load deathmatch_pistol.ini respawn");
            PlaySound();
            Format(g_sMode, sizeof(g_sMode), "Secondary Weapons Only]");
            CreateTimer(10.0, Timer_Repeat2);
        }
    }else if(iMinutes <= 11 && iMinutes >= 0){
        if (g_iMode != 7) {
            g_iMode = 7;
            ServerCommand("dm_load deathmatch.ini respawn");
            PlaySound();
            Format(g_sMode, sizeof(g_sMode), "Normal DM");
            CreateTimer(10.0, Timer_Repeat2);
        }
    }
}

public Action Timer_Repeat2(Handle hTimer)
{
    char sTemp[512];
    Format(sTemp, sizeof(sTemp), "<pre><font class='fontSize-xl'>Mode : </font><font color='#34eb9c' class='fontSize-xl'>%s</font></pre>", g_sMode);
    CPrintToChatAll("[{green}DM{default}] Mode : {purple}%s", g_sMode);
    ShowPanel(sTemp);
    CreateTimer(EVENT_PANEL_SHOW_TIME, Timer_ClosePanel);
}

public Action Timer_ClosePanel(Handle timer)
{
    ShowPanel(" ");
}

stock int GetTotalRoundTime()
{
    return GameRules_GetProp("m_iRoundTime");
}

stock int GetCurrentRoundTime()
{
    return (GetTime() - g_iRoundStart) - g_iFreezeTime;
}

stock void PlaySound()
{
	for (int i = 1; i < MaxClients+1; i++)
	{
		if (IsValidEntity(i))
			if (IsClientConnected(i))
				if (IsClientInGame(i))
					if (!IsFakeClient(i) && !IsClientObserver(i))
					{
						// EmitSoundToClient(i, SOUND_PATH, i, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
						ClientCommand(i, "play *%s", SOUND_PATH);
					}
	}
}

stock bool IsWarmup()
{
	return view_as<bool>(GameRules_GetProp("m_bWarmupPeriod"));
}

stock void ShowPanel(const char[] sMessage = "")
{
    Event newevent = CreateEvent("cs_win_panel_round");
    newevent.SetString("funfact_token", sMessage);
    for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
            newevent.FireToClient(i);
        }
    }
    // newevent.Cancel();
}

stock bool IsValidClient(int client, bool alive = false)
{
    return (0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)));
}