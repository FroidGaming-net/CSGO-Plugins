HTTPClient httpClient;

enum struct PlayerData
{
    int iAgentLoaded;
    int iAgentCT;
    int iAgentT;
    int iCacheTeam;
    char sCacheType[30];

    void Reset()
	{
		this.iAgentLoaded = 0;
		this.iAgentCT = -1;
		this.iAgentT = -2;
        this.iCacheTeam = 0;
        this.sCacheType = "";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];