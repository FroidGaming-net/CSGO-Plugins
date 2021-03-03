public Action OnClientSayCommand(int iClient, const char[] sCommand, const char[] iArgs)
{
	static char sCommands[][] = {"weapons", "!weapons", ".weapons", "weapon", ".weapon", "buy", "!buy", ".buy"};

	for (int i = 0; i < sizeof(sCommands); i++)
	{
		if (strcmp(iArgs[0], sCommands[i], false) == 0)
		{
			MenuTeam(iClient);

			break;
		}
	}

	return Plugin_Continue;
}

public void Retakes_OnGunsCommand(int iClient)
{
	if (!IsValidClient(iClient)) {
        return;
    }

	MenuTeam(iClient);
}

void SetRoundType(int type)
{
	if (type == FORCE_ROUND)
	{
		g_iRoundType = FORCE_ROUND;
		Format(g_sRoundType, sizeof(g_sRoundType), "Force Buy Round");
	}
	else if (type == FULL_ROUND)
	{
		g_iRoundType = FULL_ROUND;
		Format(g_sRoundType, sizeof(g_sRoundType), "Full Buy Round");
	}
	else if (type == PISTOL_ROUND)
	{
		g_iRoundType = PISTOL_ROUND;
		Format(g_sRoundType, sizeof(g_sRoundType), "Pistol Round");
	}

	EquipAllPlayerWeapon();
}


void EquipAllPlayerWeapon()
{
	g_iHEgrenade_CT = 0;
	g_iHEgrenade_T = 0;
	g_iFlashbang_CT = 0;
	g_iFlashbang_T = 0;
	g_iSmokegrenade_CT = 0;
	g_iSmokegrenade_T = 0;
	g_iMolotov_CT = 0;
	g_iMolotov_T = 0;
	g_iDeagle_CT = 0;
	g_iDeagle_T = 0;
	g_iAWP_CT = 0;
	g_iAWP_CT_Premium = 0;
	g_iAWP_T = 0;
	g_iAWP_T_Premium = 0;
	g_iScout_CT = 0;
	g_iScout_T = 0;

	ShowInfo();

	if(g_bChance){
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i))
            {
                continue;
            }

			if(CheckCommandAccess(i, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6))
            {
                EquipWeapons(i);
            }
		}
		g_bChance = false;
	}else{
		for (int i = MaxClients; i >= 1; i--)
		{
			if (!IsValidClient(i))
            {
                continue;
            }

			if(CheckCommandAccess(i, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6))
            {
                EquipWeapons(i);
            }
		}
		g_bChance = true;
	}
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
        {
            continue;
        }

		if(!CheckCommandAccess(i, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6))
        {
            EquipWeapons(i);
        }
	}
}

