void OnGetSkybox(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iSkyboxLoaded = -1;
        LogError("[OnGetSkybox] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iSkyboxLoaded = -1;
        LogError("[OnGetSkybox] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        g_PlayerData[iClient].iSkyboxLoaded = 1;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));
        jsondata2.GetString("skybox", g_PlayerData[iClient].sSkybox, sizeof(g_PlayerData[].sSkybox));
        SetSkybox(iClient, g_PlayerData[iClient].sSkybox);
        delete jsondata2;
    } else if (bStatus == false) {
        g_PlayerData[iClient].iSkyboxLoaded = 0;
        LogError("[OnGetSkybox] Internal API Error");
    } else {
        g_PlayerData[iClient].iSkyboxLoaded = -1;
        LogError("[OnGetSkybox] Invalid JSON Response 2");
    }
    delete jsondata;
}

void OnUpdateSkybox(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        LogError("[OnUpdateSkybox] HTTPStatus_OK failed");
        return;
    }
    if (response.Data == null) {
        LogError("[OnUpdateSkybox] Invalid JSON Response");
        return;
    }
}