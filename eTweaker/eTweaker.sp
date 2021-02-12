#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <eItems>
#include <PTaH>
#include <autoexecconfig>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma newdecls required
#pragma semicolon 1

#define AUTHOR "ESK0, FroidGaming.net"
#define VERSION "3.3"
#define UPDATE_URL "https://sys.froidgaming.net/eTweaker/updatefile.txt"
#define TAG_NCLR "[eTweaker]"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/ptah.sp"
#include "files/func.sp"
#include "files/convars.sp"
#include "files/sdkhooks.sp"
#include "files/database.sp"
#include "files/modules/ws.sp"
#include "files/modules/knife.sp"
#include "files/modules/skins.sp"
#include "files/modules/gloves.sp"
#include "files/modules/tweaks.sp"
#include "files/modules/musickits.sp"


public Plugin myinfo =
{
    name = "eTweaker",
    author = AUTHOR,
    version = VERSION
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] chError, int iErrMax)
{
	g_bLateLoaded = bLate;
}

public void OnPluginStart()
{
    if(GetEngineVersion() != Engine_CSGO)
    {
        SetFailState("%s This plugins is for CSGO Only!", TAG_NCLR);
    }

    if(PTaH_Version() < 101030)
    {
        SetFailState("%s PTaH version is not up to date!", TAG_NCLR);
    }

    if(g_bLateLoaded)
    {
        if(eItems_AreItemsSynced())
        {
            eItems_OnItemsSynced();
        }
        else if(!eItems_AreItemsSyncing())
        {
            eItems_ReSync();
        }

        for(int client = 1; client <= MaxClients; client++)
        {
            if(!IsValidClient(client))
            {
                continue;
            }

            OnClientPostAdminCheck(client);
        }
    }

    GameData hConfig = new GameData("eTweaker");
    if(hConfig == null)
    {
        SetFailState("gamedata/eTweaker.txt missing");
    }

    int iEquipOffset = hConfig.GetOffset("EquipWearable");
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetVirtual(iEquipOffset);
    PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
    g_hGiveWearableCall = EndPrepSDKCall();

    int iRemoveOffset = hConfig.GetOffset("RemoveAllWearables");
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetVirtual(iRemoveOffset);
    g_hRemoveWearableCall = EndPrepSDKCall();

    PTaH(PTaH_GiveNamedItemPre,     Hook, PTaH_OnGiveNamedItemPre);
    PTaH(PTaH_WeaponCanUsePre,      Hook, PTaH_OnWeaponCanUsePre);
    PTaH(PTaH_GiveNamedItemPost,    Hook, PTaH_OnGiveNamedItemPost);


    RegConsoleCmd("sm_skin",          Command_Ws);
    RegConsoleCmd("sm_skins",          Command_Ws);
    RegConsoleCmd("sm_ws",          Command_Ws);
    RegConsoleCmd("sm_wsa",         Command_WsAll);
    RegConsoleCmd("sm_knife",       Command_Knife);
    RegConsoleCmd("sm_knifes",       Command_Knife);
    RegConsoleCmd("sm_knive",       Command_Knife);
    RegConsoleCmd("sm_knives",       Command_Knife);
    RegConsoleCmd("sm_glove",      Command_Gloves);
    RegConsoleCmd("sm_gloves",      Command_Gloves);
    RegConsoleCmd("sm_music",    Command_Music);
    RegConsoleCmd("sm_musics",    Command_Music);
    RegConsoleCmd("sm_musickit",    Command_Music);
    RegConsoleCmd("sm_musickits",   Command_Music);
    RegConsoleCmd("sm_tweak",       Command_Tweaks);
    RegConsoleCmd("sm_tweaks",      Command_Tweaks);
    RegConsoleCmd("sm_sticker",    Command_Stickers);
    RegConsoleCmd("sm_stickers",    Command_Stickers);

    HookEvent("player_death",   Event_OnPlayerDeath);
    HookEvent("player_spawn",   Event_OnPlayerSpawn, EventHookMode_Post);
    HookEvent("round_start",    Event_OnRoundStart);
    HookEvent("inspect_weapon", Event_OnWeaponInspect);

    g_iNameTagOffset    = FindSendPropInfo("CBaseAttributableItem", "m_szCustomName");

    Database.Connect(Database_OnConnect, "default");

    AutoExecConfig_SetFile("eTweaker_config");

    g_cvDrawAnimation = AutoExecConfig_CreateConVar("sm_etweaker_disable_draw_animation", "1", "Set 0 to re-enable draw animation after weapon modification.", FCVAR_PROTECTED, true, 0.0, true, 1.0);
    g_cvDrawAnimation.AddChangeHook(OnConVarChanged);

    g_cvDangerZoneKnives = AutoExecConfig_CreateConVar("sm_etweaker_dangerzone_knives", "0", "Set 1 to enable Danger Zone knives", FCVAR_PROTECTED, true, 0.0, true, 1.0);
    g_cvDangerZoneKnives.AddChangeHook(OnConVarChanged);

    g_cvSelectTeamMode = AutoExecConfig_CreateConVar("sm_etweaker_select_team_mode", "3", "1 = Current team, 2 = Both teams, 3 = Ask for team", FCVAR_PROTECTED, true, 1.0, true, 3.0);
    g_cvSelectTeamMode.AddChangeHook(OnConVarChanged);

    g_cvForceFullUpdate = AutoExecConfig_CreateConVar("sm_etweaker_force_fullupdate", "1", "Set 1 to force update client view model after is sticker applied (cause small lag on client side)", FCVAR_PROTECTED, true, 0.0, true, 1.0);
    g_cvForceFullUpdate.AddChangeHook(OnConVarChanged);

    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();

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

public void OnClientPostAdminCheck(int client)
{
    if(!IsValidClient(client))
    {
        return;
    }

    ClientInfo[client].Reset();
    ClientInfo[client].edict = client;

    if(g_smWeaponSettings[client] != null)
    {
        delete g_smWeaponSettings[client];
        g_smWeaponSettings[client] = null;
    }

    g_smWeaponSettings[client] = new StringMap();

    if(eTweaker_AreDataSynced())
    {
        char szWeaponDefIndex[12];
        for(int iWeaponNum = 0; iWeaponNum < eTweaker_GetWeaponCount(); iWeaponNum++)
        {
            int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
            IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            WeaponSettings.Reset();

            g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
        }
    }

    SDKHook(client, SDKHook_WeaponSwitchPost, SDK_OnWeaponSwitchPost);
    SDKHook(client, SDKHook_WeaponEquip, SDK_OnWeaponEquip);

    Database_OnClientConnect(client);
}

public void OnClientDisconnect(int client)
{
    if(!IsValidClient(client))
    {
        return;
    }

    SDKUnhook(client, SDKHook_WeaponSwitchPost, SDK_OnWeaponSwitchPost);
    SDKUnhook(client, SDKHook_WeaponEquip, SDK_OnWeaponEquip);

    Databse_SaveClientData(client);

}

public void OnMapStart()
{
    g_bFirstSynced = false;
    g_bFirstRound = false;

    if(g_arMapWeapons != null)
    {
        delete g_arMapWeapons;
        g_arMapWeapons = null;
    }

    g_arMapWeapons = new ArrayList();
}

public void eItems_OnItemsSynced()
{
    g_bDataSynced = true;

    g_iWeaponsCount =   eItems_GetWeaponCount();
    g_iPaintsCount  =   eItems_GetPaintsCount();
    g_iGlovesCount  =   eItems_GetGlovesCount();
    g_iMusicKitsCount = eItems_GetMusicKitsCount();
    g_iStickersSetsCount = eItems_GetStickersSetsCount();
    g_iStickersCount = eItems_GetStickersCount();
}

public Action Event_OnWeaponInspect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(!IsValidClient(client, true))
    {
       return Plugin_Continue;
    }

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
    if(WeaponSettings.RareInspect || (eItems_HasRareInspectByDefIndex(iWeaponDefIndex) && ClientInfo[client].RareInspect))
    {
        int iPredictedViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
        if(!IsValidEntity(iPredictedViewModel))
        {
            return Plugin_Continue;
        }

        DataPack data = new DataPack();
        data.WriteCell(iPredictedViewModel);
        data.WriteCell(iWeaponDefIndex);

        RequestFrame(Frame_Inspect, data);
        SetEntProp(iPredictedViewModel, Prop_Send, "m_nSequence", eItems_GetRareDrawSequenceByDefIndex(iWeaponDefIndex));
    }
    return Plugin_Continue;
}

