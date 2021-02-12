public void Database_OnConnect(Database db, const char[] error, any data)
{
    if(db == null)
    {
        PrintToServer("%s Unable to connect to MySQL server. Saving is off!", TAG_NCLR);
        return;
    }

    g_hDatabase = db;
    PrintToServer("%s Connected to the MySQL successfully!", TAG_NCLR);

    Database_CreateTables();
}

public void Database_CreateTables()
{
    g_hDatabase.Query(_Database_DoNothing, "CREATE TABLE IF NOT EXISTS `etweaker_users_2` ( `id` INT UNSIGNED NOT NULL AUTO_INCREMENT , `steamid` VARCHAR(18) NOT NULL ,\
    `knife_ct` INT NOT NULL DEFAULT '-1' , `knife_t` INT NOT NULL DEFAULT '-1' , `gloves_ct_def` INT NOT NULL DEFAULT '-1' , `gloves_ct_skin` INT NOT NULL DEFAULT '-1' ,\
    `gloves_t_def` INT NOT NULL DEFAULT '-1' , `gloves_t_skin` INT NOT NULL DEFAULT '-1' , `music_kit` INT UNSIGNED NOT NULL DEFAULT '0' ,\
    `rare_inspect` BOOLEAN NOT NULL DEFAULT FALSE , `rare_draw` BOOLEAN NOT NULL DEFAULT FALSE , `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,`updated_at` TIMESTAMP NULL,\
    PRIMARY KEY (`id`), UNIQUE `steamid_unique` (`steamid`)) ENGINE = InnoDB;");

    g_hDatabase.Query(_Database_DoNothing, "CREATE TABLE IF NOT EXISTS `etweaker_user_weapons_2`(`fk_user` INT UNSIGNED NOT NULL,`def_index` INT UNSIGNED NOT NULL,`skin_id` INT UNSIGNED NOT NULL DEFAULT 0,\
    `wear` INT UNSIGNED NOT NULL DEFAULT  0,`rarity` INT UNSIGNED NOT NULL DEFAULT 0,`pattern` INT UNSIGNED NOT NULL DEFAULT 0, `nametag` VARCHAR(192) NOT NULL DEFAULT '',\
    `stattrak_kills` INT UNSIGNED NOT NULL DEFAULT 0,`stattrak_enabled` BOOLEAN NOT NULL DEFAULT FALSE, `stickers` VARCHAR(128) NOT NULL DEFAULT '', `rare_inspect` BOOLEAN NOT NULL DEFAULT FALSE,\
    `rare_draw` BOOLEAN NOT NULL DEFAULT FALSE, PRIMARY KEY (`fk_user`, `def_index`),UNIQUE INDEX `UNIQUE1` (`fk_user` ASC, `def_index` ASC, `skin_id` ASC)) ENGINE = InnoDB;");

    g_hDatabase.Query(_Database_DoNothing, "CREATE TABLE IF NOT EXISTS `etweaker_settings` ( `id` INT UNSIGNED NOT NULL AUTO_INCREMENT , `key` VARCHAR(191) NOT NULL , `value` VARCHAR(191) NULL,\
    `type` VARCHAR(64) NOT NULL , PRIMARY KEY (`id`), UNIQUE `unique_key` (`key`)) ENGINE = InnoDB;");

    g_hDatabase.Query(_Database_DoNothing, "INSERT IGNORE INTO `etweaker_settings` (`key`, `value`, `type`) VALUES ('version', '1', 'core');");

    RequestFrame(Frame_CheckVersion);
}

public void Frame_CheckVersion()
{
    Database_CheckVersion();
}

public void _Database_DoNothing(Database db, DBResultSet dbResult, const char[] error, any data)
{
    if(dbResult == null)
    {
        LogError("%s _Database_DoNothing failed \n\n\n%s", TAG_NCLR, error);
    }
}

public void Database_CheckVersion()
{
    if(g_iDatabaseVersion == -1)
    {
        g_hDatabase.Query(_Database_RetrieveVersion, "SELECT value FROM `etweaker_settings` WHERE `key` = 'version' AND type = 'core';");
        return;
    }

    if(g_iDatabaseVersion < 2)
    {
        g_hDatabase.Query(_Database_OnDatabaseUpdated, "ALTER TABLE `etweaker_user_weapons_2` ADD CONSTRAINT `user_weapons` FOREIGN KEY (`fk_user`) REFERENCES `etweaker_users_2`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT;", 2);
        return;
    }

    g_bDatabaseReady = true;
}

