public Action Command_Ws(int client, int args)
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

    if(args > 3)
    {
        CPrintToChat(client, "%s Usage: sm_ws / sm_ws <skin name>", PREFIX);
        return Plugin_Handled;
    }
    switch(args)
    {
        case 0: Ws_BuildMainMenu(client);
        default:
        {
            char szSkinName[48];
            GetCmdArgString(szSkinName, sizeof(szSkinName));

            int iActiveWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
            int iActiveWeapon = eItems_GetActiveWeapon(client);

            int iSkinDef = eTweaker_FindWeaponSkinDefIndexByName(iActiveWeaponDefIndex, szSkinName);

            switch(iSkinDef)
            {
                case -1:    Skins_BuildWeaponSkinsMenuBySkinName(client, iActiveWeaponDefIndex, szSkinName);
                case 0:     CPrintToChat(client, "%s No skin found.", PREFIX);
                default:
                {
                    char szWeaponDefIndex[12];
                    char szSkinDisplayName[48];

                    IntToString(iActiveWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
                    eWeaponSettings WeaponSettings;

                    g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
                    WeaponSettings.PaintKit = iSkinDef;
                    WeaponSettings.Changed = true;
                    g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

                    if(eItems_IsDefIndexKnife(iActiveWeaponDefIndex))
                    {
                        eTweaker_EquipKnife(client);
                    }else{
                        eItems_RespawnWeapon(client, iActiveWeapon, g_cvDrawAnimation.BoolValue);
                    }

                    eItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));

                    CPrintToChat(client, "%s You have selected \x06%s\x01 skin.", PREFIX, szSkinDisplayName);
                }
            }
        }
    }
    return Plugin_Handled;
}

public void Ws_BuildMainMenu(int client)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    Menu menu = new Menu(m_Ws);
    menu.SetTitle("★ Main Menu - Select Menu ★ \n ");
    menu.AddItem("#0", "• Weapon skins\n ❯ Change the skin of any weapon.");
    menu.AddItem("#1", "• Weapon tweaks\n ❯ Change the stickers, wear, etc.");
    menu.AddItem("#2", "• Knife selection\n ❯ Equip any knife.");
    menu.AddItem("#3", "• Glove selection\n ❯ Equip any pair of gloves.");
    menu.AddItem("#4", "• Music Kit selection\n ❯ Equip any music kit.");
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_Ws(Menu menu, MenuAction action, int client, int option)
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
                case 0: Skins_BuildMainMenu(client);
                case 1: Tweaks_BuildMainMenu(client);
                case 2: Knife_BuildMainMenu(client);
                case 3: Gloves_BuildMainMenu(client);
                case 4: MusicKits_BuildMainMenu(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public Action Command_WsAll(int client, int args)
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

    if(args < 1)
    {
        CPrintToChat(client, "%s Usage: sm_wsa <skin name>", PREFIX);
        return Plugin_Handled;
    }
    char szSkinName[48];
    GetCmdArgString(szSkinName, sizeof(szSkinName));

    int iActiveWeaponDefIndex = eItems_GetActiveWeaponDefIndex(client);
    int iActiveWeapon = eItems_GetActiveWeapon(client);


    int iSkinDef = eTweaker_FindSkinDefIndexByName(szSkinName);
    switch(iSkinDef)
    {
        case -1:    Skins_BuildSkinsMenuBySkinName(client, szSkinName);
        case 0:     CPrintToChat(client, "%s No skin found.", PREFIX);
        default:
        {
            char szWeaponDefIndex[12];
            char szSkinDisplayName[48];

            IntToString(iActiveWeaponDefIndex, szWeaponDefIndex, sizeof(szWeaponDefIndex));
            eWeaponSettings WeaponSettings;

            g_smWeaponSettings[client].GetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));
            WeaponSettings.PaintKit = iSkinDef;
            WeaponSettings.Changed = true;

            g_smWeaponSettings[client].SetArray(szWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings));

            if(eItems_IsDefIndexKnife(iActiveWeaponDefIndex))
            {
                eTweaker_EquipKnife(client);
            }else{
                eItems_RespawnWeapon(client, iActiveWeapon, g_cvDrawAnimation.BoolValue);
            }

            eItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));

            CPrintToChat(client, "%s You have selected \x06%s\x01 skin.", PREFIX, szSkinDisplayName);
        }
    }
    return Plugin_Handled;
}