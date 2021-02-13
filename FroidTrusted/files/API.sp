void OnCheckBanned(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iBannedLoaded = -1;
        LogError("[OnCheckBanned] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iBannedLoaded = -1;
        LogError("[OnCheckBanned] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        // Player Banned
        g_PlayerData[iClient].iBannedLoaded = 0;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));

        char sMsg[1024];
        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            jsondata2.GetString("msg_id", sMsg, sizeof(sMsg));
        } else {
            jsondata2.GetString("msg_en", sMsg, sizeof(sMsg));
        }

        KickClient(iClient, sMsg);
        delete jsondata2;
    } else if (bStatus == false) {
        // Player Clean
        g_PlayerData[iClient].iBannedLoaded = 1;
    } else {
        g_PlayerData[iClient].iBannedLoaded = -1;
        LogError("[OnCheckBanned] Invalid JSON Response 2");
    }

    delete jsondata;
}

void OnCheckAntiCheat(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
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

        // if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
        //     char sAuthID[64];
        //     GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));

        //     // FormatEx(sUrl, sizeof(sUrl), "api/player/%s", sAuthID);
        //     // httpClient.Get(sUrl, OnCheckPlayerData, GetClientUserId(iClient));

        //     CreateTimer(30.0, Timer_DelayJoin2, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
        // }
    } else if (bStatus == false) {
        // Player tidak menggunakan FACEIT AC
        g_PlayerData[iClient].iFACLoaded = 0;

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));

        char sMsg[1024];
        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            jsondata2.GetString("msg_id", sMsg, sizeof(sMsg));
        } else {
            jsondata2.GetString("msg_en", sMsg, sizeof(sMsg));
        }

        KickClient(iClient, sMsg);
        delete jsondata2;
    } else {
        g_PlayerData[iClient].iFACLoaded = -1;
        LogError("[OnCheckAntiCheat] Invalid JSON Response 2");
    }

    delete jsondata;
}

void OnCheckPlayerData(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iPlayerDataLoaded = -1;
        LogError("[OnCheckPlayerData] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iPlayerDataLoaded = -1;
        LogError("[OnCheckPlayerData] Invalid JSON Response");
        return;
    }

    JSONObject jsondata = view_as<JSONObject>(response.Data);
    bool bStatus = jsondata.GetBool("status");
    if (bStatus == true) {
        g_PlayerData[iClient].iPlayerDataLoaded = 1;

        char sAuthID[64], sUrl[256];
        GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));

        JSONObject jsondata2 = view_as<JSONObject>(jsondata.Get("data"));
        // CS:GO level
        if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
            if (!IsClientPrime(iClient)) {
                int tempLevel = jsondata2.GetInt("level");

                if (tempLevel == 0) {
                    int iLevel = GetClientRank(iClient);

                    if (iLevel <= 9) {
                        g_PlayerData[iClient].iCSGOLevel = 0;

                        Format(sUrl, sizeof(sUrl), "api/anticheat/%s", sAuthID);
                        httpClient.Get(sUrl, OnCheckAntiCheat, GetClientUserId(iClient));
                    } else if(iLevel >= 10) {
                        g_PlayerData[iClient].iCSGOLevel = 1;
                    }
                } else if (tempLevel == 1) {
                    g_PlayerData[iClient].iCSGOLevel = 1;
                }

                // Prose pengecekan data khusus non-premium
                int tempHours = jsondata2.GetInt("hours");

                if (tempHours == 0) {
                    FormatEx(sUrl, sizeof(sUrl), "IPlayerService/GetOwnedGames/v0001?key=26B12AFA10E748B57D135D055FA98808&steamid=%s&appids_filter[0]=730&format=json", sAuthID);
                    httpClient2.Get(sUrl, OnCheckHours, GetClientUserId(iClient));
                }
            }
        }

         // Jika player masuk dalam kategori Untrusted maka wajib FACEIT AC
        if (CheckCommandAccess(iClient, "sm_froidapp_untrusted", ADMFLAG_CUSTOM1) && !CheckCommandAccess(iClient, "sm_froidapp_admin", ADMFLAG_GENERIC)) {
            Format(sUrl, sizeof(sUrl), "api/anticheat/%s", sAuthID);
            httpClient.Get(sUrl, OnCheckAntiCheat, GetClientUserId(iClient));
        }

        delete jsondata2;
    } else if (bStatus == false) {
        g_PlayerData[iClient].iPlayerDataLoaded = 0;
        LogError("[OnCheckPlayerData] Internal API Error");
    } else {
        g_PlayerData[iClient].iPlayerDataLoaded = -1;
        LogError("[OnCheckPlayerData] Invalid JSON Response 2");
    }

    delete jsondata;
}