public void _Database_OnDatabaseUpdated(Database db, DBResultSet dbResult, const char[] error, any data)
{
    if(dbResult == null)
    {
        LogError("%s _Database_OnDatabaseUpdated failed \n\n\n%s", TAG_NCLR, error);
    }

    g_iDatabaseVersion = data;
    PrintToServer("%s MySQL updated to version: %i", TAG_NCLR, g_iDatabaseVersion);

    char szQuery[128];
    g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE `etweaker_settings` SET `value` = '%i' WHERE `key` = 'version' AND type = 'core';", g_iDatabaseVersion);
    g_hDatabase.Query(_Database_OnVersionUpdated, szQuery);


}

public void _Database_OnVersionUpdated(Database db, DBResultSet dbResult, const char[] error, any data)
{
    if(dbResult == null)
    {
        LogError("%s _Database_OnVersionUpdated failed \n\n\n%s", TAG_NCLR, error);
    }

    Database_CheckVersion();
}

public void _Database_RetrieveVersion(Database db, DBResultSet dbResult, const char[] error, any data)
{
    if(dbResult == null)
    {
        LogError("%s _Database_RetrieveVersion failed \n\n\n%s", TAG_NCLR, error);
    }

    if(!dbResult.FetchRow())
    {
        return;
    }

    g_iDatabaseVersion = dbResult.FetchInt(0);

    Database_CheckVersion();
}

public void Database_OnClientConnect(int client)
{
    if(!g_bDatabaseReady)
    {
        return;
    }

    GetClientAuthId(client, AuthId_SteamID64, ClientInfo[client].SteamID64, sizeof(eClientInfo::SteamID64));
    char szDatabaseQuery[256];

    g_hDatabase.Format(szDatabaseQuery, sizeof(szDatabaseQuery), "INSERT INTO `etweaker_users_2` (`steamid`) VALUES ('%s') ON DUPLICATE KEY UPDATE updated_at = NOW()", ClientInfo[client].SteamID64);
    g_hDatabase.Query(_Database_OnClientConnect, szDatabaseQuery, GetClientUserId(client));
}

public void _Database_OnClientConnect(Database db, DBResultSet dbResult, const char[] error, any data)
{
    int client = GetClientOfUserId(data);

    if(dbResult == null)
    {
        LogError("%s _Database_OnClientConnect failed \n\n\n%s", TAG_NCLR, error);
        return;
    }

    if(!IsValidClient(client))
    {
        return;
    }

    char szQuery[128];

    g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM `etweaker_users_2` WHERE `steamid` = '%s'", ClientInfo[client].SteamID64);
    g_hDatabase.Query(_Database_OnClientInfoFetched, szQuery, GetClientUserId(client));
}

public void _Database_OnClientInfoFetched(Database db, DBResultSet dbResult, const char[] error, any data)
{
    int client = GetClientOfUserId(data);

    if(dbResult == null)
    {
        LogError("%s _Database_OnClientInfoFetched failed \n\n\n%s", TAG_NCLR, error);
        return;
    }

    if(!IsValidClient(client))
    {
        return;
    }

    if(!dbResult.FetchRow())
    {
        return;
    }

    int iKey;
    int iKnifeCT;
    int iKnifeT;
    int iGlovesCTdef;
    int iGlovesCTskin;
    int iGlovesTdef;
    int iGlovesTskin;
    int iMusickit;
    int iRareInspectGlobal;
    int iRareDrawGlobal;
    dbResult.FieldNameToNum("id", iKey);
    dbResult.FieldNameToNum("knife_ct", iKnifeCT);
    dbResult.FieldNameToNum("knife_t", iKnifeT);
    dbResult.FieldNameToNum("gloves_ct_def", iGlovesCTdef);
    dbResult.FieldNameToNum("gloves_ct_skin", iGlovesCTskin);
    dbResult.FieldNameToNum("gloves_t_def", iGlovesTdef);
    dbResult.FieldNameToNum("gloves_t_skin", iGlovesTskin);
    dbResult.FieldNameToNum("music_kit", iMusickit);
    dbResult.FieldNameToNum("rare_inspect", iRareInspectGlobal);
    dbResult.FieldNameToNum("rare_draw", iRareDrawGlobal);

    ClientInfo[client].Key = dbResult.FetchInt(iKey);
    ClientInfo[client].Knife.CT = dbResult.FetchInt(iKnifeCT);
    ClientInfo[client].Knife.T = dbResult.FetchInt(iKnifeT);

    ClientInfo[client].GlovesCT.GloveDefIndex = dbResult.FetchInt(iGlovesCTdef);
    ClientInfo[client].GlovesCT.SkinDefIndex = dbResult.FetchInt(iGlovesCTskin);
    ClientInfo[client].GlovesT.GloveDefIndex = dbResult.FetchInt(iGlovesTdef);
    ClientInfo[client].GlovesT.SkinDefIndex = dbResult.FetchInt(iGlovesTskin);

    ClientInfo[client].MusicKit = dbResult.FetchInt(iMusickit);

    ClientInfo[client].RareInspect = view_as<bool>(dbResult.FetchInt(iRareInspectGlobal));
    ClientInfo[client].RareDraw = view_as<bool>(dbResult.FetchInt(iRareDrawGlobal));


    char szQuery[128];

    g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM `etweaker_user_weapons_2` WHERE `fk_user` = '%i'", ClientInfo[client].Key);
    g_hDatabase.Query(_Database_OnClientWeaponSettingsFetched, szQuery, GetClientUserId(client));
}


