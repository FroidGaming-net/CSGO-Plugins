stock bool IsWarmup()
{
	return view_as<bool>(GameRules_GetProp("m_bWarmupPeriod"));
}

stock bool IsSafeToCheck()
{
	if (g_bWinPanel == true) {
		return false;
	}

	if (Executes_InWarmup()) {
		return false;
	}

	if (IsWarmup()) {
		return false;
	}

	return true;
}