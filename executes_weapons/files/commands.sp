Action Call_MenuWeapon(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }
    
    MenuTeam(iClient);
	
	return Plugin_Handled;
}