void EquipWeapons(int iClient)
{
    if (!IsValidClient(iClient))
    {
        return;
    }

    if (!Retakes_Live())
    {
        return;
    }

    int iMoney = 0;
	StripPlayerWeapons(iClient);

    SetEntProp(iClient, Prop_Send, "m_ArmorValue", 0);
	SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 0);
	SetEntProp(iClient, Prop_Send, "m_bHasDefuser", 0);

    if (g_iRoundType == FULL_ROUND)
	{
        // ============================
        // ====== FULL ROUND ==========
        // ============================
        iMoney = FULL_ROUND_MONEY;

        if (GetClientTeam(iClient) == CS_TEAM_CT) {
            int iRandom = RoundToNearest(GetRandomFloat(1.0, 5.0));

            if (CheckCommandAccess(iClient, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
				if (g_PlayerData[iClient].bAWP_CT && MIN_PLAYER_AWP_CT <= GetPlayerCount(CS_TEAM_CT)) {
					if (iRandom == 1 || iRandom == 2 || iRandom == 4) {
						if (g_iAWP_CT_Premium < 1) {
							GivePlayerItem(iClient, "weapon_awp");
							iMoney -= GetWeaponPrice("weapon_awp");
							g_iAWP_CT_Premium++;
						} else {
							GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_CT);
							iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_CT);
						}
					} else {
						GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_CT);
						iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_CT);
					}
				} else {
					GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_CT);
					iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_CT);
				}
            } else if(g_PlayerData[iClient].bAWP_CT && MIN_PLAYER_AWP_CT <= GetPlayerCount(CS_TEAM_CT)) {
				if (iRandom == 3) {
					if (g_iAWP_CT < 1) {
						GivePlayerItem(iClient, "weapon_awp");
						iMoney -= GetWeaponPrice("weapon_awp");
						g_iAWP_CT++;
					} else {
						GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_CT);
						iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_CT);
					}
				} else {
					GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_CT);
					iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_CT);
				}
            } else {
				GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_CT);
				iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_CT);
			}

			if (StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_deagle") || StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_revolver")) {
				if (iRandom == 1 || iRandom == 2 || iRandom == 4) {
					if (g_iDeagle_CT < 2) {
						GivePlayerItem(iClient, g_PlayerData[iClient].sSecondary_CT);
						iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSecondary_CT);
						g_iDeagle_CT++;
					} else {
						if (StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_hkp2000")) {
							GivePlayerItem(iClient, "weapon_hkp2000");
						} else {
							GivePlayerItem(iClient, "weapon_usp_silencer");
						}
					}
				} else {
					if (StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_hkp2000")) {
						GivePlayerItem(iClient, "weapon_hkp2000");
					} else {
						GivePlayerItem(iClient, "weapon_usp_silencer");
					}
				}
			} else {
				GivePlayerItem(iClient, g_PlayerData[iClient].sSecondary_CT);
			}
        } else if (GetClientTeam(iClient) == CS_TEAM_T) {
            int iRandom = RoundToNearest(GetRandomFloat(1.0, 5.0));

            if (CheckCommandAccess(iClient, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
				if (g_PlayerData[iClient].bAWP_T && MIN_PLAYER_AWP_T <= GetPlayerCount(CS_TEAM_T)) {
                    if (iRandom == 1 || iRandom == 2 || iRandom == 4) {
						if (g_iAWP_T_Premium < 1) {
							GivePlayerItem(iClient, "weapon_awp");
							iMoney -= GetWeaponPrice("weapon_awp");
							g_iAWP_T_Premium++;
						} else {
							GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_T);
                            iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_T);
						}
					} else {
						GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_T);
                        iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_T);
					}
				}
				else
				{
					GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_T);
                    iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_T);
				}
            }else if(g_PlayerData[iClient].bAWP_T && MIN_PLAYER_AWP_T <= GetPlayerCount(CS_TEAM_T)) {
				if (iRandom == 3) {
					if (g_iAWP_T < 1) {
                        GivePlayerItem(iClient, "weapon_awp");
						iMoney -= GetWeaponPrice("weapon_awp");
						g_iAWP_T++;
					} else {
                        GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_T);
                        iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_T);
					}
				} else {
                    GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_T);
                    iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_T);
				}
			} else {
				GivePlayerItem(iClient, g_PlayerData[iClient].sPrimary_T);
				iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPrimary_T);
			}

			if (StrEqual(g_PlayerData[iClient].sSecondary_T, "weapon_deagle") || StrEqual(g_PlayerData[iClient].sSecondary_T, "weapon_revolver")) {
				if (iRandom == 1 || iRandom == 2 || iRandom == 4) {
					if (g_iDeagle_T < 2) {
						GivePlayerItem(iClient, g_PlayerData[iClient].sSecondary_T);
						iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSecondary_T);
						g_iDeagle_T++;
					} else {
						GivePlayerItem(iClient, "weapon_glock");
					}
				} else {
					GivePlayerItem(iClient, "weapon_glock");
				}
			} else {
				GivePlayerItem(iClient, g_PlayerData[iClient].sSecondary_T);
			}
		}
    } else if (g_iRoundType == PISTOL_ROUND) {
        // ============================
        // ====== PISTOL_ROUND ========
        // ============================
        iMoney = PISTOL_ROUND_MONEY;

		if (GetClientTeam(iClient) == CS_TEAM_CT) {
			GivePlayerItem(iClient, g_PlayerData[iClient].sPistolRound_CT);
			iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPistolRound_CT);
		} else if (GetClientTeam(iClient) == CS_TEAM_T) {
			GivePlayerItem(iClient, g_PlayerData[iClient].sPistolRound_T);
			iMoney -= GetWeaponPrice(g_PlayerData[iClient].sPistolRound_T);
		}
    } else if (g_iRoundType == FORCE_ROUND) {
        // ============================
        // ===== FORCE BUY ROUND ======
        // ============================
        iMoney = FORCEBUY_ROUND_MONEY;

        if (GetClientTeam(iClient) == CS_TEAM_CT) {
            int iRandom = RoundToNearest(GetRandomFloat(1.0, 5.0));

			if (CheckCommandAccess(iClient, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
				if (g_PlayerData[iClient].bScout_CT && MIN_PLAYER_SCOUT_CT <= GetPlayerCount(CS_TEAM_CT)) {
					if (g_iScout_CT < 1) {
						if (iRandom == 1 || iRandom == 2 || iRandom == 4) {
							GivePlayerItem(iClient, "weapon_ssg08");
							iMoney -= GetWeaponPrice("weapon_ssg08");
							g_iScout_CT++;
						} else {
							GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_CT);
							iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_CT);
						}
					} else {
						GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_CT);
						iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_CT);
					}
				} else {
					GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_CT);
					iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_CT);
				}
			} else if(g_PlayerData[iClient].bScout_CT && MIN_PLAYER_SCOUT_CT <= GetPlayerCount(CS_TEAM_CT)) {
				if (g_iScout_CT < 1) {
					if(iRandom == 3){
						GivePlayerItem(iClient, "weapon_ssg08");
						iMoney -= GetWeaponPrice("weapon_ssg08");
						g_iScout_CT++;
					} else {
						GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_CT);
						iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_CT);
					}
				} else {
					GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_CT);
					iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_CT);
				}
			} else {
				GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_CT);
				iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_CT);
			}

			if (StrEqual(g_PlayerData[iClient].sSecondary_CT, "weapon_hkp2000")) {
				GivePlayerItem(iClient, "weapon_hkp2000");
			} else {
				GivePlayerItem(iClient, "weapon_usp_silencer");
			}
		} else if (GetClientTeam(iClient) == CS_TEAM_T) {
            int iRandom = RoundToNearest(GetRandomFloat(1.0, 5.0));

			if (CheckCommandAccess(iClient, "sm_froidapp_premiumplus", ADMFLAG_CUSTOM6)) {
				if (g_PlayerData[iClient].bScout_T && MIN_PLAYER_SCOUT_T <= GetPlayerCount(CS_TEAM_T)) {
					if (g_iScout_T < 1) {
						if (iRandom == 1 || iRandom == 2 || iRandom == 4) {
							GivePlayerItem(iClient, "weapon_ssg08");
							iMoney -= GetWeaponPrice("weapon_ssg08");
							g_iScout_T++;
						} else {
							GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_T);
							iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_T);
						}
					} else {
						GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_T);
						iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_T);
					}
				} else {
					GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_T);
					iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_T);
				}
			} else if(g_PlayerData[iClient].bScout_T && MIN_PLAYER_SCOUT_T <= GetPlayerCount(CS_TEAM_T)) {
				if (g_iScout_T < 1) {
					if  (iRandom == 3) {
						GivePlayerItem(iClient, "weapon_ssg08");
						iMoney -= GetWeaponPrice("weapon_ssg08");
						g_iScout_T++;
					} else {
						GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_T);
						iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_T);
					}
				} else {
					GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_T);
					iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_T);
				}
			} else {
				GivePlayerItem(iClient, g_PlayerData[iClient].sSMG_T);
				iMoney -= GetWeaponPrice(g_PlayerData[iClient].sSMG_T);
			}

			GivePlayerItem(iClient, "weapon_glock");
		}
    }

	int	iOrder = RoundToNearest(GetRandomFloat(1.0, 2.0));

	if (iOrder == 1) {
		GiveNades(iClient, iMoney, iOrder);
	} else {
		GiveArmorKit(iClient, iMoney, iOrder);
	}
}