void OnCheckHours(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iHoursLoaded = -1;
        LogError("[OnCheckHours] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iHoursLoaded = -1;
        LogError("[OnCheckHours] Invalid JSON Response");
        return;
    }

    JSONObject hResponse = view_as<JSONObject>(response.Data);
    JSONObject hResponseRoot = view_as<JSONObject>(hResponse.Get("response"));

    if(!hResponseRoot.HasKey("games"))
    {
        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
            KickClient(iClient, "Ubah Pengaturan Privasi Profil kamu ke Publik yaa!\n1. Pastikan \"Game details\" diubah ke Public!\n2. Pastikan untuk tidak mencentang \"Always keep my total playtime private\" yang posisinya berada di bawah \"Game details\"\nButuh bantuan? silahkan hubungi kami di https://discord.io/froidgaming");
        }else{
            KickClient(iClient, "Change your Profile Privacy Settings to Public!\n1. Make sure \"Game details\" is changed to Public!\n2. Make sure to UNCHECK \"Always keep my total playtime private\" which is under \"Game details\"\nNeed help? please contact us at https://discord.io/froidgaming");
        }
        delete hResponseRoot;
        delete hResponse;
        return;
    }

    JSONArray hResponseGames = view_as<JSONArray>(hResponseRoot.Get("games"));
    JSONObject hGame = view_as<JSONObject>(hResponseGames.Get(0));

    int iPlaytime = hGame.GetInt("playtime_forever");

    if(iPlaytime == 0)
    {
        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
            KickClient(iClient, "Kamu tidak memenuhi persyaratan jam minimum untuk bermain di sini! (%i/100)\n1. Pastikan \"Game details\" diubah ke Public!\n2. Pastikan untuk tidak mencentang \"Always keep my total playtime private\" yang posisinya berada di bawah \"Game details\"\nButuh bantuan? silahkan hubungi kami di https://discord.io/froidgaming", (iPlaytime / 60));
        }else{
            KickClient(iClient, "You do not meet the minimum hour requirement to play here! (%i/100)\n1. Make sure \"Game details\" is changed to Public!\n2. Make sure to UNCHECK \"Always keep my total playtime private\" which is under \"Game details\"\nNeed help? please contact us at https://discord.io/froidgaming", (iPlaytime / 60));
        }
        delete hGame;
        delete hResponseGames;
        delete hResponseRoot;
        delete hResponse;
        return;
    }

    if(100 > (iPlaytime / 60))
    {
        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
            KickClient(iClient, "Kamu tidak memenuhi persyaratan jam minimum untuk bermain di sini! (%i/100)\n1. Pastikan \"Game details\" diubah ke Public!\n2. Pastikan untuk tidak mencentang \"Always keep my total playtime private\" yang posisinya berada di bawah \"Game details\"\nButuh bantuan? silahkan hubungi kami di https://discord.io/froidgaming", (iPlaytime / 60));
        }else{
            KickClient(iClient, "You do not meet the minimum hour requirement to play here! (%i/100)\n1. Make sure \"Game details\" is changed to Public!\n2. Make sure to UNCHECK \"Always keep my total playtime private\" which is under \"Game details\"\nNeed help? please contact us at https://discord.io/froidgaming", (iPlaytime / 60));
        }
        delete hGame;
        delete hResponseGames;
        delete hResponseRoot;
        delete hResponse;
        return;
    }

    char sAuthID[64], sUrl[256];
    GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
    FormatEx(sUrl, sizeof(sUrl), "ISteamUser/GetPlayerSummaries/v0002/?key=26B12AFA10E748B57D135D055FA98808&steamids=%s", sAuthID);
    httpClient2.Get(sUrl, OnCheckCreateAt, GetClientUserId(iClient));

    delete hGame;
    delete hResponseGames;
    delete hResponseRoot;
    delete hResponse;
    return;
}

