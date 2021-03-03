enum struct PlayerData
{
    int iRank;
    int iEXP;
    int iPlayersLoaded;
    char sCountryCode[3];

    void Reset()
	{
        this.iRank = 0;
        this.iEXP = 0;
        this.iPlayersLoaded = 0;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];