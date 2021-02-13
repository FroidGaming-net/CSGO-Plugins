stock bool IsFullTeam()
{
    int iPlayersInTeam = 0;
	for (int x = 1; x <= MaxClients; x++) {
		if (IsValidClient(x)) {
			if (GetClientTeam(x) == CS_TEAM_T || GetClientTeam(x) == CS_TEAM_CT) {
				iPlayersInTeam += 1;
			}
		}
	}

    if(iPlayersInTeam == 10){
        return true;
    }else if(iPlayersInTeam > 10){
        return true;
    }else{
        return false;
    }
}