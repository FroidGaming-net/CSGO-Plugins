#include <sdktools>
#include <eItems>
#include <PTaH>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

#define PREFIX "{default}[{lightblue}MusicKits{default}]"
#define PREFIX_NO_COLOR "[MusicKits]"

#define MUSIC_KIT_MAX_NAME_LEN 48

enum MCItem
{
	MCITEM_START = -1,
	MCITEM_MUSICKIT = 0,
	MCITEM_END
}

// Database
Database g_Database;

// ArrayLists
ArrayList g_alMusicKitsNames;

// Settings

enum struct PlayerInfo
{
	bool bFoundDefaults;
	
	int iOwnMusicKitNum;
	
	int iMusicKitNum;
	int iAccountID;
	
	void Reset()
	{
		this.bFoundDefaults = false;
		this.iOwnMusicKitNum = 0;
		this.iMusicKitNum = 0;
		this.iAccountID = 0;
	}
	
	bool SaveAndApplyItem(int client, MCItem item, int newvalue, bool isFirstLoad = false)
	{
		if(!isFirstLoad || newvalue)
		{
			switch (item)
			{
				// Music-Kit
				case MCITEM_MUSICKIT:
				{
					// Change in-game | 0 = Player default item
					SetEntProp(client, Prop_Send, "m_unMusicID", (!newvalue) ? this.iOwnMusicKitNum : newvalue);
					
					// Change global variable
					this.iMusicKitNum = newvalue;
				}
			}
		}

		return true;
	}
}

PlayerInfo g_PlayerInfo[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "MiscChanger", 
	author = "Natanel 'LuqS'", 
	description = "Allowing Players to change thier CS:GO miscellaneous items (Music-Kit / Coin / Pin).", 
	version = "1.2.2", 
	url = "https://steamcommunity.com/id/luqsgood || Discord: LuqS#6505 || https://github.com/Natanel-Shitrit"
}

/*********************
		Events
**********************/

public void OnPluginStart()
{
	if(GetEngineVersion() != Engine_CSGO)
		SetFailState("%s This plugin is for CSGO only.", PREFIX_NO_COLOR);
	
	RegConsoleCmd("sm_mk", Command_MusicKits);
	RegConsoleCmd("sm_musickits", Command_MusicKits);
	RegConsoleCmd("sm_musickit", Command_MusicKits);
	RegConsoleCmd("sm_music", Command_MusicKits);
	RegConsoleCmd("sm_musics", Command_MusicKits);

	// Create ArrayList for the data.
	CreateArrayLists();
	
	// Late-Loading support.
	if (eItems_AreItemsSynced())
		eItems_OnItemsSynced();
	
	// Hook event when we get the player default items.
	HookEvent("player_team", OnPlayerTeamChange);
	
	// Connect to the database
	Database.Connect(T_OnDBConnected, "default");
}

public void OnPluginEnd()
{
	// Early-Unload Support
	for (int iCurrentClient = 1; iCurrentClient <= MaxClients; iCurrentClient++)
		if(IsClientInGame(iCurrentClient))
			OnClientDisconnect(iCurrentClient);
}

// eItems has been loaded AFTER our plugin.
public void eItems_OnItemsSynced()
{
	//==================================[ Music-Kits ]==================================//
	g_alMusicKitsNames.PushString("VALVE Music-Kit 1 (Game Default)");
	g_alMusicKitsNames.PushString("VALVE Music-Kit 2 (Pre-Panorama T Default)");
	// Community Music-Kits
	for (int iCurrentMusicKit = 0; iCurrentMusicKit < eItems_GetMusicKitsCount(); iCurrentMusicKit++)
	{
		char sCurrentMusicKitName[MUSIC_KIT_MAX_NAME_LEN];
		eItems_GetMusicKitDisplayNameByDefIndex(iCurrentMusicKit + 3, sCurrentMusicKitName, MUSIC_KIT_MAX_NAME_LEN);
		
		g_alMusicKitsNames.PushString(sCurrentMusicKitName);
	}
}

void OnPlayerTeamChange(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid")), team = event.GetInt("team");
	
	if(client && !IsFakeClient(client) && !g_PlayerInfo[client].bFoundDefaults && team > 1)
		ProcessPlayerData(client);
}

