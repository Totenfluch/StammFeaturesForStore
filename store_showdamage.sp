#include <sourcemod>
#include <store>

#pragma semicolon 1


public Plugin:myinfo = 
{
	name = "Store Show Damage", 
	author = "Totenfluch", 
	version = "1.0.0", 
	description = "Allows you to see damage done when bought", 
	url = "http://ggc-base.de"
};


public OnPluginStart()
{
	Store_RegisterHandler("damagedone", "", damagedone_OnMapStart, damagedone_Reset, damagedone_Config, damagedone_Equip, damagedone_Remove, true);
	HookEvent("player_hurt", eventPlayerHurt);
}

public damagedone_OnMapStart() {  }
public damagedone_Reset() {  }
public damagedone_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, 0);
	return true;
}
public damagedone_Equip(client, id)
{
	return -1;
}
public damagedone_Remove(client, id) {  }

public Action:eventPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "attacker"));
	new m_iEquipped = Store_GetEquippedItem(client, "damagedone");
	if (m_iEquipped < 0) {
		return Plugin_Continue;
	}
	
	if (IsValidClient(client))
	{
		new damage = GetEventInt(event, "dmg_health");
		PrintHintText(client, "- %i HP", damage);
	}
	
	return Plugin_Handled;
}


public IsValidClient(client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
		return false;
	
	return true;
} 