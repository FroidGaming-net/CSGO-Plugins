void MenuTeam(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuTeam_Callback);
    hMenu.SetTitle("★ Choose a Team ★");
	hMenu.AddItem("3", "• Counter-Terrorist");
	hMenu.AddItem("2", "• Terrorist");
	hMenu.ExitBackButton = false;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuTeam_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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

			if(StringToInt(sInfo) > 1){
			 	MenuType(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuType(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

	char sBuffer[255];

    Menu hMenu = new Menu(MenuType_Callback);
    Format(sBuffer, sizeof(sBuffer), "★ Choose a Type - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");
    hMenu.SetTitle(sBuffer);

    Format(sBuffer, sizeof(sBuffer), "• Pistol Round Weapon");
    hMenu.AddItem("Pistol", sBuffer);

    Format(sBuffer, sizeof(sBuffer), "• Primary Weapon");
    hMenu.AddItem("Primary", sBuffer);

    Format(sBuffer, sizeof(sBuffer), "• Secondary Weapon");
    hMenu.AddItem("Secondary", sBuffer);

    Format(sBuffer, sizeof(sBuffer), "• Force-Buy Round Weapon");
    hMenu.AddItem("SMG", sBuffer);

    Format(sBuffer, sizeof(sBuffer), "• Snipers");
    hMenu.AddItem("Sniper", sBuffer);

	hMenu.ExitBackButton = true;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuType_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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

            if (strcmp(sInfo, "Pistol") == 0)
            {
                MenuPistolRound(iClient);
            }
            else if (strcmp(sInfo, "Primary") == 0)
            {
                MenuPrimary(iClient);
            }
            else if (strcmp(sInfo, "Secondary") == 0)
            {
                MenuSecondary(iClient);
            }
            else if (strcmp(sInfo, "SMG") == 0)
            {
                MenuSMG(iClient);
            }
            else if (strcmp(sInfo, "Sniper") == 0)
            {
                MenuSniper(iClient);
            }
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if (iSlot == MenuCancel_ExitBack) {
				MenuTeam(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuPistolRound(int iClient, int iStart = 0)
{
	if (!IsValidClient(iClient)) {
		return;
	}

	char sBuffer[255];

    Menu hMenu = new Menu(MenuPistolRound_Callback);

    Format(sBuffer, sizeof(sBuffer), "★ Pistol Round Weapon - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");
    hMenu.SetTitle(sBuffer);

    // CT = 3
    // T = 2

    if (g_PlayerData[iClient].iCacheTeam == 3) {
        hMenu.AddItem("weapon_usp_silencer", "» USP-S", StrEqual(g_PlayerData[iClient].sPistolRound_CT, "weapon_usp_silencer")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_hkp2000", "» P2000", StrEqual(g_PlayerData[iClient].sPistolRound_CT, "weapon_hkp2000")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_fiveseven", "» Five-SeveN", StrEqual(g_PlayerData[iClient].sPistolRound_CT, "weapon_fiveseven")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_deagle", "» Desert Eagle", StrEqual(g_PlayerData[iClient].sPistolRound_CT, "weapon_deagle")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_revolver", "» Revolver", StrEqual(g_PlayerData[iClient].sPistolRound_CT, "weapon_revolver")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_cz75a", "» CZ75-Auto", StrEqual(g_PlayerData[iClient].sPistolRound_CT, "weapon_cz75a")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_p250", "» P250", StrEqual(g_PlayerData[iClient].sPistolRound_CT, "weapon_p250")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    } else if (g_PlayerData[iClient].iCacheTeam == 2) {
        hMenu.AddItem("weapon_glock", "» Glock-18", StrEqual(g_PlayerData[iClient].sPistolRound_T, "weapon_glock")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_tec9", "» Tec-9", StrEqual(g_PlayerData[iClient].sPistolRound_T, "weapon_tec9")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_elite", "» Dual Berettas", StrEqual(g_PlayerData[iClient].sPistolRound_T, "weapon_elite")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_deagle", "» Desert Eagle", StrEqual(g_PlayerData[iClient].sPistolRound_T, "weapon_deagle")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_revolver", "» Revolver", StrEqual(g_PlayerData[iClient].sPistolRound_T, "weapon_revolver")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_cz75a", "» CZ75-Auto", StrEqual(g_PlayerData[iClient].sPistolRound_T, "weapon_cz75a")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_p250", "» P250", StrEqual(g_PlayerData[iClient].sPistolRound_T, "weapon_p250")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    }

	hMenu.ExitBackButton = true;

    if (iStart == 0) {
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	} else {
		hMenu.DisplayAt(iClient, iStart, MENU_TIME_FOREVER);
	}
}

int MenuPistolRound_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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

            // CT = 3
            // T = 2

            if (g_PlayerData[iClient].iCacheTeam == 3) {
                Format (g_PlayerData[iClient].sPistolRound_CT, sizeof(g_PlayerData[].sPistolRound_CT), sInfo);
            } else if (g_PlayerData[iClient].iCacheTeam == 2) {
                Format (g_PlayerData[iClient].sPistolRound_T, sizeof(g_PlayerData[].sPistolRound_T), sInfo);
            }

            PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/weapons/base_weapons/%s.png'></span>", sInfo);

            DataPack dp = new DataPack();
			CreateDataTimer(0.3, Timer_Image, dp);
			dp.WriteCell(GetClientUserId(iClient));
			dp.WriteString(sInfo);

            MenuPistolRound(iClient, GetMenuSelectionPosition());
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if (iSlot == MenuCancel_ExitBack) {
				MenuType(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuPrimary(int iClient, int iStart = 0)
{
	if (!IsValidClient(iClient)) {
		return;
	}

	char sBuffer[255];

    Menu hMenu = new Menu(MenuPrimary_Callback);

    Format(sBuffer, sizeof(sBuffer), "★ Primary Weapon - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");
    hMenu.SetTitle(sBuffer);

    // CT = 3
    // T = 2

    if (g_PlayerData[iClient].iCacheTeam == 3) {
        hMenu.AddItem("weapon_m4a1", "» M4A4", StrEqual(g_PlayerData[iClient].sPrimary_CT, "weapon_m4a1")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_m4a1_silencer", "» M4A1-S", StrEqual(g_PlayerData[iClient].sPrimary_CT, "weapon_m4a1_silencer")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_famas", "» FAMAS", StrEqual(g_PlayerData[iClient].sPrimary_CT, "weapon_famas")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_aug", "» AUG", StrEqual(g_PlayerData[iClient].sPrimary_CT, "weapon_aug")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    } else if (g_PlayerData[iClient].iCacheTeam == 2) {
        hMenu.AddItem("weapon_ak47", "» AK-47", StrEqual(g_PlayerData[iClient].sPrimary_T, "weapon_ak47")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_galilar", "» Galil AR", StrEqual(g_PlayerData[iClient].sPrimary_T, "weapon_galilar")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_sg556", "» SG 553", StrEqual(g_PlayerData[iClient].sPrimary_T, "weapon_sg556")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    }

	hMenu.ExitBackButton = true;

    if (iStart == 0) {
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	} else {
		hMenu.DisplayAt(iClient, iStart, MENU_TIME_FOREVER);
	}
}

int MenuPrimary_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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

            // CT = 3
            // T = 2

            if (g_PlayerData[iClient].iCacheTeam == 3) {
                Format (g_PlayerData[iClient].sPrimary_CT, sizeof(g_PlayerData[].sPrimary_CT), sInfo);
            } else if (g_PlayerData[iClient].iCacheTeam == 2) {
                Format (g_PlayerData[iClient].sPrimary_T, sizeof(g_PlayerData[].sPrimary_T), sInfo);
            }

            PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/weapons/base_weapons/%s.png'></span>", sInfo);

            DataPack dp = new DataPack();
			CreateDataTimer(0.3, Timer_Image, dp);
			dp.WriteCell(GetClientUserId(iClient));
			dp.WriteString(sInfo);

            MenuPrimary(iClient, GetMenuSelectionPosition());
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if (iSlot == MenuCancel_ExitBack) {
				MenuType(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuSecondary(int iClient, int iStart = 0)
{
	if (!IsValidClient(iClient)) {
		return;
	}

	char sBuffer[255];

    Menu hMenu = new Menu(MenuSecondary_Callback);

    Format(sBuffer, sizeof(sBuffer), "★ Secondary Weapon - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");
    hMenu.SetTitle(sBuffer);

    // CT = 3
    // T = 2

    if (g_PlayerData[iClient].iCacheTeam == 3) {
        hMenu.AddItem("weapon_usp_silencer", "» USP-S", StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_usp_silencer")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_hkp2000", "» P2000", StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_hkp2000")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_fiveseven", "» Five-SeveN", StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_fiveseven")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_deagle", "» Desert Eagle (Limited)", StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_deagle")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_revolver", "» Revolver (Limited)", StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_revolver")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_cz75a", "» CZ75-Auto", StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_cz75a")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_p250", "» P250", StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_p250")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    } else if (g_PlayerData[iClient].iCacheTeam == 2) {
        hMenu.AddItem("weapon_glock", "» Glock-18", StrEqual(g_PlayerData[iClient].sSecondary_T, "weapon_glock")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_tec9", "» Tec-9", StrEqual(g_PlayerData[iClient].sSecondary_T, "weapon_tec9")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_elite", "» Dual Berettas (Limited)", StrEqual(g_PlayerData[iClient].sSecondary_T, "weapon_elite")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_deagle", "» Desert Eagle (Limited)", StrEqual(g_PlayerData[iClient].sSecondary_T, "weapon_deagle")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_revolver", "» Revolver", StrEqual(g_PlayerData[iClient].sSecondary_T, "weapon_revolver")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_cz75a", "» CZ75-Auto", StrEqual(g_PlayerData[iClient].sSecondary_T, "weapon_cz75a")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_p250", "» P250", StrEqual(g_PlayerData[iClient].sSecondary_T, "weapon_p250")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    }

	hMenu.ExitBackButton = true;

    if (iStart == 0) {
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	} else {
		hMenu.DisplayAt(iClient, iStart, MENU_TIME_FOREVER);
	}
}

int MenuSecondary_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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

            // CT = 3
            // T = 2

            if (g_PlayerData[iClient].iCacheTeam == 3) {
                Format (g_PlayerData[iClient].sSecondary_CT, sizeof(g_PlayerData[].sSecondary_CT), sInfo);
            } else if (g_PlayerData[iClient].iCacheTeam == 2) {
                Format (g_PlayerData[iClient].sSecondary_T, sizeof(g_PlayerData[].sSecondary_T), sInfo);
            }

            PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/weapons/base_weapons/%s.png'></span>", sInfo);

            DataPack dp = new DataPack();
			CreateDataTimer(0.3, Timer_Image, dp);
			dp.WriteCell(GetClientUserId(iClient));
			dp.WriteString(sInfo);

            MenuSecondary(iClient, GetMenuSelectionPosition());
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if (iSlot == MenuCancel_ExitBack) {
				MenuType(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuSMG(int iClient, int iStart = 0)
{
	if (!IsValidClient(iClient)) {
		return;
	}

	char sBuffer[255];

    Menu hMenu = new Menu(MenuSMG_Callback);

    Format(sBuffer, sizeof(sBuffer), "★ Force-Buy Round Weapon - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");
    hMenu.SetTitle(sBuffer);

    // CT = 3
    // T = 2

    if (g_PlayerData[iClient].iCacheTeam == 3) {
        hMenu.AddItem("weapon_ump45", "» UMP-45", StrEqual(g_PlayerData[iClient].sSMG_CT, "weapon_ump45")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_bizon", "» PP-Bizon", StrEqual(g_PlayerData[iClient].sSMG_CT, "weapon_bizon")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_p90", "» P90", StrEqual(g_PlayerData[iClient].sSMG_CT, "weapon_p90")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_mp7", "» MP7", StrEqual(g_PlayerData[iClient].sSMG_CT, "weapon_mp7")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_mp5sd", "» MP5-SD", StrEqual(g_PlayerData[iClient].sSMG_CT, "weapon_mp5sd")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_mp9", "» MP9", StrEqual(g_PlayerData[iClient].sSMG_CT, "weapon_mp9")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_mag7", "» MAG-7", StrEqual(g_PlayerData[iClient].sSMG_CT, "weapon_mag7")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    } else if (g_PlayerData[iClient].iCacheTeam == 2) {
        hMenu.AddItem("weapon_ump45", "» UMP-45", StrEqual(g_PlayerData[iClient].sSMG_T, "weapon_ump45")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_bizon", "» PP-Bizon", StrEqual(g_PlayerData[iClient].sSMG_T, "weapon_bizon")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_p90", "» P90", StrEqual(g_PlayerData[iClient].sSMG_T, "weapon_p90")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_mp7", "» MP7", StrEqual(g_PlayerData[iClient].sSMG_T, "weapon_mp7")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_mp5sd", "» MP5-SD", StrEqual(g_PlayerData[iClient].sSMG_T, "weapon_mp5sd")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_mac10", "» MAC-10", StrEqual(g_PlayerData[iClient].sSMG_T, "weapon_mac10")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        hMenu.AddItem("weapon_sawedoff", "» Sawed-Off", StrEqual(g_PlayerData[iClient].sSMG_T, "weapon_sawedoff")==true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    }

	hMenu.ExitBackButton = true;

    if (iStart == 0) {
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	} else {
		hMenu.DisplayAt(iClient, iStart, MENU_TIME_FOREVER);
	}
}

int MenuSMG_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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

            // CT = 3
            // T = 2

            if (g_PlayerData[iClient].iCacheTeam == 3) {
                Format (g_PlayerData[iClient].sSMG_CT, sizeof(g_PlayerData[].sSMG_CT), sInfo);
            } else if (g_PlayerData[iClient].iCacheTeam == 2) {
                Format (g_PlayerData[iClient].sSMG_T, sizeof(g_PlayerData[].sSMG_T), sInfo);
            }

            PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/weapons/base_weapons/%s.png'></span>", sInfo);

            DataPack dp = new DataPack();
			CreateDataTimer(0.3, Timer_Image, dp);
			dp.WriteCell(GetClientUserId(iClient));
			dp.WriteString(sInfo);

            MenuSMG(iClient, GetMenuSelectionPosition());
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if (iSlot == MenuCancel_ExitBack) {
				MenuType(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuSniper(int iClient)
{
	if (!IsValidClient(iClient)) {
		return;
	}

	char sBuffer[255];

    Menu hMenu = new Menu(MenuSniper_Callback);

    Format(sBuffer, sizeof(sBuffer), "★ Sniper - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");
    hMenu.SetTitle(sBuffer);

    // CT = 3
    // T = 2

    if (g_PlayerData[iClient].iCacheTeam == 3) {
        Format(sBuffer, sizeof(sBuffer), "» AWP (%s)", g_PlayerData[iClient].bAWP_CT == true ? "Enabled" : "Disabled");
        hMenu.AddItem("1", sBuffer);

        Format(sBuffer, sizeof(sBuffer), "» SSG-08 (%s)", g_PlayerData[iClient].bScout_CT == true ? "Enabled" : "Disabled");
        hMenu.AddItem("0", sBuffer);
    } else if (g_PlayerData[iClient].iCacheTeam == 2) {
        Format(sBuffer, sizeof(sBuffer), "» AWP (%s)", g_PlayerData[iClient].bAWP_T == true ? "Enabled" : "Disabled");
        hMenu.AddItem("1", sBuffer);

        Format(sBuffer, sizeof(sBuffer), "» SSG-08 (%s)", g_PlayerData[iClient].bScout_T == true ? "Enabled" : "Disabled");
        hMenu.AddItem("0", sBuffer);
    }

	hMenu.ExitBackButton = true;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuSniper_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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

            // CT = 3
            // T = 2

            if (g_PlayerData[iClient].iCacheTeam == 3) {
                if (strcmp(sInfo, "1") == 0) {
                    if (g_PlayerData[iClient].bAWP_CT == true) {
                        g_PlayerData[iClient].bAWP_CT = false;
                    } else {
                        g_PlayerData[iClient].bAWP_CT = true;
                    }
                } else {
                    if (g_PlayerData[iClient].bScout_CT == true) {
                        g_PlayerData[iClient].bScout_CT = false;
                    } else {
                        g_PlayerData[iClient].bScout_CT = true;
                    }
                }
            } else if (g_PlayerData[iClient].iCacheTeam == 2) {
                if (strcmp(sInfo, "1") == 0) {
                    if (g_PlayerData[iClient].bAWP_T == true) {
                        g_PlayerData[iClient].bAWP_T = false;
                    } else {
                        g_PlayerData[iClient].bAWP_T = true;
                    }
                } else {
                    if (g_PlayerData[iClient].bScout_T == true) {
                        g_PlayerData[iClient].bScout_T = false;
                    } else {
                        g_PlayerData[iClient].bScout_T = true;
                    }
                }
            }

            if (strcmp(sInfo, "1") == 0) {
                PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/weapons/base_weapons/weapon_awp.png'></span>", sInfo);
            } else {
                PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/weapons/base_weapons/weapon_ssg08.png'></span>", sInfo);
            }

            DataPack dp = new DataPack();
			CreateDataTimer(0.3, Timer_Image, dp);
			dp.WriteCell(GetClientUserId(iClient));

            if (strcmp(sInfo, "1") == 0) {
                dp.WriteString("weapon_awp");
            } else {
                dp.WriteString("weapon_ssg08");
            }

            MenuSniper(iClient);
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if (iSlot == MenuCancel_ExitBack) {
				MenuType(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}