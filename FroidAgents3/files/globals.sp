HTTPClient httpClient;

#define LOADOUT_POSITION_SPACER1 38

int g_iAgentsCount = 0;

int m_iItemDefinitionIndex, m_Item;
Handle g_hSetDefaultEquippedDefinitionItemBySlot;

enum struct PlayerData
{
    int iAgentLoaded;
    int iAgent[2];
    int iCacheTeam;
    char sCountryCode[2];
	char iTempSearching[128];
    CCSPlayerInventory pInventory;
    
    void SetAgent(int iAgent, int iTeam)
	{
		this.iAgent[view_as<int>(iTeam)] = iAgent;
	}

    int GetAgent(int iTeam)
	{
		int iTempTeam = view_as<int>(iTeam == CS_TEAM_CT);

		return this.iAgent[iTempTeam];
	}

    bool SetAgentSkin(int iClient, int iTeam)
	{
		if(iTeam > 1)
		{
            CEconItemView pAgent = this.pInventory.GetItemInLoadout(iTeam, LOADOUT_POSITION_SPACER1);

			if(pAgent)
			{
				int iAgent = this.GetAgent(iTeam);

				if(pAgent.GetAccountID()) {
					StoreToAddress(view_as<Address>(pAgent) + view_as<Address>(m_iItemDefinitionIndex), iAgent, NumberType_Int16);
				} else {
					SDKCall(g_hSetDefaultEquippedDefinitionItemBySlot, this.pInventory, iTeam, LOADOUT_POSITION_SPACER1, iAgent);
					pAgent = this.pInventory.GetItemInLoadout(iTeam, LOADOUT_POSITION_SPACER1);
				}

                return true;
			} else {
				LogError("LOADOUT_POSITION_SPACER1 == nullptr");

				return false;
			}
        }

        return false;
    }
    
    void Reset()
	{
		this.iAgentLoaded = 0;
		this.iAgent[0] = -1;
		this.iAgent[1] = -1;
        this.iCacheTeam = 0;
        this.sCountryCode = "EN";
		// Searching
        this.iTempSearching = "";
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];