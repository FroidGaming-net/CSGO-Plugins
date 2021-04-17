void MenuPremium(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuPremium_Callback);
    hMenu.SetTitle("★ VIP Information ★");
	if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
		if(g_PlayerData[iClient].iVipLoaded == 1)
		{
			hMenu.AddItem("mInfo", "• Informasi VIP Saya");
		}
		hMenu.AddItem("mPremium+", "• Fitur Premium Plus");
		hMenu.AddItem("mPremium", "• Fitur Premium");
		hMenu.AddItem("mPayment", "• Metode Pembayaran");
		hMenu.AddItem("mHow", "• Cara Membeli Premium");
	}else{
		if(g_PlayerData[iClient].iVipLoaded == 1)
		{
			hMenu.AddItem("mInfo", "• My VIP Information");
		}
		hMenu.AddItem("mPremium+", "• Premium Plus Features");
		hMenu.AddItem("mPremium", "• Premium Features");
		hMenu.AddItem("mPayment", "• Payment Methods");
		hMenu.AddItem("mHow", "• How to Buy");
	}
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

void MenuPremiumFeatures(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuPremium_Callback);
    hMenu.SetTitle("★ Premium Features ★");
	hMenu.AddItem("1", "» [Retakes] !join (Join on Retakes)", ITEMDRAW_DISABLED);
	hMenu.AddItem("2", "» [Multi1v1] !join (Join on Multi1v1)", ITEMDRAW_DISABLED);
	hMenu.AddItem("3", "» [Multi1v1] 2-rounds Cooldown on Arena Challenge", ITEMDRAW_DISABLED);
	hMenu.AddItem("4", "» [AWP] 5.000 Credits in-game to buy !shop Items", ITEMDRAW_DISABLED);
	hMenu.AddItem("5", "» [All] !maks command for use a mask/hats", ITEMDRAW_DISABLED);
	hMenu.AddItem("6", "» [All] !tag command for customize name color, message color & tag", ITEMDRAW_DISABLED);
	hMenu.AddItem("7", "» [All] Reserved slots", ITEMDRAW_DISABLED);
	hMenu.AddItem("8", "» [All] Non Prime Join", ITEMDRAW_DISABLED);
	hMenu.AddItem("9", "» [All] Advertisement Immunity", ITEMDRAW_DISABLED);
	hMenu.AddItem("10", "» [Discord] Premium Rank", ITEMDRAW_DISABLED);
	hMenu.ExitBackButton = true;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

void MenuPremiumPlusFeatures(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuPremium_Callback);
    hMenu.SetTitle("★ Premium Plus Features ★");
	hMenu.AddItem("1", "» [Retakes] !join (Join on Retakes)", ITEMDRAW_DISABLED);
	hMenu.AddItem("2", "» [Retakes] AWP Chance 60% (Default 20%)", ITEMDRAW_DISABLED);
    hMenu.AddItem("3", "» [Executes] !join (Join on Executes)", ITEMDRAW_DISABLED);
	hMenu.AddItem("4", "» [Executes] AWP Chance 60% (Default 20%)", ITEMDRAW_DISABLED);
	hMenu.AddItem("5", "» [PUG] !join (Join on PUG)", ITEMDRAW_DISABLED);
	hMenu.AddItem("6", "» [PUG] !start (Forcestart the match)", ITEMDRAW_DISABLED);
	hMenu.AddItem("7", "» [Multi1v1] !join (Join on Multi1v1)", ITEMDRAW_DISABLED);
	hMenu.AddItem("8", "» [Multi1v1] No Cooldown on Arena Challenge", ITEMDRAW_DISABLED);
	hMenu.AddItem("9", "» [FFA Deathmatch] !join (Join on FFA Deathmatch)", ITEMDRAW_DISABLED);
	hMenu.AddItem("10", "» [FFA Deathmatch] No Weapon Restriction", ITEMDRAW_DISABLED);
	hMenu.AddItem("11", "» [AWP] !join (Join on AWP)", ITEMDRAW_DISABLED);
	hMenu.AddItem("12", "» [AWP] Kill Effect", ITEMDRAW_DISABLED);
	hMenu.AddItem("12", "» [AWP] Zeus Tracers", ITEMDRAW_DISABLED);
	hMenu.AddItem("12", "» [AWP] 10.000 Credits in-game to buy !shop Items", ITEMDRAW_DISABLED);
	hMenu.AddItem("13", "» [All] !emoji command for use a scoreboard emoji", ITEMDRAW_DISABLED);
	hMenu.AddItem("14", "» [All] !maks command for use a mask/hats", ITEMDRAW_DISABLED);
	hMenu.AddItem("15", "» [All] !tag command for customize name color, message color & tag", ITEMDRAW_DISABLED);
	hMenu.AddItem("16", "» [All] !rankreset command for reset rank", ITEMDRAW_DISABLED);
	hMenu.AddItem("17", "» [All] Reserved slots", ITEMDRAW_DISABLED);
	hMenu.AddItem("18", "» [All] Non Prime Join", ITEMDRAW_DISABLED);
	hMenu.AddItem("19", "» [All] Advertisement Immunity", ITEMDRAW_DISABLED);
	hMenu.AddItem("20", "» [Discord] Premium Plus Rank", ITEMDRAW_DISABLED);
	hMenu.ExitBackButton = true;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

