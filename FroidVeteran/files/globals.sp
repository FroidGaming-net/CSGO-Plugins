#define BASE_URL "https://froidgaming.net"

enum struct PlayerData
{
    int iEXP;
    int iPlayersLoaded;
    char sCountryCode[3];

    void Reset()
	{
        this.iEXP = 0;
        this.iPlayersLoaded = 0;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];