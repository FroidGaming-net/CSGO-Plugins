#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <cstrike>
#include <smlib>
#include <csgocolors>
#include <prophunt>
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045
#include <soundlib> // https://forums.alliedmods.net/showthread.php?t=105816

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopIngameClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1))

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

#define LoopArray(%1,%2) for(int %1=0;%1<GetArraySize(%2);++%1)

#define PLUGIN_VERSION "1.0"

#define MAX_WHISTLE_PACKS 32
#define MAX_WHISTLES 128

int g_iTauntSoundPacks;

ArrayList g_aTauntSound[MAXPLAYERS + 1];
ArrayList g_aTauntSoundPack[MAXPLAYERS + 1];
bool g_bTauntResistance[MAXPLAYERS + 1];

ArrayList g_aTauntDefaultSound;
ArrayList g_aTauntDefaultSoundPack;

Handle g_hCookie[MAX_WHISTLE_PACKS][MAX_WHISTLES];

bool g_sWpVIPOnly[MAX_WHISTLE_PACKS];
char g_sWpNames[MAX_WHISTLE_PACKS][255];

int g_iTauntSoundPacksFileCount[MAX_WHISTLE_PACKS];
char g_sWpFiles[MAX_WHISTLE_PACKS][MAX_WHISTLES][255];
float g_fWpSoundLength[MAX_WHISTLE_PACKS][MAX_WHISTLES];
bool g_bWpSoundVIP[MAX_WHISTLE_PACKS][MAX_WHISTLES];

public Plugin myinfo =
{
	name = "Prophunt - Taunt",
	author = ".#Zipcore",
	description = "Overrides classic taunt system.",
	version = PLUGIN_VERSION,
	url = "zipcore.net"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("prophunt-taunt");

	return APLRes_Success;
}

public void PH_OnHiderSpawn(int iClient)
{
	g_bTauntResistance[iClient] = false
}

public void PH_OnSeekerSpawn(int iClient)
{
	g_bTauntResistance[iClient] = false
}

public void OnPluginStart()
{
	LoopClients(i)
	{
		g_aTauntSound[i] = new ArrayList();
		g_aTauntSoundPack[i] = new ArrayList();
	}

	g_aTauntDefaultSound = new ArrayList();
	g_aTauntDefaultSoundPack = new ArrayList();

	LoadTauntSoundPacks();
}

bool g_bAdminCheck[MAXPLAYERS + 1];
bool g_bChookiesCached[MAXPLAYERS + 1];

public void OnClientDisconnect(int iClient)
{
	SaveCookies(iClient);

	g_bAdminCheck[iClient] = false;
	g_bChookiesCached[iClient] = false;

	g_aTauntSound[iClient].Clear();
	g_aTauntSoundPack[iClient].Clear();
}

bool HasVIP(int iClient)
{
	return Client_HasAdminFlags(iClient, ADMFLAG_CUSTOM5) || Client_HasAdminFlags(iClient, ADMFLAG_ROOT);
}

public OnClientPostAdminCheck(int iClient)
{
	g_bAdminCheck[iClient] = true;
	LoadCookies(iClient);
}

public void OnClientCookiesCached(int iClient)
{
	g_bChookiesCached[iClient] = true;
	LoadCookies(iClient);
}

void LoadCookies(int iClient)
{
	if(!g_bChookiesCached[iClient] || !g_bAdminCheck[iClient])
		return;

	g_aTauntSound[iClient].Clear();
	g_aTauntSoundPack[iClient].Clear();

	char sBuffer[32];
	for (int iPack = 0; iPack < g_iTauntSoundPacks; iPack++)
	{
		for (int iSound = 0; iSound < g_iTauntSoundPacksFileCount[iPack]; iSound++)
		{
			GetClientCookie(iClient, g_hCookie[iPack][iSound], sBuffer, sizeof(sBuffer));

			if(StrEqual(sBuffer, "disabled"))
				continue;

			// Enabled
			if(StrEqual(sBuffer, "enabled"))
			{
				// Vip
				if(g_bWpSoundVIP[iPack][iSound] && !HasVIP(iClient))
					continue;

				g_aTauntSoundPack[iClient].Push(iPack);
				g_aTauntSound[iClient].Push(iSound);

				continue;
			}

			if(g_bWpSoundVIP[iPack][iSound] && !HasVIP(iClient))
				continue;

			g_aTauntSoundPack[iClient].Push(iPack);
			g_aTauntSound[iClient].Push(iSound);
		}
	}
}

