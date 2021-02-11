Action Call_MenuAgents(int iClient, int iArgs){
	if (!IsValidClient(iClient)){
        return Plugin_Handled;
    }

    if (!eItems_AreItemsSynced()) {
        CPrintToChat(iClient, "%s Data not synced. Feature not available!", PREFIX);
        return Plugin_Handled;
    }

    switch(iArgs)
    {
        case 0: MenuAgentTeam(iClient);
        default:
        {
            char sAgentName[128];
            GetCmdArgString(sAgentName, sizeof(sAgentName));

            int iAgentDefIndex = FindAgentDefIndexByName(sAgentName);

            switch(iAgentDefIndex)
            {
                case -1:
                {
                    BuildAgentMenuBySkinName(iClient, sAgentName);
                }
                case 0:
                {
                    CPrintToChat(iClient, "%s No Agent Found.", PREFIX);
                }
                default:
                {
                    g_PlayerData[iClient].SetAgent(iAgentDefIndex, view_as<int>(eItems_GetAgentTeamByDefIndex(iAgentDefIndex) == CS_TEAM_CT));
			        g_PlayerData[iClient].SetAgentSkin(iClient, view_as<int>(eItems_GetAgentTeamByDefIndex(iAgentDefIndex)));

                    char sAgentDisplayName[128];
                    eItems_GetAgentDisplayNameByDefIndex(iAgentDefIndex, sAgentDisplayName, sizeof(sAgentDisplayName));
                    CPrintToChat(iClient, "%s You have selected {lime}%s{default} for %s.", PREFIX, sAgentDisplayName, eItems_GetAgentTeamByDefIndex(iAgentDefIndex) == CS_TEAM_CT ? "{lightblue}CT Team" : "{orange}T Team");
                }
            }
        }
    }
	
	return Plugin_Handled;
}