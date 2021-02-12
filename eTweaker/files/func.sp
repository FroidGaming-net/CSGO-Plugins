public void eTweaker_UpdateClientWeapon(int client, int iWeapon)
{
    if(!IsValidClient(client, true))
    {
        return;
    }

    if(!eItems_IsValidWeapon(iWeapon))
    {
        return;
    }

    int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeapon(iWeapon);

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    if(!g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings)))
    {
        return;
    }

    if(!eItems_IsDefIndexKnife(iWeaponDefIndex))
    {
        int iWeaponStickerSlots = eItems_GetWeaponStickersSlotsByDefIndex(iWeaponDefIndex);

        for(int iStickerSlot = 0; iStickerSlot < iWeaponStickerSlots; iStickerSlot++)
        {
            if(WeaponSettings.Sticker[iStickerSlot] == 0)
            {
                continue;
            }
            eTweaker_AddAttribute(iWeapon, 113, iStickerSlot, WeaponSettings.Sticker[iStickerSlot]);
            eTweaker_AddAttribute(iWeapon, 114, iStickerSlot, 0.0000001);
        }
    }

    SetEntProp(iWeapon, Prop_Send, "m_iAccountID", GetSteamAccountID(client));
    SetEntProp(iWeapon, Prop_Send, "m_iItemIDLow", -1);
    static int IDHigh = 16384;
    SetEntProp(iWeapon, Prop_Send, "m_iItemIDHigh", IDHigh++);

    if(WeaponSettings.PaintKit > 0)
    {
        SetEntProp(iWeapon, Prop_Send, "m_nFallbackPaintKit", WeaponSettings.PaintKit);
    }

    if(WeaponSettings.Rarity > 0)
    {
        SetEntProp(iWeapon, Prop_Send, "m_iEntityQuality", WeaponSettings.Rarity);
    }

    if(WeaponSettings.Wear > 0)
    {
        SetEntPropFloat(iWeapon, Prop_Send, "m_flFallbackWear", g_fWeaponWear[WeaponSettings.Wear]);
    }

    if(WeaponSettings.Pattern > 0)
    {
        SetEntProp(iWeapon, Prop_Send, "m_nFallbackSeed", WeaponSettings.Pattern);
    }

    if(WeaponSettings.StatTrak_Enabled)
    {
        SetEntProp(iWeapon, Prop_Send, "m_nFallbackStatTrak", WeaponSettings.StatTrak_Kills);
    }

    if(strlen(WeaponSettings.Nametag) > 0)
    {
        SetEntDataString(iWeapon, g_iNameTagOffset, WeaponSettings.Nametag, sizeof(eWeaponSettings::Nametag));
    }
}

stock void eTweaker_AddAttribute(int entity, const int Attribute_Id, const int Attribute_Slot, const any value)
{
    CEconItemView pItemView = PTaH_GetEconItemViewFromEconEntity(entity);
    CAttributeList pAttributeList = pItemView.NetworkedDynamicAttributesForDemos;
    pAttributeList.SetOrAddAttributeValue(Attribute_Id + Attribute_Slot * 4, value);
}

stock bool eTweaker_IsControllingBot(int client)
{
    return view_as<bool>(GetEntProp(client, Prop_Send, "m_bIsControllingBot"));
}

stock bool eTweaker_AreDataSynced()
{
    return g_bDataSynced;
}

stock int eTweaker_GetWeaponCount()
{
    return g_iWeaponsCount;
}

stock int eTweaker_GetSkinsCount()
{
    return g_iPaintsCount;
}

stock int eTweaker_GetGlovesCount()
{
    return g_iGlovesCount;
}

stock int eTweaker_GetMusicKitsCount()
{
    return g_iMusicKitsCount;
}

stock int eTweaker_GetPinsCount()
{
    return g_iPinsCount;
}

stock int eTweaker_GetCoinsSetsCount()
{
    return g_iCoinsSetsCount;
}

stock int eTweaker_GetCoinsCount()
{
    return g_iCoinsCount;
}

stock int eTweaker_GetStickersSetsCount()
{
    return g_iStickersSetsCount;
}

stock int eTweaker_GetStickersCount()
{
    return g_iStickersCount;
}

stock void eTweaker_PrintDataNotSynced(int client)
{
    if(g_bFirstSynced == false) {
        if(eItems_AreItemsSynced())
        {
            eItems_OnItemsSynced();
        }
        else if(!eItems_AreItemsSyncing())
        {
            eItems_ReSync();
        }

        g_bFirstSynced = true;
    }
    CPrintToChat(client, "%s Data not \x07synced\x01. Feature not available!", PREFIX);
}

