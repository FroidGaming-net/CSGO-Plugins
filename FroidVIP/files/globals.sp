#define BASE_URL "https://froidgaming.net"

Handle g_hForward_OnClientLoadedPre;
Handle g_hForward_OnClientLoadedPost;

enum struct PlayerData
{
    int iVipLoaded;
    char sCountryCode[3];

    void Reset()
	{
		this.iVipLoaded = 0;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];