stock char GetMaskModelFromId(int iIndex)
{
	char sModel[PLATFORM_MAX_PATH];
	switch(iIndex)
	{
		case 0:
		{
			Format(sModel, sizeof(sModel), "");
		}
		case 1:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/porcelain_doll.mdl");
		}
		case 2:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_zombie_fortune_plastic.mdl");
		}
		case 3:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_wolf.mdl");
		}
		case 4:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tiki.mdl");
		}
		case 5:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tf2_spy_model.mdl");
		}
		case 6:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tf2_soldier_model.mdl");
		}
		case 7:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tf2_sniper_model.mdl");
		}
		case 8:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tf2_scout_model.mdl");
		}
		case 9:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tf2_pyro_model.mdl");
		}
		case 10:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tf2_medic_model.mdl");
		}
		case 11:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tf2_heavy_model.mdl");
		}
		case 12:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tf2_engi_model.mdl");
		}
		case 13:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_tf2_demo_model.mdl");
		}
		case 14:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_skull.mdl");
		}
		case 15:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_sheep_model.mdl");
		}
		case 16:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_sheep_bloody.mdl");
		}
		case 17:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_samurai.mdl");
		}
		case 18:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_pumpkin.mdl");
		}
		case 19:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_porcelain_doll_kabuki.mdl");
		}
		case 20:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_hoxton.mdl");
		}
		case 21:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_devil_plastic.mdl");
		}
		case 22:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_dallas.mdl");
		}
		case 23:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_chains.mdl");
		}
		case 24:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_bunny.mdl");
		}
		case 25:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_boar.mdl");
		}
		case 26:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_anaglyph.mdl");
		}
		case 27:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/evil_clown.mdl");
		}
		case 28:
		{
			Format(sModel, sizeof(sModel), "models/player/holiday/facemasks/facemask_battlemask.mdl");
		}
		default:
		{
			Format(sModel, sizeof(sModel), "");
		}
	}

	return sModel;
}

public MRESReturn SetModel(int iClient, Handle hParams)
{
	if(hTimers[iClient] != INVALID_HANDLE)
	{
		return MRES_Ignored;
	} else {
        hTimers[iClient] = CreateTimer(2.5, ReHats, iClient);
    }

	return MRES_Ignored;
}

public Action ReHats(Handle hTimer, int iClient)
{
	if(IsClientInGame(iClient))
	{
		RemoveHat(iClient);
		CreateHat(iClient);
	}
	
	hTimers[iClient] = INVALID_HANDLE;
}

void CreateHat(int iClient)
{	
	if (!IsValidClient(iClient, true)) {
        return;
    }

    if (g_PlayerData[iClient].iHatNumber == 0) {
        return;
    }
	
	float m_fHatOrigin[3], m_fHatAngles[3], m_fForward[3], m_fRight[3], m_fUp[3], m_fOffset[3];

	GetClientAbsOrigin(iClient, m_fHatOrigin);
	GetClientAbsAngles(iClient, m_fHatAngles);

    float m_fTemp[3] = { 0.000000, 0.000000, 0.000000 };

    m_fHatAngles[0] += m_fTemp[0];
    m_fHatAngles[1] += m_fTemp[1];
    m_fHatAngles[2] += m_fTemp[2];

    m_fOffset[0] = m_fTemp[0];
    m_fOffset[1] = m_fTemp[1];
    m_fOffset[2] = m_fTemp[2];

	GetAngleVectors(m_fHatAngles, m_fForward, m_fRight, m_fUp);

	m_fHatOrigin[0] += m_fRight[0]*m_fOffset[0]+m_fForward[0]*m_fOffset[1]+m_fUp[0]*m_fOffset[2];
	m_fHatOrigin[1] += m_fRight[1]*m_fOffset[0]+m_fForward[1]*m_fOffset[1]+m_fUp[1]*m_fOffset[2];
	m_fHatOrigin[2] += m_fRight[2]*m_fOffset[0]+m_fForward[2]*m_fOffset[1]+m_fUp[2]*m_fOffset[2];
	
	int m_iEnt = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(m_iEnt, "model", GetMaskModelFromId(g_PlayerData[iClient].iHatNumber));
	DispatchKeyValue(m_iEnt, "spawnflags", "256");
	DispatchKeyValue(m_iEnt, "solid", "0");
	SetEntPropEnt(m_iEnt, Prop_Send, "m_hOwnerEntity", iClient);
	
	// if(g_eHats[g_Elegido[client]][bBonemerge]) Bonemerge(m_iEnt);

	DispatchSpawn(m_iEnt);	
	AcceptEntityInput(m_iEnt, "TurnOn", m_iEnt, m_iEnt, 0);
	
	g_PlayerData[iClient].iHat = EntIndexToEntRef(m_iEnt);
	
	// if(g_eHats[g_Elegido[client]][bHide]) SDKHook(m_iEnt, SDKHook_SetTransmit, ShouldHide);
	SDKHook(m_iEnt, SDKHook_SetTransmit, ShouldHide);
	
	TeleportEntity(m_iEnt, m_fHatOrigin, m_fHatAngles, NULL_VECTOR); 

	SetVariantString("!activator");
	AcceptEntityInput(m_iEnt, "SetParent", iClient, m_iEnt, 0);
	SetVariantString("facemask");
	AcceptEntityInput(m_iEnt, "SetParentAttachmentMaintainOffset", m_iEnt, m_iEnt, 0);	
}

