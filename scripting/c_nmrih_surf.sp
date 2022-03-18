#pragma newdecls required
#pragma semicolon 1

#include <sdktools>
#include <sdkhooks>
#include <sourcemod>
#include <halflife>
#include <dhooks>


bool g_bMessagesShown[MAXPLAYERS + 1];
bool f_surfon;



public Plugin myinfo =
{
	name		= "[NMRiH] Surf!",
	author		= "Rogue Garlicbread",
	description	= "Surfing in NMRiH!.",
	version		= "1.0",
}


public void OnMapStart(){
	char map[PLATFORM_MAX_PATH];
	GetCurrentMap(map, sizeof(map));
	// CHECKS MAP NAME
	if( StrContains(map, "surf_") != -1 ){
        surfcvars_init(true);
        f_surfon = true;
    }
    else{
        f_surfon = false;
        
        for (int i=1; i<=MAXPLAYERS; i++)
            {g_bMessagesShown[i] = false;}
    }
}

ConVar 
    g_entrymessage,
    g_max_stamina,
    g_stam_drainrate,
    g_stam_jumpcost,
    g_stam_regen_crouch,
    g_stam_regen_idle,
    g_stam_regen_moving,
    g_stam_regen_sprint,
    g_speed_normal,
    g_speed_riflesights,
    g_speed_sights,
    g_speed_sprint,
    g_respawn_time_notoken,
    g_respawn_time_token,
    g_respawn_without_tokens,
    g_gravity,
    g_accelerate,
    g_airaccelerate,
    g_maxspeed,
    g_maxvelocity;

public void OnPluginStart(){
    RegAdminCmd("surf", surf_a, ADMFLAG_KICK, "turn on SURF mode");
    RegServerCmd("sm_surf", surf_acmd, "turn on surf mode; console cmd");
    RegAdminCmd("surfoff", surfoff_a, ADMFLAG_KICK, "turn off SURF mode");
    RegServerCmd("sm_surfoff", surfoff_acmd, "turn off SURF mode; console cmd");
	HookEvent("player_spawn", Event_OnPlayerSpawn);
    g_entrymessage = CreateConVar("nmrih_diffmoder_gamemode_default", "WCM \x07~ \x01Welcome to free cookies' free surf mode! \x06", "Message printed to players joining the server on a surf map");
    //non hidden cvars  
    g_max_stamina = FindConVar("sv_max_stamina");
    g_stam_drainrate = FindConVar("sv_stam_drainrate");
    g_stam_jumpcost = FindConVar("sv_stam_jumpcost");
    g_stam_regen_crouch = FindConVar("sv_stam_regen_crouch");
    g_stam_regen_idle = FindConVar("sv_stam_regen_idle");
    g_stam_regen_moving = FindConVar("sv_stam_regen_moving");
    g_stam_regen_sprint = FindConVar("sv_stam_regen_sprint");
    g_speed_normal = FindConVar("mv_speed_normal");
    g_speed_riflesights = FindConVar("mv_speed_riflesights");
    g_speed_sights = FindConVar("mv_speed_sights");
    g_speed_sprint = FindConVar("mv_speed_sprint");
    g_respawn_time_notoken = FindConVar("sv_respawn_time_notoken");
    g_respawn_time_token = FindConVar("sv_respawn_time_token");
    g_respawn_without_tokens = FindConVar("sv_respawn_without_tokens");
    g_gravity = FindConVar("sv_gravity");
    //HIDDEN cvars
    g_accelerate = FindConVar("sv_accelerate");
    g_airaccelerate = FindConVar("sv_airaccelerate");
    g_maxspeed = FindConVar("sv_maxspeed");
    g_maxvelocity = FindConVar("sv_maxvelocity");
}

public void OnMapEnd(){
    //TODO implement execute only if surfmode active
    surfcvars_default(); 
}


public Action surf_a(int client, int args){
    surfcvars_init(false);
}
public Action surf_acmd(int args){
    surfcvars_init(false);
    PrintToServer("Turning on SURF mode");
}
public Action surfoff_a(int client, int args){
    surfcvars_default();
}
public Action surfoff_acmd(int args){
    surfcvars_default();
    PrintToServer("Turning off SURF mode");
}



public void surfcvars_init(bool restart){

    //HIDDEN cvars
    g_accelerate.IntValue           =    15;
    g_airaccelerate.IntValue        =  1500;
    g_maxspeed.IntValue             =   620;
    g_maxvelocity.IntValue          =  7200;

    //non hidden cvars
    g_gravity.IntValue              =   600;
    g_max_stamina.IntValue          = 10000;
    g_stam_drainrate.IntValue       =     0;
    g_stam_jumpcost.IntValue        =     0;
    g_stam_regen_crouch.IntValue    =   200;
    g_stam_regen_idle.IntValue      =   200;
    g_stam_regen_moving.IntValue    =   200;
    g_stam_regen_sprint.IntValue    =   200;
    g_speed_normal.IntValue         =   130;
    g_speed_riflesights.IntValue    =    80;
    g_speed_sights.IntValue         =   100;
    g_speed_sprint.IntValue         =   300;
    g_respawn_time_notoken.IntValue =     5;
    g_respawn_time_token.IntValue   =     5;
    g_respawn_without_tokens.IntValue =   1;
    if (restart){
    ServerCommand("restartround");}
    PrintToChatAll("Surf Mode Activated!");
}

public void surfcvars_default(){

    //HIDDEN cvars
    g_accelerate.IntValue           =    10;
    g_airaccelerate.IntValue        =    10;
    g_maxspeed.IntValue             =   320;
    g_maxvelocity.IntValue          =  3500;

    //non hidden cvars
    g_gravity.IntValue              =   800;
    g_max_stamina.IntValue          =   130;
    g_stam_drainrate.FloatValue     =   3.5;
    g_stam_jumpcost.IntValue        =    20;
    g_stam_regen_crouch.IntValue    =    10;
    g_stam_regen_idle.IntValue      =    12;
    g_stam_regen_moving.IntValue    =     6;
    g_stam_regen_sprint.IntValue    =     0;
    g_speed_normal.IntValue         =   116;
    g_speed_riflesights.IntValue    =    60;
    g_speed_sights.IntValue         =    76;
    g_speed_sprint.IntValue         =   224;
    g_respawn_time_notoken.IntValue =    30;
    g_respawn_time_token.IntValue   =     5;
    g_respawn_without_tokens.IntValue =   1;
    // ServerCommand("restartround"); //if onmapend this might crash server lol

    PrintToChatAll("Surf Mode Deactivated.");
}


public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if ( client == 0 || IsFakeClient(client) || !f_surfon)
	{
		return;
	}
	
	CreateTimer(0.2, Timer_DelaySpawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_DelaySpawn(Handle timer, any data){
	int client = GetClientOfUserId(data);
	
	if ( client == 0 || !IsPlayerAlive(client) || g_bMessagesShown[client] )
	{
		return Plugin_Continue;
	}
    char buffer[256];
	g_entrymessage.GetString(buffer, sizeof(buffer));
	PrintToChat(client, "WCM \x07~ \x01Hey Ho, \x03%N", client);
	PrintToChat(client, "%s %s", buffer, client);
	PrintToChat(client, "WCM \x07~ \x01Enjoy!", client);
	g_bMessagesShown[client] = true;
	
	return Plugin_Continue;
}

public void OnClientDisconnect(int client){
	g_bMessagesShown[client] = false;
}
