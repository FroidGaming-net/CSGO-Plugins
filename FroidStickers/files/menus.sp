public Action Call_MenuStickers(int client, int args)
{
    if(!IsValidClient(client))
    {
        return Plugin_Handled;
    }

    if(!FroidStickers_AreDataSynced())
    {
        FroidStickers_PrintDataNotSynced(client);
        return Plugin_Handled;
    }

    if(FroidStickers_IsClientSpectating(client))
    {
        FroidStickers_PrintNotAvailableInSpec(client);
        return Plugin_Handled;
    }

    if(FroidStickers_IsControllingBot(client))
    {
        FroidStickers_PrintNotAvailableWhileControllingBot(client);
        return Plugin_Handled;
    }

    Tweaks_BuildStickersMenuForCurrent(client);
    return Plugin_Handled;
}

stock void Tweaks_BuildStickersMenuForCurrent(int client)
{
    if(FroidStickers_IsClientSpectating(client))
    {
        FroidStickers_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        FroidStickers_PrintOnlyForAlivePlayers(client);
        return;
    }

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
    char sDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, sDisplayName, sizeof(sDisplayName));

    Menu menu = new Menu(m_TweaksWeaponStickersForCurrentWeapon);
    menu.SetTitle("★ Tweaks Menu - %s Stickers ★ \n ", sDisplayName);

    int iStickerSlots = eItems_GetWeaponStickersSlotsByDefIndex(iWeaponDefIndex);

    switch(iStickerSlots)
    {
        case 0: menu.AddItem("#none", "» No sticker slots", ITEMDRAW_DISABLED);
        default:
        {
            char sMenuItem[64];
            char sWeaponDefIndex[12];
            char sStickerDisplayName[48];
            char sStickerSlot[4];
            IntToString(iWeaponDefIndex, sWeaponDefIndex, sizeof(sWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(sWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            menu.AddItem("#all", "• Apply sticker to all slots\n ❯ All slots will be affected.");
            for(int iStickerSlot = 0; iStickerSlot < iStickerSlots; iStickerSlot++)
            {
                if(!eItems_GetStickerDisplayNameByDefIndex(WeaponSettings.Sticker[iStickerSlot], sStickerDisplayName, sizeof(sStickerDisplayName)))
                {
                    strcopy(sStickerDisplayName, sizeof(sStickerDisplayName), "No sticker applied");
                }
                FormatEx(sMenuItem, sizeof(sMenuItem), "• Sticker slot %i\n ❯ %s", iStickerSlot + 1, sStickerDisplayName);

                IntToString(iStickerSlot, sStickerSlot, sizeof(sStickerSlot));
                menu.AddItem(sStickerSlot, sMenuItem);
            }
        }
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_STICKERS_MAIN;
}