public void Bonemerge(int iEnt)
{
	int m_iEntEffects = GetEntProp(iEnt, Prop_Send, "m_fEffects"); 
	m_iEntEffects &= ~32;
	m_iEntEffects |= 1;
	m_iEntEffects |= 128;
	SetEntProp(iEnt, Prop_Send, "m_fEffects", m_iEntEffects); 
}

public Action ShouldHide(int iEnt, int iClient)
{
	int iOwner = GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity");
	if (iOwner == iClient) {
		if (g_PlayerData[iClient].bViewing) {
            return Plugin_Continue;
        }
		
		return Plugin_Handled;
	}

	if (GetEntProp(iClient, Prop_Send, "m_iObserverMode") == 4) {
		if (iOwner == GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget")) {
			return Plugin_Handled;
		}
	}
	
	if (IsClientSourceTV(iClient)) {
        return Plugin_Handled;
    }
	
	return Plugin_Continue;
}

public void RemoveHat(int iClient)
{
	int iEntity = EntRefToEntIndex(g_PlayerData[iClient].iHat);
	if (iEntity != INVALID_ENT_REFERENCE && IsValidEdict(iEntity) && iEntity != 0) {
        // HIDE_IN_FIRSTPERSON
        SDKUnhook(iEntity, SDKHook_SetTransmit, ShouldHide);
        // HIDE_IN_FIRSTPERSON
		AcceptEntityInput(iEntity, "Kill");
		g_PlayerData[iClient].iHat = INVALID_ENT_REFERENCE;
	}
}

stock void SetThirdPersonView(int iClient, bool bThird)
{
	if (!IsPlayerAlive(iClient)) {
		return;
	}
	
	if (bThird) {
		
		SetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget", 0); 
		SetEntProp(iClient, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(iClient, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(iClient, Prop_Send, "m_iFOV", 120);
		SendConVarValue(iClient, mp_forcecamera, "1");
		
		SetEntProp(iClient, Prop_Send, "m_iHideHUD", GetEntProp(iClient, Prop_Send, "m_iHideHUD") | HIDE_RADAR_CSGO);
		SetEntProp(iClient, Prop_Send, "m_iHideHUD", GetEntProp(iClient, Prop_Send, "m_iHideHUD") | HIDE_CROSSHAIR_CSGO);
	} else {
		SetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget", -1);
		SetEntProp(iClient, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(iClient, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(iClient, Prop_Send, "m_iFOV", 90);
		char sValor[6];
		GetConVarString(mp_forcecamera, sValor, 6);
		SendConVarValue(iClient, mp_forcecamera, sValor);
		
		SetEntProp(iClient, Prop_Send, "m_iHideHUD", GetEntProp(iClient, Prop_Send, "m_iHideHUD") & ~HIDE_RADAR_CSGO);
		SetEntProp(iClient, Prop_Send, "m_iHideHUD", GetEntProp(iClient, Prop_Send, "m_iHideHUD") & ~HIDE_CROSSHAIR_CSGO);
	}
}

stock bool IsWarmup()
{
	return view_as<bool>(GameRules_GetProp("m_bWarmupPeriod"));
}