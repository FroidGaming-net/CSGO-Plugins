void MenuAppearance(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    g_PlayerData[iClient].bWaitingForData = false;

    char szBuffer[PLATFORM_MAX_PATH], value[PLATFORM_MAX_PATH];

    Menu hMenu = new Menu(MenuAppearance_Callback);
    /// Title
    Format(szBuffer, sizeof(szBuffer), "★ Chat Appearance - Main Menu ★", szBuffer);
    hMenu.SetTitle("%s \n \n", szBuffer);

    // Name color
    strcopy(value, sizeof(value), g_PlayerData[iClient].sName);

    if (!value[0]) {
        Format(value, sizeof(value), "None");
    } else if(StrContains(value, "rainbow", false) > -1) {
        Format(value, sizeof(value), "Rainbow");
    } else if(StrContains(value, "random", false) > -1) {
        Format(value, sizeof(value), "Random");
    } else {
        Format(value, sizeof(value), "%T", value, iClient);
    }

    FormatEx(szBuffer, sizeof(szBuffer), "n• Name Color [%s]", value);
    ccp_replaceColors(szBuffer[1], true);
    hMenu.AddItem(szBuffer, szBuffer[1]);

    // Message color
    strcopy(value, sizeof(value), g_PlayerData[iClient].sMessage);
    if (!value[0]) {
        Format(value, sizeof(value), "None");
    } else if(StrContains(value, "rainbow", false) > -1) {
        Format(value, sizeof(value), "Rainbow");
    } else if(StrContains(value, "random", false) > -1) {
        Format(value, sizeof(value), "Random");
    } else {
        Format(value, sizeof(value), "%T", value, iClient);
    }

    FormatEx(szBuffer, sizeof(szBuffer), "m• Message Color [%s]", value);
    ccp_replaceColors(szBuffer[1], true);
    hMenu.AddItem(szBuffer, szBuffer[1]);

    // clantag
    strcopy(value, sizeof(value), g_PlayerData[iClient].sClanTag);
    if(!TrimString(value[0])) {
        FormatEx(value, sizeof(value), "None");
    }

    FormatEx(szBuffer, sizeof(szBuffer), "t• Clan Tag [%s]", value);
    hMenu.AddItem(szBuffer, szBuffer[1]);

    // Reset to default
    FormatEx(szBuffer, sizeof(szBuffer), "r• Reset to Default");
    hMenu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_NOTEXT|ITEMDRAW_SPACER);
    hMenu.AddItem(szBuffer, szBuffer[1]);

    // Finally
	hMenu.ExitBackButton = false;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuAppearance_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
            if (!IsValidClient(iClient)) {
                return;
            }

			char sInfo[4];

			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));
            
            if(sInfo[0] == 'r') {
                /// Reset
                char sTag[32];
                CS_GetClientClanTag(iClient, sTag, sizeof(sTag));
                if (!strcmp(sTag, g_PlayerData[iClient].sClanTag)) {
                    CS_SetClientClanTag(iClient, NULL_STRING);
                }

                g_PlayerData[iClient].Clear();
                MenuAppearance(iClient);
                return;
            } else if(sInfo[0] == 't') {
                /// Clantag
                g_PlayerData[iClient].bWaitingForData = true;
                if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
                    CPrintToChat(iClient, "%s Ketik clantag yang diinginkan. {lightblue}!cancel {default}untuk batalkan.", PREFIX);
                }else{
                    CPrintToChat(iClient, "%s Type the desired clantag. {lightblue}!cancel {default}to abort.", PREFIX);
                }
                return;
            }

            MenuColor(iClient, sInfo[0]);
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuColor(int iClient, char sType, int iStart = 0)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    g_PlayerData[iClient].bWaitingForData = false;

    char szBuffer[PLATFORM_MAX_PATH];

    Menu hMenu = new Menu(MenuColor_Callback);
    /// Title
    szBuffer = (sType == 'n') ? "Name Color" : "Message Color";
    Format(szBuffer, sizeof(szBuffer), "★ Chat Appearance - %s ★", szBuffer);
    hMenu.SetTitle("%s \n \n", szBuffer);

    /// Body
    ArrayList palette = cc_drop_palette();
    int drawType = ITEMDRAW_DEFAULT;

    char key[PLATFORM_MAX_PATH], value[PLATFORM_MAX_PATH];
    strcopy(value, sizeof(value), (sType == 'n') ? g_PlayerData[iClient].sName : g_PlayerData[iClient].sMessage);

    // Reset Menu
    drawType = (!value[0]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT;
    FormatEx(szBuffer, sizeof(szBuffer), "%cReset \n \n", sType);
    FormatEx(key, sizeof(key), "%creset", sType);
    hMenu.AddItem(key, szBuffer[1], drawType);

    // Color
    for(int i; i < palette.Length; i+=2) {
        palette.GetString(i, key, sizeof(key));
        drawType = (!strcmp(key, value)) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT;

        FormatEx(szBuffer, sizeof(szBuffer), "%T", key, iClient);
        Format(key, sizeof(key), "%c%s", sType, key);
        ccp_replaceColors(szBuffer, true);

        if(StrContains(szBuffer, "red", false) == -1 && StrContains(szBuffer, "grey", false) == -1 && StrContains(szBuffer, "team", false) == -1 && StrContains(szBuffer, "banana", false) == -1 && StrContains(szBuffer, "violet", false) == -1 && StrContains(szBuffer, "white", false) == -1) {
            hMenu.AddItem(key, szBuffer, drawType);
        }
    }

    // Rainbow Color
    drawType = (!strcmp("rainbow", value)) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT;
    FormatEx(szBuffer, sizeof(szBuffer), "%cRainbow", sType);
    FormatEx(key, sizeof(key), "%crainbow", sType);
    hMenu.AddItem(key, szBuffer[1], drawType);

    // Random Color
    drawType = (!strcmp("random", value)) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT;
    FormatEx(szBuffer, sizeof(szBuffer), "%cRandom", sType);
    FormatEx(key, sizeof(key), "%crandom", sType);
    hMenu.AddItem(key, szBuffer[1], drawType);
    /// End Body

    // Finally
    hMenu.ExitBackButton = true;
    hMenu.ExitButton = true;
    if (iStart == 0) {
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	} else {
		hMenu.DisplayAt(iClient, iStart, MENU_TIME_FOREVER);
	}
}

int MenuColor_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
            if (!IsValidClient(iClient)) {
                return;
            }

			char sInfo[PLATFORM_MAX_PATH];
			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));

            if(!strcmp(sInfo[1], "reset")) {
                sInfo[1] = 0;
            }

            strcopy(
                (sInfo[0] == 'n') ? g_PlayerData[iClient].sName : g_PlayerData[iClient].sMessage,
                (sInfo[0] == 'n') ? sizeof(g_PlayerData[].sName) : sizeof(g_PlayerData[].sMessage), 
                sInfo[1]
            );

            char szBuffer[PLATFORM_MAX_PATH];
            szBuffer = (sInfo[0] == 'n') ? "Name Color" : "Message Color";

            if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
                CPrintToChat(iClient, "%s Kamu berhasil mengubah %s Kamu!", PREFIX, szBuffer);
            }else{
                CPrintToChat(iClient, "%s You've changed your %s!", PREFIX, szBuffer);
            }

            MenuColor(iClient, sInfo[0], GetMenuSelectionPosition());
		}
		case MenuAction_Cancel:
		{
            if (!IsValidClient(iClient)) {
                return;
            }

            if (iSlot == MenuCancel_ExitBack) {
				MenuAppearance(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}