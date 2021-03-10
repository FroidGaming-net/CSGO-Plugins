public Action OnPlayerRunCmd(int iClient, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

    if(StrContains(g_sHostname, "Arena") == -1){
        char sTag[32];
        CS_GetClientClanTag(iClient, sTag, sizeof(sTag));
        if(!(StrEqual(g_PlayerData[iClient].sClanTag, sTag))) {
            CS_SetClientClanTag(iClient, g_PlayerData[iClient].sClanTag);
        }
    }

    return Plugin_Continue;
}

public Action OnClientSayCommand(int iClient, const char[] sCommand, const char[] sArgs)
{
    if (!IsValidClient(iClient)) {
        return Plugin_Continue;
    }

    if (!g_PlayerData[iClient].bWaitingForData) {
        return Plugin_Continue;
    }

    g_PlayerData[iClient].bWaitingForData = false;

    if(StrContains(sArgs, "cancel") > -1) {
        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
			CPrintToChat(iClient, "%s Tindakan dibatalkan!", PREFIX);
		}else{
			CPrintToChat(iClient, "%s Action aborted!", PREFIX);
		}
        return Plugin_Handled;
    }

    /// General Blacklist
    if(!IsValidChatTag(sArgs)){
        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
            CPrintToChat(iClient, "%s Kamu tidak dapat menggunakan clantag itu!", PREFIX);
        }else{
            CPrintToChat(iClient, "%s You can't use that clantag!", PREFIX);
        }
        return Plugin_Handled;
    }

    /// Validasi panjang karakter
    if(strlen(sArgs) > 9)
    {
        if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
            CPrintToChat(iClient, "%s Maksimal 9 Karakter!", PREFIX);
        }else{
            CPrintToChat(iClient, "%s Maximum 9 Characters!", PREFIX);
        }
        return Plugin_Handled;
    }

    if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
        CPrintToChat(iClient, "%s Mohon tunggu, sedang melakukan validasi clantag...", PREFIX);
    }else{
        CPrintToChat(iClient, "%s Please wait...", PREFIX);
    }

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(iClient));
    pack.WriteString(sArgs);

    JSONObject jsondata = new JSONObject();
    jsondata.SetString("clantag", sArgs);
    httpClient.Post("api/chat", jsondata, OnCheckChat, pack);
    delete jsondata;

    return Plugin_Handled;
}

public void Multi1v1_AfterPlayerSetup(int iClient)
{
	int iArena = Multi1v1_GetArenaNumber(iClient);
	char sClanTag[32];

	if(CheckCommandAccess(iClient, "sm_froidchat_premium", ADMFLAG_CUSTOM5)){
		if(StrEqual(g_PlayerData[iClient].sClanTag, ""))
		{
			Format(sClanTag, sizeof(sClanTag), "A %d", iArena);
		}else{
			Format(sClanTag, sizeof(sClanTag), "A %d | %s", iArena, g_PlayerData[iClient].sClanTag);
		}
	}else{
		Format(sClanTag, sizeof(sClanTag), "A %d", iArena);
	}

	CS_SetClientClanTag(iClient, sClanTag);

	if (hl_isInChallenge(iClient))
	{
		CS_SetClientClanTag(iClient, "[CHALLENGE]");
		CS_SetClientContributionScore(iClient, -1);
	}
}

