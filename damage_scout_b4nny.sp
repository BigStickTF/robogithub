#pragma semicolon 1
#include <sourcemod>
#include <tf2_stocks>
#include <tf2attributes>
#include <sm_logger>
#include <berobot_constants>
#include <berobot>

#define PLUGIN_VERSION "1.0"
#define ROBOT_NAME	"B4nny"
#define ROBOT_ROLE "Damage"
#define ROBOT_DESCRIPTION "Scatter Scout"

#define GSCOUT		"models/bots/scout_boss/bot_scout_boss.mdl"
#define SPAWN	"#mvm/giant_heavy/giant_heavy_entrance.wav"
#define DEATH	"mvm/sentrybuster/mvm_sentrybuster_explode.wav"
#define LOOP	"mvm/giant_scout/giant_scout_loop.wav"

#define LEFTFOOT        ")mvm/giant_scout/giant_scout_step_01.wav"
#define LEFTFOOT1       ")mvm/giant_scout/giant_scout_step_03.wav"
#define RIGHTFOOT       ")mvm/giant_scout/giant_scout_step_02.wav"
#define RIGHTFOOT1      ")mvm/giant_scout/giant_scout_step_04.wav"

#define PRINNYPOUCH 30757
#define GRAYBANNS 30104
#define BROTHEROFARMS 30066

public Plugin:myinfo = 
{
	name = "[TF2] Be the Giant <Someone> Scout",
	author = "Erofix using the code from: Pelipoika, PC Gamer, Jaster and StormishJustice",
	description = "Play as the Giant Scout",
	version = PLUGIN_VERSION,
	url = "www.sourcemod.com"
}

char LOG_TAGS[][] = {"VERBOSE", "INFO", "ERROR"};
enum(<<= 1)
{
    SML_VERBOSE = 1,
    SML_INFO,
    SML_ERROR,
}

public OnPluginStart()
{
    SMLoggerInit(LOG_TAGS, sizeof(LOG_TAGS), SML_ERROR, SML_FILE);

	LoadTranslations("common.phrases");

	AddNormalSoundHook(BossScout);


	RobotDefinition robot;
    robot.name = ROBOT_NAME;
    robot.role = ROBOT_ROLE;
    robot.class = "Scout";
    robot.shortDescription = ROBOT_DESCRIPTION;
    robot.sounds.spawn = SPAWN;
    robot.sounds.loop = LOOP;
    robot.sounds.death = DEATH;
	AddRobot(robot, MakeGiantscout, PLUGIN_VERSION);
}

public void OnPluginEnd()
{
	RemoveRobot(ROBOT_NAME);
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
//	CreateNative("BeGiantPyro_MakeGiantscout", Native_SetGiantPyro);
//	CreateNative("BeGiantPyro_IsGiantPyro", Native_IsGiantPyro);
	return APLRes_Success;
}

public OnMapStart()
{
	PrecacheModel(GSCOUT);
	PrecacheSound(SPAWN);
	PrecacheSound(DEATH);
	PrecacheSound(LOOP);
	

	PrecacheSound("mvm/giant_scout/giant_scout_step_01.wav");
	PrecacheSound("mvm/giant_scout/giant_scout_step_03.wav");
	PrecacheSound("mvm/giant_scout/giant_scout_step_02.wav");
	PrecacheSound("mvm/giant_scout/giant_scout_step_04.wav");
	
	//PrecacheSound(SOUND_GUNFIRE);
	//PrecacheSound(SOUND_WINDUP);
	
}

public Action:SetModel(client, const String:model[])
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");

		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}
}

public Action:BossScout(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
		if (!IsValidClient(entity)) return Plugin_Continue;
		if (!IsRobot(entity, ROBOT_NAME)) return Plugin_Continue;

	if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		if (StrContains(sample, "1.wav", false) != -1)
		{
			Format(sample, sizeof(sample), "mvm/giant_scout/giant_scout_step_01.wav");
			EmitSoundToAll(sample, entity);
		}
		else if (StrContains(sample, "3.wav", false) != -1)
		{
			Format(sample, sizeof(sample), "mvm/giant_scout/giant_scout_step_03.wav");
			EmitSoundToAll(sample, entity);
		}
		else if (StrContains(sample, "2.wav", false) != -1)
		{
			Format(sample, sizeof(sample), "mvm/giant_scout/giant_scout_step_02.wav");
			EmitSoundToAll(sample, entity);
		}
		else if (StrContains(sample, "4.wav", false) != -1)
		{
			Format(sample, sizeof(sample), "mvm/giant_scout/giant_scout_step_04.wav");
			EmitSoundToAll(sample, entity);
		}
		return Plugin_Changed;
	}
	if (volume == 0.0 || volume == 0.9997) return Plugin_Continue;

	return Plugin_Continue;
}

