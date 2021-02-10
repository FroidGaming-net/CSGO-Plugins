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

			if(StringToInt(sInfo) > 1){
			 	MenuAgentType(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuAgentType(int iClient)
{
	Menu hMenu = new Menu(MenuAgentType_Callback);
	
	char sTempTitle[100];
	Format(sTempTitle, sizeof(sTempTitle), "★ Choose Agents Type - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");
	
	hMenu.SetTitle(sTempTitle);
	if(g_PlayerData[iClient].iCacheTeam == 3) hMenu.AddItem("-1", "• Default Agents", g_PlayerData[iClient].iAgentCT == -1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(g_PlayerData[iClient].iCacheTeam == 2) hMenu.AddItem("-2", "• Default Agents", g_PlayerData[iClient].iAgentT == -2 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	hMenu.AddItem("deserved", "• Distinguished Agents");
	hMenu.AddItem("nomine", "• Exceptional Agents");
	hMenu.AddItem("perfect", "• Superior Agents");
	hMenu.AddItem("master", "• Master Agents");
	hMenu.ExitBackButton = true;
    hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int MenuAgentType_Callback(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
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
			if(StrEqual(sInfo, "-1") || StrEqual(sInfo, "-2")){
				int iTeams = GetClientTeam(iClient);
				if(g_PlayerData[iClient].iCacheTeam == 3) // CT
				{
					g_PlayerData[iClient].iAgentCT = StringToInt(sInfo);
					
					PrintHintText(iClient, "<span><img src='https://froidgaming.net/images/customplayer_ct_map_based.png'></span>");

					DataPack dp = new DataPack();
					CreateDataTimer(0.3, Timer_Image, dp);
					dp.WriteCell(GetClientUserId(iClient));
					dp.WriteString("ct_map_based");
				}else if(g_PlayerData[iClient].iCacheTeam == 2) // T
				{
					g_PlayerData[iClient].iAgentT = StringToInt(sInfo);

					PrintHintText(iClient, "<span><img src='https://froidgaming.net/images/customplayer_t_map_based.png'></span>");

					DataPack dp = new DataPack();
					CreateDataTimer(0.3, Timer_Image, dp);
					dp.WriteCell(GetClientUserId(iClient));
					dp.WriteString("t_map_based");
				}

				if(iTeams == GetAgentModelTeam(StringToInt(sInfo))) {
					CS_UpdateClientModel(iClient);
				}
				
				MenuAgentType(iClient);
			}else{
				Format(g_PlayerData[iClient].sCacheType, sizeof(g_PlayerData[].sCacheType), sInfo);
				MenuAgentSelect(iClient);
			}
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if (iSlot == MenuCancel_ExitBack) {
				MenuAgentTeam(iClient);
			}
		}
		case MenuAction_End:
		{
			hMenu.Close();
		}
	}
}

void MenuAgentSelect(int iClient, int iStart = 0)
{	
	if (!IsValidClient(iClient)) {
		return;
	}

	Menu hMenu = new Menu(MenuAgentSelect_Callback);
	if(StrEqual(g_PlayerData[iClient].sCacheType, "deserved"))
	{
        char sTempTitle[100];
        Format(sTempTitle, sizeof(sTempTitle), "★ Distinguished Agents - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");

    	hMenu.SetTitle(sTempTitle);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(1)) hMenu.AddItem("1", "» SEAL TEAM 6 SOLDIER | NSWC SEAL", g_PlayerData[iClient].iAgentCT==1?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(2)) hMenu.AddItem("2", "» 3RD COMMANDO COMPANY | KSK", g_PlayerData[iClient].iAgentCT==2?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(3)) hMenu.AddItem("3", "» OPERATOR | FBI SWAT", g_PlayerData[iClient].iAgentCT==3?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(7)) hMenu.AddItem("7", "» B SQUADRON OFFICER | SAS", g_PlayerData[iClient].iAgentCT==7?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		//NEW 
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(23)) hMenu.AddItem("23", "» SWAT | CHEM-HAZ SPECIALIST (NEW)", g_PlayerData[iClient].iAgentCT==23?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(24)) hMenu.AddItem("24", "» SWAT | Bio-Haz Specialist (NEW)", g_PlayerData[iClient].iAgentCT==24?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);

		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(4)) hMenu.AddItem("4", "» GROUND REBEL | ELITE CREW", g_PlayerData[iClient].iAgentT==4?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(5)) hMenu.AddItem("5", "» ENFORCER | PHOENIX", g_PlayerData[iClient].iAgentT==5?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(6)) hMenu.AddItem("6", "» SOLDIER | PHOENIX", g_PlayerData[iClient].iAgentT==6?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		//NEW 
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(25)) hMenu.AddItem("25", "» THE PROFESSIONALS | STREET SOLDIER (NEW)", g_PlayerData[iClient].iAgentT==25?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(26)) hMenu.AddItem("26", "» SABRE FOOTSOLDIER | DRAGOMIR (NEW)", g_PlayerData[iClient].iAgentT==26?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	} else if(StrEqual(g_PlayerData[iClient].sCacheType, "nomine"))
	{
        char sTempTitle[100];
        Format(sTempTitle, sizeof(sTempTitle), "★ Exceptional Agents - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");

		hMenu.SetTitle(sTempTitle);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(8)) hMenu.AddItem("8", "» MARKUS DELROW | FBI HRT", g_PlayerData[iClient].iAgentCT==8?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(10)) hMenu.AddItem("10", "» BUCKSHOT | NSWC SEAL", g_PlayerData[iClient].iAgentCT==10?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		//NEW 
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(27)) hMenu.AddItem("27", "» SWAT | SERGEANT BOMBSON (NEW)", g_PlayerData[iClient].iAgentCT==27?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(28)) hMenu.AddItem("28", "» SWAT | JOHN 'VAN HEALEN' KASK (NEW)", g_PlayerData[iClient].iAgentCT==28?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(29)) hMenu.AddItem("29", "» NSWC SEAL | 'BLUEBERRIES' BUCKSHOT (NEW)", g_PlayerData[iClient].iAgentCT==29?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);

		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(9)) hMenu.AddItem("9", "» MAXIMUS | SABRE", g_PlayerData[iClient].iAgentT==9?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(11)) hMenu.AddItem("11", "» OSIRIS | ELITE CREW", g_PlayerData[iClient].iAgentT==11?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(12)) hMenu.AddItem("12", "» SLINGSHOT | PHOENIX", g_PlayerData[iClient].iAgentT==12?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(13)) hMenu.AddItem("13", "» DRAGOMIR | SABRE", g_PlayerData[iClient].iAgentT==13?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		//NEW 
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(30)) hMenu.AddItem("30", "» THE PROFESSIONALS | GETAWAY SALLY (NEW)", g_PlayerData[iClient].iAgentT==30?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(31)) hMenu.AddItem("31", "» THE PROFESSIONALS | LITTLE KEV (NEW)", g_PlayerData[iClient].iAgentT==31?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	} else if(StrEqual(g_PlayerData[iClient].sCacheType, "perfect"))
	{
        char sTempTitle[100];
        Format(sTempTitle, sizeof(sTempTitle), "★ Superior Agents - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");

		hMenu.SetTitle(sTempTitle);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(15)) hMenu.AddItem("15", "» MICHAEL SYFERS | FBI SNIPER", g_PlayerData[iClient].iAgentCT==15?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(16)) hMenu.AddItem("16", "» 'TWO TIMES' MCCOY | USAF TACP", g_PlayerData[iClient].iAgentCT==16?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		//NEW 
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(32)) hMenu.AddItem("32", "» TACP CAVALRY | 'TWO TIMES' MCCOY (NEW)", g_PlayerData[iClient].iAgentCT==32?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(33)) hMenu.AddItem("33", "» SWAT | 1ST LIEUTENANT FARLOW (NEW)", g_PlayerData[iClient].iAgentCT==33?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);

		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(14)) hMenu.AddItem("14", "» BLACKWOLF | SABRE", g_PlayerData[iClient].iAgentT==14?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(17)) hMenu.AddItem("17", "» PROF. SHAHMAT | ELITE CREW", g_PlayerData[iClient].iAgentT==17?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(18)) hMenu.AddItem("18", "» REZAN THE READY | SABRE", g_PlayerData[iClient].iAgentT==18?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		//NEW 
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(34)) hMenu.AddItem("34", "» SABRE | REZAN THE REDSHIRT (NEW)", g_PlayerData[iClient].iAgentT==34?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(35)) hMenu.AddItem("35", "» THE PROFESSIONALS | NUMBER K (NEW)", g_PlayerData[iClient].iAgentT==35?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(36)) hMenu.AddItem("36", "» THE PROFESSIONALS | SAFECRACKER VOLTZMANN (NEW)", g_PlayerData[iClient].iAgentT==36?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	} else if(StrEqual(g_PlayerData[iClient].sCacheType, "master"))
	{
        char sTempTitle[100];
        Format(sTempTitle, sizeof(sTempTitle), "★ Master Agents - %s ★", g_PlayerData[iClient].iCacheTeam == 3 ? "CT" : "T");

		hMenu.SetTitle(sTempTitle);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(19)) hMenu.AddItem("19", "» LT. COMMANDER RICKSAW | NSWC SEAL", g_PlayerData[iClient].iAgentCT==19?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(20)) hMenu.AddItem("20", "» SPECIAL AGENT AVA | FBI", g_PlayerData[iClient].iAgentCT==20?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		//NEW 
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(37)) hMenu.AddItem("37", "» SWAT | CMDR. MAE 'DEAD COLD' JAMISON (NEW)", g_PlayerData[iClient].iAgentCT==37?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);

		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(21)) hMenu.AddItem("21", "» 'THE DOCTOR' ROMANOV | SABRE", g_PlayerData[iClient].iAgentT==21?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(22)) hMenu.AddItem("22", "» THE ELITE MR. MUHLIK | ELITE CREW", g_PlayerData[iClient].iAgentT==22?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		//NEW 
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(38)) hMenu.AddItem("38", "» THE PROFESSIONALS | SIR BLOODY MIAMI DARRYL (NEW)", g_PlayerData[iClient].iAgentT==38?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(39)) hMenu.AddItem("39", "» THE PROFESSIONALS | SIR BLOODY SILENT DARRYL (NEW)", g_PlayerData[iClient].iAgentT==39?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(40)) hMenu.AddItem("40", "» THE PROFESSIONALS | SIR BLOODY SKULLHEAD DARRYL (NEW)", g_PlayerData[iClient].iAgentT==40?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(41)) hMenu.AddItem("41", "» THE PROFESSIONALS | SIR BLOODY DARRYL ROYALE (NEW)", g_PlayerData[iClient].iAgentT==41?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		if(g_PlayerData[iClient].iCacheTeam == GetAgentModelTeam(42)) hMenu.AddItem("42", "» THE PROFESSIONALS | SIR BLOODY LOUDMOUTH DARRYL (NEW)", g_PlayerData[iClient].iAgentT==42?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	}
	hMenu.ExitBackButton = true;

	if(iStart == 0)
	{
    	hMenu.Display(iClient, MENU_TIME_FOREVER);
	}else{
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
			int iTeams = GetClientTeam(iClient);

			hMenu.GetItem(iSlot, sInfo, sizeof(sInfo));

			if(3 == GetAgentModelTeam(StringToInt(sInfo))) // CT
			{
				g_PlayerData[iClient].iAgentCT = StringToInt(sInfo);
			}else if(2 == GetAgentModelTeam(StringToInt(sInfo))) // T
			{
				g_PlayerData[iClient].iAgentT = StringToInt(sInfo);
			}

			if(iTeams == GetAgentModelTeam(StringToInt(sInfo)))
			{
				SetEntityModel(iClient, GetAgentModelFromId(StringToInt(sInfo)));
			}
		
			MenuAgentSelect(iClient, GetMenuSelectionPosition());

			char sUrlImage[256];
			Format(sUrlImage, sizeof(sUrlImage), "%s", GetAgentModelFromId(StringToInt(sInfo)));
			ReplaceString(sUrlImage, sizeof(sUrlImage), "models/player/custom_player/legacy/", "");
			ReplaceString(sUrlImage, sizeof(sUrlImage), ".mdl", "");

			PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/characters/customplayer_%s.png'></span>", sUrlImage);

			DataPack dp = new DataPack();
			CreateDataTimer(0.3, Timer_Image, dp);
			dp.WriteCell(GetClientUserId(iClient));
			dp.WriteString(sUrlImage);
		}
		case MenuAction_Cancel:
		{
			if (!IsValidClient(iClient)) {
				return;
			}

			if(iSlot == MenuCancel_ExitBack)
			{
				MenuAgentType(iClient);
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
		PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/characters/customplayer_%s.png'></span>", sUrlImage);
	}
}
