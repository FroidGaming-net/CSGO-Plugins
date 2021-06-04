StringMap PlayerConnect;

enum struct PlayerData
{
    int iFailedToPlant;
    char sCountryCode[3];

    void Reset()
	{
		this.iFailedToPlant = 0;
        this.sCountryCode = "EN";
	}
}

Handle g_hForward_OnForceEndFreezeTime;
PlayerData g_PlayerData[MAXPLAYERS + 1];

enum
{
    BOMBSITE_INVALID = -1,
    BOMBSITE_A = 0,
    BOMBSITE_B = 1
}