Action Event_RoundStartPUG(Event event, const char[] name, bool dontBroadcast)
{
	for (int iClient = 1; iClient <= MaxClients; iClient++) {
		if (IsValidClient(iClient)) {

			if (GetClientTeam(iClient) == CS_TEAM_SPECTATOR) {
				if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && !CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM6)) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Capek nungguin di {lightred}Spectator{default}? yuk beli {lightred}Premium Plus{default} sekarang juga supaya bisa {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {default}Ketik {lightred}!vip{default} untuk info lebih lanjut yaaa :D", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Buy our {lightred}Premium Plus{default} now to use {lightred}Reserved Slot{default} with {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {lightred}!vip{default} for more info about {lightred}Premium Plus", PREFIX);
					}
				} else if (CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && !CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM6)) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Capek nungguin di {lightred}Spectator{default}? yuk upgrade ke {lightred}Premium Plus{default} sekarang juga supaya bisa {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {default}Ketik {lightred}!vip{default} untuk info lebih lanjut yaaa :D", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Upgrade to {lightred}Premium Plus{default} now to use {lightred}Reserved Slot{default} with {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {lightred}!vip{default} for more info about {lightred}Premium Plus", PREFIX);
					}
				}
			}

			if (g_PlayerData[iClient].bQueue == true) {
				if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
					}
					g_PlayerData[iClient].bQueue = false;
				}

				int iPlayersPremiumPlus = 0;
				int iPlayersPremium = 0;
				int iPlayersFreemium = 0;
				int iPlayersInQueue = 0;
				int iPlayersInTeams = 0;
				/// Mendapatkan Total Player in Team
				for(int x = 1; x <= MaxClients; x++) {
					if (IsValidClient(x)) {
						if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
							if (CheckCommandAccess(x, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
								iPlayersPremiumPlus += 1;
							} else if (CheckCommandAccess(x, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
								iPlayersPremium += 1;
							} else {
								iPlayersFreemium += 1;
							}

							if (g_PlayerData[x].bQueue == true) {
								iPlayersInQueue += 1;
							}
							iPlayersInTeams += 1;
						}
					}
				}
				PrintToConsole(iClient, "[INFO] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
				PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
				PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
				PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
				PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
				/// Mendapatkan Total Player in Team
				// Melakukan !join
				if (iPlayersInTeams == 10) {
					for(int i = 1; i <= MaxClients; i++) {
						if (IsValidClient(i)) {
							if (GetClientTeam(i) == CS_TEAM_T || GetClientTeam(i) == CS_TEAM_CT) {
								if (iPlayersFreemium >= 1) {
									if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && g_PlayerData[iClient].bQueue == true) {
										int iTeamJoin = GetClientTeam(i);

										SendPlayerToSpectators(i);
										ChangeClientTeam(iClient, iTeamJoin);

										g_PlayerData[iClient].bQueue = false;
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);

										char sAuthID[64];
										GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
										PlayerCooldown.SetValue(sAuthID, 1);
									}
								} else if (iPlayersPremium >= 1) {
									if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM6) && g_PlayerData[iClient].bQueue == true) {
										int iTeamJoin = GetClientTeam(i);

										SendPlayerToSpectators(i);
										ChangeClientTeam(iClient, iTeamJoin);

										g_PlayerData[iClient].bQueue = false;
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Upgrade to Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Upgrade to Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);

										char sAuthID[64];
										GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
										PlayerCooldown.SetValue(sAuthID, 1);
									}
								} else if (iPlayersPremiumPlus >= 10 && g_PlayerData[iClient].bQueue == true) {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium Plus, coba server lain.", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Both Team full by Premium Plus, try other server.", PREFIX);
									}

									g_PlayerData[iClient].bQueue = false;
								} else {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #001", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #001", PREFIX);
									}
									PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 1");
									PrintToConsole(iClient, "[INFO] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
									PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
									PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
									PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
									PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
									g_PlayerData[iClient].bQueue = true;
								}
							}
						}
					}
				} else if (iPlayersInTeams > 10) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Jumlah Pemain melebihi batas team.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Total Player exceeds the team limit.", PREFIX);
					}

					g_PlayerData[iClient].bQueue = false;
				} else if (iPlayersInTeams < 10) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kamu masih bisa bergabung dengan team.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}You can still join the team.", PREFIX);
					}
                    
					g_PlayerData[iClient].bQueue = false;
				} else {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #002", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #002", PREFIX);
					}

					PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 2");
					PrintToConsole(iClient, "[INFO] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
                    PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
                    PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
                    PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
                    PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
					g_PlayerData[iClient].bQueue = true;
				}
			}
		}
	}
	return Plugin_Continue;
}

