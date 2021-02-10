Handle g_hForward_OnClientReplaced;

ConVar g_cHostname = null;
char g_sHostname[64];

StringMap PlayerCooldown;
StringMap PlayerDisconnect;

enum struct PlayerData
{
    bool bQueue;
    char sCountryCode[3];

    void Reset()
	{
        this.bQueue = false;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];