public Processing  cc_proc_OnRebuildString(const int[] props, int part, ArrayList params, int &level, char[] value, int size) {
    static const char channels[][] = {"STP", "STA"};
    static char szValue[MESSAGE_LENGTH];
    static char channel[64];
    static int index = BIND_MAX;

    if(!SENDER_INDEX(props[1]) || (index = indexOfPart(part)) == -1 || level > g_iLevel[index]) {
        return Proc_Continue;
    }

    params.GetString(0, channel, sizeof(channel));
    if(!InChannels(channel, channels, sizeof(channels))) {
        return Proc_Continue;
    }

    FormatEx(
        szValue, sizeof(szValue),
        (!index)
        ? g_PlayerData[SENDER_INDEX(props[1])].sName
        : g_PlayerData[SENDER_INDEX(props[1])].sMessage
    );

    if(!szValue[0]) {
        return Proc_Continue;
    }

    level = g_iLevel[index];
    if(!strcmp(szValue, "rainbow")) {
        FormatEx(szValue, sizeof(szValue), NULL_STRING);
        doRainbow(szValue, sizeof(szValue), value);
        FormatEx(value, size, "%s", szValue);
        return Proc_Change;
    } else if(!strcmp(szValue, "random")) {
        doRandom(szValue, sizeof(szValue));
    }

    Format(value, size, "%s%s", szValue, value);
    return Proc_Change;
}

public void levelHandler(ConVar convar, const char[] oldVal, const char[] newVal) {
    char name[PLATFORM_MAX_PATH];
    convar.GetName(name, sizeof(name));

    int part = BindFromString(name);
    if(part == BIND_MAX || (part = indexOfPart(part)) == -1) {
        return;
    }

    g_iLevel[part] = convar.IntValue;
}

void triggerConVars() {
    char convarName[PLATFORM_MAX_PATH];

    for(int i; i < BIND_MAX; i++) {
        if(indexOfPart(i) == -1) {
            continue;
        }

        FormatBind("level_", i, 'l', convarName, sizeof(convarName));
        levelHandler(FindConVar(convarName), NULL_STRING, NULL_STRING);
    }
}

void doRainbow(char[] buffer, int size, const char[] input) {
    static const int rainbow[] = { 2, 16, 9, 4, 11, 12, 13 };
    const int rainbowSize = sizeof(rainbow);

    int inLen = strlen(input);

    for(int i, a, b, bytes; i < inLen; i++) {
        buffer[a++] = rainbow[b++];

        if(b >= rainbowSize) {
            b = 0;
        }

        bytes = IsCharMB(input[i]);
        if(!bytes) {
            bytes = 1;
        }

        bytes += i;

        while(i < bytes) {
            if(a >= size) {
                break;
            }

            buffer[a++] = input[i++];
        }
        // because i++
        i--;

        if(a >= size) {
            buffer[a-1] = 0;
            break;
        } else {
            buffer[a] = 0 ;
        }
    }
}

void doRandom(char[] input, int size) {
    static const int random[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16 };
    FormatEx(input, size, "%c", GetRandomInt(0, sizeof(random) - 1));
}

int indexOfPart(int part) {

    int parts[] = { BIND_NAME, BIND_MSG };

    for(int i; i < sizeof(parts); i++) {
        if(parts[i] == part) {
            return i;
        }
    }

    return -1;
}

stock bool IsValidChatTag(const char[] Tag)
{
	if((StrContains(Tag, "admin", false) != -1) || (StrContains(Tag, "owner", false) != -1) || (StrContains(Tag, "staff", false) != -1) || (StrContains(Tag, "staf", false) != -1) ||(StrContains(Tag, "nigg", false) != -1) || (StrContains(Tag, "mod", false) != -1) || (StrContains(Tag, "onetap", false) != -1) || (StrContains(Tag, "ware", false) != -1) || (StrContains(Tag, "aim", false) != -1) || (StrContains(Tag, "cheat", false) != -1) || (StrContains(Tag, "hack", false) != -1) || (StrContains(Tag, "heat", false) != -1) || (StrContains(Tag, "ack", false) != -1) || (StrContains(Tag, "spin", false) != -1) || (StrContains(Tag, ".", false) != -1) || (StrContains(Tag, "'", false) != -1) || (StrContains(Tag, "`", false) != -1) || (StrContains(Tag, "?", false) != -1))
		return false;

	return true;
}

stock bool InChannels(const char[] channel, const char[][] channels, int count) {
    for(int i; i < count; i++) {
        if(!strcmp(channel, channels[i])) {
            return true;
        }
    }

    return false;
}