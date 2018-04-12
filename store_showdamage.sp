#include <sourcemod>
#include <store>

#pragma semicolon 1

public Plugin myinfo = {
	name = "Store Show Damage", 
	author = "Totenfluch", 
	version = "1.1", 
	description = "Allows you to see damage done when bought", 
	url = "https://totenfluch.de"
};

#pragma newdecls required

public void OnPluginStart() {
	Store_RegisterHandler("damagedone", "", damagedone_OnMapStart, damagedone_Reset, damagedone_Config, damagedone_Equip, damagedone_Remove, true);
	HookEvent("player_hurt", eventPlayerHurt);
}

public void damagedone_OnMapStart() {  }

public void damagedone_Reset() {  }

public bool damagedone_Config(Handle kv, int itemid) {
	Store_SetDataIndex(itemid, 0);
	return true;
}

public int damagedone_Equip(int client, int id) {
	return -1;
}

public void damagedone_Remove(int client, int id) {  }

public Action eventPlayerHurt(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "attacker"));
	int m_iEquipped = Store_GetEquippedItem(client, "damagedone");
	if (m_iEquipped < 0) {
		return Plugin_Continue;
	}
	
	if (isValidClient(client)) {
		int damage = GetEventInt(event, "dmg_health");
		PrintHintText(client, "- %i HP", damage);
	}
	
	return Plugin_Handled;
}

stock bool isValidClient(int client) {
	return (1 <= client <= MaxClients && IsClientInGame(client));
}
