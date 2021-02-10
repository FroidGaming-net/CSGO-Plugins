void MenuSkybox(int iClient, int iStart = 0)
{	
	if (!IsValidClient(iClient)) {
		return;
	}
	
    Menu hMenu = new Menu(MenuSkybox_Callback);
    hMenu.SetTitle("★ Choose a skybox ★");
	hMenu.AddItem("mapdefault", "• Default", StrEqual(g_PlayerData[iClient].sSkybox ,"mapdefault")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("cs_baggage_skybox_", "• Baggage", StrEqual(g_PlayerData[iClient].sSkybox ,"cs_baggage_skybox_")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("cs_tibet", "• Tibet", StrEqual(g_PlayerData[iClient].sSkybox ,"cs_tibet")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_lunacy", "• Lunacy", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_lunacy")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("embassy", "• Embassy", StrEqual(g_PlayerData[iClient].sSkybox ,"embassy")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("italy", "• Italy", StrEqual(g_PlayerData[iClient].sSkybox ,"italy")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("jungle", "• Jungle", StrEqual(g_PlayerData[iClient].sSkybox ,"jungle")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("office", "• Office", StrEqual(g_PlayerData[iClient].sSkybox ,"office")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_cs15_daylight01_hdr", "• Daylight 01", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_cs15_daylight01_hdr")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_cs15_daylight02_hdr", "• Daylight 02", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_cs15_daylight02_hdr")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_cs15_daylight03_hdr", "• Daylight 03", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_cs15_daylight03_hdr")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_cs15_daylight04_hdr", "• Daylight 04", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_cs15_daylight04_hdr")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_day02_05", "• Day", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_day02_05")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_venice", "• Venice", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_venice")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_csgo_cloudy01", "• Cloudy", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_csgo_cloudy01")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_csgo_night02", "• Night 01", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_csgo_night02")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_csgo_night02b", "• Night 02", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_csgo_night02b")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("vertigo", "• Vertigo", StrEqual(g_PlayerData[iClient].sSkybox ,"vertigo")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("vertigoblue_hdr", "• Vertigo Blue", StrEqual(g_PlayerData[iClient].sSkybox ,"vertigoblue_hdr")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("sky_dust", "• Dust", StrEqual(g_PlayerData[iClient].sSkybox ,"sky_dust")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	hMenu.AddItem("vietnam", "• Vietnam", StrEqual(g_PlayerData[iClient].sSkybox ,"vietnam")?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);

	if(iStart == 0)
	{
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	}else{
		hMenu.DisplayAt(iClient, iStart, MENU_TIME_FOREVER);
	}
}

int MenuSkybox_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			char sInfo[30], sInfo2[30];
			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));
			hMenu.GetTitle(sInfo2, sizeof(sInfo2));
			Format(g_PlayerData[iClient].sSkybox, sizeof(g_PlayerData[].sSkybox), sInfo);
			SetSkybox(iClient, sInfo);
			MenuSkybox(iClient, GetMenuSelectionPosition());
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}