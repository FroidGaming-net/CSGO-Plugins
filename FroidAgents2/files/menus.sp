void MenuAgentTeam(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuAgentTeam_Callback);
    hMenu.SetTitle("★ Choose Agents Team ★");
	hMenu.AddItem("3", "• Counter-Terrorist");
	hMenu.AddItem("2", "• Terrorist");
	hMenu.ExitBackButton = false;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuAgentTeam_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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

			g_PlayerData[iClient].iCacheTeam = StringToInt(sInfo);
			MenuAgentSelect(iClient);
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuAgentSelect(int iClient, int iStart = 0)
{
	char sDisplayName[48];
    char sDefIndex[12];
	char sTemp[100];

	Menu hMenu = new Menu(MenuAgentSelect_Callback);
	
	Format(sTemp, sizeof(sTemp), "★ Choose Agents - %s ★", g_PlayerData[iClient].iCacheTeam == CS_TEAM_CT ? "CT" : "T");
	hMenu.SetTitle(sTemp);

	hMenu.AddItem("-1", "» Default", g_PlayerData[iClient].iAgent[view_as<int>(g_PlayerData[iClient].iCacheTeam == CS_TEAM_CT)] == -1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	for(int iAgentsNum = 0; iAgentsNum < g_iAgentsCount; iAgentsNum++)
    {
		int iAgentDefIndex = eItems_GetAgentDefIndexByAgentNum(iAgentsNum);

		if(eItems_GetAgentTeamByDefIndex(iAgentDefIndex) == g_PlayerData[iClient].iCacheTeam)
		{
			IntToString(iAgentDefIndex, sDefIndex, sizeof(sDefIndex));
			eItems_GetAgentDisplayNameByDefIndex(iAgentDefIndex, sDisplayName, sizeof(sDisplayName));
			Format(sTemp, sizeof(sTemp), "» %s", sDisplayName);
			hMenu.AddItem(sDefIndex, sTemp, g_PlayerData[iClient].iAgent[view_as<int>(g_PlayerData[iClient].iCacheTeam == CS_TEAM_CT)] == iAgentDefIndex ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		}
	}

	hMenu.ExitBackButton = true;
	if (iStart == 0) {
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	} else {
		hMenu.DisplayAt(iClient, iStart, MENU_TIME_FOREVER);
	}
}

int MenuAgentSelect_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			char sInfo[30];
			char sUrlImage[256];

			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));

			if (StringToInt(sInfo) == -1) {
				if (g_PlayerData[iClient].iCacheTeam == CS_TEAM_T) {
					Format(sUrlImage, sizeof(sUrlImage), "t_map_based");
				} else if(g_PlayerData[iClient].iCacheTeam == CS_TEAM_CT) {
					Format(sUrlImage, sizeof(sUrlImage), "ct_map_based");
				}
			} else {
				eItems_GetAgentPlayerModelByDefIndex(StringToInt(sInfo), sUrlImage, sizeof(sUrlImage));
				ReplaceString(sUrlImage, sizeof(sUrlImage), "models/player/custom_player/legacy/", "");
				ReplaceString(sUrlImage, sizeof(sUrlImage), ".mdl", "");
			}

			g_PlayerData[iClient].SetAgent(StringToInt(sInfo), view_as<int>(g_PlayerData[iClient].iCacheTeam == CS_TEAM_CT));
			g_PlayerData[iClient].SetAgentSkin(iClient, g_PlayerData[iClient].iCacheTeam);

			CPrintToChat(iClient, "%s Agent model choosed! you will have it in the next spawn", PREFIX);
			PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/characters/customplayer_%s.png'></span>", sUrlImage);

			DataPack dp = new DataPack();
			CreateDataTimer(0.3, Timer_Image, dp);
			dp.WriteCell(GetClientUserId(iClient));
			dp.WriteString(sUrlImage);

			MenuAgentSelect(iClient, GetMenuSelectionPosition());
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if(iSlot == MenuCancel_ExitBack)
			{
				MenuAgentTeam(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}