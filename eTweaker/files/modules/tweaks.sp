public Action Command_Tweaks(int client, int args)
{
    if(!IsValidClient(client))
    {
        return Plugin_Handled;
    }

    if(!eTweaker_AreDataSynced())
    {
        eTweaker_PrintDataNotSynced(client);
        return Plugin_Handled;
    }

    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return Plugin_Handled;
    }

    if(eTweaker_IsControllingBot(client))
    {
        eTweaker_PrintNotAvailableWhileControllingBot(client);
        return Plugin_Handled;
    }

    Tweaks_BuildMainMenu(client);
    return Plugin_Handled;
}

public Action Command_Stickers(int client, int args)
{
    if(!IsValidClient(client))
    {
        return Plugin_Handled;
    }

    if(!eTweaker_AreDataSynced())
    {
        eTweaker_PrintDataNotSynced(client);
        return Plugin_Handled;
    }

    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return Plugin_Handled;
    }

    if(eTweaker_IsControllingBot(client))
    {
        eTweaker_PrintNotAvailableWhileControllingBot(client);
        return Plugin_Handled;
    }

    if(!IsPlayerAlive(client))
    {
       eTweaker_PrintOnlyForAlivePlayers(client);
       return Plugin_Handled;
    }

    Tweaks_BuildStickersMenuForCurrent(client);
    return Plugin_Handled;
}

