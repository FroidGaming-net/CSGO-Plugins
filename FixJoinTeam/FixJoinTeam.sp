#pragma newdecls required
#pragma semicolon 1

#include <sdktools>

public Plugin myinfo =  {
	name = "[FIX] - JoinTeam Teleport", 
	description = "Исправляет баг с телепортом", 
	version = "1.0", 
	author = "MaZa", 
	url = "vk.com/xMaZax & hotstar-project.net & STEAM_1:0:84111"
};

public void OnPluginStart()
{
	AddCommandListener(JoinTeamListener, "jointeam");
}

Action JoinTeamListener(int iClient, const char[] szCommand, int iArgc)
{
	float fGameTime = GetGameTime();
	static float fLastTime;
	
	if ((fGameTime - fLastTime) == 0.0)
	{
		return Plugin_Handled;
	}
	
	fLastTime = fGameTime;
	
	return Plugin_Continue;
}