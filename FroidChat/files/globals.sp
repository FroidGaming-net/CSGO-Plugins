#define BASE_URL "https://froidgaming.net"

enum struct PlayerData
{
    int iChatLoaded;

    char sName[NAME_LENGTH];
    char sMessage[MESSAGE_LENGTH];
    char sClanTag[PREFIX_LENGTH];
    char sCountryCode[3];

    bool bWaitingForData;

    void Reset()
    {
        this.iChatLoaded = 0;
        this.sName[0] = 0;
        this.sMessage[0] = 0;
        this.sClanTag[0] = 0;
        this.sCountryCode = "EN";
        this.bWaitingForData = false;
    }

    void Clear()
    {
        this.sName[0] = 0;
        this.sMessage[0] = 0;
        this.sClanTag[0] = 0;
    }
}

PlayerData g_PlayerData[MAXPLAYERS + 1];

int g_iLevel[2];
char g_sHostname[64];
ConVar g_cHostname;