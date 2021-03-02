HTTPClient httpClient;

#define FULL_ROUND 1
#define FORCE_ROUND 2
#define PISTOL_ROUND 3

#define PISTOL_ROUND_TOTAL 5
#define FORCE_ROUND_TOTAL 3

#define MIN_PLAYER_AWP_CT 3
#define MIN_PLAYER_AWP_T 3
#define MIN_PLAYER_SCOUT_CT 2
#define MIN_PLAYER_SCOUT_T 2

#define FULL_ROUND_MONEY 16000
#define FORCEBUY_ROUND_MONEY 2700
#define PISTOL_ROUND_MONEY 800

enum struct PlayerData
{
    int iWeaponsLoaded;

    // CT
    char sPistolRound_CT[24];
    char sPrimary_CT[24];
    char sSecondary_CT[24];
    char sSMG_CT[24];
    bool bAWP_CT;
    bool bScout_CT;

    // T
    char sPistolRound_T[24];
    char sPrimary_T[24];
    char sSecondary_T[24];
    char sSMG_T[24];
    bool bAWP_T;
    bool bScout_T;

    int iCacheTeam;

    void Reset()
	{
		this.iWeaponsLoaded = 0;

        // CT
		this.sPistolRound_CT = "weapon_usp_silencer";
		this.sPrimary_CT = "weapon_m4a1";
		this.sSecondary_CT = "weapon_usp_silencer";
		this.sSMG_CT = "weapon_ump45";
		this.bAWP_CT = false;
		this.bScout_CT = false;

        // T
		this.sPistolRound_T = "weapon_glock";
		this.sPrimary_T = "weapon_ak47";
		this.sSecondary_T = "weapon_glock";
		this.sSMG_T = "weapon_ump45";
		this.bAWP_T = false;
		this.bScout_T = false;

        this.iCacheTeam = 0;
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];

char g_sBombSite[16];
char g_sRoundType[64];

int g_iRoundType;
int g_iHEgrenade_CT = 0;
int g_iHEgrenade_T = 0;
int g_iFlashbang_CT = 0;
int g_iFlashbang_T = 0;
int g_iSmokegrenade_CT = 0;
int g_iSmokegrenade_T = 0;
int g_iMolotov_CT = 0;
int g_iMolotov_T = 0;
int g_iDeagle_CT = 0;
int g_iDeagle_T = 0;
int g_iAWP_CT = 0;
int g_iAWP_T = 0;
int g_iAWP_CT_Premium = 0;
int g_iAWP_T_Premium = 0;
int g_iScout_CT = 0;
int g_iScout_T = 0;
int g_iRounds_Pistol = 0;
int g_iRounds_Force = 0;

bool g_bChance = true;