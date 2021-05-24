#define LoopClients(%1) for(int %1=1;%1<=MaxClients;++%1)

#define LoopIngameClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1))

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))

ConVar g_cvCheckInterval = null;
ConVar g_cvBeaconInterval = null;
ConVar g_cvSlapInterval = null;
ConVar g_cvAfkState[4] = { null, ... };
ConVar g_cvSlap[4] = { null, ... };
ConVar g_cvIgnite = null;
ConVar g_cvBeacon = null;
ConVar g_cvDropBomb = null;
ConVar g_cvMidgame = null;
ConVar g_cvMidgameMult = null;
ConVar g_cvKick = null;
ConVar g_cvSpec = null;
ConVar g_cvTeam = null;

float g_fLastAngle[MAXPLAYERS + 1][3];
float g_fLastTime[MAXPLAYERS + 1];
Handle g_hBeaconTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_hSlapTimer[MAXPLAYERS + 1] = { null, ... };

int g_iAfkstate[MAXPLAYERS + 1] = {-1 , ...};

#define VMT_BOMBRING "materials/sprites/bomb_planted_ring.vmt"
#define VMT_HALO "materials/sprites/halo.vmt"

bool bEnable = false;
float g_fRoundStart = -1.0;

int g_iBombRing;
int g_iHalo;