stock void Tweaks_BuildMainMenu(int client)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    Menu menu = new Menu(m_Tweaks);
    menu.SetTitle("★ Tweaks Menu - Select Menu ★ \n ");
    menu.AddItem("#0", "• Current weapon tweaks\n ❯ Tweak current weapon");
    menu.AddItem("#1", "• Primary weapon tweaks\n ❯ Tweak primary weapon");
    menu.AddItem("#2", "• Secondary weapon tweaks\n ❯ Tweak secondary weapon");
    menu.AddItem("#3", "• Knife tweaks\n ❯ Tweak knife weapon");
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_Tweaks(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            switch(option)
            {
                case 0:
                {
                    if(!IsPlayerAlive(client))
                    {
                        eTweaker_PrintOnlyForAlivePlayers(client);
                        return;
                    }
                    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
                    ClientInfo[client].WeaponStoredDefIndex = iWeaponDefIndex;
                    Tweaks_BuildTweakMenuForCurrent(client);
                }
                case 1:
                {
                    Tweaks_BuildWeaponSelection(client, CS_SLOT_PRIMARY);
                }
                case 2:
                {
                    Tweaks_BuildWeaponSelection(client, CS_SLOT_SECONDARY);
                }
                case 3:
                {
                    Tweaks_BuildWeaponSelection(client, CS_SLOT_KNIFE);
                }
            }
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Ws_BuildMainMenu(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildWeaponSelection(int client, int iSlot)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    Menu menu = new Menu(m_TweaksWeaponSelection);

    switch(iSlot)
    {
        case CS_SLOT_PRIMARY:   menu.SetTitle("★ Tweaks Menu - Select primary weapon to tweak ★ \n ");
        case CS_SLOT_SECONDARY: menu.SetTitle("★ Tweaks Menu - Select secondary weapon to tweak ★ \n ");
        case CS_SLOT_KNIFE:     menu.SetTitle("★ Tweaks Menu - Select knife to tweak ★ \n ");
    }

    for(int iWeaponNum = 0; iWeaponNum < eTweaker_GetWeaponCount(); iWeaponNum++)
    {
        int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
        if(eItems_GetWeaponSlotByDefIndex(iWeaponDefIndex) != iSlot)
        {
            continue;
        }

        if(eTweaker_IsKnifeForbidden(iWeaponDefIndex))
        {
            continue;
        }

        if(!g_cvDangerZoneKnives.BoolValue && eTweaker_IsDangerZoneKnife(iWeaponDefIndex))
        {
            continue;
        }

        char szWeaponDisplayName[48];
        char szWeaponDefIndex[12];
        char szTranslation[256];

        eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

        Format(szTranslation, sizeof(szTranslation), "» %s", szWeaponDisplayName);
        menu.AddItem(szWeaponDefIndex, szTranslation);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_TweaksWeaponSelection(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            char szWeaponDefIndex[12];
            menu.GetItem(option, szWeaponDefIndex, sizeof(szWeaponDefIndex));
            int iWeaponDefIndex = StringToInt(szWeaponDefIndex);
            ClientInfo[client].WeaponStoredDefIndex = iWeaponDefIndex;
            Tweaks_BuildTweakMenuForWeapon(client, iWeaponDefIndex);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildMainMenu(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildTweakMenuForWeapon(int client, int iWeaponDefIndex, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    Menu menu = new Menu(m_TweaksMenuForWeapon);

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(ClientInfo[client].WeaponStoredDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    menu.SetTitle("★ Tweaks Menu - %s Tweaks ★ \n ", szWeaponDisplayName);
    menu.AddItem("#0", "• Stickers\n ❯ Apply ANY sticker");
    menu.AddItem("#1", "• Rarity\n ❯ Change rarity");
    menu.AddItem("#2", "• Wear\n ❯ Change wear");
    menu.AddItem("#3", "• Pattern\n ❯ Change pattern");
    menu.AddItem("#4", "• Nametag\n ❯ Change nametag");
    menu.AddItem("#5", "• StatTrak™\n ❯ Toggle StatTrak");

    char szMenuItem[48];
    char szWeaponDefIndex[12];

    IntToString(ClientInfo[client].WeaponStoredDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    if(eItems_HasRareInspectByDefIndex(ClientInfo[client].WeaponStoredDefIndex))
    {
        Format(szMenuItem, sizeof(szMenuItem), "» Rare inspect [%s]\n ❯ Toggle Rare inspect", WeaponSettings.RareInspect ? "ON" : "OFF");
        menu.AddItem("inspect", szMenuItem);
    }

    if(eItems_HasRareDrawByDefIndex(ClientInfo[client].WeaponStoredDefIndex))
    {
        Format(szMenuItem, sizeof(szMenuItem), "» Rare draw [%s]\n ❯ Toggle Rare draw", WeaponSettings.RareDraw ? "ON" : "OFF");
        menu.AddItem("draw", szMenuItem);
    }
    menu.ExitBackButton = true;
    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_TweaksMenuForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }
            switch(option)
            {
                case 0: Tweaks_BuildStickersMenuForWeapon(client,       ClientInfo[client].WeaponStoredDefIndex);
                case 1: Tweaks_BuildRaritiesMenuForWeapon(client,       ClientInfo[client].WeaponStoredDefIndex);
                case 2: Tweaks_BuildWearMenuForWeapon(client,           ClientInfo[client].WeaponStoredDefIndex);
                case 3: Tweaks_BuildPatternMenuForWeapon(client,        ClientInfo[client].WeaponStoredDefIndex);
                case 4: Tweaks_BuildNametagMenuForWeapon(client,        ClientInfo[client].WeaponStoredDefIndex);
                case 5: Tweaks_BuildStatTrakMenuForWeapon(client,       ClientInfo[client].WeaponStoredDefIndex);
            }

            char szMenuItem[12];
            menu.GetItem(option, szMenuItem, sizeof(szMenuItem));

            char szWeaponDefIndex[12];
            char szWeaponDisplayName[48];

            eItems_GetWeaponDisplayNameByDefIndex(ClientInfo[client].WeaponStoredDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));
            IntToString(ClientInfo[client].WeaponStoredDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            if(strcmp(szMenuItem, "inspect") == 0)
            {
                WeaponSettings.RareInspect = !WeaponSettings.RareInspect;
                WeaponSettings.Changed = true;

                CPrintToChat(client, "%s You have toggled \x06rare inspect\x01 feature for \x06%s\x01.", PREFIX, szWeaponDisplayName);
                g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
                Tweaks_BuildTweakMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex, GetMenuSelectionPosition());
            }
            else if(strcmp(szMenuItem, "draw") == 0)
            {
                WeaponSettings.RareDraw = !WeaponSettings.RareDraw;
                WeaponSettings.Changed = true;

                CPrintToChat(client, "%s You have toggled \x06rare draw\x01 feature for \x06%s\x01.", PREFIX, szWeaponDisplayName);
                g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
                Tweaks_BuildTweakMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex, GetMenuSelectionPosition());
            }
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                int iSlot = eItems_GetWeaponSlotByDefIndex(ClientInfo[client].WeaponStoredDefIndex);
                Tweaks_BuildWeaponSelection(client, iSlot);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildStickersMenuForWeapon(int client, int iWeaponDefIndex)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    char szDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szDisplayName, sizeof(szDisplayName));

    Menu menu = new Menu(m_TweaksWeaponStickersForWeapon);
    menu.SetTitle("★ Tweaks Menu - %s Stickers ★ \n ", szDisplayName);

    int iStickerSlots = eItems_GetWeaponStickersSlotsByDefIndex(iWeaponDefIndex);

    switch(iStickerSlots)
    {
        case 0: menu.AddItem("#none", "» No sticker slots", ITEMDRAW_DISABLED);
        default:
        {
            char szMenuItem[64];
            char szWeaponDefIndex[12];
            char szStickerDisplayName[48];
            char szStickerSlot[4];
            IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            menu.AddItem("#all", "• Apply sticker to all slots\n ❯ All slots will be affected.");
            for(int iStickerSlot = 0; iStickerSlot < iStickerSlots; iStickerSlot++)
            {
                if(!eItems_GetStickerDisplayNameByDefIndex(WeaponSettings.Sticker[iStickerSlot], szStickerDisplayName, sizeof(szStickerDisplayName)))
                {
                    if(!eItems_GetPatchDisplayNameByDefIndex(WeaponSettings.Sticker[iStickerSlot], szStickerDisplayName, sizeof(szStickerDisplayName)))
                    {
                        strcopy(szStickerDisplayName, sizeof(szStickerDisplayName), "No sticker applied");
                    }
                }
                FormatEx(szMenuItem, sizeof(szMenuItem), "• Sticker slot %i\n ❯ %s", iStickerSlot + 1, szStickerDisplayName);

                IntToString(iStickerSlot, szStickerSlot, sizeof(szStickerSlot));
                menu.AddItem(szStickerSlot, szMenuItem);
            }
        }
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_TweaksWeaponStickersForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            switch(option)
            {
                case 0: ClientInfo[client].StickerSlotStored = 1336;
                default:
                {
                    char szStickerSlot[4];
                    menu.GetItem(option, szStickerSlot, sizeof(szStickerSlot));
                    int iStickerSlot = StringToInt(szStickerSlot);
                    ClientInfo[client].StickerSlotStored = iStickerSlot;
                }
            }
            Tweaks_BuildStickersCategoryMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildStickersCategoryMenuForWeapon(int client, int iWeaponDefIndex, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    int iStickerSlot = ClientInfo[client].StickerSlotStored;
    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    char szDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szDisplayName, sizeof(szDisplayName));

    Menu menu = new Menu(m_TweakStickersCategoryForWeapon);
    menu.SetTitle("★ Tweaks Menu - %s Stickers (slot %i) ★ \n ", szDisplayName, iStickerSlot + 1);

    menu.AddItem("#0", "» Default");
    menu.AddItem("#1", "» Patches");

    char szStickerSetDisplayName[48];
    char szStickerSetNum[12];
    char szTranslation[256];

    for(int iStickerSetNum = 0; iStickerSetNum < eTweaker_GetStickersSetsCount(); iStickerSetNum++)
    {
        eItems_GetStickerSetDisplayNameByStickerSetNum(iStickerSetNum, szStickerSetDisplayName, sizeof(szStickerSetDisplayName));

        if (StrContains(szStickerSetDisplayName, "valve", false) == -1) {
            continue;
        }

        IntToString(iStickerSetNum, szStickerSetNum, sizeof(szStickerSetNum));
        Format(szTranslation, sizeof(szTranslation), "» %s", szStickerSetDisplayName);
        menu.AddItem(szStickerSetNum, szTranslation);
    }

    for(int iStickerSetNum = 0; iStickerSetNum < eTweaker_GetStickersSetsCount(); iStickerSetNum++)
    {
        eItems_GetStickerSetDisplayNameByStickerSetNum(iStickerSetNum, szStickerSetDisplayName, sizeof(szStickerSetDisplayName));

        if (StrContains(szStickerSetDisplayName, "valve", false) != -1) {
            continue;
        }

        IntToString(iStickerSetNum, szStickerSetNum, sizeof(szStickerSetNum));
        Format(szTranslation, sizeof(szTranslation), "» %s", szStickerSetDisplayName);
        menu.AddItem(szStickerSetNum, szTranslation);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_TweakStickersCategoryForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            int iStickerSlot = ClientInfo[client].StickerSlotStored;
            ClientInfo[client].MenuCategorySelection = GetMenuSelectionPosition();

            switch(option)
            {
                case 0:
                {
                    eTweaker_AttachStickerToWeapon(client, ClientInfo[client].WeaponStoredDefIndex, 0, iStickerSlot);
                    int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);
                    if(iWeapon > 0)
                    {
                        eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);

                        if(g_cvForceFullUpdate.BoolValue)
                        {
                            PTaH_ForceFullUpdate(client);
                        }
                    }
                    Tweaks_BuildStickersCategoryMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex, ClientInfo[client].MenuCategorySelection);

                }
                case 1:
                {
                    Tweaks_BuildPatchesSelectionMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
                }
                default:
                {
                    char szSticketSetNum[12];
                    menu.GetItem(option, szSticketSetNum, sizeof(szSticketSetNum));
                    int iStickerSetNum = StringToInt(szSticketSetNum);
                    ClientInfo[client].StickerSetStored = iStickerSetNum;

                    Tweaks_BuildStickersSelectionMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex, iStickerSetNum);
                }
            }
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildStickersMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildStickersSelectionMenuForWeapon(int client, int iWeaponDefIndex, int iStickerSetNum, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    char szStickerSetDisplayName[48];
    eItems_GetStickerSetDisplayNameByStickerSetNum(iStickerSetNum, szStickerSetDisplayName, sizeof(szStickerSetDisplayName));

    int iStickerSlot = ClientInfo[client].StickerSlotStored;
    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweakStickersSelectionForWeapon);
    menu.SetTitle("★ Tweaks Menu - %s Stickers (slot %i) ★ \n ", szStickerSetDisplayName, iStickerSlot + 1);

    char szStickerDisplayName[48];
    char szStickerDefIndex[12];
    char szTranslation[256];
    for(int iStickerNum = 0; iStickerNum < eTweaker_GetStickersCount(); iStickerNum++)
    {

        if(!eItems_IsStickerInSet(iStickerSetNum, iStickerNum))
        {
            continue;
        }

        int iStickerDefIndex = eItems_GetStickerDefIndexByStickerNum(iStickerNum);
        eItems_GetStickerDisplayNameByStickerNum(iStickerNum, szStickerDisplayName, sizeof(szStickerDisplayName));
        IntToString(iStickerDefIndex, szStickerDefIndex, sizeof(szStickerDefIndex));
        Format(szTranslation, sizeof(szTranslation), "» %s", szStickerDisplayName);
        menu.AddItem(szStickerDefIndex, szTranslation);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_TweakStickersSelectionForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            char szStickerDefIndex[12];
            menu.GetItem(option, szStickerDefIndex, sizeof(szStickerDefIndex));
            int iStickerDefIndex = StringToInt(szStickerDefIndex);

            eTweaker_AttachStickerToWeapon(client, ClientInfo[client].WeaponStoredDefIndex, iStickerDefIndex, ClientInfo[client].StickerSlotStored);
            int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);
            if(iWeapon > 0)
            {
                eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);

                if(g_cvForceFullUpdate.BoolValue)
                {
                    PTaH_ForceFullUpdate(client);
                }
            }
            Tweaks_BuildStickersSelectionMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex, ClientInfo[client].StickerSetStored, GetMenuSelectionPosition());
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildStickersCategoryMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex, ClientInfo[client].MenuCategorySelection);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildPatchesSelectionMenuForWeapon(int client, int iWeaponDefIndex, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    int iStickerSlot = ClientInfo[client].StickerSlotStored;
    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweakPatchesSelectionForWeapon);
    menu.SetTitle("★ Tweaks Menu - Patches Stickers (slot %i) ★ \n ", iStickerSlot + 1);

    char szPatchDisplayName[48];
    char szPatchDefIndex[12];
    char szTranslation[256];
    for(int iPatchNum = 0; iPatchNum < eTweaker_GetPatchesCount(); iPatchNum++)
    {
        eItems_GetPatchDisplayNameByPatchNum(iPatchNum, szPatchDisplayName, sizeof(szPatchDisplayName));
        Format(szTranslation, sizeof(szTranslation), "» %s", szPatchDisplayName);
        int iStickerDefIndex = eItems_GetPatchDefIndexByPatchNum(iPatchNum);
        IntToString(iStickerDefIndex, szPatchDefIndex, sizeof(szPatchDefIndex));
        menu.AddItem(szPatchDefIndex, szTranslation);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_TweakPatchesSelectionForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            char szPatchDefIndex[12];
            menu.GetItem(option, szPatchDefIndex, sizeof(szPatchDefIndex));
            int iPatchDefIndex = StringToInt(szPatchDefIndex);

            eTweaker_AttachStickerToWeapon(client, ClientInfo[client].WeaponStoredDefIndex, iPatchDefIndex, ClientInfo[client].StickerSlotStored);
            int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);
            if(iWeapon > 0)
            {
                eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);

                if(g_cvForceFullUpdate.BoolValue)
                {
                    PTaH_ForceFullUpdate(client);
                }
            }
            Tweaks_BuildPatchesSelectionMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex, GetMenuSelectionPosition());
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildStickersCategoryMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex, ClientInfo[client].MenuCategorySelection);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildNametagMenuForWeapon(int client, int iWeaponDefIndex)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksNametagMenuForWeapon);

    menu.SetTitle("★ Tweaks Menu - %s Nametag ★ \n \nCurrent nametag: \n%s \n ", szWeaponDisplayName, WeaponSettings.Nametag);

    menu.AddItem("0#", "» Change");
    menu.AddItem("1#", "» Remove", strlen(WeaponSettings.Nametag) > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_TweaksNametagMenuForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            switch(option)
            {
                case 0:
                {
                    ClientInfo[client].ChangingNametag = true;
                    CPrintToChat(client, "%s Nametag change enabled. Write \x07'cancel'\x01 to abort this process or write your new nametag!", PREFIX);
                }
                case 1: eTweaker_ChangeWeaponNametag(client, ClientInfo[client].WeaponStoredDefIndex, "");
            }
            Tweaks_BuildNametagMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildStatTrakMenuForWeapon(int client, int iWeaponDefIndex)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksStatTrakMenuForWeapon);

    menu.SetTitle("★ Tweaks Menu - %s StatTrak™ ★ \n \nStatTrak™ Kills: %i\n ", szWeaponDisplayName, WeaponSettings.StatTrak_Kills);

    char szStatTrakToggle[32];
    Format(szStatTrakToggle, sizeof(szStatTrakToggle), "» %s StatTrak™", WeaponSettings.StatTrak_Enabled ? "Disable" : "Enable");
    menu.AddItem("0#", szStatTrakToggle);
    menu.AddItem("1#", "-", ITEMDRAW_DISABLED);
    menu.AddItem("2#", "-", ITEMDRAW_DISABLED);
    menu.AddItem("3#", "-", ITEMDRAW_DISABLED);
    menu.AddItem("4#", "» Reset", WeaponSettings.StatTrak_Kills > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_TweaksStatTrakMenuForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            char szWeaponDefIndex[12];
            IntToString(ClientInfo[client].WeaponStoredDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            char szWeaponDisplayName[48];
            eItems_GetWeaponDisplayNameByDefIndex(ClientInfo[client].WeaponStoredDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

            switch(option)
            {
                case 0:
                {
                    WeaponSettings.StatTrak_Enabled = !WeaponSettings.StatTrak_Enabled;
                    CPrintToChat(client, "%s You have %s StatTrak™ for \x06%s\x01.", PREFIX, WeaponSettings.StatTrak_Enabled ? "\x06enabled\x01" : "\x07disabled\x01", szWeaponDisplayName);
                }
                case 4:
                {
                    WeaponSettings.StatTrak_Kills = 0;
                    CPrintToChat(client, "%s You have reseted StatTrak™ for \x06%s\x01.", PREFIX, szWeaponDisplayName);
                }
            }

            WeaponSettings.Changed = true;
            g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);

            if(eItems_IsDefIndexKnife(ClientInfo[client].WeaponStoredDefIndex))
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

            Tweaks_BuildStatTrakMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
            }


        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildPatternMenuForWeapon(int client, int iWeaponDefIndex)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    char szTranslation[256];

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksPatternMenuForWeapon);

    menu.SetTitle("★ Tweaks Menu - %s Pattern - \n \nCurrent pattern: %i", szWeaponDisplayName, WeaponSettings.Pattern);

    char szPatternSubstraction[32];
    Format(szPatternSubstraction, sizeof(szPatternSubstraction), "» Pattern subtraction [%s]", g_szPatternSubtraction[view_as<int>(ClientInfo[client].PatternSubtraction)]);
    menu.AddItem("0#", szPatternSubstraction);
    for(int iPattern = 0; iPattern <= 4; iPattern++)
    {
        Format(szTranslation, sizeof(szTranslation), "» %s", g_szWeaponPattern[iPattern]);
        menu.AddItem("", szTranslation, iPattern == 0 ? (WeaponSettings.Pattern == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT) : ITEMDRAW_DEFAULT);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_TweaksPatternMenuForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            switch(option)
            {
                case 0: ClientInfo[client].PatternSubtraction = !ClientInfo[client].PatternSubtraction;
                default:
                {
                    char szWeaponDefIndex[12];
                    IntToString(ClientInfo[client].WeaponStoredDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

                    eWeaponSettings WeaponSettings;
                    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

                    switch(option - 1)
                    {
                        case 0: WeaponSettings.Pattern = 0;
                        default:
                        {
                            if(ClientInfo[client].PatternSubtraction && WeaponSettings.Pattern == 0)
                            {
                                CPrintToChat(client, "%s You can't change pattern to negative value.", PREFIX);
                                Tweaks_BuildPatternMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
                                return;
                            }
                            else
                            {
                                int iValue = StringToInt(g_szWeaponPattern[option - 1]);
                                if(ClientInfo[client].PatternSubtraction)
                                {
                                    if((WeaponSettings.Pattern-iValue) < 0)
                                    {
                                        CPrintToChat(client, "%s You can't change pattern to negative value.", PREFIX);
                                        return;
                                    }
                                    WeaponSettings.Pattern -= iValue;
                                }
                                else
                                {
                                    if((WeaponSettings.Pattern+iValue) > 8192)
                                    {
                                        CPrintToChat(client, "%s Max 8192!", PREFIX);
                                        return;
                                    }
                                    WeaponSettings.Pattern += iValue;
                                }
                            }
                        }
                    }
                    WeaponSettings.Changed = true;
                    g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

                    int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);

                    if(eItems_IsDefIndexKnife(ClientInfo[client].WeaponStoredDefIndex))
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
                    eItems_GetWeaponDisplayNameByDefIndex(ClientInfo[client].WeaponStoredDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

                    CPrintToChat(client, "%s You have changed pattern to \x06%i\x01 for \x06%s\x01.", PREFIX, WeaponSettings.Pattern, szWeaponDisplayName);
                }
            }
            Tweaks_BuildPatternMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildWearMenuForWeapon(int client, int iWeaponDefIndex)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    char szTranslation[256];

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksWearMenuForWeapon);

    menu.SetTitle("★ Tweaks Menu - %s Wear ★ \n ", szWeaponDisplayName);

    for(int iWear = 0; iWear <= 5; iWear++)
    {
        Format(szTranslation, sizeof(szTranslation), "» %s", g_szWeaponWear[iWear]);
        menu.AddItem("", szTranslation, WeaponSettings.Wear == iWear ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_TweaksWearMenuForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            char szWeaponDefIndex[12];
            IntToString(ClientInfo[client].WeaponStoredDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            WeaponSettings.Wear = option;
            WeaponSettings.Changed = true;
            g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);

            if(eItems_IsDefIndexKnife(ClientInfo[client].WeaponStoredDefIndex))
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
            eItems_GetWeaponDisplayNameByDefIndex(ClientInfo[client].WeaponStoredDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

            CPrintToChat(client, "%s You have selected \x06%s\x01 wear for \x06%s\x01.", PREFIX, g_szWeaponWear[option], szWeaponDisplayName);

            Tweaks_BuildWearMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildRaritiesMenuForWeapon(int client, int iWeaponDefIndex, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    char szTranslation[256];

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksRaritiesMenuForWeapon);

    menu.SetTitle("★ Tweaks Menu - %s Rarities ★ \n ", szWeaponDisplayName);

    for(int iRarities = 0; iRarities <= 12; iRarities++)
    {
        if(strlen(g_szWeaponRarities[iRarities]) == 0)
        {
            continue;
        }

        char szItem[3];
        IntToString(iRarities, szItem, sizeof(szItem));
        Format(szTranslation, sizeof(szTranslation), "» %s", g_szWeaponRarities[iRarities]);
        menu.AddItem(szItem, szTranslation, WeaponSettings.Rarity == iRarities ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }

}

public int m_TweaksRaritiesMenuForWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            char szItem[3];
            menu.GetItem(option, szItem, sizeof(szItem));
            int iRarity = StringToInt(szItem);

            char szWeaponDefIndex[12];
            IntToString(ClientInfo[client].WeaponStoredDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            WeaponSettings.Rarity = iRarity;
            WeaponSettings.Changed = true;
            g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);

            if(eItems_IsDefIndexKnife(ClientInfo[client].WeaponStoredDefIndex))
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
            eItems_GetWeaponDisplayNameByDefIndex(ClientInfo[client].WeaponStoredDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

            CPrintToChat(client, "%s You have selected \x06%s\x01 rarity for \x06%s\x01.", PREFIX, g_szWeaponRarities[iRarity], szWeaponDisplayName);

            Tweaks_BuildRaritiesMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex, GetMenuSelectionPosition());
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForWeapon(client, ClientInfo[client].WeaponStoredDefIndex);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildTweakMenuForCurrent(int client, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }


    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

    char szDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szDisplayName, sizeof(szDisplayName));

    Menu menu = new Menu(m_TweaksCurrentWeapon);
    menu.SetTitle("★ Tweaks Menu - %s Menu ★ \n ", szDisplayName);
    menu.AddItem("#0", "• Stickers\n ❯ Apply ANY sticker");
    menu.AddItem("#1", "• Rarity\n ❯ Change rarity");
    menu.AddItem("#2", "• Wear\n ❯ Change wear");
    menu.AddItem("#3", "• Pattern\n ❯ Change pattern");
    menu.AddItem("#4", "• Nametag\n ❯ Change nametag");
    menu.AddItem("#5", "• StatTrak\n ❯ Toggle StatTrak");

    char szMenuItem[48];
    char szWeaponDefIndex[12];

    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    if(eItems_HasRareInspectByDefIndex(iWeaponDefIndex))
    {
        Format(szMenuItem, sizeof(szMenuItem), "» Rare inspect [%s]\n ❯ Toggle Rare inspect", WeaponSettings.RareInspect ? "ON" : "OFF");
        menu.AddItem("inspect", szMenuItem);
    }

    if(eItems_HasRareDrawByDefIndex(iWeaponDefIndex))
    {
        Format(szMenuItem, sizeof(szMenuItem), "» Rare draw [%s]\n ❯ Toggle Rare draw", WeaponSettings.RareDraw ? "ON" : "OFF");
        menu.AddItem("draw", szMenuItem);
    }

    menu.ExitBackButton = true;
    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }

    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENTMAIN;
}

public int m_TweaksCurrentWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }

            switch(option)
            {
                case 0: Tweaks_BuildStickersMenuForCurrent(client);
                case 1: Tweaks_BuildRaritiesMenuForCurrent(client);
                case 2: Tweaks_BuildWearMenuForCurrent(client);
                case 3: Tweaks_BuildPatternMenuForCurrent(client);
                case 4: Tweaks_BuildNametagMenuForCurrent(client);
                case 5: Tweaks_BuildStatTrakMenuForCurrent(client);
            }

            int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

            char szMenuItem[12];
            menu.GetItem(option, szMenuItem, sizeof(szMenuItem));

            char szWeaponDefIndex[12];
            char szWeaponDisplayName[48];

            eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));
            IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            if(strcmp(szMenuItem, "inspect") == 0)
            {
                WeaponSettings.RareInspect = !WeaponSettings.RareInspect;
                WeaponSettings.Changed = true;

                CPrintToChat(client, "%s You have toggled \x06rare inspect\x01 feature for \x06%s\x01.", PREFIX, szWeaponDisplayName);
                g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
                Tweaks_BuildTweakMenuForCurrent(client, GetMenuSelectionPosition());
            }
            else if(strcmp(szMenuItem, "draw") == 0)
            {
                WeaponSettings.RareDraw = !WeaponSettings.RareDraw;
                WeaponSettings.Changed = true;

                CPrintToChat(client, "%s You have toggled \x06rare draw\x01 feature for \x06%s\x01.", PREFIX, szWeaponDisplayName);
                g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
                Tweaks_BuildTweakMenuForCurrent(client, GetMenuSelectionPosition());
            }
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildMainMenu(client);
            }

        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildNametagMenuForCurrent(int client)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksNametagMenuForCurrent);

    menu.SetTitle("★ Tweaks Menu - %s Nametag ★ \n \nCurrent nametag: \n%s \n ", szWeaponDisplayName, WeaponSettings.Nametag);

    menu.AddItem("0#", "» Change");
    menu.AddItem("1#", "» Remove", strlen(WeaponSettings.Nametag) > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_NAMETAG;
}