stock void eTweaker_PrintNotAvailableInSpec(int client)
{
    CPrintToChat(client, "%s This function is not available while spectating!", PREFIX);
}

stock void eTweaker_PrintNotAvailableWhileControllingBot(int client)
{
    CPrintToChat(client, "%s This function is not available while controlling bot!", PREFIX);
}

stock void eTweaker_PrintOnlyForAlivePlayers(int client)
{
    CPrintToChat(client, "%s This function is available only for alive players!", PREFIX);
}

stock bool eTweaker_IsKnifeForbidden(int iDefIndex)
{
	return (iDefIndex == DEFAULT_KNIFE || iDefIndex == DEFAULT_KNIFE2 || iDefIndex == DEFAULT_KNIFE3 || iDefIndex == DEFAULT_KNIFE_T || iDefIndex == GHOST_KNIFE);
}

stock bool eTweaker_IsDangerZoneKnife(int iKnifeDefIndex)
{
    switch(iKnifeDefIndex)
    {
        case 69: return true; // Bare Hands
        case 75: return true; // Axe
        case 76: return true; // Hammer
        case 78: return true; // Wrench
        default: return false;
    }
}

stock void eTweaker_EquipKnife(int client)
{

    int iKnifeDefIndex = eTwekaer_GetClientTeamKnife(client);
    char szClassName[48];

    switch(iKnifeDefIndex)
    {
        case -1: FormatEx(szClassName, sizeof(szClassName), "%s", ClientInfo[client].Team() == CS_TEAM_T ? "weapon_knife_t" : "weapon_knife");
        default: eItems_GetWeaponClassNameByDefIndex(iKnifeDefIndex, szClassName, sizeof(szClassName));
    }

    if(!IsPlayerAlive(client))
    {
        return;
    }

    eItems_RemoveKnife(client);
    PTaH_GivePlayerItem(client, szClassName);
}

stock int eTweaker_FindKnifeDefIndexByName(const char[] szKnifeName)
{
    int iFound = 0;
    int iFoundKnife;
    char szKnifeDisplayName[48];
    for(int iKnifeNumm = 0; iKnifeNumm < eTweaker_GetWeaponCount(); iKnifeNumm++)
    {
        int iKnifeDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iKnifeNumm);

        if(!eItems_IsDefIndexKnife(iKnifeDefIndex))
        {
            continue;
        }

        if(eTweaker_IsKnifeForbidden(iKnifeDefIndex))
        {
            continue;
        }

        eItems_GetWeaponDisplayNameByDefIndex(iKnifeDefIndex, szKnifeDisplayName, sizeof(szKnifeDisplayName));

        if(StrContains(szKnifeDisplayName, szKnifeName, false) != -1)
        {
            iFoundKnife = iKnifeDefIndex;
            iFound++;
        }
    }

    if(iFound == 0)
    {
        return 0;
    }
    else if(iFound > 1)
    {
        return -1;
    }

    return iFoundKnife;
}

stock void eTweaker_ChangeWeaponNametag(int client, int iWeaponDefIndex, const char[] szNametag)
{
    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
    strcopy(WeaponSettings.Nametag, sizeof(eWeaponSettings::Nametag), szNametag);
    WeaponSettings.Changed = true;
    g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    int iWeapon = eItems_FindWeaponByDefIndex(client, iWeaponDefIndex);

    if(eItems_IsDefIndexKnife(iWeaponDefIndex))
    {
        if(iWeapon > 0)
        {
            eTweaker_EquipKnife(client);
        }
    }else{
        if(iWeapon > 0)
        {
            eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
        }
    }

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    if(strlen(szNametag) > 0)
    {
        CPrintToChat(client, "%s You have changed nametag to \x06%s\x01 for \x06%s\x01", PREFIX, szNametag, szWeaponDisplayName);
    }
    else
    {
        CPrintToChat(client, "%s You have \x07removed\x01 nametag from \x06%s\x01",PREFIX, szWeaponDisplayName);
    }
}

