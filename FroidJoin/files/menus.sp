void MenuJoin(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuJoin_Callback);
    hMenu.SetTitle("★ Choose a Team ★");
    hMenu.AddItem("0", "• Random Team");
	hMenu.AddItem("1", "• Counter-Terrorist Team", ITEMDRAW_DISABLED);
	hMenu.AddItem("2", "• Terrorist Team", ITEMDRAW_DISABLED);
	hMenu.ExitBackButton = false;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuJoin_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			char sInfo[2];
			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));

			switch(sInfo[0])
			{
                case '0':
				{
                    if(StrContains(g_sHostname, "PUG") > -1 || StrContains(g_sHostname, "5v5") > -1){
                        CommandJoinPUG(iClient);
                    }else if(StrContains(g_sHostname, "Retakes") > -1){
                        CommandJoinRetakes(iClient);
					}else if(StrContains(g_sHostname, "Executes") > -1){
                        CommandJoinExecutes(iClient);
					}else if(StrContains(g_sHostname, "AWP") > -1){
                        CommandJoinAWP(iClient);
                    }else if(StrContains(g_sHostname, "Arena") > -1){
                        CommandJoinArena(iClient);
                    }else if(StrContains(g_sHostname, "FFA") > -1){
                        CommandJoinFFA(iClient);
                    }
				}
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}