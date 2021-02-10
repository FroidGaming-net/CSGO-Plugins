void MenuHats(int iClient, int iStart = 0)
{
	if (!IsValidClient(iClient)) {
		return;
	}

    Menu hMenu = new Menu(MenuHats_Callback);
    hMenu.SetTitle("★ Choose a Facemask ★");
    
    hMenu.AddItem("0", "» Default", g_PlayerData[iClient].iHatNumber==0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("1", "» Porcelain Doll", g_PlayerData[iClient].iHatNumber==1?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("2", "» Zombie Fortune", g_PlayerData[iClient].iHatNumber==2?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("3", "» Wolf", g_PlayerData[iClient].iHatNumber==3?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("4", "» Tiki", g_PlayerData[iClient].iHatNumber==4?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("5", "» TF2 Spy", g_PlayerData[iClient].iHatNumber==5?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("6", "» TF2 Soldier", g_PlayerData[iClient].iHatNumber==6?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("7", "» TF2 Sniper", g_PlayerData[iClient].iHatNumber==7?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("8", "» TF2 Scout", g_PlayerData[iClient].iHatNumber==8?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("9", "» TF2 Pyro", g_PlayerData[iClient].iHatNumber==9?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("10", "» TF2 Medic", g_PlayerData[iClient].iHatNumber==10?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("11", "» TF2 Heavy", g_PlayerData[iClient].iHatNumber==11?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("12", "» TF2 Engineer", g_PlayerData[iClient].iHatNumber==12?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("13", "» TF2 Demoman", g_PlayerData[iClient].iHatNumber==13?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("14", "» Skull", g_PlayerData[iClient].iHatNumber==14?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("15", "» Sheep", g_PlayerData[iClient].iHatNumber==15?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("16", "» Sheep (Bloody)", g_PlayerData[iClient].iHatNumber==16?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("17", "» Samurai", g_PlayerData[iClient].iHatNumber==17?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("18", "» Pumpkin", g_PlayerData[iClient].iHatNumber==18?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("19", "» Porcelain Doll Kabuki", g_PlayerData[iClient].iHatNumber==19?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("20", "» Hoxton", g_PlayerData[iClient].iHatNumber==20?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("21", "» Devil", g_PlayerData[iClient].iHatNumber==21?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("22", "» Dallas", g_PlayerData[iClient].iHatNumber==22?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("23", "» Chains", g_PlayerData[iClient].iHatNumber==23?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("24", "» Bunny", g_PlayerData[iClient].iHatNumber==24?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("25", "» Boar", g_PlayerData[iClient].iHatNumber==25?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("26", "» Anaglyph", g_PlayerData[iClient].iHatNumber==26?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("27", "» Evil Clown", g_PlayerData[iClient].iHatNumber==27?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    hMenu.AddItem("28", "» Battle Mask", g_PlayerData[iClient].iHatNumber==28?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);

	hMenu.ExitBackButton = false;

    if (iStart == 0) {
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	} else {
		hMenu.DisplayAt(iClient, iStart, MENU_TIME_FOREVER);
	}
    
    if(IsWarmup())
	{
		g_PlayerData[iClient].bViewing = true;
		SetThirdPersonView(iClient, true);
	}
}

int MenuHats_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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

			g_PlayerData[iClient].iHatNumber = StringToInt(sInfo);
            RemoveHat(iClient);
            CreateHat(iClient);

            char sUrlImage[256];
			Format(sUrlImage, sizeof(sUrlImage), "%s", GetMaskModelFromId(StringToInt(sInfo)));
			ReplaceString(sUrlImage, sizeof(sUrlImage), "models/player/holiday/facemasks/", "");
			ReplaceString(sUrlImage, sizeof(sUrlImage), ".mdl", "");

			PrintHintText(iClient, "<span><img src='https://froidgaming.net/images/facemask/%s.png'></span>", sUrlImage);

			DataPack dp = new DataPack();
			CreateDataTimer(0.3, Timer_Image, dp);
			dp.WriteCell(GetClientUserId(iClient));
			dp.WriteString(sUrlImage);

            MenuHats(iClient, GetMenuSelectionPosition());
		}
		case MenuAction_Cancel:
		{
            if (g_PlayerData[iClient].bViewing) {
                g_PlayerData[iClient].bViewing = false;
			    SetThirdPersonView(iClient, false);
            }
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

public Action Timer_Image(Handle hTimer, Handle dp)
{
    ResetPack(dp);
    int iClient = GetClientOfUserId(ReadPackCell(dp));
    char sUrlImage[256];
    ReadPackString(dp, sUrlImage, sizeof(sUrlImage));

	if (IsValidClient(iClient)) {
		PrintHintText(iClient, "<span><img src='https://froidgaming.net/images/facemask/%s.png'></span>", sUrlImage);
	}
}