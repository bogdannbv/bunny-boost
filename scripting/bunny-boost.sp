#include <sourcemod>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME "BunnyBoost"
#define PLUGIN_VERSION "0.1.0"

#define HORIZONTAL 33
#define VERTICAL 33

#define ENABLED_DEFAULT "1"
#define STRENGTH_DEFAULT "2"

ConVar CvarEnabled;
ConVar CvarUpwardStrength;
ConVar CvarForwardStrength;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "BogdanNBV",
	version = PLUGIN_VERSION,
	description = "Yet another bunny hop boost plugin.",
	url = "https://github.com/bogdannbv/bunny-boost"
};

public void OnPluginStart()
{
	CreateConVar("sm_bunny-boost_version", PLUGIN_VERSION, "BunnyBoost version.", FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_DONTRECORD|FCVAR_SPONLY);

	CvarEnabled = CreateConVar("sm_bunny-boost_enabled", ENABLED_DEFAULT, "Determines if the plugin should be enabled.", FCVAR_NOTIFY|FCVAR_REPLICATED);

	CvarUpwardStrength = CreateConVar("sm_bunny-boost_upward_strength", STRENGTH_DEFAULT, "The upwards boost strength.", FCVAR_NOTIFY|FCVAR_REPLICATED);

	CvarForwardStrength = CreateConVar("sm_bunny-boost_forward_strength", STRENGTH_DEFAULT, "The forwards boost strength.", FCVAR_NOTIFY|FCVAR_REPLICATED);

	AutoExecConfig(true);

	HookEvent("player_jump", EventPlayerJump);
}

public Action EventPlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	if (CvarEnabled.IntValue != 1) {
		return Plugin_Continue;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	float viewVector[3];

	float angle0 = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[0]");
	float angle1 = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[1]");

	float baseVelocity[3];

	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", baseVelocity);

	viewVector[0] = Cosine(DegToRad(angle1));
	viewVector[1] = Sine(DegToRad(angle1));
	viewVector[2] = -1 * Sine(DegToRad(angle0));

	viewVector[0] = float(HORIZONTAL) * CvarForwardStrength.FloatValue * viewVector[0];
	viewVector[1] = float(HORIZONTAL) * CvarForwardStrength.FloatValue * viewVector[1];
	viewVector[2] = float(VERTICAL) * CvarUpwardStrength.FloatValue;

	AddVectors(baseVelocity, viewVector, viewVector);

	SetEntPropVector(client, Prop_Send, "m_vecBaseVelocity", viewVector);

	return Plugin_Continue;
}
