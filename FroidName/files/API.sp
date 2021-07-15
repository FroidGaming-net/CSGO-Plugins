void OnCheckName(HTTPResponse response, DataPack pack)
{
    pack.Reset();
    int iClient = GetClientOfUserId(pack.ReadCell());
    CloseHandle(pack);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        LogError("[OnCheckName] HTTPStatus_OK failed [1]");
        return;
    }

    if (response.Data == null) {
        LogError("[OnCheckName] Invalid JSON Response [1]");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        g_PlayerData[iClient].bChanged = true;
        RandomizeName(iClient);
        SetClientName(iClient, g_PlayerData[iClient].sNewName);
        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            CPrintToChat(iClient, "%s Kamu tidak dapat menggunakan nickname itu! Mohon ganti nickname kamu...", PREFIX);
        } else {
            CPrintToChat(iClient, "%s You cant use that nickname! Please change your nickname...", PREFIX);
        }
    }

    delete jsondata;
    return;
}