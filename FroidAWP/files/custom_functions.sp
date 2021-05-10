public void RandomRound(int iRoundMode)
{
    switch(iRoundMode)
    {
        case 1:
        {
            PrintNotification("1HP Decoy + Bhop Disabled + No Knife Damage");
            ServerCommand("sv_infinite_ammo 1");
            DisabledBhop();
            g_bNoKnifeDamage = true;
            g_bNades = true;
        }
        case 2:
        {
            PrintNotification("Scout + Bhop Enabled");
            EnabledBhop();
        }
        case 3:
        {
            PrintNotification("Autosniper + Bhop Disabled");
            DisabledBhop();
        }
        case 4:
        {
            PrintNotification("AWP Noscope + Bhop Enabled + No Knife Damage");
            EnabledBhop();
            ServerCommand("sv_infinite_ammo 2");
            g_bNoKnifeDamage = true;
            g_bNoScope = true;
        }
        case 5:
        {
            PrintNotification("Deagle + Bhop Disabled");
            DisabledBhop();
        }
        case 6:
        {
            PrintNotification("Knife + Zeus + Bhop Enabled");
            EnabledBhop();
            g_bNormalKnifeDamage = true;
        }
        case 7:
        {
            PrintNotification("MAG-7 + Bhop Enabled + No Knife Damage");
            EnabledBhop();
            ServerCommand("sv_infinite_ammo 2");
            g_bNoKnifeDamage = true;
        }
    }
}

public void GiveWeapon(int iClient)
{
    Client_RemoveAllWeapons(iClient);
    GivePlayerItem(iClient, "weapon_knife");
    if (g_iRoundCount == 5) {
        //Special Rounds
        switch(g_iRoundMode)
        {
            case 1:
            {
                // Decoy Rounds + 1 HP + no bhop + no armor
                PTaH_GivePlayerItem(iClient, "weapon_decoy");
                SetEntProp(iClient, Prop_Send, "m_iHealth", 1);
                SetEntProp(iClient, Prop_Send, "m_ArmorValue", 0);
                SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 0);
            }
            case 2:
            {
                // Scout round + bhop
                PTaH_GivePlayerItem(iClient, "weapon_ssg08");
                SetEntProp(iClient, Prop_Send, "m_iHealth", 100);
                SetEntProp(iClient, Prop_Send, "m_ArmorValue", 100);
                SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
            }
            case 3:
            {
                // auto sniper round + no bhop
                PTaH_GivePlayerItem(iClient, "weapon_scar20");
                SetEntProp(iClient, Prop_Send, "m_iHealth", 100);
                SetEntProp(iClient, Prop_Send, "m_ArmorValue", 100);
                SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
            }
            case 4:
            {
                // awp bhop + noscoped
                PTaH_GivePlayerItem(iClient, "weapon_awp");
                SetEntProp(iClient, Prop_Send, "m_iHealth", 100);
                SetEntProp(iClient, Prop_Send, "m_ArmorValue", 100);
                SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
            }
            case 5:
            {
                // deagle round + no bhop
                PTaH_GivePlayerItem(iClient, "weapon_deagle");
                SetEntProp(iClient, Prop_Send, "m_iHealth", 100);
                SetEntProp(iClient, Prop_Send, "m_ArmorValue", 100);
                SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
            }
            case 6:
            {
                // Knife + Zeus + Bhop
                PTaH_GivePlayerItem(iClient, "weapon_taser");
                SetEntProp(iClient, Prop_Send, "m_iHealth", 100);
                SetEntProp(iClient, Prop_Send, "m_ArmorValue", 100);
                SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
            }
            case 7:
            {
                // MAG7
                PTaH_GivePlayerItem(iClient, "weapon_mag7");
                SetEntProp(iClient, Prop_Send, "m_iHealth", 100);
                SetEntProp(iClient, Prop_Send, "m_ArmorValue", 100);
                SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
            }
        }
    }else{
        // Normal Rounds
        // AWP Rounds
        PTaH_GivePlayerItem(iClient, "weapon_awp");
        SetEntProp(iClient, Prop_Send, "m_iHealth", 100);
        SetEntProp(iClient, Prop_Send, "m_ArmorValue", 100);
        SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
    }
}

public void PrintNotification(const char[] sName)
{
    for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;

        CPrintToChat(i, "%s Mode : {lightred}%s", PREFIX, sName);
		PrintHintText(i, "\n\t<font class='fontSize-l' color='#00FF00'>»</font><font class='fontSize-xl'><b>%s</b></font><font class='fontSize-l' color='#00FF00'>«</font>", sName);
	}
}

public void EnabledBhop()
{
    ServerCommand("sv_autobunnyhopping 1");
    ServerCommand("sv_enablebunnyhopping 1");
    ServerCommand("sv_staminajumpcost 0");
    ServerCommand("sv_staminalandcost 0");
    ServerCommand("sv_staminamax 0");
    ServerCommand("sv_staminarecoveryrate 0");
    ServerCommand("sv_airaccelerate 2000");
}

public void DisabledBhop()
{
    ServerCommand("sv_autobunnyhopping 0");
    ServerCommand("sv_enablebunnyhopping 0");
    ServerCommand("sv_staminajumpcost .080");
    ServerCommand("sv_staminalandcost .050");
    ServerCommand("sv_staminamax 80");
    ServerCommand("sv_staminarecoveryrate 60");
    ServerCommand("sv_airaccelerate 12");
}

public void RemoveRagdoll(int iClient)
{
    if (IsValidEdict(iClient))
    {
        int ragdoll = GetEntPropEnt(iClient, Prop_Send, "m_hRagdoll");
        if (ragdoll != -1) {
            AcceptEntityInput(ragdoll, "Kill");
        }
    }
}