MakeGiantscout(client)
{
	SMLogTag(SML_VERBOSE, "Createing ScoutName");
	TF2_SetPlayerClass(client, TFClass_Scout);
	TF2_RegeneratePlayer(client);

	new ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (ragdoll > MaxClients && IsValidEntity(ragdoll)) AcceptEntityInput(ragdoll, "Kill");
	decl String:weaponname[32];
	GetClientWeapon(client, weaponname, sizeof(weaponname));
	if (strcmp(weaponname, "tf_weapon_", false) == 0) 
	{
		SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Send, "m_iWeaponState", 0);
		TF2_RemoveCondition(client, TFCond_Slowed);
	}
	CreateTimer(0.0, Timer_Switch, client);
	SetModel(client, GSCOUT);
	
	int iHealth = 1250;
		
	int MaxHealth = 125;
	//PrintToChatAll("MaxHealth %i", MaxHealth);
	
	int iAdditiveHP = iHealth - MaxHealth;
	
	TF2_SetHealth(client, iHealth);
	// PrintToChatAll("iHealth %i", iHealth);
	
	// PrintToChatAll("iAdditiveHP %i", iAdditiveHP);
	
	
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.75);
	SetEntProp(client, Prop_Send, "m_bIsMiniBoss", true);
	TF2Attrib_SetByName(client, "max health additive bonus", float(iAdditiveHP));
	TF2Attrib_SetByName(client, "ammo regen", 100.0);
	TF2Attrib_SetByName(client, "move speed penalty", 0.75);
	TF2Attrib_SetByName(client, "damage force reduction", 1.5);
	TF2Attrib_SetByName(client, "airblast vulnerability multiplier", 1.5);
	TF2Attrib_SetByName(client, "airblast vertical vulnerability multiplier", 1.0);
	float HealthPackPickUpRate =  float(MaxHealth) / float(iHealth);
	TF2Attrib_SetByName(client, "health from packs decreased", HealthPackPickUpRate);
	TF2Attrib_SetByName(client, "cancel falling damage", 1.0);
	TF2Attrib_SetByName(client, "patient overheal penalty", 0.15);
	
	
	TF2Attrib_SetByName(client, "increased jump height", 1.25);
	TF2Attrib_SetByName(client, "rage giving scale", 0.85);
	TF2Attrib_SetByName(client, "self dmg push force increased", 3.0);
	
	UpdatePlayerHitbox(client, 1.75);
	
	TF2_RemoveCondition(client, TFCond_CritOnFirstBlood);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.1);
	
	PrintToChat(client, "1. You are now Giant B4nny!");
	// SetEntProp(client, Prop_Send, "m_bForcedSkin", 1);
	// SetEntProp(client, Prop_Send, "m_nForcedSkin", 0);

}

stock TF2_SetHealth(client, NewHealth)
{
	SetEntProp(client, Prop_Send, "m_iHealth", NewHealth, 1);
	SetEntProp(client, Prop_Data, "m_iHealth", NewHealth, 1);
SetEntProp(client, Prop_Data, "m_iMaxHealth", NewHealth, 1);
}

public Action:Timer_Switch(Handle:timer, any:client)
{
	if (IsValidClient(client))
		GiveGiantPyro(client);
}

stock GiveGiantPyro(client)
{
	if (IsValidClient(client))
	{
		RoboRemoveAllWearables(client);

		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 2);

		CreateRoboWeapon(client, "tf_weapon_scattergun", 13, 6, 1, 0, 0);//scattergun
		CreateRoboWeapon(client, "tf_weapon_pistol", 294, 6, 1, 1, 0);//lugermorph
		CreateRoboWeapon(client, "tf_weapon_bat", 452, 6, 1, 2, 0);//three rune blade
		
		CreateRoboHat(client, PRINNYPOUCH, 10, 6, 0.0, 1.0, -1.0); //Prinny Pouch
		CreateRoboHat(client, GRAYBANNS, 10, 6, 1315860.0, 1.0, 0.0);//gray banns
		CreateRoboHat(client, BROTHEROFARMS, 10, 6, 1315860.0, 1.0, -1.0); //brotherhood of arms
		
		//TF2Attrib_SetByDefIndex(hat, 542, 2.0);

		int Scattergun = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
		int Lugermorph = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		int Threerune = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);

		if(IsValidEntity(Scattergun))
		{
			TF2Attrib_RemoveAll(Scattergun);
			TF2Attrib_SetByName(Scattergun, "killstreak tier", 1.0);
			TF2Attrib_SetByName(Threerune, "fire rate bonus", 0.9);
			TF2Attrib_SetByName(Scattergun, "weapon spread bonus", 0.6);
			TF2Attrib_SetByName(Scattergun, "clip size bonus", 1.4);
			TF2Attrib_SetByName(Scattergun, "Reload time increased", 0.8);
			TF2Attrib_SetByName(Scattergun, "dmg penalty vs players", 1.30);
		}
		if(IsValidEntity(Lugermorph))
		{
			TF2Attrib_RemoveAll(Lugermorph);
			TF2Attrib_SetByName(Lugermorph, "killstreak tier", 1.0);
			TF2Attrib_SetByName(Lugermorph, "clip size bonus", 1.35);
			TF2Attrib_SetByName(Scattergun, "Reload time increased", 0.4);
			
		}
		if(IsValidEntity(Threerune))
		{
			TF2Attrib_RemoveAll(Threerune);
			TF2Attrib_SetByName(Threerune, "killstreak tier", 1.0);
			TF2Attrib_SetByName(Threerune, "fire rate bonus", 0.75);
		}
	}
}
 
public Native_SetGiantPyro(Handle:plugin, args)
	MakeGiantscout(GetNativeCell(1));

