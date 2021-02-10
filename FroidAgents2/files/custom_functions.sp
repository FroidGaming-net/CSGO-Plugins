public Action Timer_Image(Handle hTimer, Handle dp)
{
    ResetPack(dp);
    int iClient = GetClientOfUserId(ReadPackCell(dp));
    char sUrlImage[256];
    ReadPackString(dp, sUrlImage, sizeof(sUrlImage));

	if (IsValidClient(iClient)) {
		PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/characters/customplayer_%s.png'></span>", sUrlImage);
	}
}				