void GiveArmorKit(int client, int money, int order)
{
	if (money >= 1000) {
		SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
		money -= 1000;
	} else if (money >= 650) {
		SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
		money -= 650;
	}

	if (GetClientTeam(client) == CS_TEAM_CT && (money >= 400)) {
		SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
		money -= 400;
	}

	if (order == 2) {
		GiveNades(client, money, order);
	}
}

void GiveNades(int client, int money, int order)
{
    int	iRandom = RoundToNearest(GetRandomFloat(1.0, 4.0));

	if (GetClientTeam(client) == CS_TEAM_T)
	{
		GivePlayerItem(client, "weapon_knife_t");

		if (iRandom == 1) {
			if (g_iMolotov_T < 1 && money >= 400) {
				GivePlayerItem(client, "weapon_molotov");
				money -= GetWeaponPrice("weapon_molotov");
				g_iMolotov_T++;
			} else {
				iRandom = GetRandomInt(2, 4);
			}
		} else if (iRandom == 2) {
			if (g_iSmokegrenade_T < 1 && money >= 300)
			{
				GivePlayerItem(client, "weapon_smokegrenade");
				money -= GetWeaponPrice("weapon_smokegrenade");
				g_iSmokegrenade_T++;
			}
			else
			{
				iRandom = GetRandomInt(3, 4);
			}
		} else if (iRandom == 3) {
			if (g_iHEgrenade_T < 1 && money >= 300)
			{
				GivePlayerItem(client, "weapon_hegrenade");
				money -= GetWeaponPrice("weapon_hegrenade");
				g_iHEgrenade_T++;
			}
			else
			{
				iRandom = 4;
			}
		} else if (iRandom == 4) {
			if (g_iFlashbang_T < 1 && money >= 200) {
				GivePlayerItem(client, "weapon_flashbang");
				money -= GetWeaponPrice("weapon_flashbang");
				g_iFlashbang_T++;
			}
		}
	} else if (GetClientTeam(client) == CS_TEAM_CT) {
		GivePlayerItem(client, "weapon_knife");

		if (iRandom == 1) {
			if (g_iMolotov_CT < 1 && money >= 600) {
				GivePlayerItem(client, "weapon_incgrenade");
				money -= GetWeaponPrice("weapon_incgrenade");
				g_iMolotov_CT++;
			} else {
				iRandom = GetRandomInt(2, 4);
			}
		} else if (iRandom == 2) {
			if (g_iSmokegrenade_CT < 1 && money >= 300) {
				GivePlayerItem(client, "weapon_smokegrenade");
				money -= GetWeaponPrice("weapon_smokegrenade");
				g_iSmokegrenade_CT++;
			} else {
				iRandom = GetRandomInt(3, 4);
			}
		} else if (iRandom == 3) {
			if (g_iHEgrenade_CT < 1 && money >= 300) {
				GivePlayerItem(client, "weapon_hegrenade");
				money -= GetWeaponPrice("weapon_hegrenade");
				g_iHEgrenade_CT++;
			} else {
				iRandom = 4;
			}
		} else if (iRandom == 4) {
			if (g_iFlashbang_CT < 2 && money >= 200) {
				GivePlayerItem(client, "weapon_flashbang");
				money -= GetWeaponPrice("weapon_flashbang");
				g_iFlashbang_CT++;
			}
		}
	}

	if (order == 1)
	{
		GiveArmorKit(client, money, order);
	}
}

