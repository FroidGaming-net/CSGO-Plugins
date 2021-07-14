#pragma semicolon 1
// #pragma newdecls required
#pragma tabsize 4

#include <sourcemod>
// #include <sdktools>
#include <sdkhooks>
#include <nexd>

ConVar sv_disable_radar;

public Plugin myinfo =
{
	name = "AntiGhosting",
	author = "FroidCode",
	version = "0.1"
};

public void OnPluginStart()
{
    sv_disable_radar = FindConVar("sv_disable_radar");
    CreateTimer(3.0, Timer_Repeat, _, TIMER_REPEAT);
}

// public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
// {
//     if (!IsFakeClient(client)) {
//         if (!(tickcount % 32))
// 		{
// 			if (GetClientTeam(client) == 1)
// 			{
// 				sv_disable_radar.ReplicateToClient(client, "1");
// 			}else{
// 			    sv_disable_radar.ReplicateToClient(client, "0");
//             }
// 		}
//     }
// }

public Action Timer_Repeat(Handle hTimer)
{
    for (int i = 1; i < MAXPLAYERS; i++) {
		if (IsValidClient(i)) {
			if (GetClientTeam(i) == 1) {
				SetClientViewEntity(i, 0);
				SDKHook(i, SDKHook_SetTransmit, DontSee);
				sv_disable_radar.ReplicateToClient(i, "1");
			} else {
                SetClientViewEntity(i, i);
                SDKUnhook(i, SDKHook_SetTransmit, DontSee);
				sv_disable_radar.ReplicateToClient(i, "0");
            }
        }
    }
}

public Action DontSee(int client, int entity)
{
    return Plugin_Continue;
}