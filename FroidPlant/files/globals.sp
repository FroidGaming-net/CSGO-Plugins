enum struct PlayerData
{
    int iFailedToPlant;

    void Reset()
	{
		this.iFailedToPlant = 0;
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];

enum
{
    BOMBSITE_INVALID = -1,
    BOMBSITE_A = 0,
    BOMBSITE_B = 1
}