stock int eTweaker_FindWeaponSkinDefIndexByName(int iWeaponDefIndex, const char[] szSkinName)
{
    int iFound = 0;
    int iFoundSkin;

    int iWeaponNum = eItems_GetWeaponNumByDefIndex(iWeaponDefIndex);
    char szFoundSkinName[48];

    for(int iSkinNum = 0; iSkinNum < eTweaker_GetSkinsCount(); iSkinNum++)
    {
        if(!eItems_IsNativeSkin(iSkinNum, iWeaponNum, ITEMTYPE_WEAPON))
        {
            continue;
        }

        eItems_GetSkinDisplayNameBySkinNum(iSkinNum, szFoundSkinName, sizeof(szFoundSkinName));
        if(StrContains(szFoundSkinName, szSkinName, false) != -1)
        {
            iFoundSkin = eItems_GetSkinDefIndexBySkinNum(iSkinNum);
            iFound++;
        }
    }

    if(iFound == 0)
    {
        return 0;
    }
    else if(iFound > 1)
    {
        return -1;
    }

    return iFoundSkin;
}

stock int eTweaker_FindSkinDefIndexByName(const char[] szSkinName)
{
    int iFound = 0;
    int iFoundSkin;
    char szFoundSkinName[48];

    for(int iSkinNum = 0; iSkinNum < eTweaker_GetSkinsCount(); iSkinNum++)
    {

        eItems_GetSkinDisplayNameBySkinNum(iSkinNum, szFoundSkinName, sizeof(szFoundSkinName));
        if(StrContains(szFoundSkinName, szSkinName, false) != -1)
        {
            iFoundSkin = eItems_GetSkinDefIndexBySkinNum(iSkinNum);
            iFound++;
        }
    }
    if(iFound == 0)
    {
        return 0;
    }
    else if(iFound > 1)
    {
        return -1;
    }
    return iFoundSkin;
}

stock int eTwekaer_GetClientTeamKnife(int client)
{
    switch(GetClientTeam(client))
    {
        case CS_TEAM_CT:    return ClientInfo[client].Knife.CT;
        case CS_TEAM_T:     return ClientInfo[client].Knife.T;
    }
    return -1;
}

stock bool eTwekaer_SetClientTeamKnife(int client, int iKnifeDefIndex, int Team = 0)
{
    char szDisplayName[48];
    char szTeam[32];

    if(Team == 0)
    {
        Team = GetClientTeam(client);
    }
    switch(Team)
    {
        case -1:
        {
            ClientInfo[client].Knife.CT = iKnifeDefIndex;
            ClientInfo[client].Knife.T = iKnifeDefIndex;
            strcopy(szTeam, sizeof(szTeam), "\x03both \x01teams");
        }
        case CS_TEAM_CT:
        {
            ClientInfo[client].Knife.CT = iKnifeDefIndex;
            strcopy(szTeam, sizeof(szTeam), "\x0BCT \x01team");
        }
        case CS_TEAM_T:
        {
            ClientInfo[client].Knife.T = iKnifeDefIndex;
            strcopy(szTeam, sizeof(szTeam), "\x10T \x01team");
        }
    }

    if(!eItems_GetWeaponDisplayNameByDefIndex(iKnifeDefIndex, szDisplayName, sizeof(szDisplayName)))
    {
        strcopy(szDisplayName, sizeof(szDisplayName), "Default");
    }

    CPrintToChat(client, "%s You have selected \x06%s\x01 for %s.", PREFIX, szDisplayName, szTeam);
}

stock bool eTweaker_IsClientSpectating(int client)
{
    return ClientInfo[client].Team() == CS_TEAM_SPECTATOR;
}

stock void eTwekaer_SetClientTeamGloves(int client, int iGlovesDefIndex, int iSkinDefIndex, int Team)
{
    char szTeam[32];
    char szGlovesDisplayName[48];
    char szSkinDisplayName[48];

    switch(Team)
    {
        case -1:
        {
            ClientInfo[client].GlovesCT.GloveDefIndex = iGlovesDefIndex;
            ClientInfo[client].GlovesCT.SkinDefIndex = iSkinDefIndex;

            ClientInfo[client].GlovesT.GloveDefIndex = iGlovesDefIndex;
            ClientInfo[client].GlovesT.SkinDefIndex = iSkinDefIndex;
            strcopy(szTeam, sizeof(szTeam), "\x03both \x01teams");
        }
        case CS_TEAM_CT:
        {
            ClientInfo[client].GlovesCT.GloveDefIndex = iGlovesDefIndex;
            ClientInfo[client].GlovesCT.SkinDefIndex = iSkinDefIndex;
            strcopy(szTeam, sizeof(szTeam), "\x0BCT \x01team");
        }
        case CS_TEAM_T:
        {
            ClientInfo[client].GlovesT.GloveDefIndex = iGlovesDefIndex;
            ClientInfo[client].GlovesT.SkinDefIndex = iSkinDefIndex;
            strcopy(szTeam, sizeof(szTeam), "\x10T \x01team");
        }
    }


    if(iSkinDefIndex == -1)
    {
        CPrintToChat(client, "%s You have \x06removed gloves\x01 for %s.", PREFIX, szTeam);
    }
    else
    {
        eItems_GetGlovesDisplayNameByDefIndex(iGlovesDefIndex, szGlovesDisplayName, sizeof(szGlovesDisplayName));
        eItems_GetSkinDisplayNameByDefIndex(iSkinDefIndex, szSkinDisplayName, sizeof(szSkinDisplayName));
        CPrintToChat(client, "%s You have selected \x06%s (%s)\x01 for %s.", PREFIX, szGlovesDisplayName, szSkinDisplayName, szTeam);
    }
    return;
}

