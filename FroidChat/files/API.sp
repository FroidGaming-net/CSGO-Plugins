void OnGetChat(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iChatLoaded = -1;
        LogError("[OnGetChat] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iChatLoaded = -1;
        LogError("[OnGetChat] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        g_PlayerData[iClient].iChatLoaded = 1;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));
        jsondata2.GetString("namecolor", g_PlayerData[iClient].sName, sizeof(g_PlayerData[].sName));
        jsondata2.GetString("messagecolor", g_PlayerData[iClient].sMessage, sizeof(g_PlayerData[].sMessage));
        jsondata2.GetString("clantag", g_PlayerData[iClient].sClanTag, sizeof(g_PlayerData[].sClanTag));
        delete jsondata2;
    } else if (bStatus == false) {
        g_PlayerData[iClient].iChatLoaded = 0;
        LogError("[OnGetChat] Internal API Error");
    } else {
        g_PlayerData[iClient].iChatLoaded = -1;
        LogError("[OnGetChat] Invalid JSON Response 2");
    }
    delete jsondata;
}

void OnCheckChat(HTTPResponse response, DataPack pack)
{
    pack.Reset();
    int iClient = GetClientOfUserId(pack.ReadCell());
    char sClanTag[128];
    pack.ReadString(sClanTag, sizeof(sClanTag));
    CloseHandle(pack);

    if (!IsValidClient(iClient)) {
        return;
    }
    
    if (response.Status != HTTPStatus_OK) {
        CPrintToChat(iClient, "%s Failed to retrieve response from FroidAPI!", PREFIX);
        LogError("[OnClantagCheck] HTTPStatus_OK failed [1]");
        return;
    }
    
    if (response.Data == null) {
        CPrintToChat(iClient, "%s Invalid JSON Response!", PREFIX);
        LogError("[OnClantagCheck] Invalid JSON Response [1]");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            CPrintToChat(iClient, "%s Kamu tidak dapat menggunakan clantag itu!", PREFIX);
        } else {
            CPrintToChat(iClient, "%s You can't use that clantag!", PREFIX);
        }
    } else if(bStatus == false) {
        strcopy(g_PlayerData[iClient].sClanTag, sizeof(g_PlayerData[].sClanTag), sClanTag);

        if (StrContains(g_sHostname, "Arena") > -1) {
            Multi1v1_AfterPlayerSetup(iClient);
        } else if(StrContains(g_sHostname, "Arena") == -1) {
            CS_SetClientClanTag(iClient, g_PlayerData[iClient].sClanTag);
        }

        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            CPrintToChat(iClient, "%s Kamu berhasil mengubah clantag Kamu!", PREFIX);
        } else {
            CPrintToChat(iClient, "%s You've changed your clantag!", PREFIX);
        }
    } else {
        CPrintToChat(iClient, "%s Invalid JSON Response!", PREFIX);
        LogError("[OnClantagCheck] Invalid JSON Response [2]");
    }

    delete jsondata;
    return;
}

void OnUpdateChat(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        PrintToServer("[OnUpdateChat] HTTPStatus_OK failed [1]");
        LogError("[OnUpdateChat] HTTPStatus_OK failed [1]");
        return;
    }
    if (response.Data == null) {
        PrintToServer("[OnUpdateChat] Invalid JSON Response [1]");
        LogError("[OnUpdateChat] Invalid JSON Response [1]");
        return;
    }
}