// Processing the player data is:
// 1. Getting the client default items. (And his Steam-Account ID)
// 2. Get the prefrences from the database.
void ProcessPlayerData(int client)
{
	// Player default items.
	g_PlayerInfo[client].iOwnMusicKitNum = GetEntProp(client, Prop_Send, "m_unMusicID");
	
	// We found the default values.
	g_PlayerInfo[client].bFoundDefaults = true;
	
	// Get the player account id so we find his data in the database.
	g_PlayerInfo[client].iAccountID = GetSteamAccountID(client);
	
	// If the database is avilable, Ask for the data.
	if(g_Database)
	{
		char sQuery[256];
		Format(sQuery, sizeof(sQuery), "SELECT `musickit_num` FROM `csgo_musickits` WHERE `account_id` = %d", g_PlayerInfo[client].iAccountID);
		g_Database.Query(T_OnClientDataRecived, sQuery, GetClientUserId(client));
	}
}

public void OnClientDisconnect(int client)
{
	if(IsFakeClient(client))
		return;
	
	if(g_Database)
	{
		char sQuery[256];
		Format(sQuery, sizeof(sQuery), "INSERT INTO `csgo_musickits` (`account_id`, `musickit_num`) VALUES (%d, %d) ON DUPLICATE KEY UPDATE `musickit_num` = VALUES(`musickit_num`)",
			g_PlayerInfo[client].iAccountID,
			g_PlayerInfo[client].iMusicKitNum
		);
		
		g_Database.Query(T_OnClientSavedDataResponse, sQuery);
	}
	
	g_PlayerInfo[client].Reset();
}

/***********************
		Database
************************/

void T_OnDBConnected(Database db, const char[] error, any data)
{
	if (db == null) // Oops, something went wrong :S
		SetFailState("%s Cannot Connect To MySQL Server! | Error: %s", PREFIX_NO_COLOR, error);
	else
	{
		(g_Database = db).Query(T_OnDatabaseReady, "CREATE TABLE IF NOT EXISTS `csgo_musickits` (`account_id` INT NOT NULL DEFAULT '-1', `musickit_num` INT NOT NULL DEFAULT '-1', UNIQUE (`account_id`))", _, DBPrio_High);
	}
}

void T_OnDatabaseReady(Database db, DBResultSet results, const char[] error, any data)
{
	if(!db || !results || error[0])
	{
		SetFailState("[T_OnDatabaseReady] Query Failed | Error: %s", error);
	}
	
	// Late Load Support
	for (int iCurrentClient = 1; iCurrentClient <= MaxClients; iCurrentClient++)
		if(IsClientInGame(iCurrentClient))
			ProcessPlayerData(iCurrentClient);
}

void T_OnClientDataRecived(Database db, DBResultSet results, const char[] error, any data)
{
	if(!db || !results || error[0])
	{
		LogError("[T_OnClientDataRecived] Query Failed | Error: %s", error);
		return;
	}
	
	if(results.FetchRow())
	{
		int client = GetClientOfUserId(data);
		if(!(0 < client <= MaxClients) || !IsClientConnected(client))
		{
			LogError("[T_OnClientDataRecived] Client disconnected before fetching data, aborting.");
			return;
		}
		
		// 0 - 'musickit_num'
		g_PlayerInfo[client].SaveAndApplyItem(client, MCITEM_MUSICKIT, results.FetchInt(0), true);
	}
}

void T_OnClientSavedDataResponse(Database db, DBResultSet results, const char[] error, any data)
{
	if(!db || !results || error[0])
	{
		LogError("[T_OnClientSavedDataResponse] Query Failed | Error: %s", error);
		return;
	}
}

/***********************
		Commands
************************/

// Music Kits Menu - Lets you choose your preferred music kit from all the Music Kits that avilable in the game (With the help of eItems).
public Action Command_MusicKits(int client, int argc)
{
	if (0 < client <= MaxClients && IsClientInGame(client))
	{
		char sFindMusicKit[MUSIC_KIT_MAX_NAME_LEN];
		GetCmdArgString(sFindMusicKit, sizeof(sFindMusicKit));
		OpenMusicKitsMenu(client, 0, sFindMusicKit);
	}
	
	return Plugin_Handled;
}

