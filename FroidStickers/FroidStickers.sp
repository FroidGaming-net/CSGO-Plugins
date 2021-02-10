/* SM Includes */
#include <sourcemod>
#include <eItems>
#include <PTaH>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0"
#define UPDATE_URL "https://sys.froidgaming.net/FroidStickers/updatefile.txt"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"
#define PREFIX_CONSOLE "[FroidStickers]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/ptah.sp"
// #include "files/API.sp"
// #include "files/commands.sp"
// #include "files/menus.sp"
#include "files/custom_functions.sp"
#include "files/database.sp"

public Plugin myinfo =
{
	name = "[FroidApp] Stickers",
	author = "FroidGaming.net",
	description = "Stickers Management.",
	version = VERSION,
	url = "https://froidgaming.net"
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] chError, int iErrMax)
{
	g_bLateLoaded = bLate;
}

public void OnPluginStart()
{
    if(GetEngineVersion() != Engine_CSGO)
    {
        SetFailState("%s This plugins is for CSGO Only!", PREFIX_CONSOLE);
    }

    if(PTaH_Version() < 101030)
    {
        SetFailState("%s PTaH version is not up to date!", PREFIX_CONSOLE);
    }

    if (g_bLateLoaded) {
        if (eItems_AreItemsSynced()) {
            eItems_OnItemsSynced();
        }
    }

	PTaH(PTaH_GiveNamedItemPost, Hook, PTaH_OnGiveNamedItemPost);

	RegConsoleCmd("sm_sticker", Call_MenuStickers);
	RegConsoleCmd("sm_stickers", Call_MenuStickers);

    Database.Connect(Database_OnConnect, "default");

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

public void OnMapStart()
{
    g_bFirstSynced = false;
}

public void eItems_OnItemsSynced()
{
    g_bDataSynced = true;

    g_iWeaponsCount = eItems_GetWeaponCount();
    g_iPatchesCount = eItems_GetPatchesCount();
    g_iStickersSetsCount = eItems_GetStickersSetsCount();
    g_iStickersCount = eItems_GetStickersCount();
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

    if(FroidStickers_AreDataSynced())
    {
        char sWeaponDefIndex[12];
        for(int iWeaponNum = 0; iWeaponNum < FroidStickers_GetWeaponCount(); iWeaponNum++)
        {
            int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
            IntToString(iWeaponDefIndex, sWeaponDefIndex, sizeof(sWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            WeaponSettings.Reset();

            g_smWeaponSettings[client].SetArray(sWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
        }
    }

    Database_OnClientConnect(client);
}

public void OnClientDisconnect(int client)
{
    if(!IsValidClient(client))
    {
        return;
    }

    // Databse_SaveClientData(client);
}