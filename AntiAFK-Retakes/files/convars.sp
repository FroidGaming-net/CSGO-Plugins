public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if(convar == g_cvCheckInterval)
    {
        g_cvCheckInterval.SetFloat(StringToFloat(newValue));
    }
    else if(convar == g_cvAfkState[0])
    {
        g_cvAfkState[0].SetFloat(StringToFloat(newValue));
    }
    else if(convar == g_cvAfkState[1])
    {
        g_cvAfkState[1].SetFloat(StringToFloat(newValue));
    }
    else if(convar == g_cvAfkState[2])
    {
        g_cvAfkState[2].SetFloat(StringToFloat(newValue));
    }
    else if(convar == g_cvAfkState[3])
    {
        g_cvAfkState[3].SetFloat(StringToFloat(newValue));
    }
    else if(convar == g_cvDropBomb)
    {
        g_cvDropBomb.SetInt(StringToInt(newValue));
    }
    else if(convar == g_cvMidgame)
    {
        g_cvMidgame.SetFloat(StringToFloat(newValue));
    }
    else if(convar == g_cvMidgameMult)
    {
        g_cvMidgameMult.SetFloat(StringToFloat(newValue));
    }
    else if(convar == g_cvKick)
    {
        g_cvKick.SetInt(StringToInt(newValue));
    }
    else if(convar == g_cvSpec)
    {
        g_cvSpec.SetInt(StringToInt(newValue));
    }
    else if(convar == g_cvTeam)
    {
        g_cvTeam.SetInt(StringToInt(newValue));
    }
    else if(convar == g_cvDebug)
    {
        g_cvDebug.SetInt(StringToInt(newValue));
    }
}