public void Retakes_OnPreRoundEnqueue(ArrayList rankingQueue, ArrayList waitingQueue)
{
	for(int iClient = 1; iClient <= MaxClients; iClient++) {
		if (IsValidClient(iClient)) {
			if (GetClientTeam(iClient) == CS_TEAM_SPECTATOR && !CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
				if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
					CPrintToChat(iClient, "%s {default}Capek nungguin di {lightred}Spectator{default}? yuk beli {lightred}Premium Plus{default} sekarang juga supaya bisa {lightred}!join", PREFIX);
					CPrintToChat(iClient, "%s {default}Ketik {lightred}!vip{default} untuk info lebih lanjut yaaa :D", PREFIX);
				} else {
					CPrintToChat(iClient, "%s {default}Buy our {lightred}Premium Plus{default} now to use {lightred}Reserved Slot{default} with {lightred}!join", PREFIX);
					CPrintToChat(iClient, "%s {lightred}!vip{default} for more info about {lightred}Premium Plus", PREFIX);
				}
			}

			if (g_PlayerData[iClient].bQueue == true) {
				if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
					}

					g_PlayerData[iClient].bQueue = false;
				}

				int iPlayersPremium = 0;
				int iPlayersFreemium = 0;
				int iPlayersInQueue = 0;
				int iPlayersInTeams = 0;
				/// Mendapatkan Total Player in Team
				for (int x = 1; x <= MaxClients; x++) {
					if (IsValidClient(x)) {
						if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
							if (CheckCommandAccess(x, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
								iPlayersPremium += 1;
							} else {
								iPlayersFreemium += 1;
							}

							if (g_PlayerData[iClient].bQueue == true) {
								iPlayersInQueue += 1;
							}
							iPlayersInTeams += 1;
						}
					}
				}
				PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
				PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
				PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
				PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
				/// Mendapatkan Total Player in Team
				// Melakukan !join
				if (iPlayersInTeams == 10) {
					/// Mendapatkan Jumlah Player Hidup
					for (int i = 1; i <= MaxClients; i++) {
						if (IsValidClient(i)) {
							if (GetClientTeam(i) == CS_TEAM_CT || GetClientTeam(i) == CS_TEAM_T) {
								if (iPlayersFreemium >= 1) {
									if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && g_PlayerData[iClient].bQueue == true) {
										int iTeamJoin = GetClientTeam(i);

										SendPlayerToSpectators(i);
										ChangeClientTeam(iClient, iTeamJoin);
										g_PlayerData[iClient].bQueue = false;

										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);

										char sAuthID[64];
										GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
										PlayerCooldown.SetValue(sAuthID, 1);
									}
								} else if (iPlayersPremium >= 10  && g_PlayerData[iClient].bQueue == true) {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium or Premium Plus, coba server lain.", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Both Team full by Premium or Premium Plus, try another server.", PREFIX);
									}

									g_PlayerData[iClient].bQueue = false;
								} else {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #001", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #001", PREFIX);
									}
									PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 1");
									PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
									PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
									PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
									PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
									g_PlayerData[iClient].bQueue = true;
								}
							}
						}
					}
				} else if(iPlayersInTeams > 10) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Jumlah Pemain melebihi batas team.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Total Player exceeds the team limit.", PREFIX);
					}

					g_PlayerData[iClient].bQueue = false;
				} else if(iPlayersInTeams < 10){
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kamu masih bisa bergabung dengan team.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}You can still join the team.", PREFIX);
					}

					g_PlayerData[iClient].bQueue = false;
				} else {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #002", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #002", PREFIX);
					}

					PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 2");
					PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
					PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
					PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
					PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
					g_PlayerData[iClient].bQueue = true;
				}
			}
		}
	}
}

