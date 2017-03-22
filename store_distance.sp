#include <sourcemod>
#include <store>
#include <sdktools>

#pragma semicolon 1

new Handle:g_hUnit;

new bool:g_bVipPlayers[MAXPLAYERS + 1][3];



public Plugin:myinfo = 
{
	name = "Store Player Distance", 
	author = "Totenfluch", 
	version = "1.0.0", 
	description = "See the nearest player & distance when bought", 
	url = "http://ggc-base.de"
};

public OnPluginStart()
{
	Store_RegisterHandler("radar1", "", radar1_OnMapStart, radar1_Reset, radar1_Config, radar1_Equip, radar1_Remove, true);
	Store_RegisterHandler("radar2", "", radar2_OnMapStart, radar2_Reset, radar2_Config, radar2_Equip, radar2_Remove, true);
	HookEvent("player_spawn", eventPlayerSpawn);
}

public OnMapStart()
{
	CreateTimer(0.2, checkPlayers, _, TIMER_REPEAT);
}

public radar1_OnMapStart() {  }
public radar1_Reset() {  }
public radar1_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, 0);
	return true;
}
public radar1_Equip(client, id)
{
	return -1;
}
public radar1_Remove(client, id) {  }

public radar2_OnMapStart() {  }
public radar2_Reset() {  }
public radar2_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, 0);
	return true;
}
public radar2_Equip(client, id)
{
	return -1;
}
public radar2_Remove(client, id) {  }

public OnConfigsExecuted()
{
	if (FindConVar("sv_hudhint_sound") != INVALID_HANDLE)
	{
		SetConVarInt(FindConVar("sv_hudhint_sound"), 0);
	}
}




// A player spawned
public Action:eventPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	
	// Reset
	g_bVipPlayers[client][0] = false;
	g_bVipPlayers[client][1] = false;
	g_bVipPlayers[client][2] = false;
	
	if (IsValidClient(client))
	{
		new m_iEquipped = Store_GetEquippedItem(client, "radar1");
		new m_iEquipped2 = Store_GetEquippedItem(client, "radar2");
		
		if (m_iEquipped >= 0)
		{
			g_bVipPlayers[client][2] = true;
		}
		
		if (m_iEquipped2 >= 0)
		{
			g_bVipPlayers[client][1] = true;
		}
		
		if (m_iEquipped2 >= 0)
		{
			g_bVipPlayers[client][0] = true;
		}
	}
}

public OnClientDisconnect(client)
{
	g_bVipPlayers[client][0] = false;
	g_bVipPlayers[client][1] = false;
	g_bVipPlayers[client][2] = false;
}


// Check for nearest player
public Action:checkPlayers(Handle:timer, any:data)
{
	decl String:unitString[12];
	decl String:unitStringOne[12];
	
	new Float:clientOrigin[3];
	new Float:searchOrigin[3];
	new Float:near;
	new Float:distance;
	
	new nearest;
	
	
	
	Format(unitString, sizeof(unitString), "meters");
	Format(unitStringOne, sizeof(unitStringOne), "meter");
	
	
	
	
	for (new client = 1; client <= MaxClients; client++)
	{
		if ((g_bVipPlayers[client][0] || g_bVipPlayers[client][1] || g_bVipPlayers[client][2]) && IsPlayerAlive(client))
		{
			if (!IsValidClient(client))
			{
				g_bVipPlayers[client][0] = false;
				g_bVipPlayers[client][1] = false;
				g_bVipPlayers[client][2] = false;
			}
			
			else
			{
				nearest = 0;
				near = 0.0;
				
				// Get origin
				GetClientAbsOrigin(client, clientOrigin);
				
				// Next client loop
				for (new search = 1; search <= MaxClients; search++)
				{
					if (IsClientInGame(search) && IsPlayerAlive(search) && search != client && (GetClientTeam(client) != GetClientTeam(search)))
					{
						// Get distance to first client
						GetClientAbsOrigin(search, searchOrigin);
						
						distance = GetVectorDistance(clientOrigin, searchOrigin);
						
						// Is he more near to the player as the player before?
						if (near == 0.0)
						{
							near = distance;
							nearest = search;
						}
						
						if (distance < near)
						{
							near = distance;
							nearest = search;
						}
					}
				}
				
				// Found a player?
				if (nearest != 0)
				{
					new Float:dist;
					new Float:vecPoints[3];
					new Float:vecAngles[3];
					new Float:clientAngles[3];
					
					decl String:directionString[64];
					new String:textToPrint[64];
					
					
					// Client get Direction?
					if (g_bVipPlayers[client][2])
					{
						// Get the origin of the nearest player
						GetClientAbsOrigin(nearest, searchOrigin);
						
						// Angles
						GetClientAbsAngles(client, clientAngles);
						
						// Angles from origin
						MakeVectorFromPoints(clientOrigin, searchOrigin, vecPoints);
						GetVectorAngles(vecPoints, vecAngles);
						
						// Differenz
						new Float:diff = clientAngles[1] - vecAngles[1];
						
						// Correct it
						if (diff < -180)
						{
							diff = 360 + diff;
						}
						
						if (diff > 180)
						{
							diff = 360 - diff;
						}
						
						
						// Now geht the direction
						
						// Up
						if (diff >= -22.5 && diff < 22.5)
						{
							Format(directionString, sizeof(directionString), "\xe2\x86\x91");
						}
						
						// right up
						else if (diff >= 22.5 && diff < 67.5)
						{
							Format(directionString, sizeof(directionString), "\xe2\x86\x97");
						}
						
						// right
						else if (diff >= 67.5 && diff < 112.5)
						{
							Format(directionString, sizeof(directionString), "\xe2\x86\x92");
						}
						
						// right down
						else if (diff >= 112.5 && diff < 157.5)
						{
							Format(directionString, sizeof(directionString), "\xe2\x86\x98");
						}
						
						// down
						else if (diff >= 157.5 || diff < -157.5)
						{
							Format(directionString, sizeof(directionString), "\xe2\x86\x93");
						}
						
						// down left
						else if (diff >= -157.5 && diff < -112.5)
						{
							Format(directionString, sizeof(directionString), "\xe2\x86\x99");
						}
						
						// left
						else if (diff >= -112.5 && diff < -67.5)
						{
							Format(directionString, sizeof(directionString), "\xe2\x86\x90");
						}
						
						// left up
						else if (diff >= -67.5 && diff < -22.5)
						{
							Format(directionString, sizeof(directionString), "\xe2\x86\x96");
						}
						
						
						
						// Add to text
						if (g_bVipPlayers[client][1] || g_bVipPlayers[client][0])
						{
							Format(textToPrint, sizeof(textToPrint), "%s\n", directionString);
						}
						else
						{
							Format(textToPrint, sizeof(textToPrint), directionString);
						}
					}
					
					
					
					// Client get Distance?
					if (g_bVipPlayers[client][1])
					{
						// Distance to meters
						dist = near * 0.01905;
						
						
						// Add to text
						if (g_bVipPlayers[client][0])
						{
							Format(textToPrint, sizeof(textToPrint), "%s(%i %s)\n", textToPrint, RoundFloat(dist), (RoundFloat(dist) == 1 ? unitStringOne : unitString));
						}
						else
						{
							Format(textToPrint, sizeof(textToPrint), "%s(%i %s)", textToPrint, RoundFloat(dist), (RoundFloat(dist) == 1 ? unitStringOne : unitString));
						}
					}
					
					
					// Add name
					if (g_bVipPlayers[client][0])
					{
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

public IsValidClient(client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
		return false;
	
	return true;
} 