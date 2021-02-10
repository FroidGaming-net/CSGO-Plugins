stock char GetAgentModelFromId(int iIndex, int iMode = 0)
{
	char sModel[PLATFORM_MAX_PATH];
	char sVoice[PLATFORM_MAX_PATH];
	switch(iIndex)
	{
		case 6:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_phoenix_varianth.mdl");
		}
		case 12:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_phoenix_variantg.mdl");
		}
		case 5:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_phoenix_variantf.mdl");
		}
		case 17:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_leet_varianti.mdl");
		}
		case 4:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_leet_variantg.mdl");
		}
		case 11:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_leet_varianth.mdl");
		}
		case 14:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_balkan_variantj.mdl");
		}
		case 9:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_balkan_varianti.mdl");
		}
		case 21:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_balkan_varianth.mdl");
            Format(sVoice, sizeof(sVoice), "balkan_epic");
		}					
		case 18:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_balkan_variantg.mdl");
		}
		case 22:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_leet_variantf.mdl");
            Format(sVoice, sizeof(sVoice), "leet_epic");
		}
		case 13:
		{ 
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_balkan_variantf.mdl");
		}
		case 16:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_st6_variantm.mdl");
		}
		case 19:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_st6_varianti.mdl");
            Format(sVoice, sizeof(sVoice), "seal_epic");
		}
		case 10:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_st6_variantg.mdl");
		}
		case 7:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_sas_variantf.mdl");
		}
		case 15:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_fbi_varianth.mdl");
		}
		case 8:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_fbi_variantg.mdl");
		}
		case 20:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_fbi_variantb.mdl");
            Format(sVoice, sizeof(sVoice), "fbihrt_epic");
		}
		case 3:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_fbi_variantf.mdl");
		}
		case 1:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_st6_variante.mdl");
		}
		case 2:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_st6_variantk.mdl");
            Format(sVoice, sizeof(sVoice), "ctm_gsg9");
		}
		case 23:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_swat_variantj.mdl");
		}
		case 24:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_swat_varianth.mdl");
		}
		case 25:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_phoenix_varianti.mdl");
		}
		case 26:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_balkan_variantl.mdl");
		}
		case 27:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_swat_varianti.mdl");
		}
		case 28:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_swat_variantg.mdl");
		}
		case 29:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_st6_variantj.mdl");
		}
		case 30:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_professional_varj.mdl");
            Format(sVoice, sizeof(sVoice), "professional_fem");
		}
		case 31:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_professional_varh.mdl");
		}
		case 32:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_st6_variantl.mdl");
		}
		case 33:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_swat_variantf.mdl");
            Format(sVoice, sizeof(sVoice), "swat_fem");
		}
		case 34:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_balkan_variantk.mdl");
		}
		case 35:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_professional_vari.mdl");
		}
		case 36:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_professional_varg.mdl");
            Format(sVoice, sizeof(sVoice), "professional_fem");
		}
		case 37:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/ctm_swat_variante.mdl");
            Format(sVoice, sizeof(sVoice), "swat_epic");
		}
		case 38:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_professional_varf.mdl");
            Format(sVoice, sizeof(sVoice), "professional_epic");
		}
		case 39:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_professional_varf1.mdl");
            Format(sVoice, sizeof(sVoice), "professional_epic");
		}
		case 40:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_professional_varf2.mdl");
            Format(sVoice, sizeof(sVoice), "professional_epic");
		}
		case 41:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_professional_varf3.mdl");
            Format(sVoice, sizeof(sVoice), "professional_epic");
		}
		case 42:
		{
			Format(sModel, sizeof(sModel), "models/player/custom_player/legacy/tm_professional_varf4.mdl");
            Format(sVoice, sizeof(sVoice), "professional_epic");
		}
		default:
		{
			Format(sModel, sizeof(sModel), "");
		}
	}

	if (iMode == 0) {
		return sModel;
	} else {
		return sVoice;
	}
}

stock int GetAgentModelTeam(int index)
{
	if(StrContains(GetAgentModelFromId(index), "models/player/custom_player/legacy/ctm") > -1 || index == -1)
	{
		// CT
		return 3;
	} else if(StrContains(GetAgentModelFromId(index), "models/player/custom_player/legacy/tm") > -1 || index == -2){
		// T
		return 2;
	}
	return 0;
}