public void SDK_OnWeaponSwitchPost(int client, int iWeapon)
{
    if(!IsValidClient(client, true))
    {
        return;
    }

    if(!eItems_IsValidWeapon(iWeapon))
    {
        return;
    }

    int iWeaponNum = eItems_GetWeaponNumByWeapon(iWeapon);
    int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeapon(iWeapon);

    if(-1 < iWeaponNum < eItems_GetWeaponCount())
    {
        switch(ClientInfo[client].WeaponSwitch)
        {
            case SWITCH_ALLWEAPONS:                     Skins_BuildAllWeaponSkinsMenu(client);
            case SWITCH_CURRENTWEAPON:                  Skins_BuildCurrentWeaponSkinsMenu(client);
            case SWITCH_TWEAKS_CURRENTMAIN:             Tweaks_BuildTweakMenuForCurrent(client);
            case SWITCH_TWEAKS_CURRENT_STICKERS_MAIN:   Tweaks_BuildStickersMenuForCurrent(client);
            case SWITCH_TWEAKS_CURRENT_STATTRAK:        Tweaks_BuildStatTrakMenuForCurrent(client);
            case SWITCH_TWEAKS_CURRENT_RARITIES:        Tweaks_BuildRaritiesMenuForCurrent(client);
            case SWITCH_TWEAKS_CURRENT_WEAR:            Tweaks_BuildWearMenuForCurrent(client);
            case SWITCH_TWEAKS_CURRENT_PATTERN:         Tweaks_BuildPatternMenuForCurrent(client);
            case SWITCH_TWEAKS_CURRENT_NAMETAG:         Tweaks_BuildNametagMenuForCurrent(client);
        }
    }

    // if(ClientInfo[client].PreviousWeapon != INVALID_ENT_REFERENCE)
    // {
    //     int iPreviousWeapon = EntRefToEntIndex(ClientInfo[client].PreviousWeapon);
    //     if(eItems_IsValidWeapon(iPreviousWeapon))
    //     {
    //         int iPreviousWeaponDefIndex = eItems_GetWeaponDefIndexByWeapon(iPreviousWeapon);
    //         char szPreviousWeaponDefIndex[12];
    //         IntToString(iPreviousWeaponDefIndex, szPreviousWeaponDefIndex, sizeof(szPreviousWeaponDefIndex));

    //         eWeaponSettings WeaponSettings;
    //         if(g_smWeaponSettings[client].GetArray(szPreviousWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings)))
    //         {
    //             if(WeaponSettings.StatTrak_Enabled)
    //             {
    //                 int iHasPreviousWeapon = eItems_FindWeaponByWeaponNum(client, iPreviousWeapon);
    //                 int iCurrentStatTrackKills = GetEntProp(iPreviousWeapon, Prop_Send, "m_nFallbackStatTrak");
    //                 if(iPreviousWeapon == iHasPreviousWeapon && iCurrentStatTrackKills != WeaponSettings.StatTrak_Kills)
    //                 {
    //                     if(eItems_IsDefIndexKnife(iPreviousWeaponDefIndex))
    //                     {
    //                         eTweaker_EquipKnife(client);
    //                     }else{
    //                         eItems_RespawnWeapon(client, iPreviousWeapon);
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }
    ClientInfo[client].PreviousWeapon = EntIndexToEntRef(iWeapon);

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
    if(WeaponSettings.RareDraw || (eItems_HasRareDrawByDefIndex(iWeaponDefIndex) && ClientInfo[client].RareDraw))
    {
        int iPredictedViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
        if(!IsValidEntity(iPredictedViewModel))
        {
            return;
        }

        SetEntProp(iPredictedViewModel, Prop_Send, "m_nSequence", eItems_GetRareDrawSequenceByDefIndex(iWeaponDefIndex));
    }

}

public Action SDK_OnWeaponEquip(int client, int iWeapon)
{

    if(!IsValidClient(client, true))
    {
        return Plugin_Continue;
    }

    if(!eItems_IsValidWeapon(iWeapon))
    {
        return Plugin_Continue;
    }

    int iPrevOwner = GetEntProp(iWeapon, Prop_Send, "m_hPrevOwner");
    if(iPrevOwner > 0)
    {
        return Plugin_Continue;
    }

    if(!eTweaker_IsMapWeapon(iWeapon))
    {
        return Plugin_Continue;
    }

    DataPack datapack = new DataPack();
    datapack.WriteCell(GetClientUserId(client));
    datapack.WriteCell(iWeapon);

    RequestFrame(eTwekaer_OnMapWeaponEquip, datapack);

    return Plugin_Continue;
}