public int m_TweaksNametagMenuForCurrent(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }

            int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

            switch(option)
            {
                case 0:
                {
                    ClientInfo[client].ChangingNametagCurrent = true;
                    CPrintToChat(client, "%s Nametag change enabled. Write \x07'cancel'\x01 to abort this process or write your new nametag!", PREFIX);
                }
                case 1: eTweaker_ChangeWeaponNametag(client, iWeaponDefIndex, "");
            }
            Tweaks_BuildNametagMenuForCurrent(client);
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForCurrent(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildPatternMenuForCurrent(int client)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    char szTranslation[256];

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksPatternMenuForCurrent);

    menu.SetTitle("★ Tweaks Menu - %s Pattern - \n \nCurrent pattern: %i", szWeaponDisplayName, WeaponSettings.Pattern);

    char szPatternSubstraction[32];
    Format(szPatternSubstraction, sizeof(szPatternSubstraction), "» Pattern subtraction [%s]", g_szPatternSubtraction[view_as<int>(ClientInfo[client].PatternSubtraction)]);
    menu.AddItem("0#", szPatternSubstraction);
    for(int iPattern = 0; iPattern <= 4; iPattern++)
    {
        Format(szTranslation, sizeof(szTranslation), "» %s", g_szWeaponPattern[iPattern]);
        menu.AddItem("", szTranslation, iPattern == 0 ? (WeaponSettings.Pattern == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT) : ITEMDRAW_DEFAULT);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);

    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_PATTERN;
}

