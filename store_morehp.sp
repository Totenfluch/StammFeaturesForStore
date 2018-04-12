#include <sourcemod>
#include <sdktools>
#include <store>
#include <autoexecconfig>

#pragma semicolon 1

ConVar g_hHpAmount;
int g_iHpAmount;

public Plugin myinfo =  {
	name = "Store_MoreHP", 
	author = "Totenfluch", 
	description = "give more hp if you buy this", 
	version = "1.1", 
	url = "https://totenfluch.de"
};

#pragma newdecls required

public void OnPluginStart() {
	HookEvent("player_spawn", onPlayerSpawn);
	Store_RegisterHandler("morehp", "", MoreHP_OnMapStart, MoreHP_Reset, MoreHP_Config, MoreHP_Equip, MoreHP_Remove, true);
	
	AutoExecConfig_SetFile("store_morehp");
	AutoExecConfig_SetCreateFile(true);
	
	g_hHpAmount = AutoExecConfig_CreateConVar("store_morehp_amount", "10", "Amount of HP to add to player");
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
}

public void MoreHP_OnMapStart() {  }

public void MoreHP_Reset() {  }

public bool MoreHP_Config(Handle kv, int itemid) {
	Store_SetDataIndex(itemid, 0);
	return true;
}

public int MoreHP_Equip(int client, int id) {
	return -1;
}

public void MoreHP_Remove(int client, int id) {  }

public void OnConfigsExecuted() {
	g_iHpAmount = GetConVarInt(g_hHpAmount);
}

public Action onPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!isValidClient(client)) {
		return Plugin_Continue;
	}
	
	int m_iEquipped = Store_GetEquippedItem(client, "morehp");
	if (m_iEquipped < 0) {
		return Plugin_Continue;
	}
	
	if (IsPlayerAlive(client)) {
		SetEntityHealth(client, 100 + g_iHpAmount);
	}
	
	
	return Plugin_Continue;
}


stock bool isValidClient(int client) {
	return (1 <= client <= MaxClients && IsClientInGame(client));
}
