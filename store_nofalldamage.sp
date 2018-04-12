#include <sourcemod>
#include <sdkhooks>
#include <store>

#pragma semicolon 1

#define DMG_FALL   (1 << 5)

public Plugin myinfo =  {
	name = "Store No Fall Damage", 
	author = "Totenfluch", 
	version = "1.1", 
	description = "Allows you to buy No Fall Damage", 
	url = "https://totenfluch.de"
};

#pragma newdecls required

public void OnPluginStart() {
	Store_RegisterHandler("nofall", "", nofall_OnMapStart, nofall_Reset, nofall_Config, nofall_Equip, nofall_Remove, true);
}

public void nofall_OnMapStart() {  }

public void nofall_Reset() {  }

public bool nofall_Config(Handle kv, int itemid) {
	Store_SetDataIndex(itemid, 0);
	return true;
}

public int nofall_Equip(int client, int id) {
	return -1;
}

public void nofall_Remove(int client, int id) {  }

public void OnClientPutInServer(int client) {
	if(isValidClient(client)) {
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public void OnClientDisconnect(int client) {
	if(isValidClient(client)) {
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &bweapon, float damageForce[3], const float damagePosition[3]) {
	int m_iEquipped = Store_GetEquippedItem(client, "nofall");
	if (m_iEquipped < 0) {
		return Plugin_Continue;
	}
	
	if (isValidClient(client)){
		if ((GetClientTeam(client) == 2 || GetClientTeam(client) == 3) && IsPlayerAlive(client)){
			if (damagetype & DMG_FALL){
				return Plugin_Handled;
			}
		}
	}
	
	return Plugin_Continue;
}

stock bool isValidClient(int client) {
	return (1 <= client <= MaxClients && IsClientInGame(client));
}
