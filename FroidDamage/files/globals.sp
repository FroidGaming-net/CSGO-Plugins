ConVar g_cHostname = null;
char g_sHostname[64];

enum struct PlayerData
{
    int iBanned;
    int iTeamDamage;
    int iTotalTeamDamage;
    float fStamina;
    char sCountryCode[3];

    void Reset()
	{
        this.iBanned = 0;
		this.iTeamDamage = 0;
		this.iTotalTeamDamage = 0;
		this.fStamina = 0.0;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];