public int m_TweaksPatternMenuForCurrent(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }

            int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

            switch(option)
            {
                case 0: ClientInfo[client].PatternSubtraction = !ClientInfo[client].PatternSubtraction;
                default:
                {
                    char szWeaponDefIndex[12];
                    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

                    eWeaponSettings WeaponSettings;
                    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

                    switch(option - 1)
                    {
                        case 0: WeaponSettings.Pattern = 0;
                        default:
                        {
                            if(ClientInfo[client].PatternSubtraction && WeaponSettings.Pattern == 0)
                            {
                                CPrintToChat(client, "%s You can't change pattern to negative value.", PREFIX);
                                Tweaks_BuildPatternMenuForCurrent(client);
                                return;
                            }
                            else
                            {
                                int iValue = StringToInt(g_szWeaponPattern[option - 1]);
                                if(ClientInfo[client].PatternSubtraction)
                                {
                                    if((WeaponSettings.Pattern-iValue) < 0)
                                    {
                                        CPrintToChat(client, "%s You can't change pattern to negative value.", PREFIX);
                                        return;
                                    }
                                    WeaponSettings.Pattern -= iValue;
                                }
                                else
                                {
                                    if((WeaponSettings.Pattern+iValue) > 8192)
                                    {
                                        CPrintToChat(client, "%s Max 8192!", PREFIX);
                                        return;
                                    }
                                    WeaponSettings.Pattern += iValue;
                                }
                            }
                        }
                    }
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

                    CPrintToChat(client, "%s You have changed pattern to \x06%i\x01 for \x06%s\x01.", PREFIX, WeaponSettings.Pattern, szWeaponDisplayName);
                }
            }
            Tweaks_BuildPatternMenuForCurrent(client);
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForCurrent(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildWearMenuForCurrent(int client)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    char szTranslation[256];

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksWearMenuForCurrent);

    menu.SetTitle("★ Tweaks Menu - %s Wear ★ \n ", szWeaponDisplayName);

    for(int iWear = 0; iWear <= 5; iWear++)
    {
        Format(szTranslation, sizeof(szTranslation), "» %s", g_szWeaponWear[iWear]);
        menu.AddItem("", szTranslation, WeaponSettings.Wear == iWear ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);

    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_WEAR;
}