void ShowInfo()
{
	Retakes_MessageToAll("Now is: %s", g_sRoundType);

	Bombsite site = Retakes_GetCurrrentBombsite();

	if (site == BombsiteA) {
        Format(g_sBombSite, sizeof(g_sBombSite), "A-A-A");
    } else if (site == BombsiteB) {
        Format(g_sBombSite, sizeof(g_sBombSite), "B-B-B");
    }

	CreateTimer (0.7, Timer_ShowInfo);
}

public Action Timer_ShowInfo(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;

		PrintHintText(i, "<font face='Arial' size='20'>%s on bombsite: </font>\n\t<font face='Arial' color='#00FF00' size='40'>  <b>%s</b></font>", g_sRoundType, g_sBombSite);
	}
}

void StripPlayerWeapons(int iClient)
{
	int iWeapon;
	for (int i = 0; i <= 3; i++)
	{
		if ((iWeapon = GetPlayerWeaponSlot(iClient, i)) != -1)
		{
			RemovePlayerItem(iClient, iWeapon);
			AcceptEntityInput(iWeapon, "Kill");
		}
	}
	if ((iWeapon = GetPlayerWeaponSlot(iClient, CS_SLOT_GRENADE)) != -1)
	{
		RemovePlayerItem(iClient, iWeapon);
		AcceptEntityInput(iWeapon, "Kill");
	}
}

