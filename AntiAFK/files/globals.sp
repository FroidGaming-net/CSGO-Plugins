ConVar g_cvCheckInterval = null;
ConVar g_cvAfkState[4] = { null, ... };
ConVar g_cvDropBomb = null;
ConVar g_cvMidgame = null;
ConVar g_cvMidgameMult = null;
ConVar g_cvKick = null;
ConVar g_cvSpec = null;
ConVar g_cvTeam = null;

float g_fLastAngle[MAXPLAYERS + 1][3];
float g_fLastTime[MAXPLAYERS + 1];

int g_iAfkstate[MAXPLAYERS + 1] = {-1 , ...};

bool bEnable = false;
float g_fRoundStart = -1.0;