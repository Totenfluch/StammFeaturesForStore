#include <sourcemod>
#include <store>
#include <sdktools>
#include <autoexecconfig>

#pragma semicolon 1


bool g_bVipPlayers[MAXPLAYERS + 1][3];

ConVar g_hTime;
float g_fTime;

public Plugin myinfo =  {
	name = "Store Player Distance", 
	author = "Totenfluch", 
	version = "1.1", 
	description = "See the nearest player & distance when bought", 
	url = "https://totenfluch.de"
};

#pragma newdecls required

public void OnPluginStart() {
	Store_RegisterHandler("radar1", "", radar1_OnMapStart, radar1_Reset, radar1_Config, radar1_Equip, radar1_Remove, true);
	Store_RegisterHandler("radar2", "", radar2_OnMapStart, radar2_Reset, radar2_Config, radar2_Equip, radar2_Remove, true);
	
	AutoExecConfig_SetFile("store_distance");
	AutoExecConfig_SetCreateFile(true);
	
	g_hTime = AutoExecConfig_CreateConVar("store_distance_time", "3.0", "Time between HUD refreshes");
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
	
	
	HookEvent("player_spawn", onPlayerSpawn);
}

public void OnConfigsExecuted() {
	g_fTime = GetConVarFloat(g_hTime);
	
	CreateTimer(g_fTime, checkPlayers, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	if (FindConVar("sv_hudhint_sound") != INVALID_HANDLE) {
		SetConVarInt(FindConVar("sv_hudhint_sound"), 0);
	}
}

public void radar1_OnMapStart() {  }

public void radar1_Reset() {  }

public bool radar1_Config(Handle kv, int itemid) {
	Store_SetDataIndex(itemid, 0);
	return true;
}

public int radar1_Equip(int client, int id) {
	return -1;
}

public void radar1_Remove(int client, int id) {  }

public void radar2_OnMapStart() {  }

public void radar2_Reset() {  }

public bool radar2_Config(Handle kv, int itemid) {
	Store_SetDataIndex(itemid, 0);
	return true;
}
public int radar2_Equip(int client, int id) {
	return -1;
}

public void radar2_Remove(int client, int id) {  }



public Action onPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	g_bVipPlayers[client][0] = false;
	g_bVipPlayers[client][1] = false;
	g_bVipPlayers[client][2] = false;
	
	if (isValidClient(client)) {
		int m_iEquipped = Store_GetEquippedItem(client, "radar1");
		int m_iEquipped2 = Store_GetEquippedItem(client, "radar2");
		
		if (m_iEquipped >= 0) {
			g_bVipPlayers[client][2] = true;
		}
		
		if (m_iEquipped2 >= 0) {
			g_bVipPlayers[client][1] = true;
		}
		
		if (m_iEquipped2 >= 0) {
			g_bVipPlayers[client][0] = true;
		}
	}
}

public void OnClientDisconnect(int client) {
	g_bVipPlayers[client][0] = false;
	g_bVipPlayers[client][1] = false;
	g_bVipPlayers[client][2] = false;
}


