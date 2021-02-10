Action Call_MenuFeatures(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }
    
    MenuFeatures(iClient);
	
	return Plugin_Handled;
}

Action Call_MenuRules(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }

    MenuRules(iClient);
	
	return Plugin_Handled;
}