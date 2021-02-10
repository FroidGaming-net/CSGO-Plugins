#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <clientprefs>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>
#include <sdktools_functions>

#include <PTaH>

#pragma newdecls required

#if !defined SPPP_COMPILER
	#define decl static
#endif

#define SETTING_PREVIEW (1 << 0)
#define SETTING_PREVIEW_BLOCK_TRANSMITS (1 << 1)
#define SETTING_FORCIBLY_SET_MODEL (1 << 2)
#define SETTING_HIDE_NO_ACCESS_AGENTS (1 << 3)

#define LOADOUT_POSITION_SPACER1 38
#define DEFINITION_INDEX_OFFSET 8
#define ECON_IMG_OFFSET 108
#define WORLD_MODEL_OFFSET 148

#define SQL_CREATE_TABLE \
"CREATE TABLE IF NOT EXISTS `agent_chooser` \
(\
	`accountid` int NOT NULL, \
	`team` int NOT NULL, \
	`agent` int NOT NULL, \
	`patch_1` int NOT NULL DEFAULT 0, \
	`patch_2` int NOT NULL DEFAULT 0, \
	`patch_3` int NOT NULL DEFAULT 0, \
	`patch_4` int NOT NULL DEFAULT 0, \
	PRIMARY KEY (`accountid`, `team`)\
);"

#define SQL_CREATE_DATA \
"INSERT INTO `agent_chooser` \
(\
	`accountid`, \
	`team`, \
	`agent`\
) \
VALUES (%i, 2, %i), (%i, 3, %i);"

#define SQL_LOAD_DATA \
"SELECT \
	`team`, \
	`agent`, \
	`patch_1`, \
	`patch_2`, \
	`patch_3`, \
	`patch_4` \
FROM \
	`agent_chooser` \
WHERE \
	`accountid` = %i \
LIMIT 2;"

#define SQL_UPDATE_DATA \
"UPDATE `agent_chooser` SET \
	`agent` = %i, \
	`patch_1` = %i, \
	`patch_2` = %i, \
	`patch_3` = %i, \
	`patch_4` = %i \
WHERE \
	`accountid` = %i AND `team` = %i;"

int             g_iSettings,
                g_iPreviewCount,
                m_vecPlayerPatchEconIndices, m_hObserverTarget, m_iObserverMode, m_Item, m_bDrawViewmodel, m_iFOV, m_iItemDefinitionIndex;

ArrayList       g_hAgents, g_hAgentNames, g_hPatchs, g_hPatchNames;

ConVar          g_hForceCamera;

Database        g_hDatabase;

GlobalForward   g_hForwardLoad;

PrivateForward  g_hFeatureOpenMenu, g_hFeatureAddItem, g_hFeatureOpenPatchMenu, g_hFeatureAddPatchItem;

Handle          g_hSetDefaultEquippedDefinitionItemBySlot;

enum struct PlayerData
{
	bool bPreview;
	bool bIsFake;
	bool bInGame;
	bool bTransmit;
	int  iPreviewOldButtons;
	int  iAccountID;
	int  iBufferTeam;
	int  iDefaultAgent[2];
	int  iAgent[2];
	int  iPatchsT[4];
	int  iPatchsCT[4];
	int  iTeam;
	CCSPlayerInventory pInventory;

	void SetAgent(int iAgent, int iTeam)
	{
		this.iAgent[view_as<int>(iTeam == CS_TEAM_CT)] = iAgent;
	}

	int GetAgent(int iTeam)
	{
		int iSimpleTeam = view_as<int>(iTeam == CS_TEAM_CT);

		return this.iAgent[iSimpleTeam] > 0 ? this.iAgent[iSimpleTeam] : this.iDefaultAgent[iSimpleTeam];
	}

	bool SetAgentSkin(int iClient, int iTeam, bool bShowInHint = true)
	{
		if(iTeam > 1)
		{
			CEconItemView pAgent = this.pInventory.GetItemInLoadout(iTeam, LOADOUT_POSITION_SPACER1);

			if(pAgent)
			{
				int iAgent = this.GetAgent(iTeam);
				PrintToChatAll("Team : %i | Agent : %i", iTeam, iAgent);
				if(pAgent.GetAccountID())
				{
					PrintToChatAll("StoreToAddress");
					StoreToAddress(view_as<Address>(pAgent) + view_as<Address>(m_iItemDefinitionIndex), iAgent, NumberType_Int16);
				}
				else
				{
					PrintToChatAll("SDKCall");
					SDKCall(g_hSetDefaultEquippedDefinitionItemBySlot, this.pInventory, iTeam, LOADOUT_POSITION_SPACER1, iAgent);
					pAgent = this.pInventory.GetItemInLoadout(iTeam, LOADOUT_POSITION_SPACER1);
				}

				// CEconItemDefinition pAgentDefinition = pAgent.GetItemDefinition();

				// Address pAgentModel = view_as<Address>(LoadFromAddress(view_as<Address>(pAgentDefinition) + view_as<Address>(WORLD_MODEL_OFFSET), NumberType_Int32)),
				// 		pAgentEcon = view_as<Address>(LoadFromAddress(view_as<Address>(pAgentDefinition) + view_as<Address>(ECON_IMG_OFFSET), NumberType_Int32));

				// if(pAgentModel && pAgentEcon)
				// {
				// 	int iIndex = g_hAgents.FindValue(LoadFromAddress(view_as<Address>(pAgentDefinition) + view_as<Address>(DEFINITION_INDEX_OFFSET), NumberType_Int16));
				// 	PrintToChatAll("DATA : %i", iIndex);
				// 	if(g_iSettings & SETTING_FORCIBLY_SET_MODEL && IsPlayerAlive(iClient) && ((iIndex != -1 ? g_hAgents.Get(iIndex, 1) : iTeam) == GetClientTeam(iClient)))
				// 	{
				// 		decl char sBuffer[PLATFORM_MAX_PATH];

				// 		LoadFromAddressString(pAgentModel, sBuffer, sizeof(sBuffer));
				// 		PrintToChatAll("DATA 2 : %s", sBuffer);
				// 		if(iIndex != -1)
				// 		{
				// 			// SetEntityModel(iClient, sBuffer);
				// 		}
				// 		else
				// 		{
				// 			SetEntData(iClient, m_nModelIndex, PrecacheModel(sBuffer), 2, true);
				// 		}
				// 	}

				// 	if(bShowInHint)
				// 	{
				// 		PrintHintTextAgent(iClient, pAgentEcon);

				// 		CreateTimer(0.15, OnHintCrutch, GetClientUserId(iClient) << 16 | pAgentDefinition.GetDefinitionIndex());
				// 	}
				// }
				// else
				// {
				// 	LogError("CEconItemDefinition::char pointers error (%X, %X)", pAgentModel, pAgentEcon);

				// 	return false;
				// }

				return true;
			}
			else
			{
				LogError("LOADOUT_POSITION_SPACER1 == nullptr");

				return false;
			}
		}

		return false;
	}