public void Executes_OnPreRoundEnqueue(ArrayList rankingQueue, ArrayList waitingQueue)
{
	for (int iClient = 1; iClient <= MaxClients; iClient++) {
		if (IsValidClient(iClient)) {

			if (GetClientTeam(iClient) == CS_TEAM_SPECTATOR) {
				if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && !CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM6)) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Capek nungguin di {lightred}Spectator{default}? yuk beli {lightred}Premium Plus{default} sekarang juga supaya bisa {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {default}Ketik {lightred}!vip{default} untuk info lebih lanjut yaaa :D", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Buy our {lightred}Premium Plus{default} now to use {lightred}Reserved Slot{default} with {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {lightred}!vip{default} for more info about {lightred}Premium Plus", PREFIX);
					}
				} else if (CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && !CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM6)) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Capek nungguin di {lightred}Spectator{default}? yuk upgrade ke {lightred}Premium Plus{default} sekarang juga supaya bisa {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {default}Ketik {lightred}!vip{default} untuk info lebih lanjut yaaa :D", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Upgrade to {lightred}Premium Plus{default} now to use {lightred}Reserved Slot{default} with {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {lightred}!vip{default} for more info about {lightred}Premium Plus", PREFIX);
					}
				}
			}

			if (g_PlayerData[iClient].bQueue == true) {
				if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
					}
					g_PlayerData[iClient].bQueue = false;
				}

				int iPlayersPremiumPlus = 0;
				int iPlayersPremium = 0;
				int iPlayersFreemium = 0;
				int iPlayersInQueue = 0;
				int iPlayersInTeams = 0;
				/// Mendapatkan Total Player in Team
				for(int x = 1; x <= MaxClients; x++) {
					if (IsValidClient(x)) {
						if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
							if (CheckCommandAccess(x, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
								iPlayersPremiumPlus += 1;
							} else if (CheckCommandAccess(x, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
								iPlayersPremium += 1;
							} else {
								iPlayersFreemium += 1;
							}

							if (g_PlayerData[x].bQueue == true) {
								iPlayersInQueue += 1;
							}
							iPlayersInTeams += 1;
						}
					}
				}
				PrintToConsole(iClient, "[INFO] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
				PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
				PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
				PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
				PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
				/// Mendapatkan Total Player in Team
				// Melakukan !join
				if (iPlayersInTeams == 10) {
					for(int i = 1; i <= MaxClients; i++) {
						if (IsValidClient(i)) {
							if (GetClientTeam(i) == CS_TEAM_T || GetClientTeam(i) == CS_TEAM_CT) {
								if (iPlayersFreemium >= 1) {
									if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && g_PlayerData[iClient].bQueue == true) {
										int iTeamJoin = GetClientTeam(i);

										SendPlayerToSpectators(i);
										ChangeClientTeam(iClient, iTeamJoin);

										g_PlayerData[iClient].bQueue = false;
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);

										char sAuthID[64];
										GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
										PlayerCooldown.SetValue(sAuthID, 1);
									}
								} else if (iPlayersPremium >= 1) {
									if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM6) && g_PlayerData[iClient].bQueue == true) {
										int iTeamJoin = GetClientTeam(i);

										SendPlayerToSpectators(i);
										ChangeClientTeam(iClient, iTeamJoin);

										g_PlayerData[iClient].bQueue = false;
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Upgrade to Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Upgrade to Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);

										char sAuthID[64];
										GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
										PlayerCooldown.SetValue(sAuthID, 1);
									}
								} else if (iPlayersPremiumPlus >= 10 && g_PlayerData[iClient].bQueue == true) {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium Plus, coba server lain.", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Both Team full by Premium Plus, try other server.", PREFIX);
									}

									g_PlayerData[iClient].bQueue = false;
								} else {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #001", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #001", PREFIX);
									}
									PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 1");
									PrintToConsole(iClient, "[INFO] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
									PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
									PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
									PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
									PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
									g_PlayerData[iClient].bQueue = true;
								}
							}
						}
					}
				} else if (iPlayersInTeams > 10) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Jumlah Pemain melebihi batas team.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Total Player exceeds the team limit.", PREFIX);
					}

					g_PlayerData[iClient].bQueue = false;
				} else if (iPlayersInTeams < 10) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kamu masih bisa bergabung dengan team.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}You can still join the team.", PREFIX);
					}
                    
					g_PlayerData[iClient].bQueue = false;
				} else {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #002", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #002", PREFIX);
					}

					PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 2");
					PrintToConsole(iClient, "[INFO] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
                    PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
                    PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
                    PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
                    PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
					g_PlayerData[iClient].bQueue = true;
				}
			}
		}
	}
}

