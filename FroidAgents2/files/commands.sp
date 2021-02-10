Action Call_MenuAgents(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }

    if (!eItems_AreItemsSynced()) {
        CPrintToChat(iClient, "%s Data not synced. Feature not available!", PREFIX);
        return Plugin_Handled;
    }
    
    MenuAgentTeam(iClient);
	
	return Plugin_Handled;
}