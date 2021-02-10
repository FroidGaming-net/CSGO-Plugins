public Action Timer_Image(Handle hTimer, Handle dp)
{
    ResetPack(dp);
    int iClient = GetClientOfUserId(ReadPackCell(dp));
    char sUrlImage[256];
    ReadPackString(dp, sUrlImage, sizeof(sUrlImage));

	if (IsValidClient(iClient)) {
		PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/characters/customplayer_%s.png'></span>", sUrlImage);
	}
}

stock int FindAgentDefIndexByName(const char[] sAgentName)
{
    int iFound = 0;
    int iFoundAgent;
    char sAgentDisplayName[48];
    for(int iAgentNum = 0; iAgentNum < g_iAgentsCount; iAgentNum++)
    {
        int iAgentDefIndex = eItems_GetAgentDefIndexByAgentNum(iAgentNum);

        eItems_GetAgentDisplayNameByDefIndex(iAgentDefIndex, sAgentDisplayName, sizeof(sAgentDisplayName));

        if(StrContains(sAgentDisplayName, sAgentName, false) != -1)
        {
            iFoundAgent = iAgentDefIndex;
            iFound++;
        }
    }

    if(iFound == 0)
    {
        return 0;
    }
    else if(iFound > 1)
    {
        return -1;
    }

    return iFoundAgent;
}