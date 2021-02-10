Action Call_MenuHats(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }

    if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
        if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
            CPrintToChat(iClient, "%s {default}Fitur ini hanya dapat digunakan oleh Premium/Premium Plus. Beli Premium/Premium Plus+ Sekarang! @ {lightred}froidgaming.net", PREFIX);
        } else {
            CPrintToChat(iClient, "%s {default}This feature can only be used by Premium/Premium Plus. Buy Premium/Premium Plus Now! @ {lightred}froidgaming.net", PREFIX);
        }

        return Plugin_Handled;
    }
    
    MenuHats(iClient);
	
	return Plugin_Handled;
}