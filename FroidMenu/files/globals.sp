enum struct PlayerData
{
    char sCountryCode[3];

    void Reset()
	{
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];