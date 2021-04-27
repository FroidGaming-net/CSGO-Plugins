#include <sdktools>
#include <dhooks>
#include <discord_extended>
#include <multicolors>
#include <geoip>
#include <eItems>
#undef REQUIRE_PLUGIN
#include <updater>

#define UPDATE_URL "https://sys.froidgaming.net/DropsSummoner/updatefile.txt"

#define PLUGIN_NAME "FroidApp"
#define PLUGIN_AUTHORS "FroidGaming.net"
#define PLUGIN_VERSION "1.0.7"
#define PREFIX "{default}[{lightblue}FroidGaming.net{default}]"

public Plugin myinfo =
{
	name = "[" ... PLUGIN_NAME ... "] Drop Summoner",
	author = PLUGIN_AUTHORS,
	version = PLUGIN_VERSION
};

Handle g_hRewardMatchEndDrops = null;
int g_iOS = -1;
char sIP[26];
char sCountryCode[3];
ConVar g_cHostname;
char g_sHostname[64];

public void OnPluginStart()
{
	GameData hGameData = LoadGameConfigFile("DropsSummoner.games");

	if (!hGameData)
	{
		SetFailState("Failed to load DropsSummoner gamedata.");

		return;
	}

	g_iOS = hGameData.GetOffset("OS");

	if(g_iOS == -1)
	{
		SetFailState("Failed to get OS offset");

		return;
	}

	if(g_iOS == 1)
	{
		StartPrepSDKCall(SDKCall_Raw);
	}
	else
	{
		StartPrepSDKCall(SDKCall_Static);
	}

	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CCSGameRules::RewardMatchEndDrops");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);

	if (!(g_hRewardMatchEndDrops = EndPrepSDKCall()))
	{
		SetFailState("Failed to create SDKCall for CCSGameRules::RewardMatchEndDrops");

		return;
	}

	Handle hCCSGameRules_RecordPlayerItemDrop = DHookCreateFromConf(hGameData, "CCSGameRules::RecordPlayerItemDrop");

	delete hGameData;

	if (!hCCSGameRules_RecordPlayerItemDrop)
	{
		SetFailState("Failed to setup detour for CCSGameRules::RecordPlayerItemDrop");

		return;
	}

	if (!DHookEnableDetour(hCCSGameRules_RecordPlayerItemDrop, true, Detour_RecordPlayerItemDrop))
	{
		SetFailState("Failed to detour CCSGameRules::RecordPlayerItemDrop.");

		return;
	}

	HookEvent("round_prestart", Event_PreRoundStart);
	CreateTimer(10.0, Timer_Setting);

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

public Action Timer_Setting(Handle hTimer)
{
	g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));
	if(StrContains(g_sHostname, "FFA") > -1 || StrContains(g_sHostname, "Practice") > -1){
		CreateTimer(60.0, Timer_SendRewardMatchEndDrops, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void EscapeString(char[] string, int maxlen)
{
	ReplaceString(string, maxlen, "@", "＠");
	ReplaceString(string, maxlen, "'", "\'");
	ReplaceString(string, maxlen, "\"", "＂");
}

public void OnMapStart()
{
	PrecacheSound("ui/panorama/case_awarded_1_uncommon_01.wav");
}

public Action Event_PreRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(3.0, Timer_SendRewardMatchEndDrops);
	return Plugin_Continue;
}

MRESReturn Detour_RecordPlayerItemDrop(Handle hParams)
{
	int iAccountID = DHookGetParamObjectPtrVar(hParams, 1, 16, ObjectValueType_Int);
	int iClient = GetClientFromAccountID(iAccountID);

	if(iClient != -1)
	{
		int iDefIndex = DHookGetParamObjectPtrVar(hParams, 1, 20, ObjectValueType_Int);
		int iPaintIndex = DHookGetParamObjectPtrVar(hParams, 1, 24, ObjectValueType_Int);
		int iRarity = DHookGetParamObjectPtrVar(hParams, 1, 28, ObjectValueType_Int);
		int iQuality = DHookGetParamObjectPtrVar(hParams, 1, 32, ObjectValueType_Int);

		// char sNewMessage[1024];
		g_cHostname = FindConVar("hostname");
		g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));
		// FormatEx(sNewMessage, sizeof(sNewMessage), "Player %L dropped [%u-%u-%u-%u] [%s]", iClient, iDefIndex, iPaintIndex, iRarity, iQuality, g_sHostname);
		// EscapeString(sNewMessage, sizeof(sNewMessage));

		// Discord_StartMessage();
		// Discord_SetUsername("FroidGaming.net");
		// Discord_SetContent(sNewMessage);
		// Discord_EndMessage("rewards", true);

		Protobuf hSendPlayerItemFound = view_as<Protobuf>(StartMessageAll("SendPlayerItemFound", USERMSG_RELIABLE));
		hSendPlayerItemFound.SetInt("entindex", iClient);

		Protobuf hIteminfo = hSendPlayerItemFound.ReadMessage("iteminfo");
		hIteminfo.SetInt("defindex", iDefIndex);
		hIteminfo.SetInt("paintindex", iPaintIndex);
		hIteminfo.SetInt("rarity", iRarity);
		hIteminfo.SetInt("quality", iQuality);
		hIteminfo.SetInt("inventory", 6); //UNACK_ITEM_GIFTED

		EndMessage();

		// Discord
		Discord_StartMessage();
		Discord_SetUsername("FroidGaming.net");
		Discord_SetTitle(NULL_STRING, "★ Drop Details ★");
		/// Content
		char szBody[2][1048];
		GetClientAuthId(iClient, AuthId_SteamID64, szBody[0], sizeof(szBody[]));
		GetClientName(iClient, szBody[1], sizeof(szBody[]));
		EscapeString(szBody[1], sizeof(szBody[]));

		char sAuthid[32];
		GetClientAuthId(iClient, AuthId_Steam2, sAuthid, sizeof(sAuthid));
		Format(szBody[0], sizeof(szBody[]), "» [%s](https://steamcommunity.com/profiles/%s/) (%s)", szBody[1], szBody[0], sAuthid);
		Discord_AddField("• Player :", szBody[0], false);

		char sItem[128];
		eItems_GetCrateDisplayNameByDefIndex(iDefIndex, sItem, sizeof(sItem));
		Format(szBody[0], sizeof(szBody[]), "» %s", sItem);
		Discord_AddField("• Item :", szBody[0], false);

		g_cHostname = FindConVar("hostname");
		g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));
		Format(szBody[0], sizeof(szBody[]), "» %s", g_sHostname);
		Discord_AddField("• Server :", szBody[0], false);

		/// Content
		Discord_EndMessage("rewards", true);
		/// Discord


		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client))
			{
				GetClientIP(client, sIP, sizeof(sIP));
				GeoipCode2(sIP, sCountryCode);
				if(StrEqual(sCountryCode, "ID")){
					CPrintToChat(client, "%s {default}Selamat {lightred}%N{default} kamu mendapatkan hadiah! Terus main di froidgaming.net supaya dapet drop ya...", PREFIX, iClient);
				}else{
					CPrintToChat(client, "%s {default}Congratulation {lightred}%N{default} you got a drop! Keep playing on froidgaming.net to get a drop...", PREFIX, iClient);
				}
			}
		}
		EmitSoundToAll("ui/panorama/case_awarded_1_uncommon_01.wav", SOUND_FROM_LOCAL_PLAYER, _, SNDLEVEL_NONE);
	}

	return MRES_Ignored;
}

int GetClientFromAccountID(int iAccountID)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i) && !IsFakeClient(i) && IsClientAuthorized(i))
		{
			if(GetSteamAccountID(i) == iAccountID)
			{
				return i;
			}
		}
	}

	return -1;
}

Action Timer_SendRewardMatchEndDrops(Handle hTimer)
{
	if(g_iOS == 1)
	{
		SDKCall(g_hRewardMatchEndDrops, 0xDEADC0DE, false);
	}
	else
	{
		SDKCall(g_hRewardMatchEndDrops, false);
	}
	// PrintToConsoleAll("Trying to get a drop...");

	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
	if(client <= 0) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	if(IsFakeClient(client)) return false;
	if(IsClientSourceTV(client)) return false;
	return IsClientInGame(client);
}