#pragma newdecls required

#include <ccprocessor>
#include <cstrike>

#define CONSOLE_COMMAND "sm_chatapp"
#define CONNECTION_NAME "chat_app"

public Plugin myinfo = 
{
    name        = "[CCP] ChatApp",
    author      = "nyood?",
    description = "...",
    version     = "1.0.1",
    url         = "discord.gg/ChTyPUG"
};

static const char databaseTable[] = 
    "CREATE TABLE IF NOT EXISTS `chatapp` (\
        `account` INT NOT NULL PRIMARY KEY, \
        `name` VARCHAR(16) DEFAULT '', \
        `msg` VARCHAR(16) DEFAULT '', \
        `tag` VARCHAR(32) DEFAULT '') \
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

static const char addRow[] = 
    "INSERT INTO `chatapp` \
        (`account`) \
    VALUES \
        (%i)";

static const char selectRow[] = 
    "SELECT * FROM `chatapp` WHERE `account`=%i";

static const char staticTitleTag[] = "static_title_tag"

Database connection;

enum struct chatApp
{
    char name[NAME_LENGTH];
    char message[MESSAGE_LENGTH];
    char clanTag[PREFIX_LENGTH];

    int flags;
    bool awaitInput;

    void Clear(int option = -1) {
        if(option == -1 || !option) {
            this.name[0] = 0;
        }

        if(option == -1 || option == 1) {
            this.message[0] = 0;
        }

        if(option == -1 || option == 2) {
            this.clanTag[0] = 0;
        }
    }
}

chatApp chatClient[MAXPLAYERS+1];

int level[2];
int accessFlag;

public void OnPluginStart() {
    LoadTranslations("chatapp.phrases");
    LoadTranslations("ccproc.phrases");

    RegConsoleCmd(CONSOLE_COMMAND, cmduse);
    
    Database.Connect(OnDatabaseConnected, CONNECTION_NAME);

    char convarName[PLATFORM_MAX_PATH];
    for(int i; i < BIND_MAX; i++) {
        if(indexOfPart(i) == -1) {
            continue;
        }

        FormatBind("level_", i, 'l', convarName, sizeof(convarName));

        // level_:part
        // level_prefixco
        (CreateConVar(convarName, "2", "Priority level", _, true, 1.0)).AddChangeHook(view_as<ConVarChanged>(GetFunctionByName(GetMyHandle(), "levelHandler")));
    }

    AutoExecConfig(true, "chatapp", "ccprocessor");
}

public void OnDatabaseConnected(Database dConnection, const char[] error, any data) {
    if(!dConnection || error[0]) {
        SetFailState("OnDatabaseConnect: %s", error);
    }

    connection = dConnection;
    connection.SetCharset("utf8mb4");

    char table[512];
    connection.Format(table, sizeof(table), databaseTable);
    if(!SQL_FastQuery(connection, table)) {
        SQL_GetError(connection, table, sizeof(table));
        SetFailState("OnDatabaseConnect: %s", table);
    }
}

public void OnMapStart() {
    cc_proc_APIHandShake(cc_get_APIKey());

    triggerConVars();
    // access
    // bind keys
    // ..-> ArrayList
    // ....-> Value translation keys
    // mapClient[0].Clear();

    ReadConfig();
}

