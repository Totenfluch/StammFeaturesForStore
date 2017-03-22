#include <sourcemod>
#include <store>
#include <multicolors>
#include <cstrike>

#pragma semicolon 1

public Plugin:myinfo = 
{
	name = "Store Welcome/Leave Messages", 
	author = "Totenfluch", 
	version = "1.0", 
	description = "Join/Leave Messages if bought", 
	url = "http://ggc-base.de"
};

public OnPluginStart() {
	Store_RegisterHandler("welcomemsg", "", welcome_OnMapStart, welcome_Reset, welcome_Config, welcome_Equip, welcome_Remove, true);
	Store_RegisterHandler("leavemsg", "", leavemsg_OnMapStart, leavemsg_Reset, leavemsg_Config, leavemsg_Equip, leavemsg_Remove, true);
}

public welcome_OnMapStart() {  }
public welcome_Reset() {  }
public welcome_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, 0);
	return true;
}
public welcome_Equip(client, id)
{
	return -1;
}
public welcome_Remove(client, id) {  }

public leavemsg_OnMapStart() {  }
public leavemsg_Reset() {  }
public leavemsg_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, 0);
	return true;
}
public leavemsg_Equip(client, id)
{
	return -1;
}
public leavemsg_Remove(client, id) {  }

public OnClientAuthorized(client)
{
	if (IsValidClient(client))
	{
		new m_iEquipped = Store_GetEquippedItem(client, "welcomemsg");
		if (m_iEquipped < 0) {
			return;
		}
		
		decl String:name[MAX_NAME_LENGTH + 1];
		decl String:tag[64];
		
		GetClientName(client, name, sizeof(name));
		CS_GetClientClanTag(client, tag, sizeof(tag));
		CPrintToChatAll("{red}[{purple}GGC{red}] {olive}%s %s{green} has joined the Game!", tag, name);
	}
}

public OnClientDisconnect(client)
{
	if (IsValidClient(client))
	{
		new m_iEquipped = Store_GetEquippedItem(client, "leavemsg");
		if (m_iEquipped < 0) {
			return;
		}
		
		decl String:name[MAX_NAME_LENGTH + 1];
		decl String:tag[64];
		
		GetClientName(client, name, sizeof(name));
		CS_GetClientClanTag(client, tag, sizeof(tag));
		
		CPrintToChatAll("{red}[{purple}GGC{red}] {olive}%s %s{green} has left the Game!", tag, name);
	}
}

public IsValidClient(client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
		return false;
	
	return true;
} 