stock char GetAgentModelFromId(int index)
{
	char model[PLATFORM_MAX_PATH];
	switch(index)
	{
		case 6:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_phoenix_varianth.mdl");
		}
		case 12:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_phoenix_variantg.mdl");
		}
		case 5:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_phoenix_variantf.mdl");
		}
		case 17:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_leet_varianti.mdl");
		}
		case 4:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_leet_variantg.mdl");
		}
		case 11:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_leet_varianth.mdl");
		}
		case 14:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_balkan_variantj.mdl");
		}
		case 9:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_balkan_varianti.mdl");
		}
		case 21:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_balkan_varianth.mdl");
		}					
		case 18:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_balkan_variantg.mdl");
		}
		case 22:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_leet_variantf.mdl");
		}
		case 13:
		{ 
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_balkan_variantf.mdl");
		}
		case 16:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_st6_variantm.mdl");
		}
		case 19:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_st6_varianti.mdl");
		}
		case 10:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_st6_variantg.mdl");
		}
		case 7:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantf.mdl");
		}
		case 15:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_fbi_varianth.mdl");
		}
		case 8:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_fbi_variantg.mdl");
		}
		case 20:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_fbi_variantb.mdl");
		}
		case 3:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_fbi_variantf.mdl");
		}
		case 1:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_st6_variante.mdl");
		}
		case 2:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_st6_variantk.mdl");
		}
		case 23:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_swat_variantj.mdl");
		}
		case 24:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_swat_varianth.mdl");
		}
		case 25:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_phoenix_varianti.mdl");
		}
		case 26:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_balkan_variantl.mdl");
		}
		case 27:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_swat_varianti.mdl");
		}
		case 28:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_swat_variantg.mdl");
		}
		case 29:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_st6_variantj.mdl");
		}
		case 30:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_professional_varj.mdl");
		}
		case 31:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_professional_varh.mdl");
		}
		case 32:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_st6_variantl.mdl");
		}
		case 33:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_swat_variantf.mdl");
		}
		case 34:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_balkan_variantk.mdl");
		}
		case 35:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_professional_vari.mdl");
		}
		case 36:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_professional_varg.mdl");
		}
		case 37:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_swat_variante.mdl");
		}
		case 38:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_professional_varf.mdl");
		}
		case 39:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_professional_varf1.mdl");
		}
		case 40:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_professional_varf2.mdl");
		}
		case 41:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_professional_varf3.mdl");
		}
		case 42:
		{
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_professional_varf4.mdl");
		}
		default:
		{
			Format(model, sizeof(model), "");
		}
	}

	return model;
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