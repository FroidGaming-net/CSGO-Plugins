void OnGetExp(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iPlayersLoaded = -1;
        LogError("[OnGetExp] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iPlayersLoaded = -1;
        LogError("[OnGetExp] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        g_PlayerData[iClient].iPlayersLoaded = 1;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));
        g_PlayerData[iClient].iEXP = jsondata2.GetInt("score");
        OnCheckPlayer(iClient);
        delete jsondata2;
    } else if (bStatus == false) {
        g_PlayerData[iClient].iPlayersLoaded = 0;
        LogError("[OnGetExp] Internal API Error");
    } else {
        g_PlayerData[iClient].iPlayersLoaded = -1;
        LogError("[OnGetExp] Invalid JSON Response 2");
    }
    delete jsondata;
}