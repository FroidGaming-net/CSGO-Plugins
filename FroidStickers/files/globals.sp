bool g_bLateLoaded;
bool g_bDataSynced = false;
bool g_bFirstSynced = false;

int g_iWeaponsCount;
int g_iPatchesCount;
int g_iStickersSetsCount;
int g_iStickersCount;

Database g_hDatabase = null;
bool g_bDatabaseReady = false;

enum struct eClientInfo
{
    int edict;
    int Key;
    int WeaponStoredDefIndex;
    char SteamID64[18];

    bool Reset()
    {
        this.Key = -1;
        this.WeaponStoredDefIndex = -1;
        strcopy(this.SteamID64, sizeof(eClientInfo::SteamID64), "");
    }
}

eClientInfo ClientInfo[MAXPLAYERS +1];

enum struct eWeaponSettings
{
    bool Changed;
    int Sticker[6];

    bool Reset()
    {
        this.Changed = false;
        this.Sticker[0] = 0;
        this.Sticker[1] = 0;
        this.Sticker[2] = 0;
        this.Sticker[3] = 0;
        this.Sticker[4] = 0;
        this.Sticker[5] = 0;
    }

    int Team()
    {
        return GetClientTeam(this.edict);
    }
}

StringMap g_smWeaponSettings[MAXPLAYERS +1] = {null, ...};