public void Database_OnConnect(Database db, const char[] error, any data)
{
    if(db == null)
    {
        PrintToServer("%s Unable to connect to MySQL server. Saving is off!", PREFIX_CONSOLE);
        return;
    }

    g_hDatabase = db;
    PrintToServer("%s Connected to the MySQL successfully!", PREFIX_CONSOLE);

    g_bDatabaseReady = true;
}

public void Database_OnClientConnect(int iClient)
{
    if(!g_bDatabaseReady)
    {
        return;
    }

    GetClientAuthId(iClient, AuthId_SteamID64, ClientInfo[iClient].SteamID64, sizeof(eClientInfo::SteamID64));
    char sDatabaseQuery[256];

    g_hDatabase.Format(sDatabaseQuery, sizeof(sDatabaseQuery), "INSERT INTO `froid_players` (`steamid`) VALUES ('%s') ON DUPLICATE KEY UPDATE updated_at = NOW()", ClientInfo[iClient].SteamID64);
    g_hDatabase.Query(_Database_OnClientConnect, sDatabaseQuery, GetClientUserId(iClient));
}

public void _Database_OnClientConnect(Database db, DBResultSet dbResult, const char[] error, any data)
{
    int iClient = GetClientOfUserId(data);

    if(dbResult == null)
    {
        LogError("%s _Database_OnClientConnect failed \n\n\n%s", PREFIX_CONSOLE, error);
        return;
    }

    if(!IsValidClient(iClient))
    {
        return;
    }

    char sQuery[128];
    g_hDatabase.Format(sQuery, sizeof(sQuery), "SELECT * FROM `froid_players` WHERE `steamid` = '%s'", ClientInfo[iClient].SteamID64);
    g_hDatabase.Query(_Database_OnClientInfoFetched, sQuery, GetClientUserId(iClient));
}

public void _Database_OnClientInfoFetched(Database db, DBResultSet dbResult, const char[] error, any data)
{
    int iClient = GetClientOfUserId(data);

    if(dbResult == null)
    {
        LogError("%s _Database_OnClientInfoFetched failed \n\n\n%s", PREFIX_CONSOLE, error);
        return;
    }

    if(!IsValidClient(iClient))
    {
        return;
    }

    if(!dbResult.FetchRow())
    {
        return;
    }

    int iKey;
    dbResult.FieldNameToNum("id", iKey);

    ClientInfo[iClient].Key = dbResult.FetchInt(iKey);

    char sQuery[128];
    g_hDatabase.Format(sQuery, sizeof(sQuery), "SELECT * FROM `froid_player_weapons` WHERE `fk_user` = '%i'", ClientInfo[iClient].Key);
    g_hDatabase.Query(_Database_OnClientWeaponSettingsFetched, sQuery, GetClientUserId(iClient));
}

public void _Database_OnClientWeaponSettingsFetched(Database db, DBResultSet dbResult, const char[] error, any data)
{
    int iClient = GetClientOfUserId(data);

    if(dbResult == null)
    {
        LogError("%s _Database_OnClientWeaponSettingsFetched failed \n\n\n%s", PREFIX_CONSOLE, error);
        return;
    }

    if(!IsValidClient(iClient))
    {
        return;
    }

    if(dbResult.RowCount == 0)
    {
        return;
    }

    int iWeaponDef;
    int iStickers;
    dbResult.FieldNameToNum("def_index", iWeaponDef);
    dbResult.FieldNameToNum("stickers", iStickers);

    while(dbResult.FetchRow())
    {
        int iWeaponDefIndex = dbResult.FetchInt(iWeaponDef);
        char sWeaponDefIndex[12];
        IntToString(iWeaponDefIndex, sWeaponDefIndex, sizeof(sWeaponDefIndex));

        eWeaponSettings WeaponSettings;

        g_smWeaponSettings[iClient].SetArray(sWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
    }
}

public void Database_SaveClientData(int iClient)
{
    if(!g_bDatabaseReady)
    {
        return;
    }

    if(!FroidStickers_AreDataSynced())
    {
        return;
    }

    char sQuery[1024];
    char sWeaponDefIndex[12];
    for(int iWeaponNum = 0; iWeaponNum < FroidStickers_GetWeaponCount(); iWeaponNum++)
    {
        int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
        IntToString(iWeaponDefIndex, sWeaponDefIndex, sizeof(sWeaponDefIndex));

        eWeaponSettings WeaponSettings;
        g_smWeaponSettings[iClient].GetArray(sWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

        if(!WeaponSettings.Changed)
        {
            continue;
        }

        char sStickers[192];
        Format(sStickers, sizeof(sStickers), "%i;%i;%i;%i;%i;%i", WeaponSettings.Sticker[0], WeaponSettings.Sticker[1], WeaponSettings.Sticker[2], WeaponSettings.Sticker[3], WeaponSettings.Sticker[4], WeaponSettings.Sticker[5]);

        g_hDatabase.Format(sQuery, sizeof(sQuery), "INSERT INTO `froid_player_weapons` (`fk_user`, `def_index`, `stickers`) VALUES ('%i', '%i', '%s') ON DUPLICATE KEY UPDATE `fk_user` = '%i', `def_index` = '%i', `stickers` = '%s'", ClientInfo[iClient].Key, iWeaponDefIndex, sStickers, ClientInfo[iClient].Key, iWeaponDefIndex, sStickers);

        g_hDatabase.Query(_Database_OnClientWeaponSettingsSaved ,sQuery);
    }
}

public void _Database_OnClientWeaponSettingsSaved(Database db, DBResultSet dbResult, const char[] error, any data)
{
    if(dbResult == null)
    {
        LogError("%s _Database_OnClientWeaponSettingsSaved failed \n\n\n%s", PREFIX_CONSOLE, error);
        return;
    }
}