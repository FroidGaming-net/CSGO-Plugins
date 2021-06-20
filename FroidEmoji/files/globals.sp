#define BASE_URL "https://froidgaming.net"

enum struct LevelIcon
{
    char sName[32];
    int iIconIndex;
}

LevelIcon g_LevelIcons[MAX_ICONS];

int g_iLevelIcons = 0;
int m_iOffset = -1;

char m_sFilePath[PLATFORM_MAX_PATH];

enum struct PlayerData
{
    int iEmojiLoaded;
    int iEmojiData;
    char sCountryCode[3];

    void Reset()
	{
		this.iEmojiLoaded = 0;
        this.iEmojiData = 0;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];