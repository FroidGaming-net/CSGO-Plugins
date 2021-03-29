public Action Command_Music(int client, int args)
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

    MusicKits_BuildMainMenu(client);
    return Plugin_Handled;
}

stock void MusicKits_BuildMainMenu(int client, int iPosition = 0)
{
    if(eTweaker_IsClientSpectating(client))
    {
        eTweaker_PrintNotAvailableInSpec(client);
        return;
    }

    char szDisplayName[48];
    char szDefIndex[12];
    char szTranslation[256];
    Menu menu = new Menu(m_MusicKits);

    Format(szTranslation, sizeof(szTranslation), "★ Music Kit Menu - Select Music Kit ★ \n ");
    menu.SetTitle(szTranslation);

    Format(szTranslation, sizeof(szTranslation), "» Default");
    menu.AddItem("#0", szTranslation, ClientInfo[client].MusicKit == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

    for(int iMusicKitNum = 0; iMusicKitNum < eTweaker_GetMusicKitsCount(); iMusicKitNum++)
    {
        int iMusicKitDefIndex = eItems_GetMusicKitDefIndexByMusicKitNum(iMusicKitNum);
        IntToString(iMusicKitDefIndex, szDefIndex, sizeof(szDefIndex));

        eItems_GetMusicKitDisplayNameByDefIndex(iMusicKitDefIndex, szDisplayName, sizeof(szDisplayName));
        Format(szTranslation, sizeof(szTranslation), "» %s", szDisplayName);
        menu.AddItem(szDefIndex, szTranslation, ClientInfo[client].MusicKit == iMusicKitDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }

    menu.ExitBackButton = true;
    switch(iPosition)
    {
        case 0: menu.Display(client, MENU_TIME_FOREVER);
        default: menu.DisplayAt(client, iPosition, MENU_TIME_FOREVER);
    }
}

public int m_MusicKits(Menu menu, MenuAction action, int client, int option)
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

            int iMusicKitDefIndex = StringToInt(szDefIndex);
            eTweaker_EquipMusicKit(client, iMusicKitDefIndex);
            MusicKits_BuildMainMenu(client, GetMenuSelectionPosition());
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