public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if(convar == g_cvDrawAnimation)
    {
        g_cvDrawAnimation.SetInt(StringToInt(newValue));
    }
    else if(convar == g_cvDangerZoneKnives)
    {
        g_cvDangerZoneKnives.SetInt(StringToInt(newValue));
    }
    else if(convar == g_cvSelectTeamMode)
    {
        g_cvSelectTeamMode.SetInt(StringToInt(newValue));
    }
    else if(convar == g_cvForceFullUpdate)
    {
        g_cvForceFullUpdate.SetInt(StringToInt(newValue));
    }
}