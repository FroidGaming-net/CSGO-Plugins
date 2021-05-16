bool g_bLateLoad;

Handle g_Forward_OnParseOS;

enum OS {
	OS_Unknown = -1,
	OS_Windows = 0,
	OS_Mac = 1,
	OS_Linux = 2,
	OS_Total = 3
};

enum struct OSData
{
    bool bOSLoaded;
    char iOS[32];

    void Reset()
	{
		this.bOSLoaded = false;
		this.iOS = "";
	}
}

OSData g_OSData[OS];

enum struct PlayerData
{
    OS iOS;

    void Reset()
	{
		this.iOS = OS_Unknown;
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];