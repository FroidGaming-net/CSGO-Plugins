ConVar g_cHostname = null;
char g_sHostname[64];
int g_iRoundCount = 0;
bool g_bHalfTime = false;

enum struct PlayerData
{
    int iBanned;
    int iTeamDamage;
    int iRoundTeamDamage;
    int iTotalTeamDamage;
    float fStamina;
    char sCountryCode[3];

    void Reset()
	{
        this.iBanned = 0;
		this.iTeamDamage = 0;
		this.iRoundTeamDamage = 0;
		this.iTotalTeamDamage = 0;
		this.fStamina = 0.0;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];