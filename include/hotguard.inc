#if defined _hotguard_included_
  #endinput
#endif
#define _hotguard_included_

/**
 *  Called after the player gets banned.
 *
 *  @note You get the data after the player is penalized..
 *	@param iClient		The index of the player.
 *	@param iTime		Bantime.
 *	@param szReason		Reason for ban.
 *
 *
*/
forward void HG_WhenPlayerPunished(int iClient, int iTime, const char[] szReason);

public SharedPlugin __pl_hotguard =
{
	name = "hotguard_4.0",
	file = "hotguard_4.0.smx",
    required = 0
};
