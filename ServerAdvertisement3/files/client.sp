stock bool IsValidClient(int client, bool alive = false)
{
    if(0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
    {
        return true;
    }
    return false;
}
stock bool IsPlayerAdmin(int client)
{
    return CheckCommandAccess(client, "sm_admin_flag", ADMFLAG_GENERIC);
}
stock bool IsPlayerVIP(int client)
{
    return CheckCommandAccess(client, "sm_admin_flag", ADMFLAG_GENERIC) && CheckCommandAccess(client, "sm_admin_reservation_flag", ADMFLAG_RESERVATION);
}
