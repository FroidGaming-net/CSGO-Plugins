bool g_bLateLoaded;
bool g_bDataSynced = false;
bool g_bFirstSynced = false;
bool g_bFirstRound = false;

int g_iWeaponsCount;
int g_iPaintsCount;
int g_iGlovesCount;
int g_iMusicKitsCount;
int g_iStickersSetsCount;
int g_iStickersCount;

Handle g_hGiveWearableCall;
Handle g_hRemoveWearableCall;

Database g_hDatabase = null;
int g_iDatabaseVersion = -1;
bool g_bDatabaseReady = false;

int g_iNameTagOffset;

ArrayList g_arMapWeapons = null;


ConVar g_cvDrawAnimation;
ConVar g_cvDangerZoneKnives;
ConVar g_cvSelectTeamMode;
ConVar g_cvForceFullUpdate;

char g_szWeaponRarities[][] =
{
    "Normal",
    "Genuine",
    "Vintage",
    "Unusual",
    "",
    "Community",
    "Valve",
    "Prototype",
    "Customized",
    "StatTrak™",
    "Completed",
    "",
    "Souvenir"
};

float g_fWeaponWear[] =
{
    0.0,
    0.05,
    0.14,
    0.37,
    0.44,
    0.8
};

char g_szWeaponWear[][] =
{
    "Default",
    "Factory New",
    "Minimal Wear",
    "Field-Tested",
    "Well-Worn",
    "Battle-Scarred"
};

char g_szPatternSubtraction[][] =
{
    "✘",
    "✔"
};

char g_szWeaponPattern[][] =
{
    "Reset",
    "1",
    "10",
    "100",
    "1000"
};

#define DEFAULT_KNIFE   41
#define DEFAULT_KNIFE2  42
#define DEFAULT_KNIFE3  74
#define DEFAULT_KNIFE_T 59
#define GHOST_KNIFE     80

#define KNIFE_BAYONET 500

#define SWITCH_ALLWEAPONS 0
#define SWITCH_CURRENTWEAPON 1
#define SWITCH_TWEAKS_CURRENTMAIN 2
#define SWITCH_TWEAKS_CURRENT_STICKERS_MAIN 3
#define SWITCH_TWEAKS_CURRENT_STATTRAK 4
#define SWITCH_TWEAKS_CURRENT_RARITIES 5
#define SWITCH_TWEAKS_CURRENT_WEAR 6
#define SWITCH_TWEAKS_CURRENT_PATTERN 7
#define SWITCH_TWEAKS_CURRENT_NAMETAG 8


enum struct eKnife
{
    int CT;
    int T;

    bool Reset()
    {
        this.CT = -1;
        this.T = -1;
    }
}

enum struct eGloves
{
    int GloveDefIndex;
    int SkinDefIndex;

    bool Reset()
    {
        this.GloveDefIndex = -1;
        this.SkinDefIndex = -1;
    }
}
enum struct eClientInfo
{
    int edict;
    int Key;
    eKnife Knife;
    eGloves GlovesCT;
    eGloves GlovesT;
    int MusicKit;
    int ActiveCoin;
    bool RareInspect;
    bool RareDraw;
    int WeaponSwitch;
    bool PatternSubtraction;
    bool ChangingNametag;
    bool ChangingNametagCurrent;
    int WeaponStoredDefIndex;
    int PreviousWeapon;
    int GlovesStoredDefIndex;
    int CoinSetStoredId;
    int GlovesEntReference;
    int MenuSelection;
    int MenuCategorySelection;
    int StickerSlotStored;
    int StickerSetStored;
    char StoredSkinName[48];
    char SteamID64[18];

    bool Reset()
    {
        this.Knife.Reset();
        this.Key = -1;
        this.GlovesCT.Reset();
        this.GlovesT.Reset();
        this.MusicKit = 0;
        this.ActiveCoin = 0;
        this.RareInspect = false;
        this.RareDraw = false;
        this.WeaponSwitch = -1;
        this.PatternSubtraction = false;
        this.ChangingNametag = false;
        this.ChangingNametagCurrent = false;
        this.WeaponStoredDefIndex = -1;
        this.PreviousWeapon = INVALID_ENT_REFERENCE;
        this.GlovesStoredDefIndex = -1;
        this.CoinSetStoredId = -1;
        this.StickerSlotStored = -1;
        this.StickerSetStored = -1;
        this.GlovesEntReference = INVALID_ENT_REFERENCE;
        this.MenuSelection = -1;
        this.MenuCategorySelection = -1;
        strcopy(this.StoredSkinName, sizeof(eClientInfo::StoredSkinName), "");
        strcopy(this.SteamID64, sizeof(eClientInfo::SteamID64), "");
    }

    bool Alive()
    {
        return IsPlayerAlive(this.edict);
    }

    int Team()
    {
        return GetClientTeam(this.edict);
    }

}

eClientInfo ClientInfo[MAXPLAYERS +1];

enum struct eWeaponSettings
{
    bool Changed;
    int PaintKit;
    int Rarity;
    int Wear;
    int Pattern;
    bool RareInspect;
    bool RareDraw;
    char Nametag[192];
    bool StatTrak_Enabled;
    int StatTrak_Kills;
    int Sticker[6];

    bool Reset()
    {
        this.Changed = false;
        this.PaintKit = 0;
        this.Rarity = 0;
        this.Wear = 0;
        this.Nametag = "";
        this.Pattern = 0;
        this.RareInspect = false;
        this.RareDraw = false;
        this.StatTrak_Enabled = false;
        this.StatTrak_Kills = 0;
        this.Sticker[0] = 0;
        this.Sticker[1] = 0;
        this.Sticker[2] = 0;
        this.Sticker[3] = 0;
        this.Sticker[4] = 0;
        this.Sticker[5] = 0;
    }
}

StringMap g_smWeaponSettings[MAXPLAYERS +1] = {null, ...};