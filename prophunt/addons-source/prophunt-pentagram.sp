#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include <csgocolors>
#include <soundlib>
#include <emitsoundany>
#include <prophunt>
#include <speedrules>

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define PLUGIN_VERSION "1.0"
#define PENTAGRAM "Pentagram"

#define PREFIX "{magenta}[{lime}Prop{yellow}Hunt{darkred}X{magenta}] {yellow}"

public Plugin myinfo =
{
	name = "Prophunt - Pentagram",
	author = ".#Zipcore",
	description = "Allows seekers to create a pentagram which makes demos week.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

ConVar g_cvPrice;
ConVar g_cvSort;
ConVar g_cvUnlockTime;
ConVar g_cvSpeed;
ConVar g_cvSpeedEnable;
ConVar g_cvSpeedPriority;

int g_iPentagramState[MAXPLAYERS + 1];
float g_fPentagramStateTime[MAXPLAYERS + 1];
float g_fPentagramPos[MAXPLAYERS + 1][3];
float g_fPentagramTrapTime[MAXPLAYERS + 1];

int g_iLaser;
int g_iHalo;

#define VMT_LASERBEAM "materials/sprites/laserbeam.vmt"
#define VMT_HALO "materials/sprites/halo.vmt"

public void OnPluginStart()
{
	g_cvPrice = CreateConVar("ph_pentagram_price", "200", "Pentagram price.");
	g_cvSort = CreateConVar("ph_pentagram_sort", "1", "Pentagram sort.");
	g_cvUnlockTime = CreateConVar("ph_pentagram_unlocktime", "140", "Pentagram price.");
	g_cvSpeedEnable = CreateConVar("ph_pentagram_speed_enable", "1", "Enable slow when trapped.");
	g_cvSpeed = CreateConVar("ph_pentagram_speed", "0.25", "How fast hider are inside a pentagram.");
	g_cvSpeedPriority = CreateConVar("ph_pentagram_speed_priority", "100", "Priority used by speedrules.");

	AutoExecConfig(true, "prophunt-pentagram");
}

public void OnMapStart()
{
	LoopClients(iClient)
	{
		g_fPentagramStateTime[iClient] = 0.0;
		g_fPentagramTrapTime[iClient] = 0.0;
	}

	g_iLaser = PrecacheModel(VMT_LASERBEAM);
	g_iHalo = PrecacheModel(VMT_HALO);

	PH_RegisterShopItem(PENTAGRAM, CS_TEAM_CT, g_cvPrice.IntValue, g_cvSort.IntValue, g_cvUnlockTime.IntValue, false);
}

public void PH_OnSeekerSpawn(int iClient)
{
	g_iPentagramState[iClient] = 0;
	g_fPentagramTrapTime[iClient] = 0.0;
}

public void PH_OnHiderSpawn(int iClient)
{
	g_fPentagramTrapTime[iClient] = 0.0;
}

public Action PH_OnBuyShopItem(int iClient, char[] sName, int &iPoints)
{
	if(StrEqual(sName, PENTAGRAM)) {
		return Plugin_Handled;
	}

	if(g_fPentagramTrapTime[iClient] > GetGameTime())
	{
		CPrintToChat(iClient, "%s {darkred}You can't use this while iniside a {purple}Pentagram{darkred}.", PREFIX);
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void PH_OnBuyShopItemPost(int iClient, char[] sName, int iPoints)
{
	if(StrEqual(sName, PENTAGRAM)) {
		StartPentagram(iClient);
	}
}

void StartPentagram(int iClient)
{
	GetClientAbsOrigin(iClient, g_fPentagramPos[iClient]);
	g_iPentagramState[iClient] = 1;
	g_fPentagramStateTime[iClient] = GetGameTime();
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &impulse, float vel[3], float angles[3], int &iWeapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(!IsPlayerAlive(iClient))
		return Plugin_Continue;

	CheckPentagram(iClient);

	if(GetClientTeam(iClient) == CS_TEAM_T && g_fPentagramTrapTime[iClient] > GetGameTime())
		BlockWeapon(iClient, iWeapon, true, true);

	return Plugin_Continue;
}

void CheckPentagram(int iClient)
{
	if(GetClientTeam(iClient) != CS_TEAM_CT)
		return;

	float fPos[3];
	GetClientAbsOrigin(iClient, fPos);

	if(g_iPentagramState[iClient] > 0 && GetVectorDistance(fPos, g_fPentagramPos[iClient]) > 500.0)
	{
		CPrintToChat(iClient, "%s {purple}Pentagram {darkred}removed{yellow}. ({darkblue}You are not in range{yellow})", PREFIX);
		g_iPentagramState[iClient] = 0;
		return;
	}

	if(0 < g_iPentagramState[iClient] < 6)
	{
		if (g_fPentagramStateTime[iClient] <= GetGameTime())
		{
			g_iPentagramState[iClient] ++;
			g_fPentagramStateTime[iClient] = GetGameTime() + (float(g_iPentagramState[iClient]) * 0.2);
		}
	}

	DrawPentagram(iClient);

	if(g_iPentagramState[iClient] == 6)
	{
		LoopAlivePlayers(iTarget)
		{
			if(GetClientTeam(iTarget) != CS_TEAM_T)
				continue;

			float fTargetPos[3];
			GetClientAbsOrigin(iTarget, fTargetPos);
			if(GetVectorDistance(g_fPentagramPos[iClient], fTargetPos) > 142.0)
				continue;

			g_fPentagramTrapTime[iTarget] = GetGameTime() + 0.5;

			if(!g_cvSpeedEnable.BoolValue)
				continue;

			// Slow the hider
			SpeedRules_ClientAdd(iTarget, "pentagram", SR_Base, g_cvSpeed.FloatValue, 0.5, g_cvSpeedPriority.IntValue);

			// Override other speedrules
			SpeedRules_ClientAdd(iTarget, "pentagram", SR_Add, 0.0, 0.5, g_cvSpeedPriority.IntValue);
			SpeedRules_ClientAdd(iTarget, "pentagram", SR_Sub, 0.0, 0.5, g_cvSpeedPriority.IntValue);
			SpeedRules_ClientAdd(iTarget, "pentagram", SR_Mul, 1.0, 0.5, g_cvSpeedPriority.IntValue);
		}
	}
}

void DrawPentagram(int iClient)
{
	if(g_iPentagramState[iClient] == 0)
		return;

	float width = 3.0;
	float range = 125.0;
	int color[4];
	color = { 255, 5, 5, 255 };

	//Beam Ring
	TE_SetupBeamRingPoint(g_fPentagramPos[iClient], range * 2.0, range * 2.0 + 0.1, g_iLaser, g_iHalo, 0, 10, 0.5, width, 0.0, color, 0, 0);
	TE_SendToAll();

	if(g_iPentagramState[iClient] == 1)
		return;

	//Pentagram
	float fVecStart[3];
	float fVecEnd[3];

	for (int i = 1; i <= 5; i++)
	{
		if (g_iPentagramState[iClient] < i + 1)
			break;

		switch(i)
		{
			case 1:
			{
				GetCircuitPos(g_fPentagramPos[iClient], range, 0.0, fVecStart, false, true);
				GetCircuitPos(g_fPentagramPos[iClient], range, float(2*72), fVecEnd, false, true);
			}
			case 2:
			{
				GetCircuitPos(g_fPentagramPos[iClient], range, float(2*72), fVecStart, false, true);
				GetCircuitPos(g_fPentagramPos[iClient], range, float(4*72), fVecEnd, false, true);
			}
			case 3:
			{
				GetCircuitPos(g_fPentagramPos[iClient], range, float(4*72), fVecStart, false, true);
				GetCircuitPos(g_fPentagramPos[iClient], range, float(1*72), fVecEnd, false, true);
			}
			case 4:
			{
				GetCircuitPos(g_fPentagramPos[iClient], range, float(1*72), fVecStart, false, true);
				GetCircuitPos(g_fPentagramPos[iClient], range, float(3*72), fVecEnd, false, true);
			}
			case 5:
			{
				GetCircuitPos(g_fPentagramPos[iClient], range, float(3*72), fVecStart, false, true);
				GetCircuitPos(g_fPentagramPos[iClient], range, 0.0, fVecEnd, false, true);
			}
		}

		TE_SetupBeamPoints(fVecStart, fVecEnd, g_iLaser, g_iHalo, 0, 0, 0.5, width, 0.5, 0, 0.2, color, 0);
		TE_SendToAll();
	}
}

void GetCircuitPos(float center[3], float radius, float angle, float output[3], bool rotate = false, bool horizontal = false)
{
	float sin=Sine(DegToRad(angle))*radius;
	float cos=Cosine(DegToRad(angle))*radius;

	if(horizontal)
	{
		output[0] = center[0]+sin;
		output[1] = center[1]+cos;
		output[2] = center[2];
	}
	else
	{
		if(rotate)
		{
			output[0] = center[0]+sin;
			output[1] = center[1];
			output[2] = center[2]+cos;
		}
		else
		{
			output[0] = center[0];
			output[1] = center[1]+sin;
			output[2] = center[2]+cos;
		}
	}
}

stock void BlockWeapon(int iClient, int iWeapon, bool attack, bool attack2, float time = 1.0)
{
	float unlockTime = GetGameTime() + time;

	if(attack)
		SetEntPropFloat(iClient, Prop_Send, "m_flNextAttack", unlockTime);

	if(attack2 && iWeapon > 0)
		SetEntPropFloat(iWeapon, Prop_Send, "m_flNextSecondaryAttack", unlockTime);
}