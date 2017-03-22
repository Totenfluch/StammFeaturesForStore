#include <sourcemod>
#include <sdktools>
#include <store>

#pragma semicolon 1

public Plugin:myinfo = 
{
	name = "Store MoreSpeed", 
	author = "Totenfluch", 
	version = "1.0.0", 
	description = "Gives Players more Speed when bought", 
	url = "http://ggc-base.de"
};

public OnPluginStart() {
	Store_RegisterHandler("morespeed", "", morespeed_OnMapStart, morespeed_Reset, morespeed_Config, morespeed_Equip, morespeed_Remove, true);
	HookEvent("player_spawn", PlayerSpawn);
}

public morespeed_OnMapStart() {  }
public morespeed_Reset() {  }
public morespeed_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, 0);
	return true;
}

public morespeed_Equip(client, id)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.1);
	}
	return -1;
}

public morespeed_Remove(client, id) {
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
}


public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new m_iEquipped = Store_GetEquippedItem(client, "morespeed");
	if (m_iEquipped < 0) {
		return Plugin_Continue;
	}
	
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.1);
	
	return Plugin_Handled;
}

public IsValidClient(client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
		return false;
	
	return true;
} 