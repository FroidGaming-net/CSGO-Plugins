stock bool IsWarmup()
{
	return view_as<bool>(GameRules_GetProp("m_bWarmupPeriod"));
}

stock bool IsSafeToCheck()
{
	if (g_bWinPanel == true) {
		if (g_cvDebug.IntValue == 1) {
			for (int i = 1; i < MAXPLAYERS; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i)) {
					if (CheckCommandAccess(i, "sm_froidapp_root", ADMFLAG_ROOT)) {
						PrintToConsole(i, "[Anti-AFK] g_bWinPanel");
					}
				}
			}
		}
		return false;
	}

	if (Executes_InWarmup()) {
		if (g_cvDebug.IntValue == 1) {
			for (int i = 1; i < MAXPLAYERS; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i)) {
					if (CheckCommandAccess(i, "sm_froidapp_root", ADMFLAG_ROOT)) {
						PrintToConsole(i, "[Anti-AFK] Executes_InWarmup");
					}
				}
			}
		}
		return false;
	}

	if (IsWarmup()) {
		if (g_cvDebug.IntValue == 1) {
			for (int i = 1; i < MAXPLAYERS; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i)) {
					if (CheckCommandAccess(i, "sm_froidapp_root", ADMFLAG_ROOT)) {
						PrintToConsole(i, "[Anti-AFK] IsWarmup");
					}
				}
			}
		}
		return false;
	}

	return true;
}