public void Multi1v1_OnPreArenaRankingsSet(ArrayList rankingQueue)
{
	for(int iClient = 1; iClient <= MaxClients; iClient++) {
		if (IsValidClient(iClient)) {
			if (GetClientTeam(iClient) == CS_TEAM_SPECTATOR && !CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
				if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
					CPrintToChat(iClient, "%s {default}Capek nungguin di {lightred}Spectator{default}? yuk beli {lightred}Premium Plus{default} sekarang juga supaya bisa {lightred}!join", PREFIX);
					CPrintToChat(iClient, "%s {default}Ketik {lightred}!vip{default} untuk info lebih lanjut yaaa :D", PREFIX);
				} else {
					CPrintToChat(iClient, "%s {default}Buy our {lightred}Premium Plus{default} now to use {lightred}Reserved Slot{default} with {lightred}!join", PREFIX);
					CPrintToChat(iClient, "%s {lightred}!vip{default} for more info about {lightred}Premium Plus", PREFIX);
				}
			}

			if (g_PlayerData[iClient].bQueue == true) {
				if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
					}

					g_PlayerData[iClient].bQueue = false;
				}

				int iPlayersPremium = 0;
				int iPlayersFreemium = 0;
				int iPlayersInQueue = 0;
				int iPlayersInTeams = 0;
				/// Mendapatkan Total Player in Team
				for (int x = 1; x <= MaxClients; x++) {
					if (IsValidClient(x)) {
						if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
							if (CheckCommandAccess(x, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
								iPlayersPremium += 1;
							} else {
								iPlayersFreemium += 1;
							}

							if (g_PlayerData[iClient].bQueue == true) {
								iPlayersInQueue += 1;
							}
							iPlayersInTeams += 1;
						}
					}
				}
				PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
				PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
				PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
				PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
				/// Mendapatkan Total Player in Team
				// Melakukan !join
				if (Multi1v1_GetNumActiveArenas() >= Multi1v1_GetMaximumArenas()) {
					/// Mendapatkan Jumlah Player Hidup
					for (int i = 1; i <= MaxClients; i++) {
						if (IsValidClient(i)) {
							if (GetClientTeam(i) == CS_TEAM_CT || GetClientTeam(i) == CS_TEAM_T) {
								if (iPlayersFreemium >= 1) {
									if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && g_PlayerData[iClient].bQueue == true) {
										int iTeamJoin = GetClientTeam(i);

										SendPlayerToSpectators(i);
										ChangeClientTeam(iClient, iTeamJoin);
										g_PlayerData[iClient].bQueue = false;

										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);

										char sAuthID[64];
										GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
										PlayerCooldown.SetValue(sAuthID, 1);
									}
								} else if (iPlayersPremium >= GetMaxHumanPlayers()  && g_PlayerData[iClient].bQueue == true) {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium or Premium Plus, coba server lain.", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Both Team full by Premium or Premium Plus, try another server.", PREFIX);
									}

									g_PlayerData[iClient].bQueue = false;
								} else {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #001", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #001", PREFIX);
									}
									PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 1");
									PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
									PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
									PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
									PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
									g_PlayerData[iClient].bQueue = true;
								}
							}
						}
					}
				} else if(Multi1v1_GetNumActiveArenas() <= Multi1v1_GetMaximumArenas()) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {lightblue}%i {default} dari {lightblue}%i {default}Arena masih tersedia", PREFIX, Multi1v1_GetMaximumArenas()-Multi1v1_GetNumActiveArenas(), Multi1v1_GetMaximumArenas());
					} else {
						CPrintToChat(iClient, "%s {lightblue}%i {default} out of {lightblue}%i {default}Arena are still empty", PREFIX, Multi1v1_GetMaximumArenas()-Multi1v1_GetNumActiveArenas(), Multi1v1_GetMaximumArenas());
					}

					g_PlayerData[iClient].bQueue = false;
				} else {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #002", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #002", PREFIX);
					}

					PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 2");
					PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
					PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
					PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
					PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
					g_PlayerData[iClient].bQueue = true;
				}
			}
		}
	}
}

