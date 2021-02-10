HTTPClient httpClient;
HTTPClient httpClient2;

enum struct PlayerData
{
    int iBannedLoaded;
    int iFACLoaded;
    int iHoursLoaded;
    int iCreatedAtLoaded;
    // int iLevelLoaded;
	int iCSGOLevel;
    int iPlayerDataLoaded;
    char sCountryCode[3];

    void Reset()
	{
		this.iBannedLoaded = 0;
		this.iFACLoaded = 0;
		this.iHoursLoaded = 0;
		this.iCreatedAtLoaded = 0;
		// this.iLevelLoaded = 0;
		this.iCSGOLevel = 0;
		this.iPlayerDataLoaded = 0;
		this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];