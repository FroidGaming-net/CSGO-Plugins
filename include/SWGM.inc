#if defined _SWGM_included
 #endinput
#endif
#define _SWGM_included

enum Status
{
	UNASSIGNED = 0,
	NO_GROUP,
	LEAVER,
	MEMBER,
	OFFICER
};

/**
 * Called when the client has been checked for a group.
 *
 * @param iClient Client index.
 * @param IsMember Client in group
 * @param IsOfficer Client Admin/Officer in group
 * @noreturn
*/
forward void SWGM_OnJoinGroup(int iClient, bool IsMember, bool IsOfficer);

/**
 * Called when the client is rechecked and has left the group.
 *
 * @param iClient Client index.
 * @noreturn
*/
forward void SWGM_OnLeaveGroup(int iClient);


/**
 * Checks the customer for availability in the group.
 *
 * @param iClient Client Index.
 * @return true if in group, otherwise false.
 * @error Client is not on server, is a bot or its index exceeds allowed limit.
 */
native bool SWGM_InGroup(int iClient);

/**
 * Checks for Administrator or Group Officer
 *
 * @param iClient Client Index.
 * @return true if in group, otherwise false.
 * @error Client is not on server, is a bot or its index exceeds allowed limit.
 */
native bool SWGM_InGroupOfficer(int iClient);

/**
 * Returns the client's status.
 *
 * @param iClient Client Index.
 * @return Status.
 * @error Client is not on server, is a bot or its index exceeds allowed limit.
 */
native Status SWGM_GetPlayerStatus(int iClient);

/**
 * Launches a client status check on the group.
 *
 * @param iClient Client index.
 * @error Client is not on the server, is a bot or its index exceeds the allowed limit.
 * @noreturn
 */
native void SWGM_CheckPlayer(int iClient);

/**
 * Checks if the client is loaded.
 *
 * @param iClient Client index.
 * @return true if loaded, otherwise fasle;
 * @error Index exceeds permissible limit.
 */
native bool SWGM_IsPlayerValidated(int iClient);

public SharedPlugin __pl_SWGM=
{
	name = "SWGM",
	file = "SWGM.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_SWGM_SetNTVOptional()
{
	MarkNativeAsOptional("SWGM_InGroup");
	MarkNativeAsOptional("SWGM_InGroupOfficer");
	MarkNativeAsOptional("SWGM_GetPlayerStatus");
	MarkNativeAsOptional("SWGM_CheckPlayer");
	MarkNativeAsOptional("SWGM_IsPlayerValidated");
}
#endif