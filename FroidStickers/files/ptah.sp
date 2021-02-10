public void PTaH_OnGiveNamedItemPost(int client, const char[] szClassname, const CEconItemView Item, int iEnt, bool OriginIsNULL, const float Origin[3])
{
    if(!IsValidClient(client, true))
    {
        return;
    }

    if(!IsValidEntity(iEnt))
    {
        return;
    }

    if(!eItems_IsValidWeapon(iEnt))
    {
        return;
    }

    int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeapon(iEnt);
    int iWeaponNum = eItems_GetWeaponNumByDefIndex(iWeaponDefIndex);

    if (iWeaponNum == -1)
    {
        return;
    }

    if (!FroidStickers_IsValidDefIndex(iWeaponDefIndex) || eItems_IsDefIndexKnife(iWeaponDefIndex))
    {
        return;
    }

    int iPrevOwner = GetEntProp(iEnt, Prop_Send, "m_hPrevOwner");

    if(iPrevOwner != -1)
    {
        return;
    }

    eTweaker_UpdateClientWeapon(client, iEnt);
}