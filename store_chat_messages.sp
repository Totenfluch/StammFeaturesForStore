#include <sourcemod>
#include <store>
#include <multicolors>
#include <cstrike>
#include <autoexecconfig>

#pragma semicolon 1

ConVar g_hTag;
char g_cTag[20] = "-T-";

public Plugin myinfo =  {
	name = "Store Welcome/Leave Messages", 
	author = "Totenfluch", 
	version = "1.0", 
	description = "Join/Leave Messages if bought", 
	url = "https://totenfluch.de"
};

#pragma newdecls required

public void OnPluginStart() {
	Store_RegisterHandler("welcomemsg", "", welcome_OnMapStart, welcome_Reset, welcome_Config, welcome_Equip, welcome_Remove, true);
	Store_RegisterHandler("leavemsg", "", leavemsg_OnMapStart, leavemsg_Reset, leavemsg_Config, leavemsg_Equip, leavemsg_Remove, true);
	
	AutoExecConfig_SetFile("store_chat_messages");
	AutoExecConfig_SetCreateFile(true);
	
	g_hTag = AutoExecConfig_CreateConVar("store_chat_messages_chattag", "-T-", "sets the chat tag before every message for Plugin");
	
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
}

public void OnConfigsExecuted() {
	GetConVarString(g_hTag, g_cTag, sizeof(g_cTag));
}

public void welcome_OnMapStart() {  }

public void welcome_Reset() {  }

public bool welcome_Config(Handle kv, int itemid) {
	Store_SetDataIndex(itemid, 0);
	return true;
}

public int welcome_Equip(int client, int id) {
	return -1;
}

public void welcome_Remove(int client, int id) {  }


public void leavemsg_OnMapStart() {  }

public void leavemsg_Reset() {  }

public bool leavemsg_Config(Handle kv, int itemid) {
	Store_SetDataIndex(itemid, 0);
	return true;
}

public int leavemsg_Equip(int client, int id) {
	return -1;
}

public void leavemsg_Remove(int client, int id) {  }

public void OnClientAuthorized(int client) {
	if (isValidClient(client)) {
		int m_iEquipped = Store_GetEquippedItem(client, "welcomemsg");
		if (m_iEquipped < 0) {
			return;
		}
		
		char name[MAX_NAME_LENGTH + 1];
		char tag[64];
		
		GetClientName(client, name, sizeof(name));
		CS_GetClientClanTag(client, tag, sizeof(tag));
		CPrintToChatAll("{red}[{purple}%s{red}] {olive}%s %s{green} has joined the Game!", g_cTag, tag, name);
	}
}

public void OnClientDisconnect(int client) {
	if (isValidClient(client)) {
		int m_iEquipped = Store_GetEquippedItem(client, "leavemsg");
		if (m_iEquipped < 0) {
			return;
		}
		
		char name[MAX_NAME_LENGTH + 1];
		char tag[64];
		
		GetClientName(client, name, sizeof(name));
		CS_GetClientClanTag(client, tag, sizeof(tag));
		
		CPrintToChatAll("{red}[{purple}%s{red}] {olive}%s %s{green} has left the Game!", g_cTag, tag, name);
	}
}

stock bool isValidClient(int client) {
	return (1 <= client <= MaxClients && IsClientInGame(client));
}
