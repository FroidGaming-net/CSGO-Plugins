void RandomizeName(int client)
{
	char name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));

	int len = strlen(name);
	g_NewName[client][0] = '\0';

	for (int i = 0; i < len; i++)
	{
		g_NewName[client][i] = name[GetRandomInt(0, len - 1)];
	}
	g_NewName[client][len] = '\0';
}