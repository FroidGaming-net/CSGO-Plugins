Action Call_MenuSkybox(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }
    
    MenuSkybox(iClient);
	
	return Plugin_Handled;
}