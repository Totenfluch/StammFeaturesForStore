#include <sourcemod>
#include <cstrike>
#include <store>

#pragma semicolon 1

public Plugin myinfo =  {
	name = "Store VIP Tag", 
	author = "Totenfluch", 
	version = "1.1", 
	description = "*VIP* Tag is bought + Admin Tags", 
	url = "https://totenfluch.de"
};

public void OnPluginStart() {
	Store_RegisterHandler("viptag", "", viptag_OnMapStart, viptag_Reset, viptag_Config, viptag_Equip, viptag_Remove, true);
	HookEvent("player_spawn", eventPlayerSpawn);
}


public void viptag_OnMapStart() {  }

public void viptag_Reset() {  }

public bool viptag_Config(Handle kv, int itemid) {
	Store_SetDataIndex(itemid, 0);
	return true;
}

public int viptag_Equip(int client, int id) {
	NameCheck(client);
	return -1;
}

public void viptag_Remove(int client, int id) {
	NameCheck(client);
}

public Action eventPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);
	
	if (isValidClient(client)) {
		NameCheck(client);
	}
}

public void NameCheck(int client) {
	int m_iEquipped = Store_GetEquippedItem(client, "viptag");
	if (m_iEquipped < 0) {
		CS_SetClientClanTag(client, "");
		return;
	}
	
	CS_SetClientClanTag(client, GetClientClientAdminStatus(client));
}

char[] GetClientClientAdminStatus(int client) {
	bool mod = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_CHAT, true);
	bool trial = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_UNBAN, true);
	bool admin = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_CUSTOM4, true);
	bool senior = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_RCON, true);
	bool root = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_ROOT, true);
	char stuff[20];
	
	if (root) {
		Format(stuff, sizeof(stuff), "Head Admin");
	} else if (senior) {
		Format(stuff, sizeof(stuff), "Senior Admin");
	} else if (admin) {
		Format(stuff, sizeof(stuff), "Game Admin");
	} else if (trial) {
		Format(stuff, sizeof(stuff), "Trial Admin");
	} else if (mod) {
		Format(stuff, sizeof(stuff), "Moderator");
	} else {
		Format(stuff, sizeof(stuff), "*GGC-VIP*");
	}
	
	return stuff;
}

stock bool isValidClient(int client) {
	return (1 <= client <= MaxClients && IsClientInGame(client));
}
