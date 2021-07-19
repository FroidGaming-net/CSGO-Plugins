#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <prophunt>

#pragma newdecls required

bool g_bAllow[MAXPLAYERS+1] = {true, ...};
ConVar g_cvClusterNumber;
ConVar g_cvClusterRadius;
ConVar g_cvClusterPrice;
ConVar g_cvClusterSort;
ConVar g_cvClusterUnlock;

bool g_bClusterGrenadeUpgrade[MAXPLAYERS + 1];

#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
	name = "Prophunt Cluster Grenade",
	author = ".#Zipcore, Credits: Simon & Deathknife",
	description = "Adds cluster grenade upgrade to seeker shop.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

public void OnPluginStart()
{
	CreateConVar("ph_clustergrenade_version", PLUGIN_VERSION, "Cluster Grenade Version", FCVAR_DONTRECORD | FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_SPONLY);
	g_cvClusterNumber = CreateConVar("ph_clustergrenade_amount", "2", "Number of grenades in the cluster.", 0, true, 0.0, false);
	g_cvClusterRadius = CreateConVar("ph_clustergrenade_radius", "6.0", "Radius in which the cluster spawns around the main grenade.", 0, true, 0.0, false);
	g_cvClusterPrice = CreateConVar("ph_clustergrenade_price", "160", "How much points to are req to buy this upgrade.");
	g_cvClusterSort = CreateConVar("ph_clustergrenade_sort", "30", "Shop sort order.");
	g_cvClusterUnlock = CreateConVar("ph_clustergrenade_unlock", "130", "When to unlock this item.");

	AutoExecConfig(true, "prophunt-clustergrenade");

	HookEvent("player_spawn", Event_OnPlayerSpawn);
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "prophunt"))
	{
		PH_RegisterShopItem("Cluster Grenade Upgrade", CS_TEAM_CT, g_cvClusterPrice.IntValue, g_cvClusterSort.IntValue, g_cvClusterUnlock.IntValue, false);
	}
}

public void OnMapStart()
{
	PH_RegisterShopItem("Cluster Grenade Upgrade", CS_TEAM_CT, g_cvClusterPrice.IntValue, g_cvClusterSort.IntValue, g_cvClusterUnlock.IntValue, false);
}

public Action PH_OnBuyShopItem(int iClient, char[] sName, int &iPoints)
{
	if(StrEqual(sName, "Cluster Grenade Upgrade"))
		return Plugin_Handled;

	return Plugin_Continue;
}

public void PH_OnBuyShopItemPost(int iClient, char[] sName, int iPoints)
{
	if(StrEqual(sName, "Cluster Grenade Upgrade"))
	{
		g_bClusterGrenadeUpgrade[iClient] = true;
		PH_DisableShopItem("Cluster Grenade Upgrade", iClient);
	}
}

public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

	g_bClusterGrenadeUpgrade[iClient] = false;

	return Plugin_Continue;
}

public void OnEntityCreated(int iEntity, const char[] classname)
{
	if (StrContains(classname, "_projectile") != -1)
		if(StrContains(classname, "hegrenade") != -1)
			SDKHook(iEntity, SDKHook_SpawnPost, OnEntitySpawned);
}

public Action OnEntitySpawned(int iGrenade)
{
	int iClient = GetEntPropEnt(iGrenade, Prop_Send, "m_hOwnerEntity");
	if (IsValidClient(iClient) && g_bClusterGrenadeUpgrade[iClient])
	{
		char classname[50];
		GetEdictClassname(iGrenade, classname, sizeof(classname));

		if(g_bAllow[iClient])
		{
			g_bAllow[iClient] = false;
			CreateCluster(iClient, g_cvClusterNumber.IntValue, classname);
		}
	}
	CreateTimer(0.1, AllowAgain, iClient);
}

public Action AllowAgain(Handle timer, any data)
{
	g_bAllow[data] = true;
}

public void CreateCluster(int client, const int number, const char[] classname)
{
	float angles[3];
	float[][] ang = new float[number][3];
	float pos[3];
	float vel[3];
	GetClientEyeAngles(client, angles);
	GetClientEyePosition(client, pos);

	int[] GEntities = new int[number];
	float g_fSpin[3] =  { 4877.4, 0.0, 0.0 };
	float fPVelocity[3];
	float fRadius = g_cvClusterRadius.FloatValue;
	for (int i = 0; i < number; i++)
	{
		ang[i][0] = angles[0] + GetRandomFloat(fRadius * -1.0, fRadius);
		ang[i][1] = angles[1] + GetRandomFloat(fRadius * -1.0, fRadius);
		ang[i][2] = angles[2];
		float temp_ang[3];
		temp_ang[0] = ang[i][0];
		temp_ang[1] = ang[i][1];
		temp_ang[2] = ang[i][2];

		GetAngleVectors(temp_ang, vel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vel, 1250.0);
		GEntities[i] = CreateEntityByName(classname);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fPVelocity);
		AddVectors(vel, fPVelocity, vel);

		SetEntPropVector(GEntities[i], Prop_Data, "m_vecAngVelocity", g_fSpin);
		SetEntPropEnt(GEntities[i], Prop_Data, "m_hThrower", client);
		SetEntPropEnt(GEntities[i], Prop_Data, "m_hOwnerEntity", client);
		SetEntProp(GEntities[i], Prop_Send, "m_iTeamNum", GetClientTeam(client));

		if(StrContains(classname, "hegrenade") != -1)
		{
			SetEntPropFloat(GEntities[i], Prop_Send, "m_DmgRadius", 350.0);
			SetEntPropFloat(GEntities[i], Prop_Send, "m_flDamage", 99.0);
		}

		AcceptEntityInput(GEntities[i], "InitializeSpawnFromWorld");
		AcceptEntityInput(GEntities[i], "FireUser1", GEntities[i]);
		DispatchSpawn(GEntities[i]);
		TeleportEntity(GEntities[i], pos, temp_ang, vel);
	}
}

stock bool IsValidClient(int client)
{
	if (client <= 0)
		return false;

	if (client > MaxClients)
		return false;

	if (!IsClientConnected(client))
		return false;

	return IsClientInGame(client);
}