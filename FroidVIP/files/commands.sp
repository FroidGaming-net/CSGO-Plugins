Action Call_MenuPremium(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }
    MenuPremium(iClient);
	
	return Plugin_Handled;
}