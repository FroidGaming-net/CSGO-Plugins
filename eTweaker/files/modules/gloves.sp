public Action Command_Gloves(int client, int args)
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

    // if(eTweaker_IsClientNotInGroup(client))
    // {
    //     eTweaker_PrintNotInGroup(client);
    //     return Plugin_Handled;
    // }

    Gloves_BuildMainMenu(client);
    return Plugin_Handled;
}

stock void Gloves_BuildMainMenu(int client, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    char szGlovesDefIndex[12];
    char szGlovesDisplayName[48];
    char szTranslation[256];

    Menu menu = new Menu(m_BuildGlovesMainMenu);

    Format(szTranslation, sizeof(szTranslation), "★ Gloves Menu - Select Gloves ★");
    menu.SetTitle(szTranslation);

    Format(szTranslation, sizeof(szTranslation), "• Default Gloves");
    menu.AddItem("#0", szTranslation);
    for(int iGlovesNum = 0; iGlovesNum < eTweaker_GetGlovesCount(); iGlovesNum++)
    {
        int iGloveDefIndex = eItems_GetGlovesDefIndexByGlovesNum(iGlovesNum);

        IntToString(iGloveDefIndex, szGlovesDefIndex, sizeof(szGlovesDefIndex));

        eItems_GetGlovesDisplayNameByDefIndex(iGloveDefIndex, szGlovesDisplayName, sizeof(szGlovesDisplayName));

        Format(szTranslation, sizeof(szTranslation), "• %s", szGlovesDisplayName);
        menu.AddItem(szGlovesDefIndex, szTranslation);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_BuildGlovesMainMenu(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            switch(option)
            {
                case 0:
                {
                    ClientInfo[client].GlovesStoredDefIndex = -1;
                    switch(g_cvSelectTeamMode.IntValue)
                    {
                        case 1, 2:
                        {
                            int iTeam = g_cvSelectTeamMode.IntValue == 1 ? ClientInfo[client].Team() : -1;
                            eTwekaer_SetClientTeamGloves(client, -1, -1, iTeam);
                            eTweaker_EquipGloves(client, true);
                            Gloves_BuildMainMenu(client);
                        }
                        case 3:
                        {
                            Gloves_BuildTeamSelectionMenu(client, -1);
                        }
                    }

                }
                default:
                {
                    char szGlovesDefIndex[12];
                    menu.GetItem(option, szGlovesDefIndex, sizeof(szGlovesDefIndex));

                    int iGlovesDefIndex = StringToInt(szGlovesDefIndex);
                    Gloves_BuildGlovesSkinMenu(client, iGlovesDefIndex);
                    ClientInfo[client].MenuCategorySelection = GetMenuSelectionPosition();
                    ClientInfo[client].GlovesStoredDefIndex = iGlovesDefIndex;
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

stock void Gloves_BuildGlovesSkinMenu(int client, int iGlovesDefIndex, int iPosition = 0)
{

    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    if(iGlovesDefIndex == -1)
    {
        Gloves_BuildMainMenu(client);
        return;
    }

    Menu menu = new Menu(m_BuildGlovesSkinMenu);

    char szGlovesDisplayName[48];
    char szTranslation[256];

    eItems_GetGlovesDisplayNameByDefIndex(iGlovesDefIndex, szGlovesDisplayName, sizeof(szGlovesDisplayName));

    menu.SetTitle("★ Gloves Menu - %s ★ \n ", szGlovesDisplayName);

    int iGlovesNum = eItems_GetGlovesNumByDefIndex(iGlovesDefIndex);
    for(int iSkinNum = 0; iSkinNum < eTweaker_GetSkinsCount(); iSkinNum++)
    {
        if(!eItems_IsNativeSkin(iSkinNum, iGlovesNum, ITEMTYPE_GLOVES))
        {
            continue;
        }

        int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkinNum);

        char szSkinDisplayName[48];
        char szSkinDefIndex[12];
        IntToString(iSkinDefIndex, szSkinDefIndex, sizeof(szSkinDefIndex));
        eItems_GetSkinDisplayNameByDefIndex(iSkinDefIndex, szSkinDisplayName, sizeof(szSkinDisplayName));

        Format(szTranslation, sizeof(szTranslation), "» %s", szSkinDisplayName);
        menu.AddItem(szSkinDefIndex, szTranslation);
    }

    menu.ExitBackButton = true;

    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_BuildGlovesSkinMenu(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            char szSkinDefIndex[12];
            menu.GetItem(option, szSkinDefIndex, sizeof(szSkinDefIndex));

            int iSkinDefIndex = StringToInt(szSkinDefIndex);
            switch(g_cvSelectTeamMode.IntValue)
            {
                case 1, 2:
                {
                    int iTeam = g_cvSelectTeamMode.IntValue == 1 ? ClientInfo[client].Team() : -1;
                    eTwekaer_SetClientTeamGloves(client, ClientInfo[client].GlovesStoredDefIndex, iSkinDefIndex, iTeam);
                    eTweaker_EquipGloves(client);
                    Gloves_BuildGlovesSkinMenu(client, ClientInfo[client].GlovesStoredDefIndex, GetMenuSelectionPosition());
                }
                case 3:
                {
                    Gloves_BuildTeamSelectionMenu(client, iSkinDefIndex);
                    ClientInfo[client].MenuSelection = GetMenuSelectionPosition();
                }
            }
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Gloves_BuildMainMenu(client, ClientInfo[client].MenuCategorySelection);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Gloves_BuildTeamSelectionMenu(int client, int iSkinDefIndex)
{
    char szSkinDisplayName[48];
    if(iSkinDefIndex == -1)
    {
        Format(szSkinDisplayName, sizeof(szSkinDisplayName), "Default Gloves");
    }
    else
    {
        eItems_GetSkinDisplayNameByDefIndex(iSkinDefIndex, szSkinDisplayName, sizeof(szSkinDisplayName));
    }

    Menu menu = new Menu(m_BuildTeamSelectionMenu_Gloves);

    char szSkinDefIndex[12];
    char szTranslation[256];
    IntToString(iSkinDefIndex, szSkinDefIndex, sizeof(szSkinDefIndex));

    Format(szTranslation, sizeof(szTranslation), "★ Gloves Menu - %s ★ \n \nSelect Team:\n ", szSkinDisplayName);
    menu.SetTitle(szTranslation);

    Format(szTranslation, sizeof(szTranslation), "» CT Team");
    menu.AddItem(szSkinDefIndex, szTranslation, ClientInfo[client].GlovesCT.SkinDefIndex == iSkinDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    Format(szTranslation, sizeof(szTranslation), "» T Team");
    menu.AddItem("#1", szTranslation, ClientInfo[client].GlovesT.SkinDefIndex == iSkinDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    Format(szTranslation, sizeof(szTranslation), "» Both Teams");
    menu.AddItem("#2", szTranslation, (ClientInfo[client].GlovesCT.SkinDefIndex == iSkinDefIndex && ClientInfo[client].GlovesT.SkinDefIndex == iSkinDefIndex) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_BuildTeamSelectionMenu_Gloves(Menu menu, MenuAction action, int client, int option)
{
    bool bRemoveGloves = false;
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
            menu.GetItem(0, szSkinDefIndex, sizeof(szSkinDefIndex));

            int iSkinDefIndex = StringToInt(szSkinDefIndex);
            bRemoveGloves = iSkinDefIndex == -1 ? true : false;
            switch(option)
            {
                case 0:
                {
                    eTwekaer_SetClientTeamGloves(client, ClientInfo[client].GlovesStoredDefIndex, iSkinDefIndex, CS_TEAM_CT);
                    if(ClientInfo[client].Team() == CS_TEAM_CT)
                    {
                        eTweaker_EquipGloves(client, bRemoveGloves);
                    }
                }
                case 1:
                {
                    eTwekaer_SetClientTeamGloves(client, ClientInfo[client].GlovesStoredDefIndex, iSkinDefIndex, CS_TEAM_T);
                    if(ClientInfo[client].Team() == CS_TEAM_T)
                    {
                        eTweaker_EquipGloves(client, bRemoveGloves);
                    }
                }
                case 2:
                {
                    eTwekaer_SetClientTeamGloves(client, ClientInfo[client].GlovesStoredDefIndex, iSkinDefIndex, -1);
                    eTweaker_EquipGloves(client , bRemoveGloves);
                }
            }
            Gloves_BuildTeamSelectionMenu(client, iSkinDefIndex);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Gloves_BuildGlovesSkinMenu(client, ClientInfo[client].GlovesStoredDefIndex, ClientInfo[client].MenuSelection);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}
