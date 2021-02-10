void OnInstantDefusePost(int client, int c4)
{
	Call_StartForward(fw_OnInstantDefusePost);

	Call_PushCell(client);
	Call_PushCell(c4);

	Call_Finish();
}

void EndRound(int team, bool waitFrame = true)
{
    if (waitFrame)
    {
        RequestFrame(Frame_EndRound, team);

        return;
    }

    Frame_EndRound(team);
}

void Frame_EndRound(int team)
{
    int RoundEndEntity = CreateEntityByName("game_round_end");

    DispatchSpawn(RoundEndEntity);

    SetVariantFloat(1.0);

    if (team == CS_TEAM_CT)
    {
        AcceptEntityInput(RoundEndEntity, "EndRound_CounterTerroristsWin");
    }
    else if (team == CS_TEAM_T)
    {
        AcceptEntityInput(RoundEndEntity, "EndRound_TerroristsWin");
    }

    AcceptEntityInput(RoundEndEntity, "Kill");
}

stock int GetDefusingPlayer()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i) && GetEntProp(i, Prop_Send, "m_bIsDefusing"))
        {
            return i;
        }
    }

    return 0;
}

stock bool OnInstandDefusePre(int client, int c4)
{
	Action response;

	Call_StartForward(fw_OnInstantDefusePre);
	Call_PushCell(client);
	Call_PushCell(c4);
	Call_Finish(response);

	return !(response != Plugin_Continue && response != Plugin_Changed);
}

bool HasDefuseKit(int client)
{
	bool hasDefuseKit = GetEntProp(client, Prop_Send, "m_bHasDefuser") == 1;
	return hasDefuseKit;
}

stock bool HasAlivePlayer(int team)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
        {
            return true;
        }
    }

    return false;
}