void SaveCookies(int iClient)
{
	char sBuffer[32];
	for (int iPack = 0; iPack < g_iTauntSoundPacks; iPack++)
	{
		for (int iSound = 0; iSound < g_iTauntSoundPacksFileCount[iPack]; iSound++)
		{
			bool enabled = HasSound(iClient, iPack, iSound);
			GetClientCookie(iClient, g_hCookie[iPack][iSound], sBuffer, sizeof(sBuffer));

			// By default enabled and not disabled
			if(StrEqual(sBuffer, "enabled") && enabled)
				continue;

			// Disabled already
			if(StrEqual(sBuffer, "disabled") && !enabled)
				continue;

			// Default enabled
			if(StrEqual(sBuffer, "") && enabled)
				continue;

			SetClientCookie(iClient, g_hCookie[iPack][iSound], enabled ? "enabled" : "disabled");
		}
	}
}

public Action PH_OnOpenTauntMenu(int iClient)
{
	if(!iClient || !IsClientInGame(iClient))
		return Plugin_Continue;

	Menu_TauntPacks(iClient);
	return Plugin_Stop;
}

int g_iNextTaunt[MAXPLAYERS + 1];
int g_iNextTauntPack[MAXPLAYERS + 1];

public Action PH_OnTauntPre(int iHider, float &fSoundln)
{
	if(g_aTauntSound[iHider].Length < 1)
	{
		int iRandom = GetRandomInt(0, g_aTauntDefaultSound.Length - 1);
		g_iNextTauntPack[iHider] = g_aTauntDefaultSoundPack.Get(iRandom);
		g_iNextTaunt[iHider] = g_aTauntDefaultSound.Get(iRandom);
		fSoundln = g_fWpSoundLength[g_iNextTauntPack[iHider]][g_iNextTaunt[iHider]];
		return Plugin_Changed;
	}

	int iRandom = GetRandomInt(0, g_aTauntSound[iHider].Length - 1);
	g_iNextTauntPack[iHider] = g_aTauntSoundPack[iHider].Get(iRandom);
	g_iNextTaunt[iHider] = g_aTauntSound[iHider].Get(iRandom);
	fSoundln = g_fWpSoundLength[g_iNextTauntPack[iHider]][g_iNextTaunt[iHider]];

	return Plugin_Changed;
}

public void PH_OnTaunt(int iHider, float fSoundln)
{
	PlaySound(iHider, g_iNextTauntPack[iHider], g_iNextTaunt[iHider]);
}

public Action PH_OnForceTauntPre(int iClient, int iHider, float &fSoundln)
{
	if(g_bTauntResistance[iHider])
	{
		CPrintToChatAll("{darkred} %N resisted %N's taunt grenade.", iHider, iClient);
		return Plugin_Stop;
	}

	if(g_aTauntSound[iClient].Length < 1)
	{
		int iRandom = GetRandomInt(0, g_aTauntDefaultSound.Length - 1);
		g_iNextTauntPack[iClient] = g_aTauntDefaultSoundPack.Get(iRandom);
		g_iNextTaunt[iClient] = g_aTauntDefaultSound.Get(iRandom);
		fSoundln = g_fWpSoundLength[g_iNextTauntPack[iClient]][g_iNextTaunt[iClient]];
		return Plugin_Changed;
	}

	int iRandom = GetRandomInt(0, g_aTauntSound[iClient].Length - 1);
	g_iNextTauntPack[iHider] = g_aTauntSoundPack[iClient].Get(iRandom);
	g_iNextTaunt[iHider] = g_aTauntSound[iClient].Get(iRandom);
	fSoundln = g_fWpSoundLength[g_iNextTauntPack[iClient]][g_iNextTaunt[iClient]];

	return Plugin_Changed;
}

public void PH_OnForceTaunt(int iClient, int iHider, float fSoundln)
{
	PlaySound(iHider, g_iNextTauntPack[iHider], g_iNextTaunt[iHider]);
}

bool HasSound(int iClient, int iPack, int iSound)
{
	LoopArray(i, g_aTauntSound[iClient])
	{
		if(g_aTauntSoundPack[iClient].Get(i) != iPack)
			continue;

		if(g_aTauntSound[iClient].Get(i) != iSound)
			continue;

		return true;
	}

	return false;
}

void AddSound(int iClient, int iPack, int iSound)
{
	LoopArray(i, g_aTauntSound[iClient])
	{
		if(g_aTauntSoundPack[iClient].Get(i) != iPack)
			continue;

		if(g_aTauntSound[iClient].Get(i) != iSound)
			continue;

		return;
	}

	g_aTauntSoundPack[iClient].Push(iPack);
	g_aTauntSound[iClient].Push(iSound);
}