// Check for nearest player
public Action checkPlayers(Handle timer, any data) {
	char unitString[12];
	char unitStringOne[12];
	
	float clientOrigin[3];
	float searchOrigin[3];
	float near;
	float distance;
	
	int nearest;
	
	Format(unitString, sizeof(unitString), "meters");
	Format(unitStringOne, sizeof(unitStringOne), "meter");
	
	
	for (int client = 1; client <= MaxClients; client++) {
		if ((g_bVipPlayers[client][0] || g_bVipPlayers[client][1] || g_bVipPlayers[client][2]) && IsPlayerAlive(client)) {
			if (!isValidClient(client)) {
				g_bVipPlayers[client][0] = false;
				g_bVipPlayers[client][1] = false;
				g_bVipPlayers[client][2] = false;
			} else {
				nearest = 0;
				near = 0.0;
				
				// Get origin
				GetClientAbsOrigin(client, clientOrigin);
				
				// Next client loop
				for (int search = 1; search <= MaxClients; search++) {
					if (IsClientInGame(search) && IsPlayerAlive(search) && search != client && (GetClientTeam(client) != GetClientTeam(search))) {
						// Get distance to first client
						GetClientAbsOrigin(search, searchOrigin);
						
						distance = GetVectorDistance(clientOrigin, searchOrigin);
						
						// Is he more near to the player as the player before?
						if (near == 0.0) {
							near = distance;
							nearest = search;
						}
						
						if (distance < near) {
							near = distance;
							nearest = search;
						}
					}
				}
				
				// Found a player?
				if (nearest != 0) {
					float dist;
					float vecPoints[3];
					float vecAngles[3];
					float clientAngles[3];
					
					char directionString[64];
					char textToPrint[64];
					
					
					// Client get Direction?
					if (g_bVipPlayers[client][2]) {
						// Get the origin of the nearest player
						GetClientAbsOrigin(nearest, searchOrigin);
						
						// Angles
						GetClientAbsAngles(client, clientAngles);
						
						// Angles from origin
						MakeVectorFromPoints(clientOrigin, searchOrigin, vecPoints);
						GetVectorAngles(vecPoints, vecAngles);
						
						// Differenz
						float diff = clientAngles[1] - vecAngles[1];
						
						// Correct it
						if (diff < -180) {
							diff = 360 + diff;
						}
						
						if (diff > 180) {
							diff = 360 - diff;
						}
						
						
						// Now geht the direction
						
						if (diff >= -22.5 && diff < 22.5) {
							Format(directionString, sizeof(directionString), "\xe2\x86\x91");
						} else if (diff >= 22.5 && diff < 67.5) {
							Format(directionString, sizeof(directionString), "\xe2\x86\x97");
						} else if (diff >= 67.5 && diff < 112.5) {
							Format(directionString, sizeof(directionString), "\xe2\x86\x92");
						} else if (diff >= 112.5 && diff < 157.5) {
							Format(directionString, sizeof(directionString), "\xe2\x86\x98");
						} else if (diff >= 157.5 || diff < -157.5) {
							Format(directionString, sizeof(directionString), "\xe2\x86\x93");
						} else if (diff >= -157.5 && diff < -112.5) {
							Format(directionString, sizeof(directionString), "\xe2\x86\x99");
						} else if (diff >= -112.5 && diff < -67.5) {
							Format(directionString, sizeof(directionString), "\xe2\x86\x90");
						} else if (diff >= -67.5 && diff < -22.5) {
							Format(directionString, sizeof(directionString), "\xe2\x86\x96");
						}
						
						
						
						// Add to text
						if (g_bVipPlayers[client][1] || g_bVipPlayers[client][0]) {
							Format(textToPrint, sizeof(textToPrint), "%s\n", directionString);
						} else {
							Format(textToPrint, sizeof(textToPrint), directionString);
						}
					}
					
					
					
					// Client get Distance?
					if (g_bVipPlayers[client][1]) {
						// Distance to meters
						dist = near * 0.01905;
						
						
						// Add to text
						if (g_bVipPlayers[client][0]) {
							Format(textToPrint, sizeof(textToPrint), "%s(%i %s)\n", textToPrint, RoundFloat(dist), (RoundFloat(dist) == 1 ? unitStringOne : unitString));
						} else {
							Format(textToPrint, sizeof(textToPrint), "%s(%i %s)", textToPrint, RoundFloat(dist), (RoundFloat(dist) == 1 ? unitStringOne : unitString));
						}
					}
					
					
					// Add name
					if (g_bVipPlayers[client][0]) {
						Format(textToPrint, sizeof(textToPrint), "%s%N", textToPrint, nearest);
					}
					
					// Print text
					PrintHintText(client, textToPrint);
				}
			}
		}
	}
	
	return Plugin_Continue;
}

stock bool isValidClient(int client) {
	return (1 <= client <= MaxClients && IsClientInGame(client));
}
