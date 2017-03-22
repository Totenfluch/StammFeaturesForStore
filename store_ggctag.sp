#include <sourcemod>
#include <cstrike>
#include <store>

#pragma semicolon 1

public Plugin:myinfo = 
{
	name = "Store VIP Tag", 
	author = "Totenfluch", 
	version = "1.0.0", 
	description = "*VIP* Tag is bought", 
	url = "http://ggc-base.de"
};

public OnPluginStart()
{
	Store_RegisterHandler("viptag", "", viptag_OnMapStart, viptag_Reset, viptag_Config, viptag_Equip, viptag_Remove, true);
	HookEvent("player_spawn", eventPlayerSpawn);
}


public viptag_OnMapStart() {  }
public viptag_Reset() {  }
public viptag_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, 0);
	return true;
}
public viptag_Equip(client, id)
{
	NameCheck(client);
	return -1;
}
public viptag_Remove(client, id) {
	NameCheck(client);
}

public Action eventPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	if (IsValidClient(client))
	{
		NameCheck(client);
	}
}

public NameCheck(client)
{
	new m_iEquipped = Store_GetEquippedItem(client, "viptag");
	if (m_iEquipped < 0) {
		CS_SetClientClanTag(client, "");
		return;
	}
	
	CS_SetClientClanTag(client, GetClientClientAdminStatus(client));
}



String:GetClientClientAdminStatus(any:client) {
	bool mod = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_CHAT, true);
	bool trial = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_UNBAN, true);
	bool admin = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_CUSTOM4, true);
	bool senior = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_RCON, true);
	bool root = CheckCommandAccess(client, "sm_ccommand", ADMFLAG_ROOT, true);
	decl String:stuff[20];
	
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

public IsValidClient(client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
		return false;
	
	return true;
}


