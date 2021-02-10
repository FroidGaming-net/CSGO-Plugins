void SetSkybox(int iClient, char[] skybox) {
	if (StrEqual(skybox, "mapdefault")) {
		char buffer[32];
		GetConVarString(g_cSkyName, buffer, sizeof(buffer));
		SendConVarValue(iClient, g_cSkyName, buffer);
		
		return;
	}
	SendConVarValue(iClient, g_cSkyName, skybox);
}