stock void DisablePlugin(char[] pluginname)
{
	char sPath[64];
	BuildPath(Path_SM, sPath, sizeof(sPath), "plugins/%s.smx", pluginname);
	if (FileExists(sPath)) {
		char sNewPath[64];
		BuildPath(Path_SM, sNewPath, sizeof(sNewPath), "plugins/disabled/%s.smx", pluginname);

		ServerCommand("sm plugins unload %s", pluginname);

		if (FileExists(sNewPath)) {
			DeleteFile(sNewPath);
		}
		RenameFile(sNewPath, sPath);

		LogMessage("%s was unloaded and moved to %s to avoid conflicts", sPath, sNewPath);
	}
}

public int GetBombSite(float pos[3])
{
    int playerManager = FindEntityByClassname(INVALID_ENT_REFERENCE, "cs_player_manager");
    if(playerManager == INVALID_ENT_REFERENCE)
        return INVALID_ENT_REFERENCE;

    float aCenter[3], bCenter[3];
    GetEntPropVector(playerManager, Prop_Send, "m_bombsiteCenterA", aCenter);
    GetEntPropVector(playerManager, Prop_Send, "m_bombsiteCenterB", bCenter);

    float aDist = GetVectorDistance(aCenter, pos, true);
    float bDist = GetVectorDistance(bCenter, pos, true);
    if(aDist < bDist)
        return BOMBSITE_A;
    return BOMBSITE_B;
}

void SendPlayerToSpectators(int iClient)
{
    if (GetClientTeam(iClient) != CS_TEAM_SPECTATOR)
    {
        if (IsPlayerAlive(iClient))
        {
            ForcePlayerSuicide(iClient);
        }

        ChangeClientTeam(iClient, CS_TEAM_SPECTATOR);
		RemoveRagdoll(iClient);
		FakeClientCommand(iClient, "jointeam 2");
		FakeClientCommand(iClient, "jointeam 3");
    }
}

void RemoveRagdoll(int client)
{
    if (IsValidEdict(client))
    {
        int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
        if (ragdoll != -1)
            RemoveEntity(ragdoll);
    }
}