public void levelHandler(ConVar convar, const char[] oldVal, const char[] newVal) {
    char name[PLATFORM_MAX_PATH];
    convar.GetName(name, sizeof(name));

    int part = BindFromString(name);
    if(part == BIND_MAX || (part = indexOfPart(part)) == -1) {
        return;
    }

    level[part] = convar.IntValue;
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

void ReadConfig() {
    static char config[PLATFORM_MAX_PATH] = "configs/ccprocessor/chatapp/settings.ini";

    if(config[0] == 'c') {
        BuildPath(Path_SM, config, sizeof(config), config);
    }

    if(!FileExists(config)) {
        SetFailState("Where is my config: %s", config);
    }

    KeyValues kv = new KeyValues("chatapp");
    if(kv.ImportFromFile(config)) {

        kv.Rewind();

        char szBuffer[PLATFORM_MAX_PATH];
        kv.GetString("access", szBuffer, sizeof(szBuffer));

        accessFlag = ReadFlagString(szBuffer);
    }
    
    delete kv;
}

Action cmduse(int iClient, int args) {
    if(iClient && IsClientInGame(iClient) && !IsFakeClient(iClient) && HasAccess(iClient)) {
        chatClient[iClient].awaitInput = false;

        Menu hMenu;

        // TR: static_title_tag
        // TR: features_title
        char szBuffer[PLATFORM_MAX_PATH];
        FormatEx(szBuffer, sizeof(szBuffer), "%T", staticTitleTag, iClient);
        Format(szBuffer, sizeof(szBuffer), "%s%T", szBuffer, "features_title", iClient);

        hMenu = new Menu(featuresMenuCallback);
        hMenu.SetTitle("%s \n \n", szBuffer);

        char value[PLATFORM_MAX_PATH];

        // clantag
        strcopy(value, sizeof(value), chatClient[iClient].clanTag);
        if(!value[0]) {
            FormatEx(value, sizeof(value), "%T", "null_value", iClient);
        }

        FormatEx(szBuffer, sizeof(szBuffer), "t%T%T", "feature_clantag", iClient, "key_option", iClient, value);
        hMenu.AddItem(szBuffer, szBuffer[1]);

        // Name color
        strcopy(value, sizeof(value), chatClient[iClient].name);
        if(!value[0]) {
            value = "null_value";
        }

        Format(value, sizeof(value), "%T", value, iClient);
        FormatEx(szBuffer, sizeof(szBuffer), "n%T%T", "feature_name", iClient, "key_option", iClient, value);
        ccp_replaceColors(szBuffer[1], true);
        hMenu.AddItem(szBuffer, szBuffer[1]);

        // Message color
        strcopy(value, sizeof(value), chatClient[iClient].message);
        if(!value[0]) {
            value = "null_value";
        }

        Format(value, sizeof(value), "%T", value, iClient);
        FormatEx(szBuffer, sizeof(szBuffer), "m%T%T", "feature_message", iClient, "key_option", iClient, value);
        ccp_replaceColors(szBuffer[1], true);
        hMenu.AddItem(szBuffer, szBuffer[1]);
        
        // Reset to default
        FormatEx(szBuffer, sizeof(szBuffer), "r%T", "value_default", iClient);
        hMenu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_NOTEXT|ITEMDRAW_SPACER);
        hMenu.AddItem(szBuffer, szBuffer[1]);

        hMenu.Display(iClient, MENU_TIME_FOREVER);
    }

    return Plugin_Handled;
}

public int featuresMenuCallback(Menu hMenu, MenuAction action, int iClient, int option) {
    switch(action) {
        case MenuAction_End: delete hMenu;
        case MenuAction_Select: {
            char buffer[4];
            hMenu.GetItem(option, buffer, sizeof(buffer));

            if(buffer[0] == 'r') {
                char tag[32];
                CS_GetClientClanTag(iClient, tag, sizeof(tag));
                if(!strcmp(tag, chatClient[iClient].clanTag)) {
                    CS_SetClientClanTag(iClient, NULL_STRING);
                }

                chatClient[iClient].Clear();
                cmduse(iClient, 0);
                return;
            } else if(buffer[0] == 't') {
                chatClient[iClient].awaitInput = true;
                PrintToChat(iClient, "%T", "await_input", iClient);
                return;
            }

            featureMenu(iClient, buffer[0]).Display(iClient, MENU_TIME_FOREVER);
        }
    }
}

