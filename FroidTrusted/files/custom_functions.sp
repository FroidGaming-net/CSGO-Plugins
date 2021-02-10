stock int GetInGameClientCount2()
{
	int j = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			j++;
		}
	}
	return j;
}

stock bool IsClientPrime(int iClient)
{
	return k_EUserHasLicenseResultHasLicense == SteamWorks_HasLicenseForApp(iClient, 624820);
}