public int m_TweaksWearMenuForCurrent(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }

            int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

            char szWeaponDefIndex[12];
            IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            WeaponSettings.Wear = option;
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

            CPrintToChat(client, "%s You have selected \x06%s\x01 wear for \x06%s\x01.", PREFIX, g_szWeaponWear[option], szWeaponDisplayName);

            Tweaks_BuildWearMenuForCurrent(client);
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForCurrent(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildRaritiesMenuForCurrent(int client, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    char szTranslation[256];

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksRaritiesMenuForCurrent);

    menu.SetTitle("★ Tweaks Menu - %s Rarities ★ \n ", szWeaponDisplayName);

    for(int iRarities = 0; iRarities <= 12; iRarities++)
    {
        if(strlen(g_szWeaponRarities[iRarities]) == 0)
        {
            continue;
        }

        char szItem[3];
        IntToString(iRarities, szItem, sizeof(szItem));
        Format(szTranslation, sizeof(szTranslation), "» %s", g_szWeaponRarities[iRarities]);
        menu.AddItem(szItem, szTranslation, WeaponSettings.Rarity == iRarities ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }

    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_RARITIES;
}

public int m_TweaksRaritiesMenuForCurrent(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }

            int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

            char szItem[3];
            menu.GetItem(option, szItem, sizeof(szItem));
            int iRarity = StringToInt(szItem);

            char szWeaponDefIndex[12];
            IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            WeaponSettings.Rarity = iRarity;
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

            CPrintToChat(client, "%s You have selected \x06%s\x01 rarity for \x06%s\x01.", PREFIX, g_szWeaponRarities[iRarity], szWeaponDisplayName);

            Tweaks_BuildRaritiesMenuForCurrent(client, GetMenuSelectionPosition());
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForCurrent(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Tweaks_BuildStatTrakMenuForCurrent(int client)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;

    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweaksStatTrakMenuForCurrent);

    menu.SetTitle("★ Tweaks Menu - %s StatTrak™ ★ \n \nStatTrak™ Kills: %i\n ", szWeaponDisplayName, WeaponSettings.StatTrak_Kills);

    char szStatTrakToggle[32];
    Format(szStatTrakToggle, sizeof(szStatTrakToggle), "» %s StatTrak™", WeaponSettings.StatTrak_Enabled ? "Disable" : "Enable");
    menu.AddItem("0#", szStatTrakToggle);
    menu.AddItem("1#", "-", ITEMDRAW_DISABLED);
    menu.AddItem("2#", "-", ITEMDRAW_DISABLED);
    menu.AddItem("3#", "-", ITEMDRAW_DISABLED);
    menu.AddItem("4#", "» Reset", WeaponSettings.StatTrak_Kills > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);

    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_STATTRAK;
}

