enum OS {
	OS_Unknown = -1,
	OS_Windows = 0,
	OS_Linux = 1,
	OS_Mac = 2,
};

enum struct PlayerData
{
    char sCountryCode[3];

    void Reset()
    {
        this.sCountryCode = "EN";
    }
}

PlayerData g_PlayerData[MAXPLAYERS + 1];