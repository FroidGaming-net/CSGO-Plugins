/* SM Includes */
#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"

public Plugin myinfo =
{
    name = "[FroidApp] Electro Effects",
    author = "FroidGaming.net",
    description = "Electro Effects for VIP.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("bullet_impact", Event_BulletImpact);
}

public Action Event_BulletImpact(Event event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

    if (CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
		float fPos[3];
		fPos[0] = GetEventFloat(event, "x");
		fPos[1] = GetEventFloat(event, "y");
		fPos[2] = GetEventFloat(event, "z");

		Func_EnergySplash(fPos);
    }
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
    int iAttacker = GetClientOfUserId(GetEventInt(event, "attacker"));

    if (iAttacker != iClient && CheckCommandAccess(iAttacker, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
        float fPos[3];
        GetClientAbsOrigin(iClient, fPos);
		Func_Tesla(fPos);
    }
}

public void Func_EnergySplash(float fPos[3])
{
    float fEndPos[3];
	fEndPos[0] = fPos[0] + 20.0;
	fEndPos[1] = fPos[1] + 20.0;
	fEndPos[2] = fPos[2] + 20.0;

	TE_SetupEnergySplash(fPos, fEndPos, true);
	TE_SendToAll();
}

public void Func_Tesla(const float fPos[3])
{
	int iEntity = CreateEntityByName("point_tesla");
	DispatchKeyValue(iEntity, "beamcount_min", "5");
	DispatchKeyValue(iEntity, "beamcount_max", "10");
	DispatchKeyValue(iEntity, "lifetime_min", "0.2");
	DispatchKeyValue(iEntity, "lifetime_max", "0.5");
	DispatchKeyValue(iEntity, "m_flRadius", "100.0");
	DispatchKeyValue(iEntity, "m_SoundName", "DoSpark");
	DispatchKeyValue(iEntity, "texture", "sprites/physbeam.vmt");
	DispatchKeyValue(iEntity, "m_Color", "255 255 255");
	DispatchKeyValue(iEntity, "thick_min", "1.0");
	DispatchKeyValue(iEntity, "thick_max", "10.0");
	DispatchKeyValue(iEntity, "interval_min", "0.1");
	DispatchKeyValue(iEntity, "interval_max", "0.2");

	DispatchSpawn(iEntity);
	TeleportEntity(iEntity, fPos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(iEntity, "TurnOn");
	AcceptEntityInput(iEntity, "DoSpark");

	SetVariantString("OnUser1 !self:kill::2.0:-1");
	AcceptEntityInput(iEntity, "AddOutput");
	AcceptEntityInput(iEntity, "FireUser1");
}