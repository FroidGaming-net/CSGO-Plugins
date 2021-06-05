ConVar g_cvCheckInterval = null;
ConVar g_cvAfkState[4] = { null, ... };
ConVar g_cvDropBomb = null;
ConVar g_cvMidgame = null;
ConVar g_cvMidgameMult = null;
ConVar g_cvKick = null;
ConVar g_cvSpec = null;
ConVar g_cvTeam = null;
ConVar g_cvDebug = null;

bool bEnable = false;
float g_fRoundStart = -1.0;
bool g_bWinPanel = false;

enum struct PlayerData
{
    int iAfkstate;
    int iLastAfkstate;
    float fLastAngle[3];
    float fLastTime;

    void Reset()
	{
        this.iAfkstate = 0;
        this.iLastAfkstate = 0;
        this.fLastAngle[0] = 0.0;
        this.fLastAngle[1] = 0.0;
        this.fLastAngle[2] = 0.0;
		this.fLastTime = 0.0;
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];