
Action Call_MainMenu(int iClient, int iArgs)
{
	if(CheckStatus(iClient) && g_hDatabase)
	{
		CheckRank(iClient);
		MainMenu(iClient);
	}
	else
	{
		LR_PrintMessage(iClient, true, false, "You account is not loaded. Please reconnect on the server!");
	}

	return Plugin_Handled;
}

Action Call_ResetRank(int iClient, int iArgs)
{
	if(CheckStatus(iClient) && g_hDatabase)
	{
		CheckRank(iClient);
		ResetMenu(iClient);
	}
	else
	{
		LR_PrintMessage(iClient, true, false, "You account is not loaded. Please reconnect on the server!");
	}

	return Plugin_Handled;
}

Action Call_ReloadSettings(int iClient, int iArgs)
{
	SetSettings();

	LR_PrintMessage(iClient, true, false, "%T", "ConfigUpdated", iClient);
	PrintToServer("[LR] Settings cache has been refreshed.");

	return Plugin_Handled;
}

public void OnClientSayCommand_Post(int iClient, const char[] sCommand, const char[] sArgs)
{
	if(CheckStatus(iClient))
	{
		if(!strcmp(sArgs, "top", false) || !strcmp(sArgs, "!top", false))
		{
			OverAllTopPlayers(iClient, false);
		}
		else if(!strcmp(sArgs, "toptime", false) || !strcmp(sArgs, "!toptime", false))
		{
			OverAllTopPlayers(iClient);
		}
		else if(!strcmp(sArgs, "session", false) || !strcmp(sArgs, "!session", false))
		{
			MyStatsSession(iClient);
		}
		else if(!strcmp(sArgs, "rank", false) || !strcmp(sArgs, "!rank", false))
		{
			int iKills = g_iPlayerInfo[iClient].iStats[ST_KILLS],
				iDeaths = g_iPlayerInfo[iClient].iStats[ST_DEATHS];

			float fKDR = iKills / (iDeaths ? float(iDeaths) : 1.0);

			if(g_Settings[LR_ShowRankMessage])
			{
				int iPlaceInTop = g_iPlayerInfo[iClient].iStats[ST_PLACEINTOP],
					iExp = g_iPlayerInfo[iClient].iStats[ST_EXP];

				for(int i = GetMaxPlayers(); --i;)
				{
					if(CheckStatus(i))
					{
						LR_PrintMessage(i, true, false, "%T", "RankPlayer", i, iClient, iPlaceInTop, g_iDBCountPlayers, iExp, iKills, iDeaths, fKDR);
					}
				}
			}
			else
			{
				LR_PrintMessage(iClient, true, false, "%T", "RankPlayer", iClient, iClient, g_iPlayerInfo[iClient].iStats[ST_PLACEINTOP], g_iDBCountPlayers, g_iPlayerInfo[iClient].iStats[ST_EXP], iKills, iDeaths, fKDR);
			}
		}
	}
}
