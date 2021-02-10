HTTPClient httpClient;

char g_NewName[MAXPLAYERS+1][MAX_NAME_LENGTH];

enum struct PlayerData
{
    char sName[128];
    char sCountryCode[3];

    void Reset()
    {
        this.sName[0] = 0;
        this.sCountryCode = "EN";
    }
}

PlayerData g_PlayerData[MAXPLAYERS + 1];