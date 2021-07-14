
void GenerateRandomChars(char[] buffer, int buffersize, int len)
{
	char charset[] = "adefghijstuv6789!@#$%^klmwxyz01bc2345nopqr&+=";

	for (int i = 0; i < len; i++)
		Format(buffer, buffersize, "%s%c", buffer, charset[GetRandomInt(0, sizeof charset)]);
}

void StripCharsByBytes(char[] sBuffer, int iSize, int iMaxBytes = 3)
{
	int iBytes;

	char[] sClone = new char[iSize];

	int i = 0;
	int j = 0;
	int iBSize = 0;

	while (i < iSize)
	{
		iBytes = IsCharMB(sBuffer[i]);

		if (iBytes == 0)
			iBSize = 1;
		else
			iBSize = iBytes;

		if (iBytes <= iMaxBytes)
		{
			for (int k = 0; k < iBSize; k++)
			{
				sClone[j] = sBuffer[i + k];

				j++;
			}
		}

		i += iBSize;
	}

	Format(sBuffer, iSize, "%s", sClone);
}

static int localIPRanges[] =
{
	10	<< 24,				// 10.
	127	<< 24 | 1,			// 127.0.0.1
	127	<< 24 | 16	<< 16,	// 127.16.
	192	<< 24 | 168	<< 16,	// 192.168.
};

int Server_GetIP(bool public_=true)
{
	int ip = 0;

	static ConVar cvHostip;

	if (cvHostip == null) {
		cvHostip = FindConVar("hostip");
		MarkNativeAsOptional("Steam_GetPublicIP");
	}

	if (cvHostip != null) {
		ip = cvHostip.IntValue;
	}

	if (ip != 0 && IsIPLocal(ip) == public_) {
		ip = 0;
	}

#if defined _steamtools_included
	if (ip == 0) {
		if (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "Steam_GetPublicIP") == FeatureStatus_Available) {
			int octets[4];
			Steam_GetPublicIP(octets);

			ip =
				octets[0] << 24	|
				octets[1] << 16	|
				octets[2] << 8	|
				octets[3];

			if (IsIPLocal(ip) == public_) {
				ip = 0;
			}
		}
	}
#endif

	return ip;
}

bool Server_GetIPString(char[] buffer, int size, bool public_=true)
{
	int ip;

	if ((ip = Server_GetIP(public_)) == 0) {
		buffer[0] = '\0';
		return false;
	}

	LongToIP(ip, buffer, size);

	return true;
}

int Server_GetPort()
{
	static ConVar cvHostport;

	if (cvHostport == null) {
		cvHostport = FindConVar("hostport");
	}

	if (cvHostport == null) {
		return 0;
	}

	int port = cvHostport.IntValue;

	return port;
}

bool IsIPLocal(int ip)
{
	int range, bits, move;
	bool matches;

	for (int i=0; i < sizeof(localIPRanges); i++) {

		range = localIPRanges[i];
		matches = true;

		for (int j=0; j < 4; j++) {
			move = j * 8;
			bits = (range >> move) & 0xFF;

			if (bits && bits != ((ip >> move) & 0xFF)) {
				matches = false;
			}
		}

		if (matches) {
			return true;
		}
	}

	return false;
}

void LongToIP(int ip, char[] buffer, int size)
{
	Format(
		buffer, size,
		"%d.%d.%d.%d",
			(ip >> 24)	& 0xFF,
			(ip >> 16)	& 0xFF,
			(ip >> 8 )	& 0xFF,
			ip        	& 0xFF
		);
}