public void _Database_OnClientWeaponSettingsFetched(Database db, DBResultSet dbResult, const char[] error, any data)
{
    int client = GetClientOfUserId(data);

    if(dbResult == null)
    {
        LogError("%s _Database_OnClientWeaponSettingsFetched failed \n\n\n%s", TAG_NCLR, error);
        return;
    }

    if(!IsValidClient(client))
    {
        return;
    }

    if(dbResult.RowCount == 0)
    {
        return;
    }

    int iWeaponDef;
    int iPaintKit;
    int iWear;
    int iRarity;
    int iPattern;
    int iNametag;
    int iStatTrak_Kills;
    int iStatTrak_Enabled;
    int iStickers;
    int iRareInspect;
    int iRareDraw;
    dbResult.FieldNameToNum("def_index", iWeaponDef);
    dbResult.FieldNameToNum("skin_id", iPaintKit);
    dbResult.FieldNameToNum("wear", iWear);
    dbResult.FieldNameToNum("rarity", iRarity);
    dbResult.FieldNameToNum("pattern", iPattern);
    dbResult.FieldNameToNum("nametag", iNametag);
    dbResult.FieldNameToNum("stattrak_kills", iStatTrak_Kills);
    dbResult.FieldNameToNum("stattrak_enabled", iStatTrak_Enabled);
    dbResult.FieldNameToNum("stickers", iStickers);
    dbResult.FieldNameToNum("rare_inspect", iRareInspect);
    dbResult.FieldNameToNum("rare_draw", iRareDraw);

    while(dbResult.FetchRow())
    {
        int iWeaponDefIndex = dbResult.FetchInt(iWeaponDef);
        char szWeaponDefIndex[12];
        char szStickers[128];
        char szStickersEx[6][10];
        IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

        eWeaponSettings WeaponSettings;
        WeaponSettings.PaintKit = dbResult.FetchInt(iPaintKit);
        WeaponSettings.Rarity = dbResult.FetchInt(iRarity);
        WeaponSettings.Wear = dbResult.FetchInt(iWear);
        dbResult.FetchString(iNametag, WeaponSettings.Nametag, sizeof(eWeaponSettings::Nametag));
        WeaponSettings.Pattern = dbResult.FetchInt(iPattern);
        WeaponSettings.RareInspect = view_as<bool>(dbResult.FetchInt(iRareInspect));
        WeaponSettings.RareDraw = view_as<bool>(dbResult.FetchInt(iRareDraw));
        WeaponSettings.StatTrak_Enabled = view_as<bool>(dbResult.FetchInt(iStatTrak_Enabled));
        WeaponSettings.StatTrak_Kills = dbResult.FetchInt(iStatTrak_Kills);

        dbResult.FetchString(iStickers, szStickers, sizeof(szStickers));
        ExplodeString(szStickers, ";", szStickersEx, sizeof(szStickersEx), sizeof(szStickersEx[]));

        for(int index = 0; index <= 5; index++)
        {
            WeaponSettings.Sticker[index] = StringToInt(szStickersEx[index]);
        }

        g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
    }
}

