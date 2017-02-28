//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//

//called when starting server/loading the map
void() main =
{
	localcmd("echo Server starting...\n");

}

//called for each frame that QC runs
void() StartFrame =
{
	deathmatch = cvar("deathmatch");
	framecount = framecount + 1;

	
}

//called when map loaded
void() worldspawn =
{
	precache_model("models/humanoid_simplerig.iqm");
	
	precache_sound("sounds/player/footstep1.wav");
	precache_sound("sounds/player/footstep2.wav");
	precache_sound("sounds/player/footstep3.wav");
	precache_sound("sounds/player/footstep4.wav");
	precache_sound("sounds/player/footstep5.wav");
	precache_sound("sounds/player/jump.wav");
	precache_sound("sounds/player/land.wav");
	precache_sound("sounds/items/health.wav");
	precache_sound("sounds/items/respawn.wav");
	precache_sound("sounds/weapons/mg.wav");

	precache_sound("sounds/weapons/colt/magin.wav");
	precache_sound("sounds/weapons/colt/magout.wav");
	precache_sound("sounds/weapons/colt/shoot.wav");
	precache_sound("sounds/weapons/colt/slide.wav");
	
	precache_sound("sounds/weapons/grenade/prime.wav");
	precache_sound("sounds/weapons/grenade/throw.wav");
	
	precache_sound("sounds/misc/ching.wav");
	precache_sound("sounds/misc/buy.wav");
	precache_sound("sounds/misc/wood_door.wav");
	precache_sound("sounds/misc/debris.wav");

	
	precache_model ("models/weapons/m1911/v_colt.mdl");
	precache_model ("progs/VModels/v_nade.mdl");
	precache_model ("progs/GModels/g_grenade.mdl");
	precache_model ("progs/GModels/g_betty.mdl");

	clientstat(STAT_CURRENTMAG, EV_FLOAT, currentmag);
	clientstat(STAT_POINTS, EV_FLOAT, points);
	clientstat(STAT_WEAPON2FRAME, EV_FLOAT, weapon2frame);
	clientstat(STAT_WEAPON2MODEL, EV_STRING, weapon2model);
	clientstat(STAT_GRENADES, EV_FLOAT, primary_grenades);
	clientstat(STAT_SECGRENADES, EV_FLOAT, secondary_grenades);
	
}

void() SpectatorConnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has joined the spectators.\n");
}

