public void Skins_BuildMainMenu(int client)
{

    char szTranslation[256];
    Menu menu = new Menu(m_Paints);

    menu.SetTitle("★ Skins Menu - Weapon Skins ★ \n ", client);

    Format(szTranslation, sizeof(szTranslation), "• All weapon skins\n‎‎‎‎‎‏‏‎ ‎❯ Apply ANY skin to your current weapon.");
    menu.AddItem("#0", szTranslation, ClientInfo[client].Alive() ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    Format(szTranslation, sizeof(szTranslation), "• Current weapon skins only\n‎‎‎‎‎‏‏‎ ‎❯ Apply a skin for current weapon.");
    menu.AddItem("#1", szTranslation, ClientInfo[client].Alive() ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    Format(szTranslation, sizeof(szTranslation), "• Primary weapons\n‎‎‎‎‎‏‏‎ ‎❯ Apply a skin to your primary weapon.");
    menu.AddItem("#2", szTranslation);

    Format(szTranslation, sizeof(szTranslation), "• Secondary weapons\n ‎❯ Apply a skin to your secondary weapon.");
    menu.AddItem("#3", szTranslation);

    Format(szTranslation, sizeof(szTranslation), "• Knife skins\n ‎‎‎‎‎‏‎❯ Apply a skin to ANY knife.");
    menu.AddItem("#4", szTranslation);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_Paints(Menu menu, MenuAction action, int client, int option)
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
                case 0: Skins_BuildAllWeaponSkinsMenu(client);
                case 1: Skins_BuildCurrentWeaponSkinsMenu(client);
                case 2: Skins_BuildWeaponSlotSkinsMenu(client, CS_SLOT_PRIMARY);
                case 3: Skins_BuildWeaponSlotSkinsMenu(client, CS_SLOT_SECONDARY);
                case 4: Skins_BuildWeaponSlotSkinsMenu(client, CS_SLOT_KNIFE);
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

stock void Skins_BuildAllWeaponSkinsMenu(int client, int iPosition = 0)
{
    if(!IsPlayerAlive(client))
    {
        return;
    }

    char szTranslation[256];
    Menu menu = new Menu(m_AllWeapons);

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);

    if(iWeaponDefIndex == -1)
    {
        Format(szTranslation, sizeof(szTranslation), "Unknown weapon");
        menu.SetTitle("★ Skins Menu - %s ★ \n ", szTranslation);
        menu.AddItem("#0", szTranslation, ITEMDRAW_DISABLED);
    }
    else
    {
        char szWeaponDisplayName[48];
        char szSkinDisplayName[48];
        char szSkinDefIndex[12];
        char szWeaponDefIndex[12];
        int iPaintKit = 0;

        IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

        eWeaponSettings WeaponSettings;
        if(g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings)))
        {
            iPaintKit = WeaponSettings.PaintKit;
        }

        eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        menu.SetTitle("★ Skins Menu - %s ★ \n ", szWeaponDisplayName);

        if(!eItems_IsSkinnableDefIndex(iWeaponDefIndex))
        {
            Format(szTranslation, sizeof(szTranslation), "» This weapon is not skinnable!");
            menu.AddItem("#0", szTranslation, ITEMDRAW_DISABLED);
        }
        else
        {
            for(int iSkinNum = 0; iSkinNum < eTweaker_GetSkinsCount(); iSkinNum++)
            {
                int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkinNum);

                IntToString(iSkinDefIndex, szSkinDefIndex, sizeof(szSkinDefIndex));
                eItems_GetSkinDisplayNameByDefIndex(iSkinDefIndex, szSkinDisplayName, sizeof(szSkinDisplayName));
                Format(szTranslation, sizeof(szTranslation), "» %s", szSkinDisplayName);
                menu.AddItem(szSkinDefIndex, szTranslation, iPaintKit == iSkinDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
            }
        }
    }

    menu.ExitBackButton = true;
    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }

    ClientInfo[client].WeaponSwitch = SWITCH_ALLWEAPONS;
}