public void Databse_SaveClientData(int client)
{
    if(!g_bDatabaseReady)
    {
        return;
    }

    char szQuery[1024];

    g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE `etweaker_users_2` SET `knife_ct` = '%i', `knife_t` = '%i', `gloves_ct_def` = '%i', `gloves_ct_skin` = '%i', `gloves_t_def` = '%i',\
     `gloves_t_skin` = '%i', `music_kit` = '%i', `rare_inspect` = '%i', `rare_draw` = '%i' WHERE `id` = '%i'",\
    ClientInfo[client].Knife.CT, ClientInfo[client].Knife.T, ClientInfo[client].GlovesCT.GloveDefIndex, ClientInfo[client].GlovesCT.SkinDefIndex, ClientInfo[client].GlovesT.GloveDefIndex,\
     ClientInfo[client].GlovesT.SkinDefIndex, ClientInfo[client].MusicKit, view_as<int>(ClientInfo[client].RareInspect), view_as<int>(ClientInfo[client].RareDraw), ClientInfo[client].Key);

    g_hDatabase.Query(_Database_OnClientDataSaved, szQuery);


    if(!eTweaker_AreDataSynced())
    {
        return;
    }

    char szWeaponDefIndex[12];
    for(int iWeaponNum = 0; iWeaponNum < eTweaker_GetWeaponCount(); iWeaponNum++)
    {
        int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
        IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

        eWeaponSettings WeaponSettings;
        g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

        if(!WeaponSettings.Changed)
        {
            continue;
        }

        char szStickers[192];
        Format(szStickers, sizeof(szStickers), "%i;%i;%i;%i;%i;%i", WeaponSettings.Sticker[0], WeaponSettings.Sticker[1], WeaponSettings.Sticker[2], WeaponSettings.Sticker[3], WeaponSettings.Sticker[4],\
         WeaponSettings.Sticker[5]);

        g_hDatabase.Format(szQuery, sizeof(szQuery), "INSERT INTO `etweaker_user_weapons_2` (`fk_user`, `def_index`, `skin_id`, `wear`, `rarity`, `pattern`, `nametag`,\
         `stattrak_kills`, `stattrak_enabled`, `stickers`, `rare_inspect`, `rare_draw`) VALUES ('%i', '%i', '%i', '%i', '%i', '%i', '%s', '%i', '%i', '%s', '%i', '%i')\
          ON DUPLICATE KEY UPDATE `fk_user` = '%i', `def_index` = '%i', `skin_id` = '%i', `wear` = '%i', `rarity` = '%i', `pattern` = '%i', `nametag` = '%s',\
           `stattrak_kills` = '%i', `stattrak_enabled` = '%i', `stickers` = '%s', `rare_inspect` = '%i', `rare_draw` = '%i'",\
           ClientInfo[client].Key, iWeaponDefIndex, WeaponSettings.PaintKit, WeaponSettings.Wear, WeaponSettings.Rarity, WeaponSettings.Pattern, WeaponSettings.Nametag,\
            WeaponSettings.StatTrak_Kills, view_as<int>(WeaponSettings.StatTrak_Enabled), szStickers, view_as<int>(WeaponSettings.RareInspect), view_as<int>(WeaponSettings.RareDraw),\
             ClientInfo[client].Key, iWeaponDefIndex, WeaponSettings.PaintKit, WeaponSettings.Wear, WeaponSettings.Rarity, WeaponSettings.Pattern, WeaponSettings.Nametag,\
            WeaponSettings.StatTrak_Kills, view_as<int>(WeaponSettings.StatTrak_Enabled), szStickers, view_as<int>(WeaponSettings.RareInspect), view_as<int>(WeaponSettings.RareDraw));

        g_hDatabase.Query(_Database_OnClientWeaponSettingsSaved ,szQuery);
    }
}

public void _Database_OnClientDataSaved(Database db, DBResultSet dbResult, const char[] error, any data)
{
    if(dbResult == null)
    {
        LogError("%s _Database_OnClientDataSaved failed \n\n\n%s", TAG_NCLR, error);
        return;
    }
}

public void _Database_OnClientWeaponSettingsSaved(Database db, DBResultSet dbResult, const char[] error, any data)
{
    if(dbResult == null)
    {
        LogError("%s _Database_OnClientWeaponSettingsSaved failed \n\n\n%s", TAG_NCLR, error);
        return;
    }
}