stock void eTweaker_AttachGloveSkin(int client, int iGlovesDefIndex, int iSkinDefIndex, int iGlovesWear)
{
    eTweaker_RemoveClientGloves(client);

    int iGloves = CreateEntityByName("wearable_item");
    if(iGloves != -1 && iGlovesDefIndex != -1 && iSkinDefIndex != -1)
    {
        char szGloveWorldModel[PLATFORM_MAX_PATH];
        eItems_GetGlovesWorldModelByDefIndex(iGlovesDefIndex, szGloveWorldModel, sizeof(szGloveWorldModel));
        int iGloveModelIndex = PrecacheModel(szGloveWorldModel, true);

        SetEntProp(iGloves, Prop_Send, "m_bInitialized", 1);
        SetEntProp(iGloves, Prop_Send, "m_iItemDefinitionIndex", iGlovesDefIndex);
        SetEntProp(iGloves, Prop_Send, "m_iAccountID", GetSteamAccountID(client));
        SetEntProp(iGloves, Prop_Send, "m_iItemIDHigh", 0);
        SetEntProp(iGloves, Prop_Send, "m_OriginalOwnerXuidLow", 0);
        SetEntProp(iGloves, Prop_Send, "m_OriginalOwnerXuidHigh", 0);
        SetEntProp(iGloves, Prop_Send, "m_iItemIDLow", -1);
        SetEntProp(iGloves, Prop_Send, "m_nFallbackPaintKit", iSkinDefIndex);
        SetEntProp(iGloves, Prop_Send, "m_iEntityQuality", 4);
        SetEntPropFloat(iGloves, Prop_Send, "m_flFallbackWear", g_fWeaponWear[iGlovesWear]); // Default 0.0001
        SetEntPropEnt(iGloves, Prop_Send, "m_hOwnerEntity", client);
        SetEntProp(iGloves, Prop_Send, "m_nModelIndex", iGloveModelIndex);
        SetEntPropEnt(iGloves, Prop_Data, "m_hParent", client);
        SetEntPropEnt(iGloves, Prop_Data, "m_hOwnerEntity", client);
        SetEntPropEnt(iGloves, Prop_Data, "m_hMoveParent", client);
        SetEntProp(client, Prop_Send, "m_nBody", 1);
        SetEntityModel(iGloves, szGloveWorldModel);
        SetEntProp(iGloves, Prop_Send, "m_iTeamNum", GetClientTeam(client));
        SetEntProp(client, Prop_Send, "m_nBody", 1);
        SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
        SDKCall(g_hGiveWearableCall, client, iGloves);
        eTweaker_RefreshVM(client);
        ClientInfo[client].GlovesEntReference = EntIndexToEntRef(iGloves);
        //SDKHook(iGloves, SDKHook_SetTransmit, EventSDK_SetTransmit);
    }
}

stock void eTweaker_RemoveClientGloves(int client)
{
    if(!IsValidClient(client))
    {
        return;
    }

    int iGloves = EntRefToEntIndex(ClientInfo[client].GlovesEntReference);
    if(IsValidEntity(iGloves))
    {
        RemoveEntity(iGloves);
        ClientInfo[client].GlovesEntReference = INVALID_ENT_REFERENCE;
    }

    SDKCall(g_hRemoveWearableCall, client);
    SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
    eTweaker_RefreshVM(client);
}

stock bool eTweaker_RefreshVM(int client)
{
    if(!IsValidClient(client, true))
    {
        return false;
    }

    Event event = CreateEvent("player_spawn", true);
    if(event == null)
    {
        return false;
    }

    event.SetInt("userid", GetClientUserId(client));
    event.FireToClient(client);
    event.Cancel();
    return true;
}

