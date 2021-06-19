void RandomizeName(int iClient)
{
	char sName[MAX_NAME_LENGTH];
	GetClientName(iClient, sName, sizeof(sName));

	int iLength = strlen(sName);
	g_PlayerData[iClient].sNewName[0] = '\0';

	for (int i = 0; i < iLength; i++)
	{
		g_PlayerData[iClient].sNewName[i] = sName[GetRandomInt(0, iLength - 1)];
	}

	g_PlayerData[iClient].sNewName[iLength] = '\0';
}