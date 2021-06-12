/* SM Includes */
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <teasyftp>
#include <multicolors>
#undef REQUIRE_EXTENSIONS
#include <bzip2>
#undef REQUIRE_PLUGIN
#include <get5>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

/* Plugin Info */
#define VERSION "1.0.0"

int g_iBzip2 = 9;

public Plugin myinfo =
{
    name = "[FroidPrivateDemo] GET5",
    author = "FroidGaming.net",
    description = "GET5 Demo Uploader.",
    version = VERSION,
    url = "https://froidgaming.net"
};

public void Get5_OnDemoFinished(const char[] filename) {
	char sTempDemoName[512];
	char sTime[16];
	char sMap[32];

	FormatTime(sTime, sizeof(sTime), "%Y%m%d-%H%M%S", GetTime());
	GetCurrentMap(sMap, sizeof(sMap));

	// replace slashes in map path name with dashes, to prevent fail on workshop maps
	ReplaceString(sMap, sizeof(sMap), "/", "-", false);

	Format(sTempDemoName, sizeof(sTempDemoName), "%s-%s.dem", sMap, sTime);

	RenameFile(filename, sTempDemoName);

	LogMessage("Get5_OnDemoFinished Old %s | New %s", filename, sTempDemoName);

	Handle hDataPack = CreateDataPack();
	CreateDataTimer(5.0, Timer_UploadDemo, hDataPack);
	WritePackString(hDataPack, sTempDemoName);
}

public Action Timer_UploadDemo(Handle timer, Handle hDataPack) {
	ResetPack(hDataPack);

	char sDemoPath[PLATFORM_MAX_PATH];
	ReadPackString(hDataPack, sDemoPath, sizeof(sDemoPath));

	LogMessage("Timer_UploadDemo %s", sDemoPath);

	if(g_iBzip2 > 0 && g_iBzip2 < 10 && LibraryExists("bzip2")) {
		char sBzipPath[PLATFORM_MAX_PATH];
		Format(sBzipPath, sizeof(sBzipPath), "%s.bz2", sDemoPath);
		BZ2_CompressFile(sDemoPath, sBzipPath, g_iBzip2, CompressionComplete);
	} else {
		EasyFTP_UploadFile("demos", sDemoPath, "/", UploadComplete);
	}
}

public int CompressionComplete(BZ_Error iError, char[] inFile, char[] outFile, any data) {
	if(iError == BZ_OK) {
		LogMessage("%s compressed to %s", inFile, outFile);
		EasyFTP_UploadFile("demos", outFile, "/", UploadComplete);
	} else {
		LogBZ2Error(iError);
	}
}

public int UploadComplete(const char[] sTarget, const char[] sLocalFile, const char[] sRemoteFile, int iErrorCode, any data) {
	if(iErrorCode == 0) {
		//DeleteFile(sLocalFile);
		if(StrEqual(sLocalFile[strlen(sLocalFile)-4], ".bz2")) {
			char sLocalNoCompressFile[PLATFORM_MAX_PATH];
			strcopy(sLocalNoCompressFile, strlen(sLocalFile)-3, sLocalFile);
			//DeleteFile(sLocalNoCompressFile);
		}
	}else{
		//DeleteFile(sLocalFile);
		if(StrEqual(sLocalFile[strlen(sLocalFile)-4], ".bz2")) {
			char sLocalNoCompressFile[PLATFORM_MAX_PATH];
			strcopy(sLocalNoCompressFile, strlen(sLocalFile)-3, sLocalFile);
			//DeleteFile(sLocalNoCompressFile);
		}
	}

	for(int client = 1; client <= MaxClients; client++) {
		if(IsClientInGame(client) && GetAdminFlag(GetUserAdmin(client), Admin_Reservation)) {
			if(iErrorCode == 0) {
				PrintToChat(client, "[SourceTV] Demo uploaded successfully");
			} else {
				PrintToChat(client, "[SourceTV] Failed uploading demo file. Check the server log files.");
			}
		}
	}
}

public void onSuccess(Database database, any data, int numQueries, Handle[] results, any[] bufferData)
{
	PrintToServer("onSuccess");
}

public void onError(Database database, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	PrintToServer("onError");
}