void AddSoundPack(int iClient, int iPack)
{
	int iIndex = -1;
	while((iIndex = g_aTauntSoundPack[iClient].FindValue(iPack)) != -1)
	{
		g_aTauntSoundPack[iClient].Erase(iIndex);
		g_aTauntSound[iClient].Erase(iIndex);
	}

	int iCount;
	int iCountVIP;
	for (int iSound = 0; iSound < g_iTauntSoundPacksFileCount[iPack]; iSound++)
	{
		if(g_bWpSoundVIP[iPack][iSound] && !HasVIP(iClient))
		{
			iCountVIP++;
			continue;
		}

		iCount++;

		g_aTauntSoundPack[iClient].Push(iPack);
		g_aTauntSound[iClient].Push(iSound);
	}

	if(iCountVIP > 0)
		CPrintToChat(iClient, "{darkred} %i Vip sounds could not be selected!", iCountVIP);
}

bool RemoveSound(int iClient, int iPack, int iSound)
{
	if(g_aTauntSoundPack[iClient].Length <= 20)
	{
		CPrintToChat(iClient, "You need to keep at least 20 sounds enabled.");
		return false;
	}

	LoopArray(iIndex, g_aTauntSoundPack[iClient])
	{
		if(g_aTauntSoundPack[iClient].Get(iIndex) != iPack)
			continue;

		if(g_aTauntSound[iClient].Get(iIndex) != iSound)
			continue;

		g_aTauntSoundPack[iClient].Erase(iIndex);
		g_aTauntSound[iClient].Erase(iIndex);

		return true;
	}

	return false;
}

void RemoveSoundPack(int iClient, int iPack)
{
	int iIndex = -1;
	while((iIndex = g_aTauntSoundPack[iClient].FindValue(iPack)) != -1)
	{
		if(g_aTauntSoundPack[iClient].Length <= 20)
		{
			CPrintToChat(iClient, "You need to keep at least 20 sounds enabled.");
			return;
		}

		g_aTauntSoundPack[iClient].Erase(iIndex);
		g_aTauntSound[iClient].Erase(iIndex);
	}
}

void PlaySound(int iClient, int iPack, int iSound)
{
	float fPos[3];
	GetClientAbsOrigin(iClient, fPos);
	fPos[2] += 8.0;

	EmitAmbientSoundAny(g_sWpFiles[iPack][iSound], fPos, iClient, 120, _, 0.8);
}

int GetClientPackCount(int iClient, int iPack)
{
	int iCount;
	LoopArray(iIndex, g_aTauntSoundPack[iClient])
	{
		if(g_aTauntSoundPack[iClient].Get(iIndex) != iPack)
			continue;

		iCount++;
	}

	return iCount;
}

