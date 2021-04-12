#define m_flNextSecondaryAttack FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack")

int g_iRoundCount = 0;
int g_iRoundMode = 0;
bool g_bNades = false;
bool g_bNoScope = false;
bool g_bNoKnifeDamage = false;

enum struct PlayerData
{
    float fStamina;

    void Reset()
	{
		this.fStamina = 0.0;
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];