Action Call_MenuServers(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }

    MenuServersCategory(iClient);

	return Plugin_Handled;
}