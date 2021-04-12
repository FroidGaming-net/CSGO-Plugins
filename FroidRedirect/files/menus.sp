void MenuServersCategory(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuServersCategory_Callback);
    hMenu.SetTitle("★ Game Mode ★");
	hMenu.AddItem("pug", "• PUG (5v5 Competitive)");
	hMenu.AddItem("retakes", "• Retakes");
	hMenu.AddItem("executes", "• Executes");
	hMenu.AddItem("ffa", "• FFA Deathmatch");
	hMenu.AddItem("arena", "• Arena 1v1");
	hMenu.AddItem("practice", "• Practice Mode");
	hMenu.AddItem("awp", "• AWP Bhop");
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuServersCategory_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			char sInfo[128];
			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));

			DataPack pack = new DataPack();
			pack.WriteCell(GetClientUserId(iClient));
			pack.WriteString(sInfo);

			char sUrl[128];
    		Format(sUrl, sizeof(sUrl), "api/servers/");
			httpClient.Get(sUrl, OnGetServers, pack);
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

int MenuServers_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			char sInfo[128];
			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));
			CPrintToChatAll("%s {lightred}%N {default}switched to {lightred}%s{default} via !servers", PREFIX, iClient, sInfo);
			RedirectClientOnServerEx(iClient, sInfo);
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if (iSlot == MenuCancel_ExitBack) {
				MenuServersCategory(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}