	bool GetDefaultAgent()
	{
		Address pAgentT = view_as<Address>(this.pInventory.GetItemInLoadout(CS_TEAM_T, LOADOUT_POSITION_SPACER1)),
		        pAgentCT = view_as<Address>(this.pInventory.GetItemInLoadout(CS_TEAM_CT, LOADOUT_POSITION_SPACER1));

		if(pAgentT && pAgentCT)
		{
			this.iDefaultAgent[0] = LoadFromAddress(pAgentT + view_as<Address>(m_iItemDefinitionIndex), NumberType_Int16);
			this.iDefaultAgent[1] = LoadFromAddress(pAgentCT + view_as<Address>(m_iItemDefinitionIndex), NumberType_Int16);

			return true;
		}
		else
		{
			LogError("LOADOUT_POSITION_SPACER1 (%x or %x) == nullptr", pAgentT, pAgentCT);
		}

		return false;
	}

	void SetPatch(int iSlot, int iDefIndex, int iTeam)
	{
		if(iTeam == CS_TEAM_CT)
		{
			this.iPatchsCT[iSlot] = iDefIndex;
		}
		else
		{
			this.iPatchsT[iSlot] = iDefIndex;
		}
	}

	int GetPatch(int iSlot, int iTeam)
	{
		return iTeam == CS_TEAM_CT ? this.iPatchsCT[iSlot] : this.iPatchsT[iSlot];
	}
}

PlayerData g_iPlayerData[MAXPLAYERS + 1];

// agent_chooser.sp
public Plugin myinfo = 
{
	name = "[Agent Chooser] Core",
	author = "Wend4r",
	version = "1.1.5",
	url = "Discord: Wend4r#0001 | VK: vk.com/wend4r"
};

public APLRes AskPluginLoad2(Handle hMySelf, bool bLate, char[] sError, int iErrorSize)
{
	if(GetEngineVersion() != Engine_CSGO)
	{
		strcopy(sError, iErrorSize, "This plugin works only on CS:GO");

		return APLRes_SilentFailure;
	}

	CreateNative("AC_IsLoaded", Native_IsLoaded);
	CreateNative("AC_RegisterFeature", Native_RegisterFeature);
	CreateNative("AC_GetDatabase", Native_GetDatabase);
	CreateNative("AC_OpenMainMenu", Native_OpenMainMenu);
	CreateNative("AC_OpenPatchMenu", Native_OpenPatchMenu);
	CreateNative("AC_SetPlayerPreview", Native_SetPlayerPreview);
	CreateNative("AC_GetPlayerPreview", Native_GetPlayerPreview);
	CreateNative("AC_SetAgent", Native_SetAgent);
	CreateNative("AC_GetAgent", Native_GetAgent);

	RegPluginLibrary("agent_chooser");

	g_hForwardLoad = new GlobalForward("AC_Load", ET_Ignore);

	g_hFeatureOpenMenu = new PrivateForward(ET_Hook, Param_Cell, Param_Cell, Param_String);
	g_hFeatureAddItem = new PrivateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_String);
	g_hFeatureOpenPatchMenu = new PrivateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_String);
	g_hFeatureAddPatchItem = new PrivateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_String);

	return APLRes_Success;
}

static const char sCBasePlayer[] = "CBasePlayer",  sCEconEntity[] = "CEconEntity";

public void OnPluginStart()
{
	LoadTranslations("agent_chooser.phrases");
	LoadTranslations("common.phrases");

	// m_nModelIndex = FindSendPropInfo(sCBasePlayer, "m_nModelIndex");
	m_vecPlayerPatchEconIndices = FindSendPropInfo("CCSPlayer", "m_vecPlayerPatchEconIndices");
	m_hObserverTarget = FindSendPropInfo(sCBasePlayer, "m_hObserverTarget");
	m_iObserverMode = FindSendPropInfo(sCBasePlayer, "m_iObserverMode");
	m_bDrawViewmodel = FindSendPropInfo(sCBasePlayer, "m_bDrawViewmodel");
	m_iFOV = FindSendPropInfo(sCBasePlayer, "m_iFOV");
	m_Item = FindSendPropInfo(sCEconEntity, "m_Item");
	m_iItemDefinitionIndex = FindSendPropInfo(sCEconEntity, "m_iItemDefinitionIndex") - m_Item;

	g_hAgents = new ArrayList(2);
	g_hAgentNames = new ArrayList(32);
	g_hPatchs = new ArrayList();
	g_hPatchNames = new ArrayList(32);

	g_hForceCamera = FindConVar("mp_forcecamera");

	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_team", OnPlayerTeam);

	RegConsoleCmd("sm_agents", AgentsCommand);

	PTaH(PTaH_InventoryUpdatePost, Hook, OnInventoryUpdatePost);

	GameData hGameData = new GameData("agent_chooser.game.csgo");

	if(!hGameData)
	{
		SetFailState("Couldn't find \"agent_chooser.game.csgo.txt\" gamedata");
	}

	// m_LoadoutItems = hGameData.GetOffset("CCSPlayerInventory::m_LoadoutItems");		// Clear agent item id - not work!!!

	StartPrepSDKCall(SDKCall_Raw);		// CPlayerInventory
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SetDefaultEquippedDefinitionItemBySlot");		// void
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);		// int iClass
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);		// int iSlot
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);		// unsigned __int16 iDefIndex

	if(!(g_hSetDefaultEquippedDefinitionItemBySlot = EndPrepSDKCall()))
	{
		SetFailState("Failed to get \"SetDefaultEquippedDefinitionItemBySlot\" function");
	}

	hGameData.Close();

	LoadSettings();
	ConnectDB();
}