int GetPlayerCount(int team = -1)
{
	int i, iCount = 0;

	for (i = 1; i <= MaxClients; i++)
	{
        // Mungkin salah
		if (!IsValidClient(i))
        {
            continue;
        }

		if (team != -1 && GetClientTeam(i) != team)
        {
            continue;
        }

		iCount++;
	}

	return iCount;
}

int GetWeaponPrice(char[] weapon)
{
	if (StrEqual(weapon, "weapon_m4a1"))
		return 3100;

	else if (StrEqual(weapon, "weapon_m4a1_silencer"))
		return 3100;

	else if (StrEqual(weapon, "weapon_famas"))
		return 2250;

	else if (StrEqual(weapon, "weapon_aug"))
		return 3300;

	else if (StrEqual(weapon, "weapon_galilar"))
		return 2000;

	else if (StrEqual(weapon, "weapon_ak47"))
		return 2700;

	else if (StrEqual(weapon, "weapon_sg556"))
		return 2750;

	else if (StrEqual(weapon, "weapon_awp"))
		return 4750;

	else if (StrEqual(weapon, "weapon_ssg08"))
		return 1700;

	else if (StrEqual(weapon, "weapon_bizon"))
		return 1400;

	else if (StrEqual(weapon, "weapon_p90"))
		return 2350;

	else if (StrEqual(weapon, "weapon_ump45"))
		return 1200;

	else if (StrEqual(weapon, "weapon_mp5sd"))
		return 1500;

	else if (StrEqual(weapon, "weapon_mp7"))
		return 1500;

	else if (StrEqual(weapon, "weapon_mp9"))
		return 1250;

	else if (StrEqual(weapon, "weapon_mac10"))
		return 1050;

	else if (StrEqual(weapon, "weapon_deagle"))
		return 700;

	else if (StrEqual(weapon, "weapon_revolver"))
		return 700;

	else if (StrEqual(weapon, "weapon_cz75a"))
		return 500;

	else if (StrEqual(weapon, "weapon_p250"))
		return 300;

	else if (StrEqual(weapon, "weapon_tec9"))
		return 500;

	else if (StrEqual(weapon, "weapon_glock"))
		return 0;

	else if (StrEqual(weapon, "weapon_usp_silencer"))
		return 0;

	else if (StrEqual(weapon, "weapon_hkp2000"))
		return 0;

	else if (StrEqual(weapon, "weapon_fiveseven"))
		return 500;

	else if (StrEqual(weapon, "weapon_sawedoff"))
		return 1100;

	else if (StrEqual(weapon, "weapon_mag7"))
		return 1300;

	else if (StrEqual(weapon, "weapon_elite"))
		return 400;

	else if (StrEqual(weapon, "weapon_hegrenade"))
		return 300;

	else if (StrEqual(weapon, "weapon_flashbang"))
		return 200;

	else if (StrEqual(weapon, "weapon_smokegrenade"))
		return 300;

	else if (StrEqual(weapon, "weapon_molotov"))
		return 400;

	else if (StrEqual(weapon, "weapon_incgrenade"))
		return 650;

	return 0;
}

public Action Timer_Image(Handle hTimer, Handle dp)
{
    ResetPack(dp);
    int iClient = GetClientOfUserId(ReadPackCell(dp));
    char sUrlImage[256];
    ReadPackString(dp, sUrlImage, sizeof(sUrlImage));

	if (IsValidClient(iClient)) {
        PrintHintText(iClient, "<span><img src='file://{images_econ}/econ/weapons/base_weapons/%s.png'></span>", sUrlImage);
	}
}
