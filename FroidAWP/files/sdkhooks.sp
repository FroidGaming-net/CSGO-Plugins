public Action PreThink(int iClient)
{
	if(IsPlayerAlive(iClient) && g_bNoScope)
	{
		int iWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
		if (!IsValidEdict(iWeapon) || !IsValidEntity(iWeapon)) {
            return Plugin_Continue;
        }

		char sItem[64];
		GetEdictClassname(iWeapon, sItem, sizeof(sItem));
		if (StrEqual(sItem, "weapon_awp") || StrEqual(sItem, "weapon_ssg08")) {
			SetEntDataFloat(iWeapon, m_flNextSecondaryAttack, GetGameTime() + 9999.9);
		}
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int iVictim, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType)
{
    if (g_bNoKnifeDamage != false) {
        return Plugin_Continue;
    }

    if (iVictim != iAttacker && IsValidClient(iAttacker)) {
        if (GetClientTeam(iVictim) != GetClientTeam(iAttacker)) {
            if (iDamageType != 32) {
                char sWeapon[255];
                GetClientWeapon(iAttacker, sWeapon, sizeof(sWeapon));
                if (StrContains(sWeapon, "knife") != -1 || StrContains(sWeapon, "bayonet") != -1) {
                    if (g_bNormalKnifeDamage == true) {
                        return Plugin_Continue;
                    }
                    if (fDamage <= 30.0) {
                        // Left-Click
                        fDamage = 15.0;
                    } else if((fDamage > 30.0) && (fDamage <= 100.0)) {
                        // Backstab
                        fDamage = 35.0;
                    } else {
                        // Backstab
                        fDamage = 35.0;
                    }
                    return Plugin_Changed;
                }
            }
        }
    }

	return Plugin_Continue;
}

public Action OnTakeDamageAlive(int iVictim, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType, int &iWeapon, float fDamageForce[3], float fDamagePosition[3])
{
	if (g_bNoKnifeDamage == false) {
		return Plugin_Continue;
	}

	if (!IsValidEntity(iWeapon)) {
		return Plugin_Continue;
	}

	if (iAttacker <= 0 || iAttacker > MaxClients) {
		return Plugin_Continue;
	}

	if (iVictim <= 0 || iVictim > MaxClients) {
		return Plugin_Continue;
	}

	char sWeaponName[64];
	GetEntityClassname(iWeapon, sWeaponName, sizeof(sWeaponName));
	if (StrContains(sWeaponName, "knife", false) != -1 || StrContains(sWeaponName, "bayonet", false) != -1 || StrContains(sWeaponName, "fists", false) != -1 || StrContains(sWeaponName, "axe", false) != -1 || StrContains(sWeaponName, "hammer", false) != -1 || StrContains(sWeaponName, "spanner", false) != -1 || StrContains(sWeaponName, "melee", false) != -1) {
        g_PlayerData[iVictim].fStamina = GetEntPropFloat(iVictim, Prop_Send, "m_flStamina");
		PrintHintText(iAttacker, "Knife damage is disabled in this round.");
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void OnTakeDamagePost(int iClient, int iAttacker, int iInflictor, float fDamage, int iDamageType)
{
    if (g_bNoKnifeDamage == false) {
        return;
    }

    if(iClient != iAttacker && IsValidClient(iAttacker)) {
        if(iDamageType != 32) {
            char sWeaponName[255];
            GetClientWeapon(iAttacker, sWeaponName, sizeof(sWeaponName));
            if(StrContains(sWeaponName, "knife") != -1 || StrContains(sWeaponName, "taser") != -1 || StrContains(sWeaponName, "bayonet") != -1) {
                SetEntPropFloat(iClient, Prop_Send, "m_flVelocityModifier", 1.0);
                SetEntPropFloat(iClient, Prop_Send, "m_flStamina", g_PlayerData[iClient].fStamina);
            }
        }
    }
}