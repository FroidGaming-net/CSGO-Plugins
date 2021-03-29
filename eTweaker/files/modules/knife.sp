public Action Command_Knife(int client, int args)
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

    if(eTweaker_IsClientNotInGroup(client))
    {
        eTweaker_PrintNotInGroup(client);
        return Plugin_Handled;
    }

    switch(args)
    {
        case 0: Knife_BuildMainMenu(client);
        case 1:
        {
            char szKnifeName[48];
            GetCmdArg(1, szKnifeName, sizeof(szKnifeName));

            int iSelectedKnife = eTwekaer_GetClientTeamKnife(client);

            if(StrEqual(szKnifeName, "default", false))
            {
                if(iSelectedKnife == -1)
                {
                    CPrintToChat(client, "%s This knife is already selected.", PREFIX);
                    return Plugin_Handled;
                }
                eTwekaer_SetClientTeamKnife(client, -1);
                eTweaker_EquipKnife(client);
                return Plugin_Handled;
            }

            int iKnifeDefIndex = eTweaker_FindKnifeDefIndexByName(szKnifeName);

            if(StrEqual(szKnifeName, "bayonet", false))
            {
                iKnifeDefIndex = KNIFE_BAYONET;
            }

            if(eTweaker_IsDangerZoneKnife(iKnifeDefIndex) && !g_cvDangerZoneKnives.BoolValue)
            {
                PrintToChat(client, "%s DangerZone knives are disabled on this server.", PREFIX);
                return Plugin_Handled;
            }

            switch(iKnifeDefIndex)
            {
                case -1:    CPrintToChat(client, "%s More knives found. Please be more specific.", PREFIX);
                case 0:     CPrintToChat(client, "%s No knife found.", PREFIX);
                default:
                {

                    if(iSelectedKnife == iKnifeDefIndex)
                    {
                        CPrintToChat(client, "%s This knife is already selected.", PREFIX);
                        return Plugin_Handled;
                    }

                    eTwekaer_SetClientTeamKnife(client, iKnifeDefIndex);
                    eTweaker_EquipKnife(client);
                }
            }
        }
        default:
        {
            CPrintToChat(client, "%s Usage: sm_knife / sm_knife <knife name>", PREFIX);
        }
    }
    return Plugin_Handled;
}

stock void Knife_BuildMainMenu(int client, int iPosition = 0)
{
    char szDisplayName[48];
    char szDefIndex[12];
    char szTranslation[256];
    Menu menu = new Menu(m_Knife);

    menu.SetTitle("★ Knife Menu - Select Knife ★ \n ");
    Format(szTranslation, sizeof(szTranslation), "» Default");
    menu.AddItem("-1", szTranslation);

    for(int iKnifeNum = 0; iKnifeNum < eTweaker_GetWeaponCount(); iKnifeNum++)
    {
        int iKnifeDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iKnifeNum);

        if(!eItems_IsDefIndexKnife(iKnifeDefIndex))
        {
            continue;
        }

        if(eTweaker_IsKnifeForbidden(iKnifeDefIndex))
        {
            continue;
        }

        if(!g_cvDangerZoneKnives.BoolValue && eTweaker_IsDangerZoneKnife(iKnifeDefIndex))
        {
            continue;
        }

        IntToString(iKnifeDefIndex, szDefIndex, sizeof(szDefIndex));
        eItems_GetWeaponDisplayNameByDefIndex(iKnifeDefIndex, szDisplayName, sizeof(szDisplayName));
        Format(szTranslation, sizeof(szTranslation), "» %s", szDisplayName);
        menu.AddItem(szDefIndex, szTranslation);
    }

    menu.ExitBackButton = true;
    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }

}


public int m_Knife(Menu menu, MenuAction action, int client, int option)
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
            char szDefIndex[12];
            menu.GetItem(option, szDefIndex, sizeof(szDefIndex));

            int iKnifeDefIndex = StringToInt(szDefIndex);

            switch(g_cvSelectTeamMode.IntValue)
            {
                case 1, 2:
                {
                    int iTeam = g_cvSelectTeamMode.IntValue == 1 ? ClientInfo[client].Team() : -1;
                    eTwekaer_SetClientTeamKnife(client, iKnifeDefIndex, iTeam);
                    eTweaker_EquipKnife(client);
                    Knife_BuildMainMenu(client, GetMenuSelectionPosition());
                }
                case 3:
                {
                    ClientInfo[client].MenuSelection = GetMenuSelectionPosition();
                    ClientInfo[client].WeaponStoredDefIndex = iKnifeDefIndex;
                    Knife_BuildTeamSelectionMenu(client, iKnifeDefIndex);
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

stock void Knife_BuildTeamSelectionMenu(int client, int iKnifeDefIndex)
{
    char szKnifeDisplayName[48];
    char szTranslation[256];
    eItems_GetWeaponDisplayNameByDefIndex(iKnifeDefIndex, szKnifeDisplayName, sizeof(szKnifeDisplayName));
    Menu menu = new Menu(m_BuildTeamSelectionMenu_knife);

    Format(szTranslation, sizeof(szTranslation), "★ Knife Menu - %s ★ \n \nSelect Team:\n ", szKnifeDisplayName);
    menu.SetTitle(szTranslation);

    Format(szTranslation, sizeof(szTranslation), "» CT Team");
    menu.AddItem("#0", szTranslation, ClientInfo[client].Knife.CT == iKnifeDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    Format(szTranslation, sizeof(szTranslation), "» T Team");
    menu.AddItem("#1", szTranslation, ClientInfo[client].Knife.T == iKnifeDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    Format(szTranslation, sizeof(szTranslation), "» Both Teams");
    menu.AddItem("#2", szTranslation, (ClientInfo[client].Knife.CT == iKnifeDefIndex && ClientInfo[client].Knife.T == iKnifeDefIndex) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_BuildTeamSelectionMenu_knife(Menu menu, MenuAction action, int client, int option)
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
            int iKnifeDefIndex = ClientInfo[client].WeaponStoredDefIndex;

            switch(option)
            {
                case 0:
                {
                    eTwekaer_SetClientTeamKnife(client, iKnifeDefIndex, CS_TEAM_CT);
                    if(ClientInfo[client].Team() == CS_TEAM_CT)
                    {
                        eTweaker_EquipKnife(client);
                    }
                }
                case 1:
                {
                    eTwekaer_SetClientTeamKnife(client, iKnifeDefIndex, CS_TEAM_T);
                    if(ClientInfo[client].Team() == CS_TEAM_T)
                    {
                        eTweaker_EquipKnife(client);
                    }
                }
                case 2:
                {
                    eTwekaer_SetClientTeamKnife(client, iKnifeDefIndex, -1);
                    eTweaker_EquipKnife(client);
                }
            }
            Knife_BuildTeamSelectionMenu(client, iKnifeDefIndex);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Knife_BuildMainMenu(client, ClientInfo[client].MenuSelection);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}
