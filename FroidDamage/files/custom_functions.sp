stock void SendDiscord(int iAttacker, int iVictim, int iDamage, char[] sWeapon)
{
    // Discord
    Discord_StartMessage();
    Discord_SetUsername("FroidGaming.net");
    Discord_SetTitle(NULL_STRING, "★ Damage Logs ★");
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

    Format(szBody[0], sizeof(szBody[]), "» %f", iDamage);
    Discord_AddField("• Damage :", szBody[0], false);

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