public int m_TweaksStatTrakMenuForCurrent(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }
            int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

            char szWeaponDefIndex[12];
            IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            char szWeaponDisplayName[48];
            eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

            switch(option)
            {
                case 0:
                {
                    WeaponSettings.StatTrak_Enabled = !WeaponSettings.StatTrak_Enabled;
                    CPrintToChat(client, "%s You have %s StatTrak™ for \x06%s\x01.", PREFIX, WeaponSettings.StatTrak_Enabled ? "\x06enabled\x01" : "\x07disabled\x01", szWeaponDisplayName);
                }
                case 4:
                {
                    WeaponSettings.StatTrak_Kills = 0;
                    CPrintToChat(client, "%s You have reseted StatTrak™ for \x06%s\x01.", PREFIX, szWeaponDisplayName);
                }
            }

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

            Tweaks_BuildStatTrakMenuForCurrent(client);
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForCurrent(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildStickersMenuForCurrent(int client)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
    char szDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szDisplayName, sizeof(szDisplayName));

    Menu menu = new Menu(m_TweaksWeaponStickersForCurrentWeapon);
    menu.SetTitle("★ Tweaks Menu - %s Stickers ★ \n ", szDisplayName);

    int iStickerSlots = eItems_GetWeaponStickersSlotsByDefIndex(iWeaponDefIndex);

    switch(iStickerSlots)
    {
        case 0: menu.AddItem("#none", "» No sticker slots", ITEMDRAW_DISABLED);
        default:
        {
            char szMenuItem[64];
            char szWeaponDefIndex[12];
            char szStickerDisplayName[48];
            char szStickerSlot[4];
            IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            menu.AddItem("#all", "• Apply sticker to all slots\n ❯ All slots will be affected.");
            for(int iStickerSlot = 0; iStickerSlot < iStickerSlots; iStickerSlot++)
            {
                if(!eItems_GetStickerDisplayNameByDefIndex(WeaponSettings.Sticker[iStickerSlot], szStickerDisplayName, sizeof(szStickerDisplayName)))
                {
                    if(!eItems_GetPatchDisplayNameByDefIndex(WeaponSettings.Sticker[iStickerSlot], szStickerDisplayName, sizeof(szStickerDisplayName)))
                    {
                        strcopy(szStickerDisplayName, sizeof(szStickerDisplayName), "No sticker applied");
                    }
                }
                FormatEx(szMenuItem, sizeof(szMenuItem), "• Sticker slot %i\n ❯ %s", iStickerSlot + 1, szStickerDisplayName);

                IntToString(iStickerSlot, szStickerSlot, sizeof(szStickerSlot));
                menu.AddItem(szStickerSlot, szMenuItem);
            }
        }
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_STICKERS_MAIN;
}

public int m_TweaksWeaponStickersForCurrentWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }

            switch(option)
            {
                case 0: ClientInfo[client].StickerSlotStored = 1336;
                default:
                {
                    char szStickerSlot[4];
                    menu.GetItem(option, szStickerSlot, sizeof(szStickerSlot));
                    int iStickerSlot = StringToInt(szStickerSlot);
                    ClientInfo[client].StickerSlotStored = iStickerSlot;
                }
            }
            Tweaks_BuildStickersCategoryMenuForCurrent(client);
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildTweakMenuForCurrent(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildStickersCategoryMenuForCurrent(int client, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }

    int iStickerSlot = ClientInfo[client].StickerSlotStored;
    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    char szDisplayName[48];
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szDisplayName, sizeof(szDisplayName));

    int iStickerSlots = eItems_GetWeaponStickersSlotsByDefIndex(iWeaponDefIndex);

    if (iStickerSlots == 0) {
        Menu menu = new Menu(m_TweakStickersCategoryForCurrent);
        menu.SetTitle("★ Tweaks Menu - %s ★ \n ", szDisplayName);
        menu.AddItem("#none", "» No sticker slots", ITEMDRAW_DISABLED);
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
        ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_STICKERS_CATEGORY;
        return;
    }

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweakStickersCategoryForCurrent);
    menu.SetTitle("★ Tweaks Menu - %s Stickers (slot %i) ★ \n ", szDisplayName, iStickerSlot + 1);

    menu.AddItem("#0", "» Default");
    menu.AddItem("#1", "» Patches");

    char szStickerSetDisplayName[48];
    char szStickerSetNum[12];
    char szTranslation[256];
    for(int iStickerSetNum = 0; iStickerSetNum < eTweaker_GetStickersSetsCount(); iStickerSetNum++)
    {
        eItems_GetStickerSetDisplayNameByStickerSetNum(iStickerSetNum, szStickerSetDisplayName, sizeof(szStickerSetDisplayName));

        if (StrContains(szStickerSetDisplayName, "valve", false) == -1) {
            continue;
        }

        IntToString(iStickerSetNum, szStickerSetNum, sizeof(szStickerSetNum));
        Format(szTranslation, sizeof(szTranslation), "» %s", szStickerSetDisplayName);
        menu.AddItem(szStickerSetNum, szTranslation);
    }

    for(int iStickerSetNum = 0; iStickerSetNum < eTweaker_GetStickersSetsCount(); iStickerSetNum++)
    {
        eItems_GetStickerSetDisplayNameByStickerSetNum(iStickerSetNum, szStickerSetDisplayName, sizeof(szStickerSetDisplayName));

        if (StrContains(szStickerSetDisplayName, "valve", false) != -1) {
            continue;
        }

        IntToString(iStickerSetNum, szStickerSetNum, sizeof(szStickerSetNum));
        Format(szTranslation, sizeof(szTranslation), "» %s", szStickerSetDisplayName);
        menu.AddItem(szStickerSetNum, szTranslation);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_STICKERS_CATEGORY;
}

