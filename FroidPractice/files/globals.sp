enum struct PlayerData
{
    bool bNoFlash;

    void Reset()
    {
        this.bNoFlash = false;
    }
}

PlayerData g_PlayerData[MAXPLAYERS + 1];