void OnCheckCreateAt(HTTPResponse response, any value)
{
    int iClient = GetClientOfUserId(value);

    if (!IsValidClient(iClient)) {
        return;
    }

    if (response.Status != HTTPStatus_OK) {
        g_PlayerData[iClient].iCreatedAtLoaded = -1;
        LogError("[OnCheckCreateAt] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        g_PlayerData[iClient].iCreatedAtLoaded = -1;
        LogError("[OnCheckCreateAt] Invalid JSON Response");
        return;
    }

    JSONObject hResponse = view_as<JSONObject>(response.Data);
    JSONObject hResponseRoot = view_as<JSONObject>(hResponse.Get("response"));
    JSONArray hResponsePlayers = view_as<JSONArray>(hResponseRoot.Get("players"));
    JSONObject hPlayers = view_as<JSONObject>(hResponsePlayers.Get(0));

    if(!hPlayers.HasKey("timecreated"))
    {
        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
            KickClient(iClient, "Ubah Pengaturan Privasi Profil kamu ke Publik yaa!\n1. Ubah Pengaturan Privasi Profil kamu ke Publik yaa!\n2. Pastikan untuk tidak mencentang \"Always keep my total playtime private\" yang posisinya berada di bawah \"Game details\"\nButuh bantuan? silahkan hubungi kami di https://discord.io/froidgaming");
        }else{
            KickClient(iClient, "Change your Profile Privacy Settings to Public!\n1. Change your Profile Privacy Settings to Public!\n2. Make sure to UNCHECK \"Always keep my total playtime private\" which is under \"Game details\"\nNeed help? please contact us at https://discord.io/froidgaming");
        }
        delete hPlayers;
        delete hResponsePlayers;
        delete hResponseRoot;
        delete hResponse;
        return;
    }

    int iTimeCreated = hPlayers.GetInt("timecreated");
    if(iTimeCreated > (GetTime()-(86400*31)))
    {
        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
            KickClient(iClient, "Akun Kamu harus sudah lebih dari 31 hari!\n1. Ubah Pengaturan Privasi Profil kamu ke Publik yaa!\n2. Pastikan untuk tidak mencentang \"Always keep my total playtime private\" yang posisinya berada di bawah \"Game details\"\nButuh bantuan? silahkan hubungi kami di https://discord.io/froidgaming");
        }else{
            KickClient(iClient, "Your account must be more than 31 days old!\n1. Change your Profile Privacy Settings to Public!\n2. Make sure to UNCHECK \"Always keep my total playtime private\" which is under \"Game details\"\nNeed help? please contact us at https://discord.io/froidgaming");
        }
        delete hPlayers;
        delete hResponsePlayers;
        delete hResponseRoot;
        delete hResponse;
        return;
    }

    delete hPlayers;
    delete hResponsePlayers;
    delete hResponseRoot;
    delete hResponse;

    char sAuthID[64], sUrl[128];
    GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
    Format(sUrl, sizeof(sUrl), "api/player/%s", sAuthID);

    JSONObject jsondata = new JSONObject();
    jsondata.SetInt("hours", 1);
    if (g_PlayerData[iClient].iCSGOLevel == 1) {
        jsondata.SetInt("level", 1);
    } else if (g_PlayerData[iClient].iCSGOLevel == 0) {
        jsondata.SetInt("level", 0);
    }
    httpClient.Put(sUrl, jsondata, OnUpdatePlayerData);
    delete jsondata;

    return;
}

// void OnCheckLevel(HTTPResponse response, any value)
// {
//     int iClient = GetClientOfUserId(value);

//     if (!IsValidClient(iClient)) {
//         return;
//     }

//     if (response.Status != HTTPStatus_OK) {
//         g_PlayerData[iClient].iLevelLoaded = -1;
//         LogError("[OnCheckLevel] HTTPStatus_OK failed");
//         return;
//     }

//     if (response.Data == null) {
//         g_PlayerData[iClient].iLevelLoaded = -1;
//         LogError("[OnCheckLevel] Invalid JSON Response");
//         return;
//     }

//     JSONObject hResponse = view_as<JSONObject>(response.Data);
//     JSONObject hResponseRoot = view_as<JSONObject>(hResponse.Get("response"));

//     if(!hResponseRoot.HasKey("player_level")) {
//         if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
//             KickClient(iClient, "Ubah Pengaturan Privasi Profil kamu ke Publik yaa!");
//         } else {
//             KickClient(iClient, "Change your Profile Privacy Settings to Public!");
//         }
//         delete hResponseRoot;
//         delete hResponse;
//         return;
//     }

//     int iSteamLevel = hResponseRoot.GetInt("player_level");
//     if(iSteamLevel < 1) {
//         if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
//             char sAuthID[64], sUrl[128];
//             GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
//             Format(sUrl, sizeof(sUrl), "api/anticheat/%s", sAuthID);
//             httpClient.Get(sUrl, OnCheckAntiCheat, GetClientUserId(iClient));
//         }
//         delete hResponseRoot;
//         delete hResponse;
//         return;
//     }

//     delete hResponseRoot;
//     delete hResponse;
//     return;
// }

void OnUpdatePlayerData(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        LogError("[OnUpdatePlayerData] HTTPStatus_OK failed");
        return;
    }

    if (response.Data == null) {
        LogError("[OnUpdatePlayerData] Invalid JSON Response");
        return;
    }
}