HTTPClient httpClient;

char g_NewName[MAXPLAYERS+1][MAX_NAME_LENGTH];

ConVar g_cHostname = null;
char g_sHostname[64];

enum struct PlayerData
{
    char sName[128];
    bool bBlockMessage;
    char sCountryCode[3];

    void Reset()
    {
        this.sName[0] = 0;
        this.bBlockMessage = false;
        this.sCountryCode = "EN";
    }
}

PlayerData g_PlayerData[MAXPLAYERS + 1];