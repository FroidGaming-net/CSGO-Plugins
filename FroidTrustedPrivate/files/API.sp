void OnCheckAntiCheat(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_ROOT)) {
        g_PlayerData[iClient].iFACLoaded = 1;
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iFACLoaded = -1;
        LogError("[OnCheckAntiCheat] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iFACLoaded = -1;
        LogError("[OnCheckAntiCheat] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        // Player menggunakan FACEIT AC
        g_PlayerData[iClient].iFACLoaded = 1;
    } else if (bStatus == false) {
        // Player tidak menggunakan FACEIT AC
        g_PlayerData[iClient].iFACLoaded = 0;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));

        char sMsg[1024];
        jsondata2.GetString("msg_id", sMsg, sizeof(sMsg));

        KickClient(iClient, sMsg);
        delete jsondata2;
    } else {
        g_PlayerData[iClient].iFACLoaded = -1;
        LogError("[OnCheckAntiCheat] Invalid JSON Response 2");
    }

    delete jsondata;
}