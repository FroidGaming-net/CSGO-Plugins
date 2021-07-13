#define BASE_URL "https://froidgaming.net"

enum struct PlayerData
{
    int iFACLoaded;

    void Reset()
	{
		this.iFACLoaded = 0;
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];