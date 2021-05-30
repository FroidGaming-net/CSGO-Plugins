stock bool IsWarmup()
{
	return view_as<bool>(GameRules_GetProp("m_bWarmupPeriod"));
}

stock bool IsSafeToCheck()
{
	if (g_bWinPanel == true) {
		return false;
	}

	if (g_bRetakes == true) {
		if (!Retakes_Live()) {
			return false;
		}

		return true;
	}

	// if (g_bExecutes == true) {
	// 	if (Executes_InWarmup()) {
	// 		return false;
	// 	}
	// 	return true;
	// }

	if (IsWarmup()) {
		return false;
	}

	return true;
}