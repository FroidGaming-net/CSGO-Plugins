HTTPClient httpClient;

ConVar g_cHostname = null;
char g_sHostname[64];

enum struct PlayerData
{
    char sName[128];
    char sNewName[MAX_NAME_LENGTH];
    bool bBlockMessage;
    char sCountryCode[3];

    void Reset()
    {
        this.sName = "Default";
        this.sNewName = "Default";
        this.bBlockMessage = false;
        this.sCountryCode = "EN";
    }
}

PlayerData g_PlayerData[MAXPLAYERS + 1];