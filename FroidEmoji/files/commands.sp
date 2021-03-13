Action Call_MenuEmojis(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }

    if (!CheckCommandAccess(iClient, "sm_froidapp_premium_plus", ADMFLAG_CUSTOM6)) {
        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            CPrintToChat(iClient, "%s {default}Fitur ini hanya dapat digunakan oleh Premium Plus. Beli Premium Plus+ Sekarang! @ {lightred}froidgaming.net", PREFIX);
        } else {
            CPrintToChat(iClient, "%s {default}This feature can only be used by Premium Plus. Buy Premium Plus Now! @ {lightred}froidgaming.net", PREFIX);
        }

        return Plugin_Handled;
    }

    MenuEmojis(iClient);

	return Plugin_Handled;
}