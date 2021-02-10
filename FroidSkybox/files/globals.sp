HTTPClient httpClient;

enum struct PlayerData
{
    int iSkyboxLoaded;
    char sSkybox[32];

    void Reset()
	{
		this.iSkyboxLoaded = 0;
		this.sSkybox = "mapdefault";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];

ConVar g_cSkyName;