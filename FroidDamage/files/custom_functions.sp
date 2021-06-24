stock void SendDiscord(int iAttacker, int iVictim, int iDamage, char[] sWeapon)
{
    // Discord
    Discord_StartMessage();
    Discord_SetUsername("FroidGaming.net");
    Discord_SetTitle(NULL_STRING, "★ Team Damage Logs ★");
    /// Content
    char szBody[3][1048];
    GetClientName(iAttacker, szBody[0], sizeof(szBody[]));
    EscapeString(szBody[0], sizeof(szBody[]));
    GetClientAuthId(iAttacker, AuthId_SteamID64, szBody[1], sizeof(szBody[]));
    GetClientAuthId(iAttacker, AuthId_Steam2, szBody[2], sizeof(szBody[]));

    Format(szBody[0], sizeof(szBody[]), "» [%s](https://steamcommunity.com/profiles/%s/) (%s)", szBody[0], szBody[1], szBody[2]);
    Discord_AddField("• Attacker :", szBody[0], false);

    GetClientName(iVictim, szBody[0], sizeof(szBody[]));
    EscapeString(szBody[0], sizeof(szBody[]));
    GetClientAuthId(iVictim, AuthId_SteamID64, szBody[1], sizeof(szBody[]));
    GetClientAuthId(iVictim, AuthId_Steam2, szBody[2], sizeof(szBody[]));

    Format(szBody[0], sizeof(szBody[]), "» [%s](https://steamcommunity.com/profiles/%s/) (%s)", szBody[0], szBody[1], szBody[2]);
    Discord_AddField("• Victim :", szBody[0], false);

    Format(szBody[0], sizeof(szBody[]), "» %s", sWeapon);
    Discord_AddField("• Weapon :", szBody[0], false);

    Format(szBody[0], sizeof(szBody[]), "» %i", iDamage);
    Discord_AddField("• Damage :", szBody[0], false);

    g_PlayerData[iAttacker].iTotalTeamDamage = g_PlayerData[iAttacker].iTotalTeamDamage + iDamage;
    Format(szBody[0], sizeof(szBody[]), "» %i", g_PlayerData[iAttacker].iTotalTeamDamage);
    Discord_AddField("• Total Team Damage :", szBody[0], false);

    char sMapName[64];
    GetCurrentMap(sMapName, sizeof(sMapName));
    Format(szBody[0], sizeof(szBody[]), "» %s", sMapName);
	Discord_AddField("• Map :", szBody[0], false);

    Format(szBody[0], sizeof(szBody[]), "» %d", GetRoundCount());
	Discord_AddField("• Round :", szBody[0], false);

    char sDemoName[256] = "No Demo";
    GetDemoName(sDemoName, sizeof(sDemoName));
	if(StrContains(sDemoName, "No Demo") > -1){
		Format(sDemoName, sizeof(sDemoName), "Demo Unavailable");
	}else{
		Format(sDemoName, sizeof(sDemoName), "[Click Here](%s)", sDemoName);
	}
    Format(szBody[0], sizeof(szBody[]), "» %s", sDemoName);
	Discord_AddField("• Demo :", szBody[0], false);

    g_cHostname = FindConVar("hostname");
	g_cHostname.GetString(g_sHostname, sizeof(g_sHostname));
    FormatEx(szBody[0], sizeof(szBody[]), "» %s", g_sHostname);
    Discord_AddField("• Server :", szBody[0], false);

    FormatEx(szBody[0], sizeof(szBody[]), "» <@&583584442287652876>");
    Discord_AddField("• Tags :", szBody[0], false);
    /// Content
    Discord_EndMessage("damage_logs", true);
    /// Discord
}

stock bool IsWarmup()
{
	return view_as<bool>(GameRules_GetProp("m_bWarmupPeriod"));
}

stock void EscapeString(char[] sString, int iMaxlen)
{
	ReplaceString(sString, iMaxlen, "@", "＠");
	ReplaceString(sString, iMaxlen, "'", "\'");
	ReplaceString(sString, iMaxlen, "\"", "＂");
}

stock void ResetRoundTeamDamage()
{
	for (int i = 1; i < MAXPLAYERS; i++) {
        if (IsValidClient(i)) {
            g_PlayerData[i].iRoundTeamDamage = 0;
        }
    }
}

stock int GetRoundCount()
{
	return GameRules_GetProp("m_totalRoundsPlayed");
}