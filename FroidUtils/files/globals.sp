ConVar g_cServerName = null;
char g_sServerName[64];

StringMap PlayerCooldown;
StringMap PlayerConnect;

enum struct PlayerData
{
    int iVIPLoaded;
    int iReplaced;
    int iRoundSpectator;
    int iRoundGhost;
    char sCountryCode[3];

    void Reset()
	{
		this.iVIPLoaded = 0;
		this.iReplaced = 0;
		this.iRoundSpectator = 0;
		this.iRoundGhost = 0;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];