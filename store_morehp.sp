#include <sourcemod>
#include <sdktools>

#include <store>
#include <zephstocks>

public Plugin:myinfo = 
{
	name = "Store_MoreHP", 
	author = "Totenfluch", 
	description = "give more hp if you buy this", 
	version = "1.0", 
	url = "www.ggc-base.de"
};

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	Store_RegisterHandler("morehp", "", MoreHP_OnMapStart, MoreHP_Reset, MoreHP_Config, MoreHP_Equip, MoreHP_Remove, true);
}

public MoreHP_OnMapStart()
{
}

public MoreHP_Reset()
{
}

public MoreHP_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, 0);
	return true;
}

public MoreHP_Equip(client, id)
{
	return -1;
}

public MoreHP_Remove(client, id)
{
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new m_iEquipped = Store_GetEquippedItem(client, "morehp");
	if (m_iEquipped < 0) {
		PrintToChat(client, "not equiped");
		return Plugin_Continue;
		
	}
	PrintToChat(client, "equiped");
	
	SetEntityHealth(client, 120);
	
	
	return Plugin_Continue;
} 