#define PLUGIN_VERSION "1.0"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

public Plugin myinfo =
{
	name = "[ANY] [Debugger] Valve Profiler",
	description = "Measures per-plugin performance and provides a log with various counters",
	author = "Alex Dragokas",
	version = PLUGIN_VERSION,
	url = "https://github.com/dragokas/"
};

/*
	Commands:
	
	 - sm_debug - Start / stop vprof debug tracing
	
	Logfile:
	
	 - addons/sourcemod/logs/profiler__<DATE>_<TIME>.log
	 
	For details of implementation see also:
	https://github.com/alliedmodders/sourcemod/issues/1162
*/

char g_PathPrefix[PLATFORM_MAX_PATH];
char g_PathOrig[PLATFORM_MAX_PATH];
ConVar g_CVarLogFile;
Handle g_hTimer;

public void OnPluginStart()
{
	CreateConVar("sm_prof_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_CVarLogFile = FindConVar("con_logfile");

	RegAdminCmd("sm_debug", Cmd_Debug, ADMFLAG_ROOT, "Start / stop the valve profiler");
	
	BuildPath(Path_SM, g_PathPrefix, sizeof(g_PathPrefix), "logs/profiler_");
}

public void OnConfigsExecuted()
{
	g_CVarLogFile.GetString(g_PathOrig, sizeof(g_PathOrig));
}

public Action Cmd_Debug(int client, int args)
{
	static bool start;
	static char PathNew[PLATFORM_MAX_PATH];
	char sTime[32];
	
	if( !start )
	{
		delete g_hTimer;
		
		FormatTime(sTime, sizeof(sTime), "%F_%H-%M-%S", GetTime());
		PathNew[0] = 0;
		Format(PathNew, sizeof(PathNew), "%s_%s.log", g_PathPrefix, sTime);
		SetCvarSilent(g_CVarLogFile, PathNew);
		
		ReplyToCommand(client, "\x04[START]\x05 Profiler is started...");
		ServerCommand("vprof_on");
		ServerExecute();
		RequestFrame(OnFrameDelay);
	}
	else
	{
		ServerCommand("sm prof stop vprof");
		ServerCommand("sm prof dump vprof");
		ServerCommand("vprof_off");
		ReplyToCommand(client, "\x04[STOP]\x05 Saving profiler log to: %s", PathNew);
		g_hTimer = CreateTimer(60.0, Timer_RestoreCvar); // Profiler needs some time for analysis
	}
	start = !start;
	return Plugin_Handled;
}

public void OnFrameDelay()
{
	ServerCommand("sm prof start vprof");
}

void SetCvarSilent(ConVar cvar, char[] value)
{
	int flags = cvar.Flags;
	cvar.Flags &= ~ FCVAR_NOTIFY;
	cvar.SetString(value);
	cvar.Flags = flags;
}

public Action Timer_RestoreCvar(Handle timer)
{
	SetCvarSilent(g_CVarLogFile, g_PathOrig);
	g_hTimer = null;
}