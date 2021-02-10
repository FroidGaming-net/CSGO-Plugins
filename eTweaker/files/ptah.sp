public Action PTaH_OnWeaponCanUsePre(int client, int iEnt, bool& CanUse)
{
    int iDefIndex = eItems_GetWeaponDefIndexByWeapon(iEnt);
    if(eItems_IsDefIndexKnife(iDefIndex))
    {
        CanUse = true;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}


public void PTaH_OnGiveNamedItemPost(int client, const char[] szClassname, const CEconItemView Item, int iEnt, bool OriginIsNULL, const float Origin[3])
{
    if(!IsValidClient(client, true))
    {
        return;
    }

    if(!eItems_IsValidWeapon(iEnt))
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

public Action PTaH_OnGiveNamedItemPre(int client, char szClassName[64], CEconItemView &Item, bool &IgnoredCEconItemView, bool &OriginIsNULL, float Origin[3])
{
    if(!IsValidClient(client, true))
    {
        return Plugin_Continue;
    }

    int iWeaponDefIndex = eItems_GetWeaponDefIndexByClassName(szClassName);

    int iSelectedKnife = eTwekaer_GetClientTeamKnife(client);

    if(eItems_IsDefIndexKnife(iWeaponDefIndex))
    {
        if(!eItems_IsDefIndexKnife(iSelectedKnife))
        {
           return Plugin_Continue; 
        }

        if(!g_cvDangerZoneKnives.BoolValue && eTweaker_IsDangerZoneKnife(iSelectedKnife))
        {
            return Plugin_Continue; 
        }

        IgnoredCEconItemView = true;

        eItems_GetWeaponClassNameByDefIndex(iSelectedKnife, szClassName, sizeof(szClassName));
        
        return Plugin_Changed;
    }

    return Plugin_Continue;
}