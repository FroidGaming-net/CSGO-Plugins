ConVar g_cServerName = null;
ConVar g_cDisableRadar;
char g_sServerName[64];

StringMap PlayerCooldown;
StringMap PlayerConnect;
StringMap PlayerRoundSpectator;
StringMap PlayerRoundGhost;

enum struct PlayerData
{
    char sAuthID[64];
    int iVIPLoaded;
    int iReplaced;
    int iRoundSpectator;
    int iRoundGhost;
    bool bMakeBlind;
    char sCountryCode[3];

    void Reset()
	{
		this.sAuthID = "0";
		this.iVIPLoaded = 0;
		this.iReplaced = 0;
		this.iRoundSpectator = 0;
		this.iRoundGhost = 0;
		this.bMakeBlind = false;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];