public int m_TweakStickersCategoryForCurrent(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }

            int iStickerSlot = ClientInfo[client].StickerSlotStored;
            ClientInfo[client].MenuCategorySelection = GetMenuSelectionPosition();

            switch(option)
            {
                case 0:
                {
                    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
                    eTweaker_AttachStickerToWeapon(client, iWeaponDefIndex, 0, iStickerSlot);
                    int iWeapon = eItems_GetActiveWeapon(client);
                    eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
                    Tweaks_BuildStickersCategoryMenuForCurrent(client, ClientInfo[client].MenuCategorySelection);

                    if(g_cvForceFullUpdate.BoolValue)
                    {
                        PTaH_ForceFullUpdate(client);
                    }

                }
                case 1:
                {
                    Tweaks_BuildPatchesSelectionMenuForCurrent(client);
                }
                default:
                {
                    char szSticketSetNum[12];
                    menu.GetItem(option, szSticketSetNum, sizeof(szSticketSetNum));
                    int iStickerSetNum = StringToInt(szSticketSetNum);
                    ClientInfo[client].StickerSetStored = iStickerSetNum;

                    Tweaks_BuildStickersSelectionMenuForCurrent(client, iStickerSetNum);
                }
            }
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildStickersMenuForCurrent(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildStickersSelectionMenuForCurrent(int client, int iStickerSetNum, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }

    char szStickerSetDisplayName[48];
    eItems_GetStickerSetDisplayNameByStickerSetNum(iStickerSetNum, szStickerSetDisplayName, sizeof(szStickerSetDisplayName));

    int iStickerSlot = ClientInfo[client].StickerSlotStored;
    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweakStickersSelectionForCurrent);
    menu.SetTitle("★ Tweaks Menu - %s Stickers (slot %i) ★ \n ", szStickerSetDisplayName, iStickerSlot + 1);

    char szStickerDisplayName[48];
    char szStickerDefIndex[12];
    char szTranslation[256];
    for(int iStickerNum = 0; iStickerNum < eTweaker_GetStickersCount(); iStickerNum++)
    {

        if(!eItems_IsStickerInSet(iStickerSetNum, iStickerNum))
        {
            continue;
        }

        int iStickerDefIndex = eItems_GetStickerDefIndexByStickerNum(iStickerNum);
        eItems_GetStickerDisplayNameByStickerNum(iStickerNum, szStickerDisplayName, sizeof(szStickerDisplayName));
        IntToString(iStickerDefIndex, szStickerDefIndex, sizeof(szStickerDefIndex));
        Format(szTranslation, sizeof(szTranslation), "» %s", szStickerDisplayName);
        menu.AddItem(szStickerDefIndex, szTranslation);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_STICKERS_CATEGORY;
}

public int m_TweakStickersSelectionForCurrent(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }

            char szStickerDefIndex[12];
            menu.GetItem(option, szStickerDefIndex, sizeof(szStickerDefIndex));
            int iStickerDefIndex = StringToInt(szStickerDefIndex);

            int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

            eTweaker_AttachStickerToWeapon(client, iWeaponDefIndex, iStickerDefIndex, ClientInfo[client].StickerSlotStored);
            int iWeapon = eItems_GetActiveWeapon(client);
            eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
            Tweaks_BuildStickersSelectionMenuForCurrent(client, ClientInfo[client].StickerSetStored, GetMenuSelectionPosition());

            if(g_cvForceFullUpdate.BoolValue)
            {
                PTaH_ForceFullUpdate(client);
            }
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildStickersCategoryMenuForCurrent(client, ClientInfo[client].MenuCategorySelection);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Tweaks_BuildPatchesSelectionMenuForCurrent(int client, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(!IsPlayerAlive(client))
    {
        eTweaker_PrintOnlyForAlivePlayers(client);
        return;
    }

    int iStickerSlot = ClientInfo[client].StickerSlotStored;
    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
    char szWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

    Menu menu = new Menu(m_TweakPatchesSelectionForCurrent);
    menu.SetTitle("★ Tweaks Menu - Patches Stickers (slot %i) ★ \n ", iStickerSlot + 1);

    char szPatchDisplayName[48];
    char szPatchDefIndex[12];
    char szTranslation[256];
    for(int iPatchNum = 0; iPatchNum < eTweaker_GetPatchesCount(); iPatchNum++)
    {
        eItems_GetPatchDisplayNameByPatchNum(iPatchNum, szPatchDisplayName, sizeof(szPatchDisplayName));
        Format(szTranslation, sizeof(szTranslation), "» %s", szPatchDisplayName);
        int iStickerDefIndex = eItems_GetPatchDefIndexByPatchNum(iPatchNum);
        IntToString(iStickerDefIndex, szPatchDefIndex, sizeof(szPatchDefIndex));
        menu.AddItem(szPatchDefIndex, szTranslation);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
    ClientInfo[client].WeaponSwitch = SWITCH_TWEAKS_CURRENT_STICKERS_CATEGORY;
}

public int m_TweakPatchesSelectionForCurrent(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(eTweaker_IsClientSpectating(client))
            {
                eTweaker_PrintNotAvailableInSpec(client);
                return;
            }

            if(!IsPlayerAlive(client))
            {
                eTweaker_PrintOnlyForAlivePlayers(client);
                return;
            }

            char szPatchDefIndex[12];
            menu.GetItem(option, szPatchDefIndex, sizeof(szPatchDefIndex));
            int iPatchDefIndex = StringToInt(szPatchDefIndex);

            int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

            eTweaker_AttachStickerToWeapon(client, iWeaponDefIndex, iPatchDefIndex, ClientInfo[client].StickerSlotStored);
            int iWeapon = eItems_GetActiveWeapon(client);
            eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
            Tweaks_BuildPatchesSelectionMenuForCurrent(client, GetMenuSelectionPosition());

            if(g_cvForceFullUpdate.BoolValue)
            {
                PTaH_ForceFullUpdate(client);
            }
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponSwitch = -1;
            if(option == MenuCancel_ExitBack)
            {
                Tweaks_BuildStickersCategoryMenuForCurrent(client, ClientInfo[client].MenuCategorySelection);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}