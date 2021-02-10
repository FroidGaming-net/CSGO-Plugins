Action Command_Start(int iClient, int iArgs)
{
	if (!CheckCommandAccess(iClient, "sm_froidapp_start", ADMFLAG_CUSTOM6)) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!start {default}Hanya dapat digunakan oleh Premium+. Beli Premium+ Sekarang! @ {lightred}froidgaming.net", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!start {default}Only can be used by Premium+. Buy Premium+ Now! @ {lightred}froidgaming.net", PREFIX);
		}

		return Plugin_Handled;
	}

	int iPlayersInTeamsCT = 0;
	int iPlayersInTeamsT = 0;
	for (int x = 1; x <= MaxClients; x++) {
		if (IsValidClient(x)) {
			if (GetClientTeam(x) == CS_TEAM_CT) {
				iPlayersInTeamsCT += 1;
			} else if(GetClientTeam(x) == CS_TEAM_T) {
				iPlayersInTeamsT += 1;
			}
		}
	}

	if (iPlayersInTeamsCT < 4 || iPlayersInTeamsT < 4) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Kedua team harus memiliki minimal 4 Pemain untuk memulai Match.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Both teams must have at least 4 players to start the match.", PREFIX);
		}

		return Plugin_Handled;
	}

	if (iPlayersInTeamsCT == 5 && iPlayersInTeamsT == 5) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Match akan dimulai secara otomatis.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}The match will start automatically.", PREFIX);
		}

		return Plugin_Handled;
	}
	
	if (PugSetup_GetGameState() == GameState_Warmup) {
		CPrintToChatAll("%s {default}Match forcestarted by {lightred}%N", PREFIX, iClient);
		CPrintToChatAll("%s {default}Match forcestarted by {lightred}%N", PREFIX, iClient);
		CPrintToChatAll("%s {default}Match forcestarted by {lightred}%N", PREFIX, iClient);
		CPrintToChatAll("%s {default}Match forcestarted by {lightred}%N", PREFIX, iClient);
		ServerCommand("sm_forcestart");
	} else {
		CPrintToChat(iClient, "%s {default}Match is LIVE!", PREFIX);
	}

	return Plugin_Continue;
}