public void Frame_Inspect(DataPack data)
{
    data.Reset();
    int iPredictedViewModel = data.ReadCell();
    int iWeaponDefIndex = data.ReadCell();

    SetEntProp(iPredictedViewModel, Prop_Send, "m_nSequence", eItems_GetRareInspectSequenceByDefIndex(iWeaponDefIndex));

    delete data;
}

public Action Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    if(IsValidClient(victim) && IsValidClient(attacker) && victim != attacker)
    {
        char szWeapon[32];
        char szWeaponClassname[48];
        event.GetString("weapon", szWeapon, sizeof(szWeapon));
        Format(szWeaponClassname, sizeof(szWeaponClassname), "weapon_%s", szWeapon);
        int iWeaponDefIndex = eItems_GetWeaponDefIndexByClassName(szWeaponClassname);

        char szWeaponDefIndex[12];
        IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

        eWeaponSettings WeaponSettings;
        if(g_smWeaponSettings[attacker].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings)))
        {
            if(WeaponSettings.StatTrak_Enabled)
            {
                WeaponSettings.StatTrak_Kills += 1;
                WeaponSettings.Changed = true;
                g_smWeaponSettings[attacker].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            }
        }
    }

    eTweaker_RemoveClientGloves(victim);

    return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));

    if(!IsValidClient(client, true))
    {
        return Plugin_Handled;
    }

    eTweaker_EquipGloves(client);
    eTweaker_GiveMusicKit(client);
    return Plugin_Continue;
}

