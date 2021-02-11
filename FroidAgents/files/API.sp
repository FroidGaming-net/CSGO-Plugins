void OnGetAgent(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iAgentLoaded = -1;
        LogError("[OnGetAgent] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iAgentLoaded = -1;
        LogError("[OnGetAgent] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        g_PlayerData[iClient].iAgentLoaded = 1;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));
        g_PlayerData[iClient].iAgent[0] = jsondata2.GetInt("t_agent");
        g_PlayerData[iClient].iAgent[1] = jsondata2.GetInt("ct_agent");
		g_PlayerData[iClient].SetAgentSkin(iClient, CS_TEAM_T);
		g_PlayerData[iClient].SetAgentSkin(iClient, CS_TEAM_CT);

        delete jsondata2;
    } else if (bStatus == false) {
        g_PlayerData[iClient].iAgentLoaded = 0;
        LogError("[OnGetAgent] Internal API Error");
    } else {
        g_PlayerData[iClient].iAgentLoaded = -1;
        LogError("[OnGetAgent] Invalid JSON Response 2");
    }
    delete jsondata;
}

void OnUpdateAgent(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        LogError("[OnUpdateAgent] HTTPStatus_OK failed");
        return;
    }
    if (response.Data == null) {
        LogError("[OnUpdateAgent] Invalid JSON Response");
        return;
    }
}