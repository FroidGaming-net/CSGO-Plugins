Action Call_MenuAgents(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }
    
    MenuAgentTeam(iClient);
	
	return Plugin_Handled;
}