Menu featureMenu(int iClient, char type) {
    Menu hMenu;

    hMenu = new Menu(featureMenuCallback);
    
    char szBuffer[PLATFORM_MAX_PATH];
    szBuffer = (type == 'n') ? "t_name" : "t_message";

    Format(szBuffer, sizeof(szBuffer), "%T%T", "static_title_tag", iClient, szBuffer, iClient);
    hMenu.SetTitle("%s \n \n", szBuffer);

    StringMap palette = cc_drop_palette();
    StringMapSnapshot shotPalette = palette.Snapshot();
    int drawType = ITEMDRAW_DEFAULT;

    char key[PLATFORM_MAX_PATH], value[PLATFORM_MAX_PATH];
    strcopy(value, sizeof(value), (type == 'n') ? chatClient[iClient].name : chatClient[iClient].message);

    drawType = (!value[0]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT;
    FormatEx(szBuffer, sizeof(szBuffer), "%c%T \n \n", type, "reset", iClient);
    FormatEx(key, sizeof(key), "%creset", type);
    hMenu.AddItem(key, szBuffer[1], drawType);

    for(int i; i < shotPalette.Length; i++) {
        shotPalette.GetKey(i, key, sizeof(key));
        drawType = (!strcmp(key, value)) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT;

        FormatEx(szBuffer, sizeof(szBuffer), "%T", key, iClient);
        Format(key, sizeof(key), "%c%s", type, key);
        ccp_replaceColors(szBuffer, true);

        hMenu.AddItem(key, szBuffer, drawType);
    }

    drawType = (!strcmp("rainbow", value)) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT;
    FormatEx(szBuffer, sizeof(szBuffer), "%c%T", type, "rainbow", iClient);
    FormatEx(key, sizeof(key), "%crainbow", type);
    hMenu.AddItem(key, szBuffer[1], drawType);

    drawType = (!strcmp("random", value)) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT;
    FormatEx(szBuffer, sizeof(szBuffer), "%c%T", type, "random", iClient);
    FormatEx(key, sizeof(key), "%crandom", type);
    hMenu.AddItem(key, szBuffer[1], drawType);

    hMenu.ExitBackButton = true;
    hMenu.ExitButton = true;

    return hMenu;
}

public int featureMenuCallback(Menu hMenu, MenuAction action, int iClient, int option) {
    switch(action) {
        case MenuAction_End: delete hMenu;
        case MenuAction_Cancel: {
            if(option == MenuCancel_ExitBack) {
                cmduse(iClient, 0);
            }
        }
        case MenuAction_Select: {
            char buffer[PLATFORM_MAX_PATH]
            hMenu.GetItem(option, buffer, sizeof(buffer));

            if(!strcmp(buffer[1], "reset")) {
                buffer[1] = 0;
            }

            strcopy(
                (buffer[0] == 'n') ? chatClient[iClient].name : chatClient[iClient].message,
                (buffer[0] == 'n') ? sizeof(chatClient[].name) : sizeof(chatClient[].message), 
                buffer[1]
            );

            featureMenu(iClient, buffer[0]).Display(iClient, MENU_TIME_FOREVER);
        }
    }
}

public void OnClientPutInServer(int iClient) {
    chatClient[iClient].Clear();
    chatClient[iClient].flags = 0;
    chatClient[iClient].awaitInput = false;
}

public void OnClientPostAdminCheck(int iClient) {
    if(IsFakeClient(iClient) || IsClientSourceTV(iClient)){
        return;
    }

    chatClient[iClient].flags = GetUserFlagBits(iClient);
    if(!HasAccess(iClient)) {
        return;
    }

    DataRequest(iClient);
}

void DataRequest(int iClient) {
    int account = GetSteamAccountID(iClient);

    if(!account) {
        LogMessage("Refused to receive `SteamAccountId` for client: %N", iClient);
        chatClient[iClient].flags = 0;
        return;
    }

    char query[PLATFORM_MAX_PATH];
    connection.Format(query, sizeof(query), selectRow, account);
    connection.Query(onSelectResponse, query, GetClientUserId(iClient));
}

public void onSelectResponse(Database dConnection, DBResultSet dbResult, const char[] error, any data) {
    if(error[0]) {
        SetFailState("onSelectResponse: %s", error);
    }

    data = GetClientOfUserId(data);
    if(!data || !IsClientInGame(data)) {
        return;
    }

    if(!dbResult.FetchRow()) {
        PushRequest(data);
        return;
    }

    dbResult.FetchString(1, chatClient[data].name, sizeof(chatClient[].name));
    dbResult.FetchString(2, chatClient[data].message, sizeof(chatClient[].message));
    dbResult.FetchString(3, chatClient[data].clanTag, sizeof(chatClient[].clanTag));
}

void PushRequest(int iClient) {
    int account = GetSteamAccountID(iClient);

    if(!account) {
        chatClient[iClient].flags = 0;
        return;
    }

    char query[PLATFORM_MAX_PATH];
    connection.Format(query, sizeof(query), addRow, account);
    
    if(SQL_FastQuery(connection, query)) {
        if(IsClientInGame(iClient)) {
            DataRequest(iClient);
        }

        return;
    }

    SQL_GetError(connection, query, sizeof(query));
    LogError("PushRequest: %s", query);
}

public void OnClientDisconnect(int iClient) {
    if(IsFakeClient(iClient) || !HasAccess(iClient)) {
        return;
    }

    int account = GetSteamAccountID(iClient);
    if(!account) {
        return;
    }

    char buffer[512] = "UPDATE `chatapp` SET";
    Format(
        buffer, sizeof(buffer), 
        "%s `name`='%s', `msg`='%s', `tag`='%s' WHERE `account`=%i",
        buffer, chatClient[iClient].name, chatClient[iClient].message, chatClient[iClient].clanTag,
        account
    );

    connection.Format(buffer, sizeof(buffer), buffer);
    if(!SQL_FastQuery(connection, buffer)) {
        SQL_GetError(connection, buffer, sizeof(buffer));
        LogError("onClientDisconnect: %s", buffer);
    }           
}

public Action cc_proc_RebuildString(const int mType, int iClient, int &pLevel, const char[] szBind, char[] szBuffer, int iSize) {
    if(mType > eMsg_ALL || !HasAccess(iClient)) {
        return Plugin_Continue;
    }

    int part = BindFromString(szBind);
    if((part = indexOfPart(part)) == -1) {
        return Plugin_Continue;
    }

    if(pLevel > level[part]) {
        return Plugin_Continue;
    }

    char value[PLATFORM_MAX_PATH];
    FormatEx(value, sizeof(value), (!part) ? chatClient[iClient].name : chatClient[iClient].message);

    if(!value[0]) {
        return Plugin_Continue;
    }

    if(!strcmp(value, "rainbow")) {
        FormatEx(value, sizeof(value), NULL_STRING);
        doRainbow(value, sizeof(value), szBuffer);
        FormatEx(szBuffer, iSize, value);
        return Plugin_Continue;
    } else if(!strcmp(value, "random")) {
        doRandom(value, sizeof(value));
    }

    Format(szBuffer, iSize, "%s%s", value, szBuffer);

    return Plugin_Continue;
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

public Action OnClientSayCommand(int iClient, const char[] command, const char[] args) {
    if(!IsFakeClient(iClient) && chatClient[iClient].awaitInput) {
        chatClient[iClient].awaitInput = false;

        strcopy(chatClient[iClient].clanTag, sizeof(chatClient[].clanTag), args);
        CS_SetClientClanTag(iClient, chatClient[iClient].clanTag);

        PrintToChat(iClient, "%T", "input_success", iClient, chatClient[iClient].clanTag);
        cmduse(iClient, 0);
        return Plugin_Handled;
    }

    return Plugin_Continue;
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

bool HasAccess(int iClient) {
    return !(accessFlag && !(chatClient[iClient].flags & accessFlag) && !(chatClient[iClient].flags & ReadFlagString("z")));
}