void MenuEmojis(int iClient, int iStart = 0)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuEmojis_Callback);
    hMenu.SetTitle("★ Choose a Emoji ★");

    hMenu.AddItem("0", "» Default", g_PlayerData[iClient].iEmojiData==0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);

    char sTempIndex[10];
    char sTempName[128];
    for(int i = 0; i < g_iLevelIcons; ++i)
	{
		IntToString(g_LevelIcons[i].iIconIndex, sTempIndex, sizeof(sTempIndex));
        Format(sTempName, sizeof(sTempName), "» %s", g_LevelIcons[i].sName);
        hMenu.AddItem(sTempIndex, sTempName, g_PlayerData[iClient].iEmojiData==g_LevelIcons[i].iIconIndex?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	}

	hMenu.ExitBackButton = false;

    if (iStart == 0) {
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	} else {
		hMenu.DisplayAt(iClient, iStart, MENU_TIME_FOREVER);
	}
}

int MenuEmojis_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			char sInfo[30];

			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));

			g_PlayerData[iClient].iEmojiData = StringToInt(sInfo);

            MenuEmojis(iClient, GetMenuSelectionPosition());
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}