void LoadTauntSoundPacks()
{
	g_iTauntSoundPacks = 0;

	g_aTauntDefaultSound.Clear();
	g_aTauntDefaultSoundPack.Clear();

	char ConfigPath[255];
	BuildPath(Path_SM, ConfigPath, 255, "configs/prophunt/taunt_packs.cfg");

	Handle hFile = OpenFile(ConfigPath, "r");
	if (hFile != INVALID_HANDLE)
	{
		char sBuffer[255];
		while (ReadFileLine(hFile, sBuffer, sizeof(sBuffer)))
		{
			TrimString(sBuffer);

			// Allow Comments & empty lines
			if(strlen(sBuffer) < 3)
				continue;

			// If the line contains "VIP-Pack:" it's a new VIP only pack
			else if(ReplaceString(sBuffer, 255, "VIP-Pack:", "", true) > 0)
			{
				strcopy(g_sWpNames[g_iTauntSoundPacks], 255, sBuffer);
				g_iTauntSoundPacksFileCount[g_iTauntSoundPacks] = 0;
				g_sWpVIPOnly[g_iTauntSoundPacks] = true;
				g_iTauntSoundPacks++;
			}
			// If the line contains "Pack:" it's a new pack
			else if(ReplaceString(sBuffer, 255, "Pack:", "", true) > 0)
			{
				strcopy(g_sWpNames[g_iTauntSoundPacks], 255, sBuffer);
				g_iTauntSoundPacksFileCount[g_iTauntSoundPacks] = 0;
				g_sWpVIPOnly[g_iTauntSoundPacks] = false;
				g_iTauntSoundPacks++;
			}
			// Read taunt sounds
			else if(g_iTauntSoundPacks)
			{
				// Fix incompability with prophunt-taunt
				bool bVIP = ReplaceString(sBuffer, sizeof(sBuffer), "//VIP", "") == 1;

				if(PrepareSound(sBuffer))
				{
					char sName[16];
					Format(sName, sizeof(sName), "ph_taunt_%i_%i", g_iTauntSoundPacks - 1, g_iTauntSoundPacksFileCount[g_iTauntSoundPacks - 1]);
					g_hCookie[g_iTauntSoundPacks - 1][g_iTauntSoundPacksFileCount[g_iTauntSoundPacks - 1]] = RegClientCookie(sName, sName, CookieAccess_Public);

					// VIP sound
					g_bWpSoundVIP[g_iTauntSoundPacks - 1][g_iTauntSoundPacksFileCount[g_iTauntSoundPacks - 1]] = bVIP;

					// Add non VIP sounds to default sound list
					if(!g_bWpSoundVIP[g_iTauntSoundPacks - 1][g_iTauntSoundPacksFileCount[g_iTauntSoundPacks - 1]])
					{
						g_aTauntDefaultSound.Push(g_iTauntSoundPacksFileCount[g_iTauntSoundPacks - 1]);
						g_aTauntDefaultSoundPack.Push(g_iTauntSoundPacks-1);
					}

					// VIP pack
					if(!g_bWpSoundVIP[g_iTauntSoundPacks-1][g_iTauntSoundPacksFileCount[g_iTauntSoundPacks-1]])
						g_bWpSoundVIP[g_iTauntSoundPacks-1][g_iTauntSoundPacksFileCount[g_iTauntSoundPacks-1]] = g_sWpVIPOnly[g_iTauntSoundPacks-1];

					// Store sound length
					g_fWpSoundLength[g_iTauntSoundPacks - 1][g_iTauntSoundPacksFileCount[g_iTauntSoundPacks - 1]] = GetSoundLengthEx(sBuffer);
					// Store sound path
					strcopy(g_sWpFiles[g_iTauntSoundPacks - 1][g_iTauntSoundPacksFileCount[g_iTauntSoundPacks - 1]], 255, sBuffer);
					//Count pack sounds
					g_iTauntSoundPacksFileCount[g_iTauntSoundPacks - 1]++;
				}
			}
		}

		delete hFile;

		LoopIngameClients(iClient)
			OnClientCookiesCached(iClient);
	}
}

void Menu_TauntPacks(int iClient)
{
	if(!IsClientInGame(iClient))
		return;

	Menu menu = new Menu(SoundPack_Handler);
	menu.SetTitle("+++ Taunt sound customization +++\n\nSounds enabled: %i", g_aTauntSoundPack[iClient].Length);

	for (int iPack = 0; iPack < g_iTauntSoundPacks; iPack++)
	{
		char idx[8];
		IntToString(iPack, idx, 8);

		char sBuffer[128];
		Format(sBuffer, 128, "%s%s (%i / %i)", g_sWpNames[iPack], g_sWpVIPOnly[iPack] ? " ♔" : "", GetClientPackCount(iClient, iPack), g_iTauntSoundPacksFileCount[iPack]);

		// No access / VIP only
		menu.AddItem(idx, sBuffer);
	}

	SetMenuExitButton(menu, true);
	DisplayMenu(menu, iClient, 360);
}

