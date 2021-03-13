void OnGetServers(HTTPResponse response, DataPack pack)
{
    pack.Reset();
    int iClient = GetClientOfUserId(pack.ReadCell());
    char sTempCategory[128];
    pack.ReadString(sTempCategory, sizeof(sTempCategory));
    CloseHandle(pack);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        CPrintToChat(iClient, "%s {default}HTTPStatus_OK failed", PREFIX);
        return;
    }

    if (response.Data == null) {
        CPrintToChat(iClient, "%s {default}Invalid JSON Response", PREFIX);
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        JSONArray jsondata2 = view_as<JSONArray>(jsondata.Get("data"));
        int iDataLength = jsondata2.Length;

        JSONObject jsondata3;
        char sTemp[512];
        char sServerName[256], sIP[128], sFullPlayers[6], sMap[128], sStatus[32];

        Menu hMenu = new Menu(MenuServers_Callback);
        hMenu.SetTitle("★ Servers Menu ★");
        for (int i = 0; i < iDataLength; i++) {
            jsondata3 = view_as<JSONObject>(jsondata2.Get(i));

            jsondata3.GetString("name", sServerName, sizeof(sServerName));

            if (StrContains(sServerName, sTempCategory, false) != -1) {
                jsondata3.GetString("domain", sIP, sizeof(sIP));
                jsondata3.GetString("full_players", sFullPlayers, sizeof(sFullPlayers));
                jsondata3.GetString("map", sMap, sizeof(sMap));
                jsondata3.GetString("status", sStatus, sizeof(sStatus));

                if (StrContains(sStatus, "Online", false)) {
                    Format(sTemp, sizeof(sTemp), "• %s\n ❯ %s | %s Players", sServerName, sMap, sFullPlayers);
                    hMenu.AddItem(sIP, sTemp);
                } else {
                    Format(sTemp, sizeof(sTemp), "• %s\n ❯ %s | %s Players", sServerName, sMap, sFullPlayers);
                    hMenu.AddItem(sIP, sTemp, ITEMDRAW_DISABLED);
                }
            }

            delete jsondata3;
        }

        hMenu.ExitBackButton = true;
        hMenu.Display(iClient, MENU_TIME_FOREVER);

        delete jsondata2;
    } else if (bStatus == false) {
        CPrintToChat(iClient, "%s {default}Internal API Error", PREFIX);
    } else {
        CPrintToChat(iClient, "%s {default}Invalid JSON Response 2", PREFIX);
    }
    delete jsondata;
}