/* Music Kits */
Menu BuildMusicKitsMenu(const char[] sFindMusicKit = "", int client)
{
	Menu mMusicKitsMenu = new Menu(MusicKitsMenuHandler);
	mMusicKitsMenu.SetTitle("%s Choose Your Music-Kit:", PREFIX_NO_COLOR);
	
	// Reset Music-Kit
	mMusicKitsMenu.AddItem(sFindMusicKit, "Your Default Music-Kit", !g_PlayerInfo[client].iMusicKitNum ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	// Music-Kits Options
	for (int iCurrentMusicKit = 0; iCurrentMusicKit < g_alMusicKitsNames.Length; iCurrentMusicKit++) // + 2 Because we added 2 kits from VALVE
	{
		char sMusicKitName[MUSIC_KIT_MAX_NAME_LEN];
		g_alMusicKitsNames.GetString(iCurrentMusicKit, sMusicKitName, sizeof(sMusicKitName));
		
		char sMusicKitNum[4];
		IntToString(iCurrentMusicKit + 1, sMusicKitNum, sizeof(sMusicKitNum));
		
		if (!sFindMusicKit[0] || StrContains(sMusicKitName, sFindMusicKit, false) != -1)
			mMusicKitsMenu.AddItem(sMusicKitNum, sMusicKitName, g_PlayerInfo[client].iMusicKitNum == iCurrentMusicKit + 1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	
	return mMusicKitsMenu;
}

void OpenMusicKitsMenu(int client, int startItem = 0, const char[] sFindMusicKit = "")
{
	// Display the menu from the given item
	if (eItems_AreItemsSynced())
	{
		Menu mMenuToDisplay = BuildMusicKitsMenu(sFindMusicKit, client);
		switch (mMenuToDisplay.ItemCount)
		{
			case 1:
			{
				CPrintToChat(client, "%s No Music-Kits were found!", PREFIX);
			}
			case 2:
			{
				MusicKitsMenuHandler2(mMenuToDisplay, MenuAction_Select, client, 1);
				delete mMenuToDisplay;
			}
			default:
			{
				mMenuToDisplay.DisplayAt(client, startItem, MENU_TIME_FOREVER);
			}
		}
	}
	else
		CPrintToChat(client, "%s \x0EMusic-Kits\x01 Menu is \x02Currently Unavailable\x01!", PREFIX);
}

int MusicKitsMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sMusicKitNum[4], sMusicKitDisplayName[MUSIC_KIT_MAX_NAME_LEN];
			menu.GetItem(param2, sMusicKitNum, sizeof(sMusicKitNum), _, sMusicKitDisplayName, MUSIC_KIT_MAX_NAME_LEN);
			
			int iMusicKitNum = StringToInt(sMusicKitNum);
			// Change Client Music-Kit in the scoreboard and save his prefrence.
			if(g_PlayerInfo[client].SaveAndApplyItem(client, MCITEM_MUSICKIT, iMusicKitNum))
			{
				if(g_PlayerInfo[client].iMusicKitNum != iMusicKitNum)
				{
					eItems_GetMusicKitDisplayNameByMusicKitNum(g_PlayerInfo[client].iMusicKitNum, sMusicKitDisplayName, MUSIC_KIT_MAX_NAME_LEN);
				}
				
				// Alert him that the Music-Kit has been changed.
				CPrintToChat(client, "%s \x04Successfully\x01 changed your Music-Kit to \x02%s\x01!", PREFIX, sMusicKitDisplayName);
			}
			
			// Reopen the menu where it was.
			char sFindMusicKit[64];
			menu.GetItem(0, sFindMusicKit, sizeof(sFindMusicKit));
			OpenMusicKitsMenu(client, menu.Selection, sFindMusicKit);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

int MusicKitsMenuHandler2(Menu menu, MenuAction action, int client, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sMusicKitNum[4], sMusicKitDisplayName[MUSIC_KIT_MAX_NAME_LEN];
			menu.GetItem(param2, sMusicKitNum, sizeof(sMusicKitNum), _, sMusicKitDisplayName, MUSIC_KIT_MAX_NAME_LEN);
			
			int iMusicKitNum = StringToInt(sMusicKitNum);
			// Change Client Music-Kit in the scoreboard and save his prefrence.
			if(g_PlayerInfo[client].SaveAndApplyItem(client, MCITEM_MUSICKIT, iMusicKitNum))
			{
				if(g_PlayerInfo[client].iMusicKitNum != iMusicKitNum)
				{
					eItems_GetMusicKitDisplayNameByMusicKitNum(g_PlayerInfo[client].iMusicKitNum, sMusicKitDisplayName, MUSIC_KIT_MAX_NAME_LEN);
				}
				
				// Alert him that the Music-Kit has been changed.
				CPrintToChat(client, "%s \x04Successfully\x01 changed your Music-Kit to \x02%s\x01!", PREFIX, sMusicKitDisplayName);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

/**********************
		Helpers
***********************/

// Create ArrayList for the data.
void CreateArrayLists()
{
	g_alMusicKitsNames = new ArrayList(ByteCountToCells(MUSIC_KIT_MAX_NAME_LEN));
}