void MenuFeatures(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuFeatures_Callback);
    hMenu.SetTitle("★ FroidGaming.net Menu ★");

	if(CommandExists("sm_servers")) {
		hMenu.AddItem("0", "• Servers Menu");
	}

	if(CommandExists("sm_agents")) {
		hMenu.AddItem("1", "• Agents");
	}

	if(CommandExists("sm_guns")) {
		hMenu.AddItem("2", "• Weapons");
	}

	if(CommandExists("sm_ws")) {
		hMenu.AddItem("3", "• Weapon Skins");
	}

	if(CommandExists("sm_sticker")) {
		hMenu.AddItem("4", "• Weapon Stickers");
	}

	if(CommandExists("sm_tweak")) {
		hMenu.AddItem("5", "• Weapon Tweaks");
	}

	if(CommandExists("sm_gloves")) {
		hMenu.AddItem("6", "• Gloves");
	}

	if(CommandExists("sm_knife")) {
		hMenu.AddItem("7", "• Knives");
	}

	if(CommandExists("sm_music")) {
		hMenu.AddItem("8", "• Music Kits");
	}

	if (CommandExists("sm_hats")) {
		hMenu.AddItem("9", "• Masks/Hats");
	}

	if (CommandExists("sm_tag")) {
		hMenu.AddItem("10", "• Chat Apperance");
	}

	hMenu.ExitBackButton = false;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuFeatures_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_Select:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			switch(iSlot)
			{
                case 0:
				{
					FakeClientCommand(iClient, "sm_servers");
				}
                case 1:
				{
					FakeClientCommand(iClient, "sm_agents");
				}
				case 2:
				{
					FakeClientCommand(iClient, "sm_guns");
				}
				case 3:
				{
					FakeClientCommand(iClient, "sm_ws");
				}
				case 4:
				{
					FakeClientCommand(iClient, "sm_sticker");
				}
				case 5:
				{
					FakeClientCommand(iClient, "sm_tweak");
				}
				case 6:
				{
					FakeClientCommand(iClient, "sm_gloves");
				}
				case 7:
				{
					FakeClientCommand(iClient, "sm_knife");
				}
				case 8:
				{
					FakeClientCommand(iClient, "sm_music");
				}
				case 9:
				{
					FakeClientCommand(iClient, "sm_hats");
				}
				case 10:
				{
					FakeClientCommand(iClient, "sm_tag");
				}
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuRules(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuRules_Callback);
    hMenu.SetTitle("★ FroidGaming.net Rules ★");

    if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
		hMenu.AddItem("1", "• ATURAN UTAMA •", ITEMDRAW_DISABLED);
		hMenu.AddItem("2", "» Dilarang menggunakan cheat/hack/script", ITEMDRAW_DISABLED);
		hMenu.AddItem("3", "» Dilarang memanfaatkan bug atau glitch", ITEMDRAW_DISABLED);
		hMenu.AddItem("4", "» Dilarang melanggar privasi orang lain", ITEMDRAW_DISABLED);
		hMenu.AddItem("5", "» Dilarang rasis atau menggunakan istilah rasis", ITEMDRAW_DISABLED);
		hMenu.AddItem("6", "-", ITEMDRAW_NOTEXT);
		hMenu.AddItem("7", "• ATURAN UMUM •", ITEMDRAW_DISABLED);
		hMenu.AddItem("8", "» Jangan toxic", ITEMDRAW_DISABLED);
		hMenu.AddItem("9", "» Dilarang mengiklankan server lain", ITEMDRAW_DISABLED);
		hMenu.AddItem("10", "» Dilarang spam chat atau suara", ITEMDRAW_DISABLED);
		hMenu.AddItem("11", "» Dilarang griefing/trolling", ITEMDRAW_DISABLED);
		hMenu.AddItem("12", "» Dilarang ghosting", ITEMDRAW_DISABLED);
		hMenu.AddItem("13", "» Dilarang menyamar sebagai staff atau pemain lainnya", ITEMDRAW_DISABLED);
		hMenu.AddItem("14", "» Hargailah semua orang", ITEMDRAW_DISABLED);
	} else {
		hMenu.AddItem("1", "• MAJOR RULES •", ITEMDRAW_DISABLED);
		hMenu.AddItem("2", "» No cheating/hacking/scripting", ITEMDRAW_DISABLED);
		hMenu.AddItem("3", "» Do not exploit bugs or glitches", ITEMDRAW_DISABLED);
		hMenu.AddItem("4", "» Do not violate the privacy of others", ITEMDRAW_DISABLED);
		hMenu.AddItem("5", "» Do not be racist or use racist terms", ITEMDRAW_DISABLED);
		hMenu.AddItem("6", "-", ITEMDRAW_NOTEXT);
		hMenu.AddItem("7", "• GENERAL RULES •", ITEMDRAW_DISABLED);
		hMenu.AddItem("8", "» Do not be toxic", ITEMDRAW_DISABLED);
		hMenu.AddItem("9", "» Do not advertise other servers", ITEMDRAW_DISABLED);
		hMenu.AddItem("10", "» Do not chat or mic spam.", ITEMDRAW_DISABLED);
		hMenu.AddItem("11", "» No griefing/trolling", ITEMDRAW_DISABLED);
		hMenu.AddItem("12", "» No ghosting", ITEMDRAW_DISABLED);
		hMenu.AddItem("13", "» No impersonating staff or other players", ITEMDRAW_DISABLED);
		hMenu.AddItem("14", "» Be respectful to everyone", ITEMDRAW_DISABLED);
	}

	hMenu.ExitBackButton = false;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuRules_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
{
	switch(mAction)
	{
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}