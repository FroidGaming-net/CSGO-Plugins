#if defined _agent_chooser_included_
  #endinput
#endif
#define _agent_chooser_included_

/**
 * @param iClient           Client index.
 * @param iTeam             Team index.
 * @param sMessage          Message then after print to client chat if Plugin_Handled.
 *
 * @return                  Menu actions. Plugin_Handled for deny access.
 */
typedef AC_OpenMenu = function Action(int iClient, int iTeam, char sMessage[256]);

/**
 * @param iClient           Client index.
 * @param iTeam             Team index.
 * @param iSlot             Patch slot.
 * @param sMessage          Message then after print to client chat if Plugin_Handled.
 *
 * @return                  Menu actions. Plugin_Handled for deny access.
 */
typedef AC_OpenPatchMenu = function Action(int iClient, int iTeam, int iSlot, char sMessage[256]);

/**
 * Agent items
 *
 * @param iClient           Client index.
 * @param iTeam             Team index.
 * @param iAgentIndex       Agent definition index.
 * @param sWarning          Warning on item.
 *
 * @return                  Drawing style flags.
 */
typedef AC_AddItem = function int(int iClient, int iTeam, int iAgentIndex, char sWarning[256]);

/**
 * Patch items
 *
 * @param iClient           Client index.
 * @param iTeam             Team index.
 * @param iSlot             Patch slot.
 * @param iPatchIndex       Patch definition index.
 * @param sWarning          Warning on item.
 *
 * @return                  Drawing style flags.
 */
typedef AC_AddPatchItem = function int(int iClient, int iTeam, int iSlot, int iPatchIndex, char sWarning[256]);

/**
 * Called after the core is fully loaded for actions with.
 */
forward void AC_Load();

/**
 * Is the core loaded.
 *
 * @return                  Is loaded.
 */
native bool AC_IsLoaded();

/**
 * Returns the team agent definition index.
 *
 * @param sName             Feature name. Translation will be loaded.
 * @param funcOpenMenu      Open menu hook.
 * @param funcAddItem       Add item in menu hook.
 *
 * @noreturn
 */
native void AC_RegisterFeature(const char sName[] = NULL_STRING, AC_OpenMenu funcOpenMenu = INVALID_FUNCTION, AC_AddItem funcAddItem = INVALID_FUNCTION, AC_OpenPatchMenu funcOpenPatchMenu = INVALID_FUNCTION, AC_AddPatchItem funcAddPatchItem = INVALID_FUNCTION);

/**
 * Returns the cloned database handle. Must be closed.
 *
 * @return                  Database Handle.
 */
native Database AC_GetDatabase();

/**
 * Opens the main menu of agents.
 *
 * @param iClient           Client index.
 * @param iTeam             Team index.
 * @param iFirstSlot        Which slot to open the menu from.
 *
 * @noreturn
 */
native void AC_OpenMainMenu(int iClient, int iTeam = 2, int iFirstSlot = 0);

/**
 * Opens the patch menu of agents.
 *
 * @param iClient           Client index.
 * @param iTeam             Team index.
 * @param iSlot             Patch slot.
 * @param iFirstSlot        Which slot to open the menu from.
 *
 * @noreturn
 */
native void AC_OpenPatchMenu(int iClient, int iTeam, int iSlot, int iFirstSlot = 0);

/**
 * Sets the player in preview mode.
 *
 * @param iClient           Client index.
 * @param bIsPreview        Is preview mode.
 */
native void AC_SetPlayerPreview(int iClient, bool bIsPreview);

/**
 * Gets the player in preview mode.
 *
 * @param iClient           Client index.
 * 
 * @return                  Is preview mode.
 */
native bool AC_GetPlayerPreview(int iClient);

/**
 * Sets the team agent by definition index.
 *
 * @param iClient           Client index.
 * @param iTeam             Team index. 0 if for all teams.
 * @param iDefIndex         Agent definition index.
 * 
 * @return                  Is successful.
 */
native bool AC_SetAgent(int iClient, int iTeam = 0, int iDefIndex);

/**
 * Returns the team agent definition index.
 *
 * @param iClient           Client index.
 * @param iTeam             Team index.
 *
 * @return                  Database Handle.
 */
native int AC_GetAgent(int iClient, int iTeam);

/**
 * Returns the current agent definition index.
 *
 * @param iClient           Client index.
 *
 * @return                  Database Handle.
 */
stock int AC_GetCurrentAgent(int iClient)
{
	return AC_GetAgent(iClient, GetClientTeam(iClient));
}



public SharedPlugin __pl_agent_chooser = 
{
	name = "agent_chooser",
	file = "agent_chooser.smx",

	#if defined REQUIRE_PLUGIN
		required = 1
	#else
		required = 0
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_agent_chooser_SetNTVOptional()
{
	MarkNativeAsOptional("AC_IsLoaded");
	MarkNativeAsOptional("AC_RegisterFeature");
	MarkNativeAsOptional("AC_GetDatabase");
	MarkNativeAsOptional("AC_OpenMainMenu");
	MarkNativeAsOptional("AC_OpenPatchMenu");
	MarkNativeAsOptional("AC_SetPlayerPreview");
	MarkNativeAsOptional("AC_GetPlayerPreview");
	MarkNativeAsOptional("AC_SetAgent");
	MarkNativeAsOptional("AC_GetAgent");
}
#endif