int Native_IsLoaded(Handle hPlugin, int iArgs)
{
	return !g_hForwardLoad;
}

int Native_GetDatabase(Handle hPlugin, int iArgs)
{
	return g_hDatabase ? view_as<int>(CloneHandle(hPlugin, g_hDatabase)) : 0;
}

int Native_OpenMainMenu(Handle hPlugin, int iArgs)
{
	MainMenu(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}

int Native_OpenPatchMenu(Handle hPlugin, int iArgs)
{
	int iClient = GetNativeCell(1);

	g_iPlayerData[iClient].iBufferTeam = GetNativeCell(2);
	PatchMenu(iClient, GetNativeCell(3), GetNativeCell(4));
}

int Native_SetPlayerPreview(Handle hPlugin, int iArgs)
{
	int iClient = GetNativeCell(1);

	AgentPreview(iClient, g_iPlayerData[iClient].bPreview = GetNativeCell(2));
}

int Native_GetPlayerPreview(Handle hPlugin, int iArgs)
{
	return g_iPlayerData[GetNativeCell(1)].bPreview;
}

int Native_SetAgent(Handle hPlugin, int iArgs)
{
	int iClient = GetNativeCell(1),
	    iTeam = GetNativeCell(2),
	    iDefIndex = GetNativeCell(3);

	if(iTeam)
	{
		g_iPlayerData[iClient].iAgent[view_as<int>(iTeam == CS_TEAM_CT)] = iDefIndex;

		return g_iPlayerData[iClient].SetAgentSkin(iClient, iTeam);
	}

	// For all teams (T/CT)
	g_iPlayerData[iClient].iAgent[0] = iDefIndex;
	g_iPlayerData[iClient].iAgent[1] = iDefIndex;

	return g_iPlayerData[iClient].SetAgentSkin(iClient, CS_TEAM_T) || g_iPlayerData[iClient].SetAgentSkin(iClient, CS_TEAM_CT);
}

int Native_GetAgent(Handle hPlugin, int iArgs)
{
	return g_iPlayerData[GetNativeCell(1)].iAgent[view_as<int>(GetNativeCell(2) == CS_TEAM_CT)];
}

int Native_RegisterFeature(Handle hPlugin, int iArgs)
{
	decl char sTranslation[PLATFORM_MAX_PATH];
	
	GetNativeString(1, sTranslation, sizeof(sTranslation));

	if(sTranslation[0])
	{
		LoadTranslations(sTranslation);
	}

	Function funcOpenMenu = GetNativeFunction(2),
	         funcAddItem = GetNativeFunction(3),
	         funcOpenPatchMenu = GetNativeFunction(4),
	         funcAddPatchItem = GetNativeFunction(5);

	if(funcOpenMenu != INVALID_FUNCTION)
	{
		g_hFeatureOpenMenu.AddFunction(hPlugin, funcOpenMenu);
	}

	if(funcAddItem != INVALID_FUNCTION)
	{
		g_hFeatureAddItem.AddFunction(hPlugin, funcAddItem);
	}

	if(funcOpenPatchMenu != INVALID_FUNCTION)
	{
		g_hFeatureOpenPatchMenu.AddFunction(hPlugin, funcOpenPatchMenu);
	}

	if(funcAddPatchItem != INVALID_FUNCTION)
	{
		g_hFeatureAddPatchItem.AddFunction(hPlugin, funcAddPatchItem);
	}
}

void OnPlayerSpawn(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));

	if(iClient && !IsFakeClient(iClient))
	{
		int iTeam = hEvent.GetInt("teamnum");

		if(iTeam > 1)
		{
			for(int j = 0; j != 4; j++)
			{
				SetEntData(iClient, m_vecPlayerPatchEconIndices + j * 4, iTeam == CS_TEAM_CT ? g_iPlayerData[iClient].iPatchsCT[j] : g_iPlayerData[iClient].iPatchsT[j]);
			}

			if(g_iPlayerData[iClient].bPreview)
			{
				AgentPreview(iClient, g_iPlayerData[iClient].bPreview = false);
			}
		}
		else
		{
			g_iPlayerData[iClient].pInventory = PTaH_GetPlayerInventory(iClient);
		}
	}
}

void OnPlayerTeam(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));

	if(iClient)
	{
		g_iPlayerData[iClient].iTeam = hEvent.GetInt("team");
	}
}

void OnInventoryUpdatePost(int iClient, CCSPlayerInventory pInventory)
{
	g_iPlayerData[iClient].GetDefaultAgent();
	g_iPlayerData[iClient].SetAgentSkin(iClient, CS_TEAM_T, false);
	g_iPlayerData[iClient].SetAgentSkin(iClient, CS_TEAM_CT, false);
}

