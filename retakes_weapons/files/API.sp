void OnGetWeapon(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iWeaponsLoaded = -1;
        LogError("[OnGetWeapon] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iWeaponsLoaded = -1;
        LogError("[OnGetWeapon] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        g_PlayerData[iClient].iWeaponsLoaded = 1;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));

        // CT
        jsondata2.GetString("pistolround_ct", g_PlayerData[iClient].sPistolRound_CT, sizeof(g_PlayerData[].sPistolRound_T));
		jsondata2.GetString("primary_ct", g_PlayerData[iClient].sPrimary_CT, sizeof(g_PlayerData[].sPrimary_CT));
		jsondata2.GetString("secondary_ct", g_PlayerData[iClient].sSecondary_CT, sizeof(g_PlayerData[].sSecondary_CT));
		jsondata2.GetString("smg_ct", g_PlayerData[iClient].sSMG_CT, sizeof(g_PlayerData[].sSMG_CT));
		g_PlayerData[iClient].bAWP_CT = view_as<bool>(jsondata2.GetBool("awp_ct"));
		g_PlayerData[iClient].bScout_CT = view_as<bool>(jsondata2.GetBool("scout_ct"));

        // T
        jsondata2.GetString("pistolround_t", g_PlayerData[iClient].sPistolRound_T, sizeof(g_PlayerData[].sPistolRound_T));
		jsondata2.GetString("primary_t", g_PlayerData[iClient].sPrimary_T, sizeof(g_PlayerData[].sPrimary_T));
		jsondata2.GetString("secondary_t", g_PlayerData[iClient].sSecondary_T, sizeof(g_PlayerData[].sSecondary_T));
		jsondata2.GetString("smg_t", g_PlayerData[iClient].sSMG_T, sizeof(g_PlayerData[].sSMG_T));
		g_PlayerData[iClient].bAWP_T = view_as<bool>(jsondata2.GetBool("awp_t"));
		g_PlayerData[iClient].bScout_T = view_as<bool>(jsondata2.GetBool("scout_t"));

        delete jsondata2;
    } else if (bStatus == false) {
        g_PlayerData[iClient].iWeaponsLoaded = 0;
        LogError("[OnGetWeapon] Internal API Error");
    } else {
        g_PlayerData[iClient].iWeaponsLoaded = -1;
        LogError("[OnGetWeapon] Invalid JSON Response 2");
    }
    delete jsondata;
}

void OnUpdateWeapon(HTTPResponse response, any value)
{
    // char data[30];
    // response.GetHeader("Date", data, sizeof(data));

    LogError("[OnUpdateWeapon] %i", response.Status);

    if (response.Status != HTTPStatus_OK) {
        LogError("[OnUpdateWeapon] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        LogError("[OnUpdateWeapon] Invalid JSON Response");
        return;
    }
}