void MenuPremiumPayments(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuPremium_Callback);
    hMenu.SetTitle("★ Payments Information ★");
	hMenu.AddItem("1", "» Paypal", ITEMDRAW_DISABLED);
	hMenu.AddItem("2", "» Credit Card / Debit Card", ITEMDRAW_DISABLED);
	hMenu.AddItem("3", "» Alfamart", ITEMDRAW_DISABLED);
	hMenu.AddItem("4", "» Indomaret", ITEMDRAW_DISABLED);
	hMenu.AddItem("5", "» Telkomsel", ITEMDRAW_DISABLED);
	hMenu.AddItem("6", "» GOPAY & QRIS (ShopeePay and other)", ITEMDRAW_DISABLED);
	hMenu.AddItem("7", "» DANA & OVO", ITEMDRAW_DISABLED);
	hMenu.AddItem("8", "» Bank BCA", ITEMDRAW_DISABLED);
	hMenu.AddItem("9", "» Bank Mandiri", ITEMDRAW_DISABLED);
	hMenu.AddItem("10", "» Bank Permata", ITEMDRAW_DISABLED);
	hMenu.AddItem("11", "» Bank BNI", ITEMDRAW_DISABLED);
	hMenu.AddItem("12", "» Bank BRI", ITEMDRAW_DISABLED);
	hMenu.ExitBackButton = true;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

void MenuPremiumBuy(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuPremium_Callback);
    hMenu.SetTitle("★ How to Buy ★");
	if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
		hMenu.AddItem("1", "» Kunjungi website kami [https://froidgaming.net/store]", ITEMDRAW_DISABLED);
	}else{
		hMenu.AddItem("1", "» Visit our store [https://froidgaming.net/store]", ITEMDRAW_DISABLED);
	}
	hMenu.ExitBackButton = true;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuPremium_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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
			if (StrEqual(sInfo, "back"))
			{
				MenuPremium(iClient);
			}else if (StrEqual(sInfo, "mPremium"))
			{
				MenuPremiumFeatures(iClient);
			}else if (StrEqual(sInfo, "mPremium+"))
			{
				MenuPremiumPlusFeatures(iClient);
			}else if (StrEqual(sInfo, "mPayment"))
			{
				MenuPremiumPayments(iClient);
			}else if (StrEqual(sInfo, "mInfo"))
			{
				char 	sAuthID[64],
						sUrl[64];
				GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
				Format(sUrl, sizeof(sUrl), "api/vip/%s", sAuthID);

				httpClient.Get(sUrl, MenuPremiumInformation, GetClientUserId(iClient));
			}else if (StrEqual(sInfo, "mHow"))
			{
				MenuPremiumBuy(iClient);
			}else{
				MenuPremium(iClient);
			}
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if (iSlot == MenuCancel_ExitBack) {
				MenuPremium(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}