void OnGetHat(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iHatLoaded = -1;
        LogError("[OnGetHat] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iHatLoaded = -1;
        LogError("[OnGetHat] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        g_PlayerData[iClient].iHatLoaded = 1;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));
        g_PlayerData[iClient].iHatNumber = jsondata2.GetInt("hat_id");
        delete jsondata2;
    } else if (bStatus == false) {
        g_PlayerData[iClient].iHatLoaded = 0;
        LogError("[OnGetHat] Internal API Error");
    } else {
        g_PlayerData[iClient].iHatLoaded = -1;
        LogError("[OnGetHat] Invalid JSON Response 2");
    }
    delete jsondata;
}

void OnUpdateHats(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        LogError("[OnUpdateHats] HTTPStatus_OK failed");
        return;
    }
    if (response.Data == null) {
        LogError("[OnUpdateHats] Invalid JSON Response");
        return;
    }
}