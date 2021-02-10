Action Call_MenuJoin(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }

	int iCooldown;
	char sAuthID[64];
	GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
	if (PlayerCooldown.GetValue(sAuthID, iCooldown)) {
		if (StrContains(g_sHostname, "FFA") > -1) {
			if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
				CPrintToChat(iClient, "%s {lightred}!join{default} hanya bisa digunakan 30 menit sekali.", PREFIX);
			} else {
				CPrintToChat(iClient, "%s {lightred}!join{default} only can be used once in 30 minutes.", PREFIX);
			}
		} else {
			if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
				CPrintToChat(iClient, "%s {lightred}!join{default} hanya bisa digunakan satu kali dalam satu match.", PREFIX);
				CPrintToChat(iClient, "%s {default}Silahkan tunggu match selanjutnya untuk menggunakan {lightred}!join{default}.", PREFIX);
			} else {
				CPrintToChat(iClient, "%s {lightred}!join{default} only can be used once in one match.", PREFIX);
				CPrintToChat(iClient, "%s {default}Please wait for the next match to use {lightred}!join{default}.", PREFIX);
			}
		}
		return Plugin_Handled;
	}
    
    MenuJoin(iClient);
	
	return Plugin_Handled;
}

Action CommandJoinPUG(int iClient)
{
	if (!CheckCommandAccess(iClient, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya dapat digunakan oleh Premium Plus. Beli Premium Plus Sekarang! {lightred}froidgaming.net/store", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Premium Plus. Buy Premium Plus Now! {lightred}froidgaming.net/store", PREFIX);
		}

		return Plugin_Handled;
	}

	if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
		if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
		}

		return Plugin_Handled;
	}

	if (g_PlayerData[iClient].bQueue == true) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Mohon tunggu round selanjutnya...", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Please wait for the next round...", PREFIX);
		}
		return Plugin_Handled;
	}

	/// Mendapatkan Total Player in Game
	int iPlayersPremiumPlus = 0;
	int iPlayersInTeam = 0;
	for (int x = 1; x <= MaxClients; x++) {
		if (IsValidClient(x)) {
			if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
				if (CheckCommandAccess(x, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
					iPlayersPremiumPlus += 1;
				}
				iPlayersInTeam += 1;
			}
		}
	}
	/// Mendapatkan Total Player in Game

	// Melakukan !join
	if (iPlayersInTeam == 10) {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsValidClient(i)) {
				if (iPlayersPremiumPlus < 10) {
					g_PlayerData[iClient].bQueue = true;
                    
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kamu akan masuk pada round selanjutnya.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}You will join in the next round.", PREFIX);
					}

					return Plugin_Handled;
				} else if(iPlayersPremiumPlus >= 10) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium atau Premium Plus, coba server lain.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Both Team are full by Premium or Premium Plus, try another server.", PREFIX);
					}

					return Plugin_Handled;
				}
			}
		}
	} else if(iPlayersInTeam > 10) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Jumlah Pemain melebihi batas team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Total Player exceeds the team limit.", PREFIX);
		}

		return Plugin_Handled;
	} else if(iPlayersInTeam < 10) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Kamu masih bisa bergabung dengan team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}You can still join the team.", PREFIX);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action CommandJoinRetakes(int iClient)
{
	if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya dapat digunakan oleh Premium Plus. Beli Premium Plus Sekarang di {lightred}froidgaming.net/store", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Premium Plus. Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX);
		}

		return Plugin_Handled;
	}

	if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
		}

		return Plugin_Handled;
	}

	if (g_PlayerData[iClient].bQueue == true) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Mohon tunggu round selanjutnya...", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Please wait for the next round...", PREFIX);
		}
        
		return Plugin_Handled;
	}

	/// Mendapatkan Total Player in Game
	int iPlayersPremium = 0;
	int iPlayersInTeam = 0;
	for (int x = 1; x <= MaxClients; x++) {
		if (IsValidClient(x)) {
			if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
				if (CheckCommandAccess(x, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
					iPlayersPremium += 1;
				}
				iPlayersInTeam += 1;
			}
		}
	}
	/// Mendapatkan Total Player in Game

	// Melakukan !join
	if(iPlayersInTeam == 10){
        for (int i = 1; i <= MaxClients; i++) {
			if (IsValidClient(i)) {
				if (iPlayersPremium < 10) {
					g_PlayerData[iClient].bQueue = true;
                    
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kamu akan masuk pada round selanjutnya.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}You will join in the next round.", PREFIX);
					}

					return Plugin_Handled;
				} else if(iPlayersPremium >= 10) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium atau Premium Plus, coba server lain.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Both Team are full by Premium or Premium Plus, try another server.", PREFIX);
					}

					return Plugin_Handled;
				}
			}
		}
	} else if(iPlayersInTeam > 10) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Jumlah Pemain melebihi batas team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Total Player exceeds the team limit.", PREFIX);
		}

		return Plugin_Handled;
	} else if(iPlayersInTeam < 10) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Kamu masih bisa bergabung dengan team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}You can still join the team.", PREFIX);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action CommandJoinExecutes(int iClient)
{
	if (!CheckCommandAccess(iClient, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya dapat digunakan oleh Premium Plus. Beli Premium Plus Sekarang! {lightred}froidgaming.net/store", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Premium Plus. Buy Premium Plus Now! {lightred}froidgaming.net/store", PREFIX);
		}

		return Plugin_Handled;
	}

	if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
		}

		return Plugin_Handled;
	}

	if (g_PlayerData[iClient].bQueue == true) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Mohon tunggu round selanjutnya...", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Please wait for the next round...", PREFIX);
		}

		return Plugin_Handled;
	}

	/// Mendapatkan Total Player in Game
	int iPlayersPremiumPlus = 0;
	int iPlayersInTeam = 0;
	for (int x = 1; x <= MaxClients; x++) {
		if (IsValidClient(x)) {
			if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
				if (CheckCommandAccess(x, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
					iPlayersPremiumPlus += 1;
				}
				iPlayersInTeam += 1;
			}
		}
	}
	/// Mendapatkan Total Player in Game

	// Melakukan !join
	if (iPlayersInTeam == 10) {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsValidClient(i)) {
				if (iPlayersPremiumPlus < 10) {
					g_PlayerData[iClient].bQueue = true;
                    
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kamu akan masuk pada round selanjutnya.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}You will join in the next round.", PREFIX);
					}

					return Plugin_Handled;
				} else if(iPlayersPremiumPlus >= 10) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium Plus, coba server lain.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Both Team are full by Premium Plus, try another server.", PREFIX);
					}

					return Plugin_Handled;
				}
			}
		}
	} else if(iPlayersInTeam > 10) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Jumlah Pemain melebihi batas team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Total Player exceeds the team limit.", PREFIX);
		}

		return Plugin_Handled;
	} else if(iPlayersInTeam < 10) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Kamu masih bisa bergabung dengan team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}You can still join the team.", PREFIX);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action CommandJoinArena(int iClient)
{
	if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya dapat digunakan oleh Premium Plus. Beli Premium Plus Sekarang! {lightred}froidgaming.net/store", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Premium Plus. Buy Premium Plus Now! {lightred}froidgaming.net/store", PREFIX);
		}

		return Plugin_Handled;
	}


	if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
		}

		return Plugin_Handled;
	}

	if (g_PlayerData[iClient].bQueue == true) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya...", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Waiting for the next rounds...", PREFIX);
		}

		return Plugin_Handled;
	}

	/// Mendapatkan Total Player in Game
	int iPlayersPremium = 0;
	int iPlayersInTeam = 0;
	for (int x = 1; x <= MaxClients; x++) {
		if (IsValidClient(x)) {
			if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
				if (CheckCommandAccess(x, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
					iPlayersPremium += 1;
				}
				iPlayersInTeam += 1;
			}
		}
	}
	/// Mendapatkan Total Player in Game


	// Melakukan !join
	if(Multi1v1_GetNumActiveArenas() >= Multi1v1_GetMaximumArenas()){
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsClientConnected(i) && !IsFakeClient(i))
			{
				if(iPlayersPremium < GetMaxHumanPlayers()){
					g_PlayerData[iClient].bQueue = true;
					if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
						CPrintToChat(iClient, "%s {default}Anda akan masuk pada round selanjutnya.", PREFIX);
					}else{
						CPrintToChat(iClient, "%s {default}You will join in the next round.", PREFIX);
					}
					return Plugin_Handled;
				}else if(iPlayersPremium >= GetMaxHumanPlayers()){
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium atau Premium Plus, coba server lain.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Both Team are full by Premium or Premium Plus, try another server.", PREFIX);
					}

					return Plugin_Handled;
				}
			}
		}
	}else if(Multi1v1_GetNumActiveArenas() <= Multi1v1_GetMaximumArenas()){
		if(StrEqual(g_PlayerData[iClient].sCountryCode, "ID")){
			CPrintToChat(iClient, "%s {lightblue}%i {default}Arena dari {lightblue}%i {default}Arena masih tersedia", PREFIX, Multi1v1_GetMaximumArenas()-Multi1v1_GetNumActiveArenas(), Multi1v1_GetMaximumArenas());
		}else{
			CPrintToChat(iClient, "%s {lightblue}%i {default}Arena out of {lightblue}%i {default}Arena is still available", PREFIX, Multi1v1_GetMaximumArenas()-Multi1v1_GetNumActiveArenas(), Multi1v1_GetMaximumArenas());
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

Action CommandJoinAWP(int iClient)
{
	if (!CheckCommandAccess(iClient, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya dapat digunakan oleh Premium Plus. Beli Premium Plus Sekarang! {lightred}froidgaming.net/store", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Premium Plus. Buy Premium Plus Now! {lightred}froidgaming.net/store", PREFIX);
		}

		return Plugin_Handled;
	}

	if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
		}

		return Plugin_Handled;
	}

	if (g_PlayerData[iClient].bQueue == true) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Mohon tunggu round selanjutnya...", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Please wait for the next round...", PREFIX);
		}

		return Plugin_Handled;
	}

	/// Mendapatkan Total Player in Game
	int iPlayersPremiumPlus = 0;
	int iPlayersInTeam = 0;
	for (int x = 1; x <= MaxClients; x++) {
		if (IsValidClient(x)) {
			if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
				if (CheckCommandAccess(x, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
					iPlayersPremiumPlus += 1;
				}
				iPlayersInTeam += 1;
			}
		}
	}
	/// Mendapatkan Total Player in Game

	// Melakukan !join
	if (iPlayersInTeam == GetMaxHumanPlayers()) {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsValidClient(i)) {
				if (iPlayersPremiumPlus < GetMaxHumanPlayers()) {
					g_PlayerData[iClient].bQueue = true;
                    
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kamu akan masuk pada round selanjutnya.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}You will join in the next round.", PREFIX);
					}

					return Plugin_Handled;
				} else if(iPlayersPremiumPlus >= GetMaxHumanPlayers()) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium Plus, coba server lain.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Both Team are full by Premium Plus, try another server.", PREFIX);
					}

					return Plugin_Handled;
				}
			}
		}
	} else if(iPlayersInTeam > GetMaxHumanPlayers()) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Jumlah Pemain melebihi batas team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Total Player exceeds the team limit.", PREFIX);
		}

		return Plugin_Handled;
	} else if(iPlayersInTeam < GetMaxHumanPlayers()) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Kamu masih bisa bergabung dengan team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}You can still join the team.", PREFIX);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action CommandJoinFFA(int iClient)
{
	if (!CheckCommandAccess(iClient, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya dapat digunakan oleh Premium Plus. Beli Premium Plus Sekarang! {lightred}froidgaming.net/store", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Premium Plus. Buy Premium Plus Now! {lightred}froidgaming.net/store", PREFIX);
		}

		return Plugin_Handled;
	}

	if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
		}

		return Plugin_Handled;
	}

	if (g_PlayerData[iClient].bQueue == true) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Mohon tunggu round selanjutnya...", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Please wait for the next round...", PREFIX);
		}

		return Plugin_Handled;
	}

	g_PlayerData[iClient].bQueue = true;

    /// Mendapatkan Total Player in Game
	int iPlayersFreemium = 0;
	int iPlayersPremium = 0;
	int iPlayersPremiumPlus = 0;
	int iPlayersInTeam = 0;
	for (int x = 1; x <= MaxClients; x++) {
		if (IsValidClient(x)) {
			if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
				if (CheckCommandAccess(x, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
					iPlayersPremiumPlus += 1;
				} else if (CheckCommandAccess(x, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
					iPlayersPremium += 1;
				} else {
                    iPlayersFreemium += 1;
                }
				iPlayersInTeam += 1;
			}
		}
	}
	/// Mendapatkan Total Player in Game

	// Melakukan !join
	if (iPlayersInTeam == GetMaxHumanPlayers()) {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsValidClient(i)) {
				if (GetClientTeam(i) == CS_TEAM_T || GetClientTeam(i) == CS_TEAM_CT) {
					if (iPlayersFreemium >= 1) {
						if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && g_PlayerData[iClient].bQueue == true) {
							int teamToJoin = GetClientTeam(i);

							SendPlayerToSpectators(i);
							ChangeClientTeam(iClient, teamToJoin);
							g_PlayerData[iClient].bQueue = false;

							CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
							CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
							
							char sAuthID[64];
							GetClientAuthId(i, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
							PlayerCooldown.SetValue(sAuthID, 1);
						}
					} else if (iPlayersPremium >= GetMaxHumanPlayers()) {
						if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM6) && g_PlayerData[iClient].bQueue == true) {
							int teamToJoin = GetClientTeam(i);

							SendPlayerToSpectators(i);
							ChangeClientTeam(iClient, teamToJoin);
							g_PlayerData[iClient].bQueue = false;
							
							CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Upgrade to Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
							CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Upgrade to Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
							
							char sAuthID[64];
							GetClientAuthId(i, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
							PlayerCooldown.SetValue(sAuthID, 1);
						}
					} else if (iPlayersPremiumPlus >= GetMaxHumanPlayers() && g_PlayerData[iClient].bQueue == true) {
						if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						    CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium Plus, coba server lain.", PREFIX);
                        } else {
                            CPrintToChat(iClient, "%s {default}Both Team are full by Premium Plus, try another server.", PREFIX);
                        }

						g_PlayerData[iClient].bQueue = false;
					} else {

						if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
							CPrintToChat(iClient, "%s {default}Terjadi Kesalahan... #001", PREFIX);
						} else {
							CPrintToChat(iClient, "%s {default}Error...  #001", PREFIX);
						}

						PrintToConsole(iClient, "[DEBUGGING-WARNING] Terjadi Kesalahan 1");
						PrintToConsole(iClient, "[DEBUGGING] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
						PrintToConsole(iClient, "[DEBUGGING] Jumlah Premium : %d", iPlayersPremium);
						PrintToConsole(iClient, "[DEBUGGING] Jumlah Freemium : %d", iPlayersFreemium);
						PrintToConsole(iClient, "[DEBUGGING] Jumlah Total : %d", iPlayersInTeam);

						g_PlayerData[iClient].bQueue = false;
					}
				}
			}
		}
	}else if (iPlayersInTeam > GetMaxHumanPlayers()) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Jumlah Pemain melebihi batas team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Total Player exceeds the team limit.", PREFIX);
		}

		g_PlayerData[iClient].bQueue = false;
	} else if(iPlayersInTeam < GetMaxHumanPlayers()) {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Kamu masih bisa bergabung dengan team.", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}You can still join the team.", PREFIX);
		}

		g_PlayerData[iClient].bQueue = false;
	} else {
		if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
			CPrintToChat(iClient, "%s {default}Terjadi Kesalahan... #002", PREFIX);
		} else {
			CPrintToChat(iClient, "%s {default}Error...  #002", PREFIX);
		}

		PrintToConsole(iClient, "[DEBUGGING-WARNING] Terjadi Kesalahan 2");
		PrintToConsole(iClient, "[DEBUGGING] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
        PrintToConsole(iClient, "[DEBUGGING] Jumlah Premium : %d", iPlayersPremium);
        PrintToConsole(iClient, "[DEBUGGING] Jumlah Freemium : %d", iPlayersFreemium);
        PrintToConsole(iClient, "[DEBUGGING] Jumlah Total : %d", iPlayersInTeam);
		g_PlayerData[iClient].bQueue = false;
	}

	return Plugin_Handled;
}