void OnGetEmoji(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iEmojiLoaded = -1;
        LogError("[OnGetEmoji] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iEmojiLoaded = -1;
        LogError("[OnGetEmoji] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        g_PlayerData[iClient].iEmojiLoaded = 1;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));
        g_PlayerData[iClient].iEmojiData = jsondata2.GetInt("emoji_id");
        delete jsondata2;
    } else if (bStatus == false) {
        g_PlayerData[iClient].iEmojiLoaded = 0;
        LogError("[OnGetEmoji] Internal API Error");
    } else {
        g_PlayerData[iClient].iEmojiLoaded = -1;
        LogError("[OnGetEmoji] Invalid JSON Response 2");
    }
    delete jsondata;
}

void OnUpdateEmoji(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        LogError("[OnGetEmoji] HTTPStatus_OK failed");
        return;
    }
    if (response.Data == null) {
        LogError("[OnGetEmoji] Invalid JSON Response");
        return;
    }
}