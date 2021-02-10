void GetVipInfo(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iVipLoaded = -1;
        LogError("[GetVipInfo] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iVipLoaded = -1;
        LogError("[GetVipInfo] Invalid JSON Response");
        return;
    }

    // Global Forward
    Call_StartForward(g_hForward_OnClientLoadedPre);
    Call_PushCell(iClient);
    Call_Finish();

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        
        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));

        // Force Anti Cheat
        int iAntiCheat = jsondata2.GetInt("anticheat");
        if(iAntiCheat == 1){
            SetUserFlagBits(iClient, GetUserFlagBits(iClient) | (1 << 15));
        }

        // Premium or Premium Plus
        char sLevel[3];
        jsondata2.GetString("level", sLevel, sizeof(sLevel));
        if(StrEqual(sLevel, "1")){
            g_PlayerData[iClient].iVipLoaded = 1;
            SetUserFlagBits(iClient, GetUserFlagBits(iClient) | (1 << 19));
        }else if(StrEqual(sLevel, "2")){
            g_PlayerData[iClient].iVipLoaded = 1;
            SetUserFlagBits(iClient, GetUserFlagBits(iClient) | (1 << 19));
            SetUserFlagBits(iClient, GetUserFlagBits(iClient) | (1 << 20));
        }

        delete jsondata2;
    } else if (bStatus == false) {
        g_PlayerData[iClient].iVipLoaded = 0;
        LogError("[GetVipInfo] Internal API Error");
    } else {
        g_PlayerData[iClient].iVipLoaded = -1;
        LogError("[GetVipInfo] Invalid JSON Response 2");
    }

    // Global Forward
    Call_StartForward(g_hForward_OnClientLoadedPost);
    Call_PushCell(iClient);
    Call_Finish();
    delete jsondata;
}

void MenuPremiumInformation(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        LogError("HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        LogError("Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);

    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));

        char sTempLevel[20], sTempStart[30], sTempEnd[30], sTempDuration[30];
        char sMenuLevel[100], sMenuStart[100], sMenuEnd[100], sMenuDuration[100];

        jsondata2.GetString("level", sTempLevel, sizeof(sTempLevel));
        jsondata2.GetString("start", sTempStart, sizeof(sTempStart));
        jsondata2.GetString("end", sTempEnd, sizeof(sTempEnd));
        jsondata2.GetString("duration", sTempDuration, sizeof(sTempDuration));

		if(StrEqual(sTempLevel, "1")){
            Format(sMenuLevel, sizeof(sMenuLevel), "» Level: Premium");
        }else if(StrEqual(sTempLevel, "2")){
            Format(sMenuLevel, sizeof(sMenuLevel), "» Level: Premium Plus");
        }else{
            Format(sMenuLevel, sizeof(sMenuLevel), "» Level: UnKnown");
        }

        Format(sMenuStart, sizeof(sMenuStart), "» Started: %s", sTempStart);
        Format(sMenuEnd, sizeof(sMenuEnd), "» Ends: %s", sTempEnd);
        Format(sMenuDuration, sizeof(sMenuDuration), "» Duration: %s", sTempDuration);

		Menu hMenu = new Menu(MenuPremium_Callback);
		hMenu.SetTitle("★ VIP Information ★");
		hMenu.AddItem("1", sMenuLevel, ITEMDRAW_DISABLED);
		hMenu.AddItem("2", sMenuStart, ITEMDRAW_DISABLED);
		hMenu.AddItem("3", sMenuEnd, ITEMDRAW_DISABLED);
		hMenu.AddItem("4", sMenuDuration, ITEMDRAW_DISABLED);
		hMenu.ExitBackButton = true;
		hMenu.Display(iClient, MENU_TIME_FOREVER);
        
        delete jsondata2;
    } else if(bStatus == false) {
        CPrintToChat(iClient, "%s {default}Internal Server Error", PREFIX);
        LogError("Invalid JSON Response");
    } else {
        CPrintToChat(iClient, "%s {default}Invalid JSON Response", PREFIX);
        LogError("Invalid JSON Response");
    }
	delete jsondata;
    return;
}