#include <sourcemod>
#include <sdktools>
#include <store>
#include <autoexecconfig>

#pragma semicolon 1

ConVar g_hSpeedAmount;
float g_fSpeedAmount;

public Plugin myinfo =  {
	name = "Store MoreSpeed", 
	author = "Totenfluch", 
	version = "1.1", 
	description = "Gives Players more Speed when bought", 
	url = "https://totenfluch.de"
};

#pragma newdecls required

public void OnPluginStart() {
	Store_RegisterHandler("morespeed", "", morespeed_OnMapStart, morespeed_Reset, morespeed_Config, morespeed_Equip, morespeed_Remove, true);
	HookEvent("player_spawn", onPlayerSpawn);
	
	AutoExecConfig_SetFile("store_morespeed");
	AutoExecConfig_SetCreateFile(true);
	
	g_hSpeedAmount = AutoExecConfig_CreateConVar("store_morespeed_amount", "1.10", "Percentage Speed given... 1.10 = 10 Percent more speed");
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
}

public void morespeed_OnMapStart() {  }
public void morespeed_Reset() {  }
public bool morespeed_Config(Handle kv, int itemid) {
	Store_SetDataIndex(itemid, 0);
	return true;
}

public int morespeed_Equip(int client, int id) {
	if (isValidClient(client) && IsPlayerAlive(client)) {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_fSpeedAmount);
	}
	return -1;
}

public void morespeed_Remove(int client, int id) {
	if (isValidClient(client) && IsPlayerAlive(client)) {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
}

public void OnConfigsExecuted() {
	g_fSpeedAmount = GetConVarFloat(g_hSpeedAmount);
}

public Action onPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!isValidClient(client)) {
		return Plugin_Continue;
	}
	
	int m_iEquipped = Store_GetEquippedItem(client, "morespeed");
	if (m_iEquipped < 0) {
		return Plugin_Continue;
	}
	
	if (IsPlayerAlive(client)) {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_fSpeedAmount);
	}
	
	return Plugin_Handled;
}

stock bool isValidClient(int client) {
	return (1 <= client <= MaxClients && IsClientInGame(client));
}
