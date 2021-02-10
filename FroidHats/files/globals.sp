HTTPClient httpClient;

#define HIDE_CROSSHAIR_CSGO 1<<8
#define HIDE_RADAR_CSGO 1<<12

enum struct PlayerData
{
    int iHatLoaded;
    int iHatNumber;
    int iHat;
    bool bViewing;
    char sCountryCode[3];

    void Reset()
	{
		this.iHatLoaded = 0;
		this.iHatNumber = 0;
        this.iHat = INVALID_ENT_REFERENCE;
		this.bViewing = false;
        this.sCountryCode = "EN";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];

Handle hTimers[MAXPLAYERS+1];
Handle hSetModel, mp_forcecamera; 