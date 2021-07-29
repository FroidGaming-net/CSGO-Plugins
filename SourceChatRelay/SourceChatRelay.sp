#include <sourcemod>
#include <cstrike>
#include <socket>
#include <multicolors>
#include <bytebuffer>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"
#define UPDATE_URL "https://sys.froidgaming.net/SourceChatRelay/updatefile.txt"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/custom_functions.sp"

public Plugin myinfo =
{
	name = "Source Chat Relay",
	author = "Fishy (Modified by FroidGaming.net)",
	description = "Communicate between Discord & In-Game, monitor server without being in-game, control the flow of messages and user base engagement!",
	version = VERSION,
	url = "https://keybase.io/RumbleFrog"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("SourceChatRelay");

	CreateNative("SCR_SendMessage", Native_SendMessage);
	CreateNative("SCR_SendEvent", Native_SendEvent);

	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("rf_scr_version", VERSION, "Source Chat Relay Version", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);

	g_cHost = CreateConVar("rf_scr_host", "discordrelay.froidgaming.net", "Relay Server Host", FCVAR_PROTECTED);

	g_cPort = CreateConVar("rf_scr_port", "57452", "Relay Server Port", FCVAR_PROTECTED);

	AutoExecConfig(true, "SourceServerRelay");

	if (LibraryExists("updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }

	g_hSocket = SocketCreate(SOCKET_TCP, OnSocketError);

	SocketSetOption(g_hSocket, SocketReuseAddr, 1);
	SocketSetOption(g_hSocket, SocketKeepAlive, 1);

	#if defined DEBUG
	SocketSetOption(g_hSocket, DebugMode, 1);
	#endif

	// ClientIndex, ClientName, Message
	g_hMessageSendForward = CreateGlobalForward(
		"SCR_OnMessageSend",
		ET_Event,
		Param_Cell,
		Param_String,
		Param_String);

	// EntityName, IDType, ID, ClientName, Message
	g_hMessageReceiveForward = CreateGlobalForward(
		"SCR_OnMessageReceive",
		ET_Event,
		Param_String,
		Param_Cell,
		Param_String,
		Param_String,
		Param_String);

	// sEvent, sData
	g_hEventSendForward = CreateGlobalForward(
		"SCR_OnEventSend",
		ET_Event,
		Param_String,
		Param_String);

	// sEvent, sData
	g_hEventReceiveForward = CreateGlobalForward(
		"SCR_OnEventReceive",
		ET_Event,
		Param_String,
		Param_String);
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "updater")) {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public void OnConfigsExecuted()
{
	GetConVarString(FindConVar("hostname"), g_sHostname, sizeof g_sHostname);

	g_cHost.GetString(g_sHost, sizeof g_sHost);

	g_iPort = g_cPort.IntValue;

	File tFile;

	char sPath[PLATFORM_MAX_PATH], sIP[64];

	Server_GetIPString(sIP, sizeof sIP);

	BuildPath(Path_SM, sPath, sizeof sPath, "data/%s_%d.data", sIP, Server_GetPort());

	if (FileExists(sPath, false))
	{
		tFile = OpenFile(sPath, "r", false);

		tFile.ReadString(g_sToken, sizeof g_sToken, -1);
	} else
	{
		tFile = OpenFile(sPath, "w", false);

		GenerateRandomChars(g_sToken, sizeof g_sToken, 64);

		tFile.WriteString(g_sToken, true);
	}

	delete tFile;

	if (!SocketIsConnected(g_hSocket))
	{
		ConnectRelay();

		// Stop. The map start event will emit on authentication reply packet
		return;
	}
}

void ConnectRelay()
{
	if (!SocketIsConnected(g_hSocket))
		SocketConnect(g_hSocket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, g_sHost, g_iPort);
	else
		PrintToServer("Source Chat Relay: Socket is already connected?");
}

public Action Timer_Reconnect(Handle timer)
{
	ConnectRelay();
}

void StartReconnectTimer()
{
	if (SocketIsConnected(g_hSocket))
		SocketDisconnect(g_hSocket);

	CreateTimer(10.0, Timer_Reconnect);
}

public int OnSocketDisconnected(Handle socket, any arg)
{
	StartReconnectTimer();

	PrintToServer("Source Chat Relay: Socket disconnected");
}

public int OnSocketError(Handle socket, int errorType, int errorNum, any ary)
{
	StartReconnectTimer();

	LogError("Source Chat Relay socket error %i (errno %i)", errorType, errorNum);
}

public int OnSocketConnected(Handle socket, any arg)
{
	AuthenticateMessage(g_sToken).Dispatch();

	PrintToServer("Source Chat Relay: Socket Connected");
}

public int OnSocketReceive(Handle socket, const char[] receiveData, int dataSize, any arg)
{
	HandlePackets(receiveData, dataSize);
}

public void HandlePackets(const char[] sBuffer, int iSize)
{
	BaseMessage base = view_as<BaseMessage>(CreateByteBuffer(true, sBuffer, iSize));

	switch(base.Type)
	{
		case MessageChat:
		{
			ChatMessage m = view_as<ChatMessage>(base);

			Action aResult;

			char sEntity[64], sID[64], sName[MAX_NAME_LENGTH], sMessage[MAX_COMMAND_LENGTH];

			m.GetEntityName(sEntity, sizeof sEntity);
			m.GetUsername(sName, sizeof sName);
			m.GetMessage(sMessage, sizeof sMessage);

			// Strip anything beyond 3 bytes for character as chat can't render it
			StripCharsByBytes(sEntity, sizeof sEntity);
			StripCharsByBytes(sName, sizeof sName);
			StripCharsByBytes(sMessage, sizeof sMessage);

			Call_StartForward(g_hMessageReceiveForward);
			Call_PushString(sEntity);
			Call_PushCell(m.IDType);
			Call_PushString(sID);
			Call_PushStringEx(sName, sizeof sName, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushStringEx(sMessage, sizeof sMessage, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_Finish(aResult);

			if (aResult >= Plugin_Handled)
			{
				base.Close();
				return;
			}

			#if defined DEBUG
			PrintToConsoleAll("====== Chat Message Packet =====");
			PrintToConsoleAll("sEntity: %s", sEntity);
			PrintToConsoleAll("sName: %s", sName);
			PrintToConsoleAll("sMessage: %s", sMessage);
			PrintToConsoleAll("====== Chat Message Packet =====");
			#endif

			CPrintToChatAll("{green}STAFF %s {grey}» {default}%s", sName, sMessage);
		}
		case MessageEvent:
		{
			EventMessage m = view_as<EventMessage>(base);

			Action aResult;

			char sEvent[MAX_EVENT_NAME_LENGTH], sData[MAX_COMMAND_LENGTH];

			m.GetEvent(sEvent, sizeof sEvent);
			m.GetData(sData, sizeof sData);

			// Strip anything beyond 3 bytes for character as chat can't render it
			StripCharsByBytes(sEvent, sizeof sEvent);
			StripCharsByBytes(sData, sizeof sData);

			Call_StartForward(g_hEventReceiveForward);
			Call_PushStringEx(sEvent, sizeof sEvent, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushStringEx(sData, sizeof sData, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_Finish(aResult);

			if (aResult >= Plugin_Handled)
			{
				base.Close();
				return;
			}

			// CPrintToChatAll("{gold}[%s]{white}: {grey}%s", sEvent, sData);
		}
		case MessageAuthenticateResponse:
		{
			AuthenticateMessageResponse m = view_as<AuthenticateMessageResponse>(base);

			if (m.Response == AuthenticateDenied)
				SetFailState("Server denied our token. Stopping.");

			PrintToServer("Source Chat Relay: Successfully authenticated");
		}
		default:
		{
			// They crazy
		}
	}

	base.Close();
}

void DispatchMessage(int iClient, const char[] sMessage)
{
	char sID[64], sName[MAX_NAME_LENGTH], tMessage[MAX_COMMAND_LENGTH];

	Action aResult;

	strcopy(tMessage, MAX_COMMAND_LENGTH, sMessage);

	if (!GetClientAuthId(iClient, AuthId_SteamID64, sID, sizeof sID))
	{
		return;
	}

	if (!GetClientName(iClient, sName, sizeof sName))
	{
		return;
	}

	Call_StartForward(g_hMessageSendForward);
	Call_PushCell(iClient);
	Call_PushStringEx(sName, MAX_NAME_LENGTH, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushStringEx(tMessage, MAX_COMMAND_LENGTH, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(aResult);

	if (aResult >= Plugin_Handled)
		return;

	ChatMessage(IdentificationSteam, sID, sName, tMessage).Dispatch();
}

public int Native_SendMessage(Handle plugin, int numParams)
{
	if (numParams < 2)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Insufficient parameters");
	}

	char sBuffer[512];

	int iClient = GetNativeCell(1);

	FormatNativeString(0, 2, 3, sizeof sBuffer, _, sBuffer);

	DispatchMessage(iClient, sBuffer);

	return 0;
}

public int Native_SendEvent(Handle plugin, int numParams)
{
	if (numParams < 2)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Insufficient parameters");
	}

	Action aResult;

	char sEvent[MAX_EVENT_NAME_LENGTH], sData[MAX_COMMAND_LENGTH];

	GetNativeString(1, sEvent, sizeof sEvent);

	FormatNativeString(0, 2, 3, sizeof sData, _, sData);

	Call_StartForward(g_hEventSendForward);
	Call_PushStringEx(sEvent, sizeof sEvent, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushStringEx(sData, sizeof sData, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(aResult);

	if (aResult >= Plugin_Handled)
		return 0;

	EventMessage(sEvent, sData).Dispatch();

	return 0;
}