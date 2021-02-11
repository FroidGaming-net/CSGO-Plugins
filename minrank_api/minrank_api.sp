/* SM Includes */
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <minrank>
#include <SteamWorks>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.1"
#define UPDATE_URL "https://sys.froidgaming.net/minrank_api/updatefile.txt"

#define MAX_CSGO_LEVEL 40

Handle Trie_CoinLevelValues = INVALID_HANDLE;

public Plugin myinfo =
{
    name = "[PRIVATE] Min Rank",
    author = "FroidGaming.net",
    description = "CS:GO Level API.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void OnPluginStart()
{
	Trie_CoinLevelValues = CreateTrie();
    RegAdminCmd("sm_whatsmyrank", Command_WhatsMyRank, ADMFLAG_ROOT);

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

public Action Command_WhatsMyRank(int iClient, int iArgs)
{
	int iRank = GetRank(iClient);
	PrintToChat(iClient, "Your rank : %i", iRank);

    return Plugin_Handled;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
   CreateNative("GetClientRank", Native_GetClientRank);
   return APLRes_Success;
}

stock int GetRank(int client)
{
	int PlayerResourceEnt = GetPlayerResourceEntity();

	if(!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %i", client);
		return -1;
	}

    char sCoin[64], value, rank = GetEntProp(PlayerResourceEnt, Prop_Send, "m_nPersonaDataPublicLevel", _, client);
	IntToString(GetEntProp(PlayerResourceEnt, Prop_Send, "m_nActiveCoinRank", _, client), sCoin, sizeof(sCoin));

	if(rank == -1)
		rank = 0;

	if(GetTrieValue(Trie_CoinLevelValues, sCoin, value))
		rank += value;

	return rank;
}

public int Native_GetClientRank(Handle caller, int numParams)
{
	int PlayerResourceEnt = GetPlayerResourceEntity();

	int client = GetNativeCell(1);

	if(!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %i", client);
		return -1;
	}

    char sCoin[64], value, rank = GetEntProp(PlayerResourceEnt, Prop_Send, "m_nPersonaDataPublicLevel", _, client);
	IntToString(GetEntProp(PlayerResourceEnt, Prop_Send, "m_nActiveCoinRank", _, client), sCoin, sizeof(sCoin));

	if(rank == -1)
		rank = 0;

	if(GetTrieValue(Trie_CoinLevelValues, sCoin, value))
		rank += value;

	return rank;
}

public void OnConfigsExecuted()
{
	KeyValues keyValues = CreateKeyValues("items_game");

	if (!FileToKeyValues(keyValues, "scripts/items/items_game.txt")) {
        return;
    }

	if (!KvGotoFirstSubKey(keyValues)) {
        return;
    }

	char buffer[64], levelValue[64], position;

	do
	{
		KvGetSectionName(keyValues, buffer, sizeof(buffer));

		if(StrEqual(buffer, "items"))
		{
			KvGotoFirstSubKey(keyValues);
			break;
		}
	}
	while(KvGotoNextKey(keyValues));

	do
	{
		KvGetSectionName(keyValues, buffer, sizeof(buffer));

		if(SCS_IsStringNumber(buffer))
		{

			KvGetString(keyValues, "name", levelValue, sizeof(levelValue));

			if(StrContains(levelValue, "prestige", false) == -1)
				SetTrieValue(Trie_CoinLevelValues, buffer, 0);

			else if((position = StrContains(levelValue, "level", false)) == -1)
			{
				IntToString(MAX_CSGO_LEVEL, levelValue, sizeof(levelValue));
				SetTrieValue(Trie_CoinLevelValues, buffer, StringToInt(levelValue));
			}
			else
			{
				SetTrieValue(Trie_CoinLevelValues, buffer, StringToInt(levelValue[position]));
			}
		}
	}
	while(KvGotoNextKey(keyValues));

	CloseHandle(keyValues);

}

stock bool GetStringVector(const char[] str, float Vector[3])
{
	if(str[0] == EOS)
		return false;

	char sPart[3][12];
	int iReturned = ExplodeString(str, StrContains(str, ", ") != -1 ? ", " : " ", sPart, 3, 12);

	for (new i = 0; i < iReturned; i++)
		Vector[i] = StringToFloat(sPart[i]);

	return true;
}

stock bool SCS_IsStringNumber(const char[] str)
{
	int x = 0;
	bool numbersFound;

	while (str[x] != '\0')
	{
		if(IsCharNumeric(str[x]))
		{
			numbersFound = true;
		}
		else
			return false;

		x++;
	}

	return numbersFound;
}