public int SoundPack_Handler(Menu menu, MenuAction action, int iClient, int iInfo)
{
	if ( action == MenuAction_Select )
	{
		char sInfo[255];
		char sInfo2[255];
		bool found = GetMenuItem(menu, iInfo, sInfo, sizeof(sInfo), _, sInfo2, sizeof(sInfo2));

		if(found)
		{
			int iPack = StringToInt(sInfo);
			Menu_Taunts(iClient, iPack);
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}

int g_iPackSelected[MAXPLAYERS + 1];

void Menu_Taunts(int iClient, int iPack, int iInfo = 0)
{
	if(!IsClientInGame(iClient))
		return;

	g_iPackSelected[iClient] = iPack;
	Menu menu = new Menu(Sounds_Handler);
	menu.SetTitle("Pack: %s\n\nEnabled: %i / %i", g_sWpNames[iPack], GetClientPackCount(iClient, iPack), g_iTauntSoundPacksFileCount[iPack]);

	char sName[64];

	AddMenuItem(menu, "back", "Back");
	AddMenuItem(menu, "all", "Select All");
	AddMenuItem(menu, "none", "Unselect All");

	for (int iSound = 0; iSound < g_iTauntSoundPacksFileCount[iPack]; iSound++)
	{
		char idx[8];
		IntToString(iSound, idx, 8);

		Format(sName, sizeof(sName), "[%is] %s %s %s", RoundToCeil(g_fWpSoundLength[iPack][iSound]), g_sWpFiles[iPack][iSound][FindCharInString(g_sWpFiles[iPack][iSound], '/', true) + 1], HasSound(iClient, iPack, iSound) ? "✓" :  "", g_sWpVIPOnly[iPack] || g_bWpSoundVIP[iPack][iSound] ? "♔" : "");
		ReplaceString(sName, sizeof(sName), ".mp3", "");

		menu.AddItem(idx, sName);
	}

	menu.ExitButton = true;
	menu.DisplayAt(iClient, GetFirstPageItem(iInfo), MENU_TIME_FOREVER);
}

int g_iSoundSelected[MAXPLAYERS + 1];

public int Sounds_Handler(Menu menu, MenuAction action, int iClient, int iInfo)
{
	if ( action == MenuAction_Select )
	{
		char sInfo[255];
		char sInfo2[255];
		bool found = GetMenuItem(menu, iInfo, sInfo, sizeof(sInfo), _, sInfo2, sizeof(sInfo2));

		int iPack = g_iPackSelected[iClient];
		int iSound = StringToInt(sInfo);
		g_iSoundSelected[iClient] = iInfo;

		if(found)
		{
			if(StrEqual(sInfo, "back"))
				Menu_TauntPacks(iClient);
			else if(StrEqual(sInfo, "all"))
			{
				if(g_sWpVIPOnly[iPack]&& !HasVIP(iClient))
					CPrintToChat(iClient, "{darkred} This pack can be selected only by VIP players!");
				else AddSoundPack(iClient, iPack);
				Menu_Taunts(iClient, iPack, iInfo);
			}
			else if(StrEqual(sInfo, "none"))
			{
				RemoveSoundPack(iClient, iPack);
				Menu_Taunts(iClient, iPack, iInfo);
			}
			else
			{
				if(HasSound(iClient, iPack, iSound))
					RemoveSound(iClient, iPack, iSound)
				else
				{
					EmitSoundToClientAny(iClient, g_sWpFiles[iPack][iSound], .volume = 0.4); // Preview

					if((g_sWpVIPOnly[iPack] || g_bWpSoundVIP[iPack][iSound]) && !HasVIP(iClient))
						CPrintToChat(iClient, "{darkred} This sound can be selected only by VIP players!");
					else AddSound(iClient, iPack, iSound);
				}

				Menu_Taunts(iClient, iPack, iInfo);
			}

			if(g_aTauntSoundPack[iClient].Length < 1)
				CPrintToChat(iClient, "{darkred} You have not enough sounds selected. Default sounds are activated!");
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}

stock float GetSoundLengthEx(char[] path)
{
	Handle hFile = OpenSoundFile(path);
	float fLength = GetSoundLengthFloat(hFile);
	delete hFile;

	return fLength;
}

stock int GetFirstPageItem(int itemNum, int pagination = 6)
{
	int item = itemNum;
	int firstItem;

	while(item >= pagination)
	{
		firstItem += pagination;
		item -= pagination;
	}

	return firstItem;
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "prophunt"))
		PH_RegisterShopItem("Taunt Resistance", CS_TEAM_T, 250, 200, 0, false);
}

public void OnMapStart()
{
	PH_RegisterShopItem("Taunt Resistance", CS_TEAM_T, 250, 200, 0, false);
}

public Action PH_OnBuyShopItem(int iClient, char[] sName, int &iPoints)
{
	if(StrEqual(sName, "Taunt Resistance"))
		return Plugin_Handled;

	return Plugin_Continue;
}

public void PH_OnBuyShopItemPost(int iClient, char[] sName, int iPoints)
{
	if(StrEqual(sName, "Taunt Resistance"))
	{
		PH_DisableShopItem("Taunt Resistance", iClient);
		g_bTauntResistance[iClient] = true;
	}
}

stock bool PrepareSound(char[] sound)
{
	char fileSound[PLATFORM_MAX_PATH];
	FormatEx(fileSound, PLATFORM_MAX_PATH, "sound/%s", sound);

	if (FileExists(fileSound, false))
	{
		PrecacheSoundAny(sound, true);
		AddFileToDownloadsTable(fileSound);
		return true;
	}
	else if(FileExists(fileSound, true))
	{
		PrecacheSound(sound, true);
		return true;
	}

	LogMessage("File Not Found: %s", fileSound);
	return false;
}