public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if(g_bFirstRound == false)
    {
        g_bFirstRound = true;

        g_arMapWeapons.Clear();
        char szWeaponClassname[64];

        for(int i = MaxClients; i < GetMaxEntities(); i++)
        {
            if(!IsValidEntity(i))
            {
                continue;
            }

            GetEntityClassname(i, szWeaponClassname, sizeof(szWeaponClassname));
            if((StrContains(szWeaponClassname, "weapon_")) == -1)
            {
                continue;
            }

            if(!eItems_IsValidWeapon(i))
            {
                continue;
            }

            if(GetEntProp(i, Prop_Send, "m_hOwnerEntity") != -1)
            {
                continue;
            }

            int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeapon(i);

            if(eItems_IsDefIndexKnife(iWeaponDefIndex))
            {
                continue;
            }

            g_arMapWeapons.Push(i);
        }
    }
    return Plugin_Continue;
}

public Action OnClientSayCommand(int client, const char[] szCommand, const char[] szArgs)
{

    if(!IsValidClient(client))
    {
        return Plugin_Continue;
    }

    if(!(StrEqual(szCommand, "say", false) || StrEqual(szCommand, "say_team")))
    {
        return Plugin_Continue;
    }
    if(StrEqual(szArgs, "cancel", false) == false)
    {
        if(ClientInfo[client].ChangingNametag || ClientInfo[client].ChangingNametagCurrent)
        {
            if(strlen(szArgs) > 30)
            {
                CPrintToChat(client, "%s Maximum 30 Characters!", PREFIX);
                return Plugin_Handled;
            }

            if(ClientInfo[client].ChangingNametagCurrent)
            {
                if(!IsPlayerAlive(client))
                {
                    eTweaker_PrintOnlyForAlivePlayers(client);
                    ClientInfo[client].ChangingNametagCurrent = false;
                    return Plugin_Handled;
                }

                int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
                eTweaker_ChangeWeaponNametag(client, iWeaponDefIndex, szArgs);
                ClientInfo[client].ChangingNametagCurrent = false;
            }
            else if(ClientInfo[client].ChangingNametag)
            {
                eTweaker_ChangeWeaponNametag(client, ClientInfo[client].WeaponStoredDefIndex, szArgs);
                ClientInfo[client].ChangingNametag = false;
            }
            return Plugin_Handled;
        }
    }
    else
    {
        if(ClientInfo[client].ChangingNametag || ClientInfo[client].ChangingNametagCurrent)
        {
            ClientInfo[client].ChangingNametag = false;
            ClientInfo[client].ChangingNametagCurrent = false;
            CPrintToChat(client, "%s Nametag change process \x07aborted\x01!", PREFIX);
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}