Action Event_PreRoundStartAWP(Event event, const char[] name, bool dontBroadcast)
{
	for (int iClient = 1; iClient <= MaxClients; iClient++) {
		if (IsValidClient(iClient)) {

			if (GetClientTeam(iClient) == CS_TEAM_SPECTATOR) {
				if (!CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && !CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM6)) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Capek nungguin di {lightred}Spectator{default}? yuk beli {lightred}Premium Plus{default} sekarang juga supaya bisa {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {default}Ketik {lightred}!vip{default} untuk info lebih lanjut yaaa :D", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Buy our {lightred}Premium Plus{default} now to use {lightred}Reserved Slot{default} with {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {lightred}!vip{default} for more info about {lightred}Premium Plus", PREFIX);
					}
				} else if (CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && !CheckCommandAccess(iClient, "sm_froidapp_premium", ADMFLAG_CUSTOM6)) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Capek nungguin di {lightred}Spectator{default}? yuk upgrade ke {lightred}Premium Plus{default} sekarang juga supaya bisa {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {default}Ketik {lightred}!vip{default} untuk info lebih lanjut yaaa :D", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Upgrade to {lightred}Premium Plus{default} now to use {lightred}Reserved Slot{default} with {lightred}!join", PREFIX);
						CPrintToChat(iClient, "%s {lightred}!vip{default} for more info about {lightred}Premium Plus", PREFIX);
					}
				}
			}

			if (g_PlayerData[iClient].bQueue == true) {
				if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {lightred}!join {default}Hanya bisa digunakan di Spectator.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {lightred}!join {default}Only can be used by Spectator.", PREFIX);
					}
					g_PlayerData[iClient].bQueue = false;
				}

				int iPlayersPremiumPlus = 0;
				int iPlayersPremium = 0;
				int iPlayersFreemium = 0;
				int iPlayersInQueue = 0;
				int iPlayersInTeams = 0;
				/// Mendapatkan Total Player in Team
				for(int x = 1; x <= MaxClients; x++) {
					if (IsValidClient(x)) {
						if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
							if (CheckCommandAccess(x, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
								iPlayersPremiumPlus += 1;
							} else if (CheckCommandAccess(x, "sm_froidapp_premium", ADMFLAG_CUSTOM5)) {
								iPlayersPremium += 1;
							} else {
								iPlayersFreemium += 1;
							}

							if (g_PlayerData[x].bQueue == true) {
								iPlayersInQueue += 1;
							}
							iPlayersInTeams += 1;
						}
					}
				}
				PrintToConsole(iClient, "[INFO] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
				PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
				PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
				PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
				PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
				/// Mendapatkan Total Player in Team
				// Melakukan !join
				if (iPlayersInTeams == GetMaxHumanPlayers()) {
					for(int i = 1; i <= MaxClients; i++) {
						if (IsValidClient(i)) {
							if (GetClientTeam(i) == CS_TEAM_T || GetClientTeam(i) == CS_TEAM_CT) {
								if (iPlayersFreemium >= 1) {
									if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM5) && g_PlayerData[iClient].bQueue == true) {
										int iTeamJoin = GetClientTeam(i);

										SendPlayerToSpectators(i);
										ChangeClientTeam(iClient, iTeamJoin);

										g_PlayerData[iClient].bQueue = false;
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Buy Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);

										char sAuthID[64];
										GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
										PlayerCooldown.SetValue(sAuthID, 1);
									}
								} else if (iPlayersPremium >= 1) {
									if (!CheckCommandAccess(i, "sm_froidapp_premium", ADMFLAG_CUSTOM6) && g_PlayerData[iClient].bQueue == true) {
										int iTeamJoin = GetClientTeam(i);

										SendPlayerToSpectators(i);
										ChangeClientTeam(iClient, iTeamJoin);

										g_PlayerData[iClient].bQueue = false;
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Upgrade to Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);
										CPrintToChatAll("%s {lightred}%N {default}replaced by {lightred}%N. {default}Upgrade to Premium Plus Now at {lightred}froidgaming.net/store", PREFIX, i, iClient);

										char sAuthID[64];
										GetClientAuthId(iClient, AuthId_SteamID64, sAuthID, sizeof(sAuthID));
										PlayerCooldown.SetValue(sAuthID, 1);
									}
								} else if (iPlayersPremiumPlus >= GetMaxHumanPlayers() && g_PlayerData[iClient].bQueue == true) {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Kedua Team full dengan Premium Plus, coba server lain.", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Both Team full by Premium Plus, try other server.", PREFIX);
									}

									g_PlayerData[iClient].bQueue = false;
								} else {
									if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
										CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #001", PREFIX);
									} else {
										CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #001", PREFIX);
									}
									PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 1");
									PrintToConsole(iClient, "[INFO] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
									PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
									PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
									PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
									PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
									g_PlayerData[iClient].bQueue = true;
								}
							}
						}
					}
				} else if (iPlayersInTeams > GetMaxHumanPlayers()) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Jumlah Pemain melebihi batas team.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Total Player exceeds the team limit.", PREFIX);
					}

					g_PlayerData[iClient].bQueue = false;
				} else if (iPlayersInTeams < GetMaxHumanPlayers()) {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Kamu masih bisa bergabung dengan team.", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}You can still join the team.", PREFIX);
					}
                    
					g_PlayerData[iClient].bQueue = false;
				} else {
					if (StrEqual(g_PlayerData[iClient].sCountryCode, "ID")) {
						CPrintToChat(iClient, "%s {default}Tunggu round selanjutnya... #002", PREFIX);
					} else {
						CPrintToChat(iClient, "%s {default}Waiting for next rounds...  #002", PREFIX);
					}

					PrintToConsole(iClient, "[INFO] Terjadi Kesalahan 2");
					PrintToConsole(iClient, "[INFO] Jumlah Premium Plus : %d", iPlayersPremiumPlus);
                    PrintToConsole(iClient, "[INFO] Jumlah Premium : %d", iPlayersPremium);
                    PrintToConsole(iClient, "[INFO] Jumlah Freemium : %d", iPlayersFreemium);
                    PrintToConsole(iClient, "[INFO] Jumlah Total : %d", iPlayersInTeams);
                    PrintToConsole(iClient, "[INFO] Jumlah Queue : %d", iPlayersInQueue);
					g_PlayerData[iClient].bQueue = true;
				}
			}
		}
	}
	return Plugin_Continue;
}