public int m_AllWeapons(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(IsPlayerAlive(client))
            {
                int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
                int iWeapon = eItems_GetActiveWeapon(client);
                char szWeaponDefIndex[12];
                char szSkinDisplayName[48];
                IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

                eWeaponSettings WeaponSettings;
                g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

                char szSkinDefIndex[12];
                menu.GetItem(option, szSkinDefIndex, sizeof(szSkinDefIndex));

                WeaponSettings.PaintKit = StringToInt(szSkinDefIndex);
                WeaponSettings.Changed = true;

                g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

                if(eItems_IsDefIndexKnife(iWeaponDefIndex))
                {
                    eTweaker_EquipKnife(client);
                }else{
                    eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
                }

                eItems_GetSkinDisplayNameByDefIndex(WeaponSettings.PaintKit, szSkinDisplayName, sizeof(szSkinDisplayName));

                char szTranslation[256];
                Format(szTranslation, sizeof(szTranslation), "You have selected {lime}%s{default} skin.", szSkinDisplayName);
                CPrintToChat(client, "%s %s", PREFIX, szTranslation);
            }

            Skins_BuildAllWeaponSkinsMenu(client, GetMenuSelectionPosition());
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Skins_BuildMainMenu(client);
            }
            ClientInfo[client].WeaponSwitch = -1;
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Skins_BuildCurrentWeaponSkinsMenu(int client, int iPosition = 0)
{
    if(!IsPlayerAlive(client))
    {
        return;
    }

    char szTranslation[256];
    Menu menu = new Menu(m_CurrentWeapon);

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
    int iWeaponNum = eItems_GetWeaponNumByDefIndex(iWeaponDefIndex);

    if(iWeaponDefIndex == -1)
    {
        Format(szTranslation, sizeof(szTranslation), "Unknown weapon");
        menu.SetTitle("★ Skins Menu - %s ★ \n ", szTranslation);
        menu.AddItem("#0", szTranslation, ITEMDRAW_DISABLED);
    }
    else
    {
        char szWeaponDisplayName[48];
        char szSkinDisplayName[48];
        char szSkinDefIndex[12];
        char szWeaponDefIndex[12];
        int iPaintKit = 0;

        IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

        eWeaponSettings WeaponSettings;
        if(g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings)))
        {
            iPaintKit = WeaponSettings.PaintKit;
        }

        eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        menu.SetTitle("★ Skins Menu - %s ★ \n ", szWeaponDisplayName);

        if(!eItems_IsSkinnableDefIndex(iWeaponDefIndex))
        {
            Format(szTranslation, sizeof(szTranslation), "» This weapon is not skinnable!");
            menu.AddItem("#0", szTranslation, ITEMDRAW_DISABLED);
        }
        else
        {
            Format(szTranslation, sizeof(szTranslation), "» Default");
            menu.AddItem("#0", szTranslation, iPaintKit == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
            for(int iSkinNum = 0; iSkinNum < eTweaker_GetSkinsCount(); iSkinNum++)
            {
                int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkinNum);
                if(!eItems_IsNativeSkin(iSkinNum, iWeaponNum, ITEMTYPE_WEAPON))
                {
                    continue;
                }

                IntToString(iSkinDefIndex, szSkinDefIndex, sizeof(szSkinDefIndex));
                eItems_GetSkinDisplayNameByDefIndex(iSkinDefIndex, szSkinDisplayName, sizeof(szSkinDisplayName));
                Format(szTranslation, sizeof(szTranslation), "» %s", szSkinDisplayName);
                menu.AddItem(szSkinDefIndex, szTranslation, iPaintKit == iSkinDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
            }
        }
    }

    menu.ExitBackButton = true;
    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }

    ClientInfo[client].WeaponSwitch = SWITCH_CURRENTWEAPON;
}

