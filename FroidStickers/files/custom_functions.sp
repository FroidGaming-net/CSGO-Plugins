stock bool FroidStickers_AreDataSynced()
{
    return g_bDataSynced;
}

stock void FroidStickers_PrintDataNotSynced(int client)
{
    if(g_bFirstSynced == false) {
        if(eItems_AreItemsSynced())
        {
            eItems_OnItemsSynced();
        }
        else if(!eItems_AreItemsSyncing())
        {
            eItems_ReSync();
        }

        g_bFirstSynced = true;
    }
    CPrintToChat(client, "%s Data not \x07synced\x01. Feature not available!", PREFIX);
}

stock void FroidStickers_PrintNotAvailableInSpec(int client)
{
    CPrintToChat(client, "%s This function is not available while spectating!", PREFIX);
}

stock void FroidStickers_PrintNotAvailableWhileControllingBot(int client)
{
    CPrintToChat(client, "%s This function is not available while controlling bot!", PREFIX);
}

stock void FroidStickers_PrintOnlyForAlivePlayers(int client)
{
    CPrintToChat(client, "%s This function is available only for alive players!", PREFIX);
}

stock bool FroidStickers_IsControllingBot(int client)
{
    return view_as<bool>(GetEntProp(client, Prop_Send, "m_bIsControllingBot"));
}

stock bool FroidStickers_IsClientSpectating(int client)
{
    return ClientInfo[client].Team() == CS_TEAM_SPECTATOR;
}

stock int FroidStickers_GetWeaponCount()
{
    return g_iWeaponsCount;
}

stock bool FroidStickers_IsValidDefIndex(int defIndex)
{
	static int blackList[] =
	{
		20, 31, 37, 41, 42, 49, 57, 59, 68, 69, 70, 72, 75, 76, 78, 81, 82, 83, 84, 85
	};

	// Avoid invalid def index, grenades or knifes.
	if (defIndex <= 0 || (defIndex >= 43 && defIndex <= 48) || eItems_IsDefIndexKnife(defIndex))
	{
		return false;
	}

	// Check defIndex blacklist.
	int size = sizeof(blackList);
	for (int i = 0; i < size; i++)
	{
		if (defIndex == blackList[i])
		{
			return false;
		}
	}

	return true;
}

public void eTweaker_UpdateClientWeapon(int client, int iWeapon)
{
    if(!IsValidClient(client, true))
    {
        return;
    }

    if(!IsValidEntity(iWeapon))
    {
        return;
    }

    if(!eItems_IsValidWeapon(iWeapon))
    {
        return;
    }

    int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeapon(iWeapon);
    int iWeaponNum = eItems_GetWeaponNumByDefIndex(iWeaponDefIndex);

	if (iWeaponNum == -1)
    {
        return;
    }

    if (!FroidStickers_IsValidDefIndex(iWeaponDefIndex) || eItems_IsDefIndexKnife(iWeaponDefIndex))
    {
        return;
    }

    char sWeaponDefIndex[12];
    IntToString(iWeaponDefIndex, sWeaponDefIndex, sizeof(sWeaponDefIndex));

    eWeaponSettings WeaponSettings;
    if(!g_smWeaponSettings[client].GetArray(sWeaponDefIndex, WeaponSettings, sizeof(eWeaponSettings)))
    {
        return;
    }

	// Check if item is already initialized by external ws.
	if (GetEntProp(iWeapon, Prop_Send, "m_iItemIDHigh") < 16384)
	{
		static int IDHigh = 16384;
		SetEntProp(iWeapon, Prop_Send, "m_iItemIDLow", -1);
		SetEntProp(iWeapon, Prop_Send, "m_iItemIDHigh", IDHigh++);
	}

	int iWeaponStickerSlots = eItems_GetWeaponStickersSlotsByDefIndex(iWeaponDefIndex);

	for(int iStickerSlot = 0; iStickerSlot < iWeaponStickerSlots; iStickerSlot++)
	{
		if(WeaponSettings.Sticker[iStickerSlot] == 0)
		{
			continue;
		}
		eTweaker_AddAttribute(iWeapon, 113, iStickerSlot, WeaponSettings.Sticker[iStickerSlot]);
		eTweaker_AddAttribute(iWeapon, 114, iStickerSlot, 0.0000001);
	}
}

stock void eTweaker_AddAttribute(int entity, const int Attribute_Id, const int Attribute_Slot, const any value)
{
    CEconItemView pItemView = PTaH_GetEconItemViewFromEconEntity(entity);
    CAttributeList pAttributeList = pItemView.NetworkedDynamicAttributesForDemos;
    pAttributeList.SetOrAddAttributeValue(Attribute_Id + Attribute_Slot * 4, value);
}