stock void eTweaker_EquipGloves(int client, bool bRemoveGloves = false)
{
    if(!IsPlayerAlive(client))
    {
        return;
    }

    if(bRemoveGloves)
    {
        eTweaker_RemoveClientGloves(client);
        return;
    }

    int iGloveDefIndex = -1;
    int iSkinDefIndex = -1;
    int iGloveWear = -1;
    switch(ClientInfo[client].Team())
    {
        case CS_TEAM_CT:
        {
            iGloveDefIndex = ClientInfo[client].GlovesCT.GloveDefIndex;
            iSkinDefIndex = ClientInfo[client].GlovesCT.SkinDefIndex;
            iGloveWear = ClientInfo[client].GlovesCT.GloveWear;
        }
        case CS_TEAM_T:
        {
            iGloveDefIndex = ClientInfo[client].GlovesT.GloveDefIndex;
            iSkinDefIndex = ClientInfo[client].GlovesT.SkinDefIndex;
            iGloveWear = ClientInfo[client].GlovesT.GloveWear;
        }
    }

    if(iGloveDefIndex == -1 || iSkinDefIndex == -1)
    {
        return;
    }
    eTweaker_AttachGloveSkin(client, iGloveDefIndex, iSkinDefIndex, iGloveWear);
    return;
}

stock bool eTweaker_IsMapWeapon(int weapon)
{
    if(g_arMapWeapons == null)
    {
        return false;
    }

    for(int i = 0; i < g_arMapWeapons.Length; i++)
    {
        if(g_arMapWeapons.Get(i) != weapon)
        {
            continue;
        }

        g_arMapWeapons.Erase(i);
        return true;
    }
    return false;
}

public void eTwekaer_OnMapWeaponEquip(DataPack datapack)
{
    datapack.Reset();

    int client = GetClientOfUserId(datapack.ReadCell());
    int iWeapon = datapack.ReadCell();

    eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
    delete datapack;
}

stock void eTweaker_EquipMusicKit(int client, int iMusicKitDef)
{
    char szMusicKitDisplayName[48];
    eItems_GetMusicKitDisplayNameByDefIndex(iMusicKitDef, szMusicKitDisplayName, sizeof(szMusicKitDisplayName));
    ClientInfo[client].MusicKit = iMusicKitDef;
    CPrintToChat(client, "%s You have selected \x06%s\x01 music kit.", PREFIX, szMusicKitDisplayName);

    eTweaker_GiveMusicKit(client);
}

stock void eTweaker_GiveMusicKit(int client)
{
    SetEntProp(client, Prop_Send, "m_unMusicID", ClientInfo[client].MusicKit);
}

stock void eTweaker_AttachStickerToWeapon(int client, int iWeaponDefIndex, int iStickerDefIndex, int iStickerSlot)
{

    char szWeaponDefIndex[12];
    char szWeaponDisplayName[48];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    switch(iStickerSlot)
    {
        case 1336:
        {
            int iWeaponStickerSlots = eItems_GetWeaponStickersSlotsByDefIndex(iWeaponDefIndex);

            for(int iSlot = 0; iSlot < iWeaponStickerSlots; iSlot++)
            {
                WeaponSettings.Sticker[iSlot] = iStickerDefIndex;
            }
        }
        default: WeaponSettings.Sticker[iStickerSlot] = iStickerDefIndex;
    }

    WeaponSettings.Changed = true;
    g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    char szStickerDisplayName[48];

    if(!eItems_GetStickerDisplayNameByDefIndex(iStickerDefIndex, szStickerDisplayName, sizeof(szStickerDisplayName)))
    {
        strcopy(szStickerDisplayName, sizeof(szStickerDisplayName), "Default");
    }

    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    CPrintToChat(client, "%s You have selected \x06%s\x01 sticker (slot %i) for \x06%s\x01.", PREFIX, szStickerDisplayName, iStickerSlot + 1, szWeaponDisplayName);
}

stock void eTweaker_SetClientActiveCoin(int client, int iActiveCoinDef, bool bPin = false)
{
    char szCoinDisplayName[48];
    char szType[12];
    if(bPin)
    {
        eItems_GetPinDisplayNameByDefIndex(iActiveCoinDef, szCoinDisplayName, sizeof(szCoinDisplayName));
    }
    else
    {
        eItems_GetCoinDisplayNameByDefIndex(iActiveCoinDef, szCoinDisplayName, sizeof(szCoinDisplayName));
        strcopy(szType, sizeof(szType), " coin");
    }

    ClientInfo[client].ActiveCoin = iActiveCoinDef;
    CPrintToChat(client, "%s You have selected \x06%s\x01%s.", PREFIX, szCoinDisplayName, szType);
}