public int m_CurrentWeapon(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            if(IsPlayerAlive(client))
            {
                int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
                int iWeapon = eItems_GetActiveWeapon(client);
                char szWeaponDefIndex[12];
                char szSkinDisplayName[48];
                char szTranslation[256];
                IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

                eWeaponSettings WeaponSettings;
                g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
                switch(option)
                {

                    case 0:
                    {
                        WeaponSettings.PaintKit = 0;
                        Format(szSkinDisplayName, sizeof(szSkinDisplayName), "Default");
                    }
                    default:
                    {
                        char szSkinDefIndex[12];
                        menu.GetItem(option, szSkinDefIndex, sizeof(szSkinDefIndex));
                        WeaponSettings.PaintKit = StringToInt(szSkinDefIndex);
                        eItems_GetSkinDisplayNameByDefIndex(WeaponSettings.PaintKit, szSkinDisplayName, sizeof(szSkinDisplayName));
                    }
                }
                WeaponSettings.Changed = true;
                g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

                if(eItems_IsDefIndexKnife(iWeaponDefIndex))
                {
                    eTweaker_EquipKnife(client);
                }else{
                    eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
                }
                Format(szTranslation, sizeof(szTranslation), "You have selected {lime}%s{default} skin.", szSkinDisplayName);
                CPrintToChat(client, "%s %s", PREFIX, szTranslation);
            }
            Skins_BuildCurrentWeaponSkinsMenu(client, GetMenuSelectionPosition());
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Skins_BuildMainMenu(client);
            }
            ClientInfo[client].WeaponSwitch = -1;
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Skins_BuildWeaponSlotSkinsMenu(int client, int iSlot)
{

    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    Menu menu = new Menu(m_WeaponSlot);

    switch(iSlot)
    {
        case CS_SLOT_PRIMARY:   menu.SetTitle("★ Skins Menu - Primary weapons ★ \n ");
        case CS_SLOT_SECONDARY: menu.SetTitle("★ Skins Menu - Secondary weapons ★ \n ");
        case CS_SLOT_KNIFE:     menu.SetTitle("★ Skins Menu - Knives ★ \n ");
    }

    for(int iWeaponNum = 0; iWeaponNum < eTweaker_GetWeaponCount(); iWeaponNum++)
    {
        int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
        if(eItems_GetWeaponSlotByDefIndex(iWeaponDefIndex) != iSlot)
        {
            continue;
        }

        if(!eItems_IsSkinnableDefIndex(iWeaponDefIndex))
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

public int m_WeaponSlot(Menu menu, MenuAction action, int client, int option)
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

            Skins_BuildWeaponSkinsByDefIndex(client, iWeaponDefIndex);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Skins_BuildMainMenu(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Skins_BuildWeaponSkinsByDefIndex(int client, int iWeaponDefIndex, int iPosition = 0)
{

    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }
    Menu menu = new Menu(m_WeaponSkinsByDefIndex);
    char szWeaponDisplayName[48];
    char szWeaponDefIndex[12];
    int iPaintKit = 0;
    char szTranslation[256];

    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
    eItems_GetWeaponDisplayNameByDefIndex(iWeaponDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    eWeaponSettings WeaponSettings;
    if(g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings)))
    {
        iPaintKit = WeaponSettings.PaintKit;
    }

    menu.SetTitle("★ Skins Menu - %s ★ \n ", szWeaponDisplayName);
    int iWeaponNum = eItems_GetWeaponNumByDefIndex(iWeaponDefIndex);

    Format(szTranslation, sizeof(szTranslation), "» Default");
    menu.AddItem("#0", szTranslation, iPaintKit == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    for(int iSkinNum = 0; iSkinNum < eTweaker_GetSkinsCount(); iSkinNum++)
    {
        if(!eItems_IsNativeSkin(iSkinNum, iWeaponNum, ITEMTYPE_WEAPON))
        {
            continue;
        }

        char szSkinDisplayName[48];
        char szSkinDefIndex[12];
        int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkinNum);

        eItems_GetSkinDisplayNameByDefIndex(iSkinDefIndex, szSkinDisplayName, sizeof(szSkinDisplayName));
        IntToString(iSkinDefIndex, szSkinDefIndex, sizeof(szSkinDefIndex));
        g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
        Format(szTranslation, sizeof(szTranslation), "» %s", szSkinDisplayName);
        menu.AddItem(szSkinDefIndex, szTranslation, WeaponSettings.PaintKit == iSkinDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }
    menu.ExitBackButton = true;
    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_WeaponSkinsByDefIndex(Menu menu, MenuAction action, int client, int option)
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
            char szSkinDisplayName[48];
            char szWeaponDisplayName[48];

            char szWeaponDefIndex[12];

            char szTranslation[256];
            IntToString(ClientInfo[client].WeaponStoredDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            switch(option)
            {

                case 0:
                {
                    WeaponSettings.PaintKit = 0;
                    Format(szSkinDisplayName, sizeof(szSkinDisplayName), "Default");
                }
                default:
                {
                    char szSkinDefIndex[12];
                    menu.GetItem(option, szSkinDefIndex, sizeof(szSkinDefIndex));
                    WeaponSettings.PaintKit = StringToInt(szSkinDefIndex);
                    eItems_GetSkinDisplayNameByDefIndex(WeaponSettings.PaintKit, szSkinDisplayName, sizeof(szSkinDisplayName));
                }
            }

            WeaponSettings.Changed = true;
            g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            eItems_GetWeaponDisplayNameByDefIndex(ClientInfo[client].WeaponStoredDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));

            Format(szTranslation, sizeof(szTranslation), "You have selected {lime}%s{default} skin for {lime}%s{default}.", szSkinDisplayName, szWeaponDisplayName);
            CPrintToChat(client, "%s %s", PREFIX, szTranslation);

            int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);

            if(eItems_IsValidWeapon(iWeapon))
            {
                if(eItems_IsDefIndexKnife(ClientInfo[client].WeaponStoredDefIndex))
                {
                    eTweaker_EquipKnife(client);
                }else{
                    eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
                }
            }

            Skins_BuildWeaponSkinsByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex, GetMenuSelectionPosition());
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Skins_BuildWeaponSlotSkinsMenu(client, eItems_GetWeaponSlotByDefIndex(ClientInfo[client].WeaponStoredDefIndex));
            }
            ClientInfo[client].WeaponStoredDefIndex = -1;
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Skins_BuildWeaponSkinsMenuBySkinName(int client, int iWeaponDefIndex, char[] szSkinName, int iPosition = 0)
{

    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    ClientInfo[client].WeaponStoredDefIndex = iWeaponDefIndex;
    strcopy(ClientInfo[client].StoredSkinName, sizeof(eClientInfo::StoredSkinName), szSkinName);
    char szFoundSkinName[48];
    char szSkinDefIndex[12];
    char szWeaponDefIndex[12];
    char szTranslation[256];

    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
    int iWeaponNum = eItems_GetWeaponNumByDefIndex(iWeaponDefIndex);

    Menu menu = new Menu(m_WeaponSkinsMenuBySkinName);

    szSkinName[0] = CharToUpper(szSkinName[0]);

    menu.SetTitle("★ Skins Menu - %s skins ★ \n ", szSkinName);

    for(int iSkinNum = 0; iSkinNum < eTweaker_GetSkinsCount(); iSkinNum++)
    {

        if(!eItems_IsNativeSkin(iSkinNum, iWeaponNum, ITEMTYPE_WEAPON))
        {
            continue;
        }

        eItems_GetSkinDisplayNameBySkinNum(iSkinNum, szFoundSkinName, sizeof(szFoundSkinName));

        if(StrContains(szFoundSkinName, szSkinName, false) == -1)
        {
            continue;
        }

        int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkinNum);
        IntToString(iSkinDefIndex, szSkinDefIndex, sizeof(szSkinDefIndex));

        eWeaponSettings WeaponSettings;
        g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
        Format(szTranslation, sizeof(szTranslation), "» %s", szFoundSkinName);
        menu.AddItem(szSkinDefIndex, szTranslation, WeaponSettings.PaintKit == iSkinDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }

    menu.ExitButton = true;
    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_WeaponSkinsMenuBySkinName(Menu menu, MenuAction action, int client, int option)
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
            char szSkinDefIndex[12];
            char szWeaponDefIndex[12];
            char szSkinDisplayName[48];

            IntToString(ClientInfo[client].WeaponStoredDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
            menu.GetItem(option, szSkinDefIndex, sizeof(szSkinDefIndex));

            int iSkinDefIndex = StringToInt(szSkinDefIndex);

            eItems_GetSkinDisplayNameByDefIndex(iSkinDefIndex, szSkinDisplayName, sizeof(szSkinDisplayName));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            WeaponSettings.PaintKit = iSkinDefIndex;
            WeaponSettings.Changed = true;
            g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);

            if(eItems_IsValidWeapon(iWeapon))
            {
                if(eItems_IsDefIndexKnife(ClientInfo[client].WeaponStoredDefIndex))
                {
                    eTweaker_EquipKnife(client);
                }else{
                    eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
                }
            }
            Skins_BuildWeaponSkinsMenuBySkinName(client, ClientInfo[client].WeaponStoredDefIndex, ClientInfo[client].StoredSkinName, GetMenuSelectionPosition());

            char szTranslation[256];
            Format(szTranslation, sizeof(szTranslation), "You have selected {lime}%s{default} skin.", szSkinDisplayName);
            CPrintToChat(client, "%s %s", PREFIX, szTranslation);
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponStoredDefIndex = -1;
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Skins_BuildSkinsMenuBySkinName(int client, char[] szSkinName, int iPosition = 0)
{

    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    int iWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
    ClientInfo[client].WeaponStoredDefIndex = iWeaponDefIndex;
    strcopy(ClientInfo[client].StoredSkinName, sizeof(eClientInfo::StoredSkinName), szSkinName);
    char szFoundSkinName[48];
    char szSkinDefIndex[12];
    char szWeaponDefIndex[12];

    IntToString(iWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));

    Menu menu = new Menu(m_WeaponAllSkinsMenuBySkinName);

    szSkinName[0] = CharToUpper(szSkinName[0]);

    menu.SetTitle("★ Skins Menu - %s skins ★ \n ", szSkinName);

    for(int iSkinNum = 0; iSkinNum < eTweaker_GetSkinsCount(); iSkinNum++)
    {

        eItems_GetSkinDisplayNameBySkinNum(iSkinNum, szFoundSkinName, sizeof(szFoundSkinName));

        if(StrContains(szFoundSkinName, szSkinName, false) == -1)
        {
            continue;
        }

        int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkinNum);
        IntToString(iSkinDefIndex, szSkinDefIndex, sizeof(szSkinDefIndex));

        eWeaponSettings WeaponSettings;
        g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
        menu.AddItem(szSkinDefIndex, szFoundSkinName, WeaponSettings.PaintKit == iSkinDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }

    menu.ExitButton = true;
    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_WeaponAllSkinsMenuBySkinName(Menu menu, MenuAction action, int client, int option)
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


            char szSkinDefIndex[12];
            char szWeaponDefIndex[12];
            char szSkinDisplayName[48];

            IntToString(ClientInfo[client].WeaponStoredDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
            menu.GetItem(option, szSkinDefIndex, sizeof(szSkinDefIndex));

            int iSkinDefIndex = StringToInt(szSkinDefIndex);

            eItems_GetSkinDisplayNameByDefIndex(iSkinDefIndex, szSkinDisplayName, sizeof(szSkinDisplayName));

            eWeaponSettings WeaponSettings;
            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            WeaponSettings.PaintKit = iSkinDefIndex;
            WeaponSettings.Changed = true;
            g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            int iWeapon = eItems_FindWeaponByDefIndex(client, ClientInfo[client].WeaponStoredDefIndex);

            if(eItems_IsValidWeapon(iWeapon))
            {
                if(eItems_IsDefIndexKnife(ClientInfo[client].WeaponStoredDefIndex))
                {
                    eTweaker_EquipKnife(client);
                }else{
                    eItems_RespawnWeapon(client, iWeapon, g_cvDrawAnimation.BoolValue);
                }
            }
            Skins_BuildSkinsMenuBySkinName(client, ClientInfo[client].StoredSkinName, GetMenuSelectionPosition());

            char szTranslation[256];
            Format(szTranslation, sizeof(szTranslation), "You have selected {lime}%s{default} skin.", szSkinDisplayName);
            CPrintToChat(client, "%s %s", PREFIX, szTranslation);
        }
        case MenuAction_Cancel:
        {
            ClientInfo[client].WeaponStoredDefIndex = -1;
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}