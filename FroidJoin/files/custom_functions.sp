void SendPlayerToSpectators(int iClient) 
{ 
    if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR) 
    { 
        // if (IsPlayerAlive(iClient)) 
        // { 
        //     ForcePlayerSuicide(iClient); 
        // } 
        
        ChangeClientTeam(iClient, CS_TEAM_SPECTATOR); 
		RemoveRagdoll(iClient);
		FakeClientCommand(iClient, "jointeam 2");
		FakeClientCommand(iClient, "jointeam 3");

        // Global Forward
        Call_StartForward(g_hForward_OnClientReplaced);
        Call_PushCell(iClient);
        Call_Finish();
    } 
}

void RemoveRagdoll(int iClient)
{
    if (IsValidEdict(iClient)) {
        int iRagdoll = GetEntPropEnt(iClient, Prop_Send, "m_hRagdoll");
        if (iRagdoll != -1) {
            AcceptEntityInput(iRagdoll, "Kill");
        }
    }
}