void ConnectDB()
{
	static const char sDatabaseName[] = "agent_chooser";

	if(SQL_CheckConfig(sDatabaseName))
	{
		Database.Connect(ConnectToDatabase, sDatabaseName);
	}
	else
	{
		decl char sError[64];

		KeyValues hKv = new KeyValues(NULL_STRING, "driver", "sqlite");

		hKv.SetString("database", sDatabaseName);

		Database hDatabase = SQL_ConnectCustom(hKv, sError, sizeof(sError), false);

		ConnectToDatabase(hDatabase, sError, 0);

		hKv.Close();
	}
}

void ConnectToDatabase(Database hDatabase, const char[] sError, any NULL)
{
	if(sError[0])
	{
		SetFailState("Could not connect to the database - %s", sError);
	}

	(g_hDatabase = hDatabase).Query(SQL_Callback, SQL_CREATE_TABLE, 1, DBPrio_High);
}

void SQL_Callback(Database hDatabase, DBResultSet hResult, const char[] sError, int iData)
{
	if(!hResult)
	{
		LogError("SQL_Callback Error (%i): %s", iData, sError);
		return;
	}

	if(iData)
	{
		int iQueryType = iData & 0xF;

		switch(iQueryType)
		{
			case 1:
			{
				decl char sQuery[256];

				Transaction hTransaction = new Transaction();

				for(int i = MaxClients + 1; --i;)
				{
					if(!g_iPlayerData[i].bInGame)
					{
						if((g_iPlayerData[i].bInGame = IsClientInGame(i)))
						{
							g_iPlayerData[i].iTeam = GetClientTeam(i);

							if(!(g_iPlayerData[i].bIsFake = IsFakeClient(i)))
							{
								FormatEx(sQuery, sizeof(sQuery), SQL_LOAD_DATA, g_iPlayerData[i].iAccountID = GetSteamAccountID(i));
								hTransaction.AddQuery(sQuery, GetClientUserId(i));
							}
						}
					}
				}

				g_hDatabase.Execute(hTransaction, SQL_TransactionLoadPlayers, SQL_TransactionFailure, 10);

				Call_StartForward(g_hForwardLoad);
				Call_Finish();

				delete g_hForwardLoad;
			}
			case 2:
			{
				int iClient = GetClientOfUserId(iData >>> 4);

				if(iClient)
				{
					SQL_LoadPlayer(iClient, hResult);
				}
			}
		}
	}
}

void SQL_LoadPlayer(const int &iClient, const DBResultSet &hResult)
{
	if(g_iPlayerData[iClient].bInGame)
	{
		bool bLoad = false;

		g_iPlayerData[iClient].pInventory = PTaH_GetPlayerInventory(iClient);
		g_iPlayerData[iClient].GetDefaultAgent();

		if(hResult.HasResults)
		{
			while(hResult.FetchRow())
			{
				int iTeam = hResult.FetchInt(0);

				if(iTeam > 1)
				{
					g_iPlayerData[iClient].SetAgent(hResult.FetchInt(1), iTeam);
					g_iPlayerData[iClient].SetAgentSkin(iClient, iTeam);

					if(iTeam -= 2)
					{
						for(int i = 0; i != 4; i++)
						{
							g_iPlayerData[iClient].iPatchsCT[i] = hResult.FetchInt(2 + i);
						}
					}
					else
					{
						for(int i = 0; i != 4; i++)
						{
							g_iPlayerData[iClient].iPatchsT[i] = hResult.FetchInt(2 + i);
						}
					}

					bLoad = true;
				}
			}
		}

		if(!bLoad)
		{
			decl char sQuery[256];

			FormatEx(sQuery, sizeof(sQuery), SQL_CREATE_DATA, g_iPlayerData[iClient].iAccountID, g_iPlayerData[iClient].iDefaultAgent[0], g_iPlayerData[iClient].iAccountID, g_iPlayerData[iClient].iDefaultAgent[1]);
			g_hDatabase.Query(SQL_Callback, sQuery, 0);
		}
	}
}

void SQL_TransactionLoadPlayers(Database hDatabase, int iData, int iNumQueries, const DBResultSet[] hResults, const int[] iUserIDs)
{
	for(int i = 0, iClient; i != iNumQueries; i++)
	{
		if((iClient = GetClientOfUserId(iUserIDs[i])))
		{
			SQL_LoadPlayer(iClient, hResults[i]);
		}
	}
}

void SQL_TransactionFailure(Database hDatabase, int iData, int iNumQueries, const char[] sError, int iFailIndex, const any[] iQueryData)
{
	if(sError[0])
	{
		LogError("SQL_TransactionFailure (%i): %s", iData, sError);
	}
}

Action AgentsCommand(int iClient, int iArgs)
{
	if(iClient && g_iPlayerData[iClient].bInGame)
	{
		MainMenu(iClient, GetClientTeam(iClient));
	}

	return Plugin_Handled;
}

