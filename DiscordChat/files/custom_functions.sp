// void EscapeString(char[] string, int maxlen)
// {
// 	ReplaceString(string, maxlen, "@", "＠");
// 	ReplaceString(string, maxlen, "'", "\'");
// 	ReplaceString(string, maxlen, "\"", "＂");
// }

stock char GetClientTeamName(int iClient)
{
	char sTeam[10];

	switch(GetClientTeam(iClient)) {
		case CS_TEAM_CT:
		{
			sTeam = "CT";
		}
		case CS_TEAM_T:
		{
			sTeam = "T";
		}
		case CS_TEAM_SPECTATOR:
		{
			sTeam = "Spectator";
		}
		case CS_TEAM_NONE:
		{
			sTeam = "Ghost";
		}
		default:
		{
			sTeam = "Ghost";
		}
	}

	return sTeam;
}