void LoadSettings()
{
	decl char sBuffer[128];

	static char sPath[PLATFORM_MAX_PATH];

	KeyValues hKV = new KeyValues("Agents Choose");

	if(!sPath[0])
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "configs/agent_chooser.kv");
	}

	if(!hKV.ImportFromFile(sPath))
	{
		SetFailState("%s - is not found", sPath);
	}

	hKV.GotoFirstSubKey();
	hKV.Rewind();

	g_iSettings = view_as<int>(hKV.GetNum("hide_no_access_agents", 0) != 0) << 3 |
	              view_as<int>(hKV.GetNum("forcibly_set_model", 1) != 0) << 2 |
	              view_as<int>(hKV.GetNum("preview_block_transmits") != 0) << 1 |
	              view_as<int>(hKV.GetNum("preview") != 0);

	int i = 0;

	if(hKV.JumpToKey("agents") && hKV.GotoFirstSubKey())
	{
		do
		{
			hKV.GetSectionName(sBuffer, 12);
			g_hAgents.Push(StringToInt(sBuffer));

			hKV.GetString("name", sBuffer, sizeof(sBuffer));
			g_hAgentNames.PushString(sBuffer);

			hKV.GetString("team", sBuffer, 4);
			g_hAgents.Set(i++, true + (sBuffer[0] == 'c' || sBuffer[0] == 't') + (sBuffer[1] == 't'), 1);		// Bool math. Romeo coding...
		}
		while(hKV.GotoNextKey());

		hKV.GoBack();
		hKV.GoBack();
	}

	if(hKV.JumpToKey("patchs") && hKV.GotoFirstSubKey(false))
	{
		do
		{
			if(hKV.GetSectionName(sBuffer, 12))
			{
				g_hPatchs.Push(StringToInt(sBuffer));

				hKV.GetString(NULL_STRING, sBuffer, sizeof(sBuffer));
				g_hPatchNames.PushString(sBuffer);
			}
		}
		while(hKV.GotoNextKey(false));
	}

	hKV.Close();
}

public void OnClientPutInServer(int iClient)
{
	g_iPlayerData[iClient].bInGame = true;

	if(!(g_iPlayerData[iClient].bIsFake = IsFakeClient(iClient)))
	{
		decl char sQuery[256];

		FormatEx(sQuery, sizeof(sQuery), SQL_LOAD_DATA, g_iPlayerData[iClient].iAccountID = GetSteamAccountID(iClient));
		g_hDatabase.Query(SQL_Callback, sQuery, GetClientUserId(iClient) << 4 | 2, DBPrio_High);
	}
}

// public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float flVel[3], float flAngles[3], int &iWeapon, int &iSubType, int &iCmdNum, int &iTickCount, int &iSeed, int iMouse[2])
public void OnPlayerRunCmdPost(int iClient, int iButtons, int iImpulse, const float flVel[3], const float flAngles[3], int iWeapon, int iSubType, int iCmdNum, int iTickCount, int iSeed, const int iMouse[2])
{
	if(g_iPlayerData[iClient].bPreview)
	{
		int iOldButtons = g_iPlayerData[iClient].iPreviewOldButtons;

		if(iButtons & IN_ATTACK && iButtons & IN_ATTACK2)
		{
			if(!(iOldButtons & IN_ATTACK) || !(iOldButtons & IN_ATTACK2))
			{
				g_hForceCamera.ReplicateToClient(iClient, "0");
			}
		}
		else if(iOldButtons & IN_ATTACK || iOldButtons & IN_ATTACK2)
		{
			g_hForceCamera.ReplicateToClient(iClient, "1");
		}

		if(iButtons & IN_ATTACK2 && !(iButtons & IN_ATTACK))
		{
			// PrintToChat(iClient, "iMouse[0] = %i; iMouse[1] = %i", iMouse[0], iMouse[1]);

			int iFOV = GetEntData(iClient, m_iFOV) - iMouse[1] / 10;
		
			if(50 < iFOV < 150)
			{
				SetEntData(iClient, m_iFOV, iFOV);
			}
		}

		g_iPlayerData[iClient].iPreviewOldButtons = iButtons;
	}
}

public void OnClientDisconnect(int iClient)
{
	if(g_hDatabase)
	{
		decl char sQuery[256];

		Transaction hTransaction = new Transaction();

		FormatEx(sQuery, sizeof(sQuery), SQL_UPDATE_DATA, g_iPlayerData[iClient].iAgent[0], g_iPlayerData[iClient].iPatchsT[0], g_iPlayerData[iClient].iPatchsT[1], g_iPlayerData[iClient].iPatchsT[2], g_iPlayerData[iClient].iPatchsT[3], g_iPlayerData[iClient].iAccountID, 2);
		hTransaction.AddQuery(sQuery, 0);

		FormatEx(sQuery, sizeof(sQuery), SQL_UPDATE_DATA, g_iPlayerData[iClient].iAgent[1], g_iPlayerData[iClient].iPatchsCT[0], g_iPlayerData[iClient].iPatchsCT[1], g_iPlayerData[iClient].iPatchsCT[2], g_iPlayerData[iClient].iPatchsCT[3], g_iPlayerData[iClient].iAccountID, 3);
		hTransaction.AddQuery(sQuery, 1);

		g_hDatabase.Execute(hTransaction, _, SQL_TransactionFailure, 11);
	}

	if(g_iPlayerData[iClient].bPreview)
	{
		AgentPreview(iClient, g_iPlayerData[iClient].bPreview = false);
	}

	g_iPlayerData[iClient].bInGame = false;
	g_iPlayerData[iClient].bTransmit = false;
	g_iPlayerData[iClient].iAccountID = 0;
}

// Action OnHintCrutch(Handle hTimer, int iData)
// {
// 	int iClient = GetClientOfUserId(iData >> 16);

// 	if(iClient)
// 	{
// 		PrintHintTextAgent(iClient, view_as<Address>(LoadFromAddress(view_as<Address>(PTaH_GetItemDefinitionByDefIndex(iData & 0xFFFF)) + view_as<Address>(ECON_IMG_OFFSET), NumberType_Int32)));
// 	}
// }

// static const char sParams[] = "params";

// void PrintHintTextAgent(int iClient, Address pEconIMG)
// {
// 	decl char sMessage[PLATFORM_MAX_PATH];

// 	Protobuf hMessage = view_as<Protobuf>(StartMessageOne("TextMsg", iClient));

// 	LoadFromAddressString(pEconIMG, sMessage, sizeof(sMessage));
// 	Format(sMessage, sizeof(sMessage), "</font><img src='file://{images_econ}/%s.png'/><script>", sMessage);

// 	hMessage.SetInt("msg_dst", 4);
// 	hMessage.AddString(sParams, "#SFUI_ContractKillStart");
// 	hMessage.AddString(sParams, sMessage);
// 	hMessage.AddString(sParams, NULL_STRING);
// 	hMessage.AddString(sParams, NULL_STRING);
// 	hMessage.AddString(sParams, NULL_STRING);
// 	hMessage.AddString(sParams, NULL_STRING);

// 	EndMessage();
// }

void MainMenu(int iClient, int iTeam, int iFirstSlot = 0)
{
	if(iTeam < 2)
	{
		iTeam = 2;
	}

	Menu hMenu = new Menu(MainMenuHandler, MenuAction_Select);

	if(g_hFeatureOpenMenu.FunctionCount)
	{
		char sMessage[256];

		Action iAction = Plugin_Continue;

		Call_StartForward(g_hFeatureOpenMenu);
		Call_PushCell(iClient);
		Call_PushCell(iTeam);
		Call_PushStringEx(sMessage, sizeof(sMessage), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(iAction);

		if(iAction == Plugin_Handled)
		{
			hMenu.Close();
			return;
		}
		else if(iAction == Plugin_Changed)
		{
			Format(sMessage, sizeof(sMessage), TranslationPhraseExists(sMessage) ? "%t" : "%s", sMessage);
			hMenu.AddItem(NULL_STRING, sMessage, ITEMDRAW_DISABLED);

			hMenu.ExitBackButton = true;
			hMenu.Display(iClient, MENU_TIME_FOREVER);

			return;
		}
	}

	int iIndex = g_hAgents.FindValue(g_iPlayerData[iClient].GetAgent(iTeam));

	decl char sItem[128], sAgentArray[8];

	hMenu.SetTitle("%T", "Menu Title", iClient);

	if(g_iSettings & SETTING_PREVIEW && IsPlayerAlive(iClient))
	{
		FormatEx(sItem, sizeof(sItem), "%T [%T]", "Preview", iClient, g_iPlayerData[iClient].bPreview ? "On" : "Off", iClient);
		hMenu.AddItem("0", sItem);
	}

	if(g_hPatchs.Length)
	{
		FormatEx(sItem, sizeof(sItem), "%T", "Patch", iClient);
		hMenu.AddItem(iTeam == CS_TEAM_CT ? "1CT" : "1T", sItem);
	}

	FormatEx(sItem, sizeof(sItem), "%T [%s]\n ", "Team", iClient, iTeam == CS_TEAM_CT ? "CT" : "T");
	hMenu.AddItem(iTeam == CS_TEAM_CT ? "2CT" : "2T", sItem);

	FormatEx(sItem, sizeof(sItem), "%T", "Default", iClient);
	hMenu.AddItem("3", sItem, view_as<int>(iIndex == -1));

	for(int i = 0, iMax = g_hAgents.Length; i != iMax; i++)
	{
		if(g_hAgents.Get(i, 1) == iTeam)
		{
			int iAgentDefinition = g_hAgents.Get(i);

			g_hAgentNames.GetString(i, sItem, sizeof(sItem));

			IntToString(iAgentDefinition, sAgentArray, sizeof(sAgentArray));

			if(TranslationPhraseExists(sItem))
			{
				FormatEx(sItem, sizeof(sItem), "%T", sItem, iClient);
			}

			if(g_hFeatureAddItem.FunctionCount)
			{
				int iFlags = 0;

				char sWarning[256];

				Call_StartForward(g_hFeatureAddItem);
				Call_PushCell(iClient);
				Call_PushCell(iTeam);
				Call_PushCell(iAgentDefinition);
				Call_PushStringEx(sWarning, sizeof(sWarning), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
				Call_Finish(iFlags);

				if(!(g_iSettings & SETTING_HIDE_NO_ACCESS_AGENTS && iFlags & ITEMDRAW_DISABLED))
				{
					Format(sWarning, sizeof(sWarning), sWarning[0] ? TranslationPhraseExists(sWarning) ? "%s [%T]" : "%s [%s]" : "%s", sItem, sWarning, iClient);
					hMenu.AddItem(sAgentArray, sWarning, iFlags | view_as<int>(iIndex == i));
				}
			}
			else
			{
				hMenu.AddItem(sAgentArray, sItem, view_as<int>(iIndex == i));
			}
		}
	}

	g_iPlayerData[iClient].iBufferTeam = iTeam;
	hMenu.DisplayAt(iClient, iFirstSlot, MENU_TIME_FOREVER);
}

int MainMenuHandler(Menu hMenu, MenuAction iAction, int iParam1, int iParam2)
{
	switch(iAction)
	{
		case MenuAction_Select:
		{
			decl char sInfo[16];

			hMenu.GetItem(iParam2, sInfo, sizeof(sInfo));

			switch(sInfo[0])
			{
				case '0':
				{
					AgentPreview(iParam1, g_iPlayerData[iParam1].bPreview ^= true);

					hMenu.RemoveItem(iParam2);

					if(IsPlayerAlive(iParam1))
					{
						decl char sItem[128];

						FormatEx(sItem, sizeof(sItem), "%T [%T]", "Preview", iParam1, g_iPlayerData[iParam1].bPreview ? "On" : "Off", iParam1);
						hMenu.InsertItem(iParam2, "0", sItem);
					}

					hMenu.Display(iParam1, MENU_TIME_FOREVER);
				}
				case '1':
				{
					PatchChoiceMenu(iParam1, sInfo[1] == 'C' ? 3 : 2);
				}
				case '2':
				{
					MainMenu(iParam1, sInfo[1] == 'C' ? 2 : 3);
				}
				default:
				{
					int iTeam = g_iPlayerData[iParam1].iBufferTeam;

					g_iPlayerData[iParam1].SetAgent(sInfo[0] == '3' ? -1 : StringToInt(sInfo), iTeam);
					g_iPlayerData[iParam1].SetAgentSkin(iParam1, iTeam);

					MainMenu(iParam1, iTeam, hMenu.Selection);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(iParam2 == MenuCancel_Exit && g_iPlayerData[iParam1].bPreview)
			{
				AgentPreview(iParam1, g_iPlayerData[iParam1].bPreview = false);
			}
		}
		case MenuAction_End:
		{
			if(iParam2 == MENUFLAG_BUTTON_EXIT)
			{
				hMenu.Close();
			}
		}
	}

}

void PatchChoiceMenu(int iClient, int iTeam)
{
	decl char sItem[128], sPatch[128];

	Menu hMenu = new Menu(PatchChoiceMenuHandler, MenuAction_Select);

	SetGlobalTransTarget(iClient);
	hMenu.SetTitle("%t", "Patch Title");

	FormatEx(sItem, sizeof(sItem), "%t", "Patch");

	int iLen = strlen(sItem), iPatchs[4];
	
	iPatchs = iTeam == CS_TEAM_CT ? g_iPlayerData[iClient].iPatchsCT : g_iPlayerData[iClient].iPatchsT;

	for(int i = 0, iPatchCount = g_iPlayerData[iClient].pInventory.GetItemInLoadout(iTeam, LOADOUT_POSITION_SPACER1).GetItemDefinition().GetNumSupportedStickerSlots(); i != iPatchCount; i++)
	{
		if(iPatchs[i])
		{
			int iPatchID = g_hPatchs.FindValue(iPatchs[i]);

			if(iPatchID != -1)
			{
				g_hPatchNames.GetString(iPatchID, sPatch, sizeof(sPatch));
			}
		}
		else
		{
			sPatch = "Patch None";
		}

		if(TranslationPhraseExists(sPatch))
		{
			FormatEx(sPatch, sizeof(sPatch), "%t", sPatch);
		}

		FormatEx(sItem[iLen], sizeof(sItem) - iLen, " %i [%s]", i + 1, sPatch);
		hMenu.AddItem(NULL_STRING, sItem);
	}

	if(!hMenu.ItemCount)
	{
		FormatEx(sItem, sizeof(sItem), "%t", "Missing Patch");
		hMenu.AddItem(NULL_STRING, sItem, ITEMDRAW_DISABLED);
	}

	hMenu.ExitBackButton = true;
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int PatchChoiceMenuHandler(Menu hMenu, MenuAction iAction, int iParam1, int iParam2)
{
	switch(iAction)
	{
		case MenuAction_Select:
		{
			PatchMenu(iParam1, iParam2);
		}
		case MenuAction_Cancel:
		{
			if(iParam2 == MenuCancel_Exit)
			{
				if(g_iPlayerData[iParam1].bPreview)
				{
					AgentPreview(iParam1, g_iPlayerData[iParam1].bPreview = false);
				}
			}
			else if(iParam2 == MenuCancel_ExitBack)
			{
				MainMenu(iParam1, g_iPlayerData[iParam1].iBufferTeam);
			}
		}
		case MenuAction_End:
		{
			if(iParam2 == MENUFLAG_BUTTON_EXIT)
			{
				hMenu.Close();
			}
		}
	}
}

void PatchMenu(int iClient, int iSlot, int iFirstItem = 0)
{
	int iTeam = g_iPlayerData[iClient].iBufferTeam,
	    iIndex = g_hPatchs.FindValue(g_iPlayerData[iClient].GetPatch(iSlot, g_iPlayerData[iClient].iBufferTeam));

	decl char sSlot[2], sItem[128];

	Menu hMenu = new Menu(PatchMenuHandler, MenuAction_Select);

	SetGlobalTransTarget(iClient);
	hMenu.SetTitle("%t | %t %i", "Patch Title", "Patch", iSlot + 1);

	if(g_hFeatureOpenPatchMenu.FunctionCount)
	{
		char sMessage[256];

		Action iAction = Plugin_Continue;

		Call_StartForward(g_hFeatureOpenPatchMenu);
		Call_PushCell(iClient);
		Call_PushCell(iTeam);
		Call_PushCell(iSlot);
		Call_PushStringEx(sMessage, sizeof(sMessage), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(iAction);

		if(iAction == Plugin_Handled)
		{
			hMenu.Close();
			return;
		}
		else if(iAction == Plugin_Changed)
		{
			Format(sMessage, sizeof(sMessage), TranslationPhraseExists(sMessage) ? "%t" : "%s", sMessage);
			hMenu.AddItem(NULL_STRING, sMessage, ITEMDRAW_DISABLED);

			hMenu.ExitBackButton = true;
			hMenu.Display(iClient, MENU_TIME_FOREVER);

			return;
		}
	}

	IntToString(iSlot, sSlot, sizeof(sSlot));
	FormatEx(sItem, sizeof(sItem), "%t", "Patch None");
	hMenu.AddItem(sSlot, sItem, view_as<int>(iIndex == -1));

	for(int i = 0, iMax = g_hPatchs.Length; i != iMax; i++)
	{
		g_hPatchNames.GetString(i, sItem, sizeof(sItem));

		if(TranslationPhraseExists(sItem))
		{
			FormatEx(sItem, sizeof(sItem), "%t", sItem);
		}

		if(g_hFeatureAddPatchItem.FunctionCount)
		{
			int iFlags = 0;

			char sWarning[256];

			Call_StartForward(g_hFeatureAddPatchItem);
			Call_PushCell(iClient);
			Call_PushCell(iTeam);
			Call_PushCell(iSlot);
			Call_PushCell(g_hPatchs.Get(i));
			Call_PushStringEx(sWarning, sizeof(sWarning), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_Finish(iFlags);

			if(!(g_iSettings & SETTING_HIDE_NO_ACCESS_AGENTS && iFlags & ITEMDRAW_DISABLED))
			{
				Format(sWarning, sizeof(sWarning), sWarning[0] ? TranslationPhraseExists(sWarning) ? "%s [%t]" : "%s [%s]" : "%s", sItem, sWarning);
				hMenu.AddItem(sSlot, sWarning, iFlags | view_as<int>(iIndex == i));
			}

		}
		else
		{
			hMenu.AddItem(sSlot, sItem, view_as<int>(iIndex == i));
		}
	}

	hMenu.ExitBackButton = true;
	hMenu.DisplayAt(iClient, iFirstItem, MENU_TIME_FOREVER);
}

int PatchMenuHandler(Menu hMenu, MenuAction iAction, int iParam1, int iParam2)
{
	switch(iAction)
	{
		case MenuAction_Select:
		{
			decl char sSlot[2];

			hMenu.GetItem(iParam2, sSlot, sizeof(sSlot));

			int iSlot = StringToInt(sSlot),
				iDefIndex = iParam2 ? g_hPatchs.Get(iParam2 - 1) : 0;

			g_iPlayerData[iParam1].SetPatch(iSlot, iDefIndex, g_iPlayerData[iParam1].iBufferTeam);
			// SetEntData(iParam1, m_vecPlayerPatchEconIndices + iSlot * 4, iDefIndex, 4, true);
			SetEntData(iParam1, m_vecPlayerPatchEconIndices + iSlot * 4, iDefIndex);

			PTaH_ForceFullUpdate(iParam1);

			PatchMenu(iParam1, iSlot, hMenu.Selection);
		}
		case MenuAction_Cancel:
		{
			if(iParam2 == MenuCancel_Exit)
			{
				if(g_iPlayerData[iParam1].bPreview)
				{
					AgentPreview(iParam1, g_iPlayerData[iParam1].bPreview = false);
				}
			}
			else if(iParam2 == MenuCancel_ExitBack)
			{
				PatchChoiceMenu(iParam1, g_iPlayerData[iParam1].iBufferTeam);
			}
		}
		case MenuAction_End:
		{
			if(iParam2 == MENUFLAG_BUTTON_EXIT)
			{
				hMenu.Close();
			}
		}
	}
}

bool AgentPreview(int iClient, bool bShow)
{
	if(bShow)
	{
		SetEntDataEnt2(iClient, m_hObserverTarget, 0);
		SetEntData(iClient, m_iObserverMode, 1);
		SetEntData(iClient, m_bDrawViewmodel, 0);
		SetEntData(iClient, m_iFOV, 120);

		if(g_iSettings & SETTING_PREVIEW_BLOCK_TRANSMITS)
		{
			for(int i = MaxClients + 1, iTeam = g_iPlayerData[iClient].iTeam; --i;)
			{
				if(g_iPlayerData[i].bInGame && !g_iPlayerData[i].bTransmit && g_iPlayerData[i].iTeam != iTeam)
				{
					SDKHook(i, SDKHook_SetTransmit, OnBlockSetTransmit);
					g_iPlayerData[i].bTransmit = true;
					g_iPreviewCount++;
				}
			}
		}

		// PrintToChat(iClient, "thirdperson");
		// ClientCommand(iClient, "cam_collision 0");
		// ClientCommand(iClient, "cam_idealdist 100");
		// ClientCommand(iClient, "cam_idealpitch 0");
		// ClientCommand(iClient, "cam_idealyaw 0");
		// ClientCommand(iClient, "thirdperson");
	}
	else
	{
		SetEntDataEnt2(iClient, m_hObserverTarget, -1);
		SetEntData(iClient, m_iObserverMode, 0);
		SetEntData(iClient, m_bDrawViewmodel, 1);
		SetEntData(iClient, m_iFOV, 90);

		if(!--g_iPreviewCount)
		{
			for(int i = MaxClients + 1; --i;)
			{
				if(g_iPlayerData[i].bInGame && g_iPlayerData[i].bTransmit)
				{
					SDKUnhook(i, SDKHook_SetTransmit, OnBlockSetTransmit);
					g_iPlayerData[i].bTransmit = false;
				}
			}
		}
	
		// PrintToChat(iClient, "firstperson");
		// ClientCommand(iClient, "firstperson");
		// ClientCommand(iClient, "cam_collision 1");
		// ClientCommand(iClient, "cam_idealdist 150");
	}


	g_iPlayerData[iClient].iPreviewOldButtons = 0;
}

Action OnBlockSetTransmit(int iHookClient, int iClient)
{
	return iClient != iHookClient && g_iPlayerData[iClient].bPreview && g_iPlayerData[iHookClient].iTeam != g_iPlayerData[iClient].iTeam ? Plugin_Handled : Plugin_Continue;
}

public void OnPluginEnd()
{
	for(int i = MaxClients + 1; --i;)
	{
		if(g_iPlayerData[i].iAccountID)
		{
			OnClientDisconnect(i);
		}
	}
}

// void LoadFromAddressString(Address pAddress, char[] sBuffer, int iSize)
// {
// 	int i = 0;

// 	decl int iData;

// 	while((iData = LoadFromAddress(pAddress + view_as<Address>(i), NumberType_Int8)) && i < iSize)
// 	{
// 		sBuffer[i++] = iData;
// 	}

// 	sBuffer[i] = '\0';
// }