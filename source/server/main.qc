//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//
void() SUB_Remove = {remove(self);}

//called when starting server/loading the map
void() main =
{
	localcmd("echo Server starting...\n");
}

//called for each frame that QC runs
float zombie_cleaned_w;
void() StartFrame =
{
	deathmatch = cvar("deathmatch");
	//coop = cvar("coop");
	framecount = framecount + 1;

	if (waypoint_mode) {
		if (!zombie_cleaned_w) {
				entity zent;
				zent = find (world, classname, "ai_zombie");
				while (zent)
				{
					/*
					if (zent.head)
						remove (zent.head);
					if (zent.larm)
						remove (zent.larm);
					if (zent.rarm)
						remove (zent.rarm);
					*/
					remove (zent);
					zent = find (zent, classname, "ai_zombie");
				}
				zombie_cleaned_w = true;
				
				zent = find (world, classname, "waypoint");
				while (zent)
				{
					if (zent.targetname)
						setmodel(zent, "models/way/normal_way_door.spr");
					else
						setmodel(zent, "models/way/normal_way.spr");
					zent = find (zent, classname, "waypoint");
				}
				zent = find (world, classname, "door_nzp_cost");
				while (zent)
				{
					zent.solid = SOLID_NOT;
					zent.touch = SUB_Null;
					zent = find (zent, classname, "door_nzp_cost");
				}
				zent = find (world, classname, "door_nzp");
				while (zent)
				{
					zent.solid = SOLID_NOT;
					zent.touch = SUB_Null;
					zent.solid = SOLID_NOT;
					zent = find (zent, classname, "door_nzp");
				}
				zent = find (world, classname, "window");
				while (zent)
				{
					zent.solid = SOLID_NOT;
					zent.touch = SUB_Null;
					zent = find (zent, classname, "window");
				}
			}
			return;
		}
		
	
	if (roundinit) {
		Round_Core();
		Do_Zombie_AI ();
	} else {
	
		entity SpawnedIn;
		SpawnedIn = find(world, classname, "player");
	
		if (SpawnedIn) {
			entity getdog = find(world, classname, "spawn_dog");
			if (getdog)
				gotdog = 1;
			else 
				gotdog = 0;
				
			updateDogRound();
			InitRounds();
		}
	}
}
string(string s) precache_model         = #20;

void() precaches = 
{
	precache_model ("models/player.mdl");
	
	#ifndef PSP
	#ifndef NX
	precache_model ("models/v_morphine.mdl");

	if (world.song != "")
		precache_sound (world.song);
	#endif
	#endif
	
	precache_model ("progs/Sprites/revive.spr");
	precache_model ("progs/Sprites/revive_white.spr");
	
	precache_model ("models/ai/zfull.mdl");
	precache_model ("models/ai/zb#.mdl");
	precache_model ("models/ai/zal(.mdl");
	precache_model ("models/ai/zar(.mdl");
	precache_model ("models/ai/zh^.mdl");
	
	precache_model ("models/ai/zcfull.mdl");
	precache_model ("models/ai/zbc#.mdl");
	precache_model ("models/ai/zalc(.mdl");
	precache_model ("models/ai/zarc(.mdl");
	precache_model ("models/ai/zhc^.mdl");
	
	precache_model ("models/ai/dog.mdl");

	precache_model ("progs/Misc/maxammo!.mdl");
	precache_model ("progs/Misc/x2!.mdl");
	precache_model ("progs/Misc/instakill!.mdl");
	precache_model ("progs/Misc/nuke!.mdl");
	precache_model ("progs/Misc/carpenter!.mdl");
	
	// Iron: we can now afford to cache every sound because they're MP3s
	// every sound used in NDU is cached immediately as that's the default and most popular map
	
	precache_sound("sounds/player/footstep1.mp3");
	precache_sound("sounds/player/footstep2.mp3");
	precache_sound("sounds/player/footstep3.mp3");
	precache_sound("sounds/player/footstep4.mp3");
	precache_sound("sounds/player/footstep5.mp3");
	precache_sound("sounds/player/jump.mp3");
	precache_sound("sounds/player/jump_grunt.mp3");
	precache_sound("sounds/player/jump_old.mp3");
	precache_sound("sounds/player/jump_step.mp3");
	precache_sound("sounds/player/land.mp3");
	precache_sound("sounds/player/land-vanha1.mp3");
	precache_sound("sounds/items/health.mp3");
	precache_sound("sounds/items/health-vanha1.mp3");
	precache_sound("sounds/items/respawn.mp3");
	
	precache_sound("sounds/weapons/357/close.mp3");
	precache_sound("sounds/weapons/357/in.mp3");
	precache_sound("sounds/weapons/357/open.mp3");
	precache_sound("sounds/weapons/357/out.mp3");
	precache_sound("sounds/weapons/357/shoot.mp3");
	
	precache_sound("sounds/weapons/ballknife/insert.mp3");
	precache_sound("sounds/weapons/ballknife/shoot.mp3");
	
	precache_sound("sounds/weapons/bar/maghit.mp3");
	precache_sound("sounds/weapons/bar/magin.mp3");
	precache_sound("sounds/weapons/bar/magout.mp3");
	precache_sound("sounds/weapons/bar/shoot.mp3");
	
	precache_sound("sounds/weapons/biatch/magin.mp3");
	precache_sound("sounds/weapons/biatch/magout.mp3");
	precache_sound("sounds/weapons/biatch/slideback.mp3");
	precache_sound("sounds/weapons/biatch/sliderelease.mp3");
	
	precache_sound("sounds/weapons/browning/boltback.mp3");
	precache_sound("sounds/weapons/browning/boltforward.mp3");
	precache_sound("sounds/weapons/browning/chainoff.mp3");
	precache_sound("sounds/weapons/browning/chainon.mp3");
	precache_sound("sounds/weapons/browning/chainplace.mp3");
	precache_sound("sounds/weapons/browning/shoot.mp3");
	precache_sound("sounds/weapons/browning/topclose.mp3");
	precache_sound("sounds/weapons/browning/tophit.mp3");
	precache_sound("sounds/weapons/browning/topopen.mp3");

	precache_sound("sounds/weapons/colt/magin.mp3");
	precache_sound("sounds/weapons/colt/magout.mp3");
	precache_sound("sounds/weapons/colt/shoot.mp3");
	precache_sound("sounds/weapons/colt/slide.mp3");
	
	precache_sound("sounds/weapons/fg42/boltback.mp3");
	precache_sound("sounds/weapons/fg42/boltforward.mp3");
	precache_sound("sounds/weapons/fg42/magin.mp3");
	precache_sound("sounds/weapons/fg42/magout.mp3");
	precache_sound("sounds/weapons/fg42/shoot.mp3");

	precache_sound("sounds/weapons/garand/boltrelease.mp3");
	precache_sound("sounds/weapons/garand/clipin.mp3");
	precache_sound("sounds/weapons/garand/clipout.mp3");
	precache_sound("sounds/weapons/garand/clippush.mp3");
	precache_sound("sounds/weapons/garand/shoot.mp3");

	precache_sound("sounds/weapons/m1carbine/bolt.mp3");
	precache_sound("sounds/weapons/m1carbine/maghit.mp3");
	precache_sound("sounds/weapons/m1carbine/magin.mp3");
	precache_sound("sounds/weapons/m1carbine/magout.mp3");
	precache_sound("sounds/weapons/m1carbine/shoot.mp3");
	
	precache_sound("sounds/weapons/shotgun/close.mp3");
	precache_sound("sounds/weapons/shotgun/dbsg.mp3");
	precache_sound("sounds/weapons/shotgun/in.mp3");
	precache_sound("sounds/weapons/shotgun/insert.mp3");
	precache_sound("sounds/weapons/shotgun/open.mp3");
	precache_sound("sounds/weapons/shotgun/out.mp3");
	precache_sound("sounds/weapons/shotgun/pump.mp3");
	precache_sound("sounds/weapons/shotgun/sawoffsg.mp3")	
	precache_sound("sounds/weapons/shotgun/shoot.mp3");
	
	precache_sound("sounds/weapons/papfire.mp3");
	
	precache_sound("sounds/weapons/grenade/prime.mp3");
	precache_sound("sounds/weapons/grenade/throw.mp3");
	precache_sound("sounds/weapons/grenade/explode.mp3");
	
	precache_sound("sounds/weapons/thomp/boltback.mp3");
	precache_sound("sounds/weapons/thomp/magin.mp3");
	precache_sound("sounds/weapons/thomp/magout.mp3");
	precache_sound("sounds/weapons/thomp/shoot.mp3");
	
	precache_sound("sounds/weapons/tommy/boltback.mp3");
	precache_sound("sounds/weapons/tommy/magin.mp3");
	precache_sound("sounds/weapons/tommy/magout.mp3");
	precache_sound("sounds/weapons/tommy/shoot.mp3");

	precache_sound("sounds/weapons/knife/knife_hitbod.mp3");
	precache_sound("sounds/weapons/knife/knife.mp3");
	precache_sound("sounds/weapons/knife/knife_hit.mp3");
	
	precache_sound("sounds/rounds/eround.mp3");
	precache_sound("sounds/rounds/nround.mp3");
	precache_sound("sounds/rounds/splash.mp3");
	precache_sound("sounds/music/end.mp3");
	precache_sound("sounds/null.mp3");

	precache_sound("sounds/misc/buy.mp3");
	precache_sound("sounds/misc/wood_door.mp3");
	precache_sound("sounds/misc/debris.mp3");
	precache_sound("sounds/misc/denybuy.mp3");
	
	precache_sound("sounds/misc/what.mp3");

	precache_model ("models/weapons/m1911/v_colt.mdl");
	precache_model ("models/weapons/m1911/g_colt.mdl");
	precache_model ("progs/VModels/v_knife.mdl");
	precache_model ("progs/VModels/v_nade.mdl");
	precache_model ("progs/GModels/g_grenade.mdl");
	precache_model ("progs/GModels/g_betty.mdl");	
	
	//sprites
	precache_model ("models/way/current_way.spr");
	precache_model ("models/way/current_way_door.spr");
	precache_model ("models/way/last_way.spr");
	precache_model ("models/way/last_way_door.spr");
	precache_model ("models/way/normal_way.spr");
	precache_model ("models/way/normal_way_door.spr");
	precache_model ("models/way/way_jump.spr");
	precache_model ("models/way/way_land.spr");
	precache_model ("progs/Sprites/sprkle.spr");


	
	//Walk
	
	precache_sound ("sounds/zombie/w0.mp3");
	precache_sound ("sounds/zombie/w1.mp3");
	precache_sound ("sounds/zombie/w2.mp3");
	precache_sound ("sounds/zombie/w3.mp3");
	precache_sound ("sounds/zombie/w4.mp3");
	precache_sound ("sounds/zombie/w5.mp3");
	precache_sound ("sounds/zombie/w6.mp3");
	precache_sound ("sounds/zombie/w7.mp3");
	precache_sound ("sounds/zombie/w8.mp3");
	precache_sound ("sounds/zombie/w9.mp3");
	//Run
	precache_sound ("sounds/zombie/r0.mp3");
	precache_sound ("sounds/zombie/r1.mp3");
	precache_sound ("sounds/zombie/r2.mp3");
	precache_sound ("sounds/zombie/r3.mp3");
	precache_sound ("sounds/zombie/r4.mp3");
	precache_sound ("sounds/zombie/r5.mp3");
	precache_sound ("sounds/zombie/r6.mp3");
	precache_sound ("sounds/zombie/r7.mp3");
	precache_sound ("sounds/zombie/r8.mp3");
	precache_sound ("sounds/zombie/r9.mp3");
	//Attack
	precache_sound ("sounds/zombie/a0.mp3");
	precache_sound ("sounds/zombie/a1.mp3");
	precache_sound ("sounds/zombie/a2.mp3");
	precache_sound ("sounds/zombie/a3.mp3");
	precache_sound ("sounds/zombie/a4.mp3");
	precache_sound ("sounds/zombie/a5.mp3");
	precache_sound ("sounds/zombie/a6.mp3");
	precache_sound ("sounds/zombie/a7.mp3");
	//Death
	precache_sound ("sounds/zombie/d0.mp3");
	precache_sound ("sounds/zombie/d1.mp3");
	precache_sound ("sounds/zombie/d2.mp3");
	precache_sound ("sounds/zombie/d3.mp3");
	precache_sound ("sounds/zombie/d4.mp3");
	precache_sound ("sounds/zombie/d5.mp3");
	precache_sound ("sounds/zombie/d6.mp3");
	precache_sound ("sounds/zombie/d7.mp3");
	//Taunt
	precache_sound ("sounds/zombie/t0.mp3");
	precache_sound ("sounds/zombie/t1.mp3");
	precache_sound ("sounds/zombie/t2.mp3");
	precache_sound ("sounds/zombie/t3.mp3");
	precache_sound ("sounds/zombie/t4.mp3");
	//Footsteps
	precache_sound ("sounds/zombie/s0.mp3");
	precache_sound ("sounds/zombie/s1.mp3");
	precache_sound ("sounds/zombie/sc0.mp3");
	precache_sound ("sounds/zombie/sc1.mp3");
	//Announce
	precache_sound ("sounds/pu/pickup.mp3");
	precache_sound ("sounds/pu/maxammo.mp3");
	precache_sound ("sounds/pu/double_points.mp3");
	precache_sound ("sounds/pu/insta_kill.mp3");
	precache_sound ("sounds/pu/nuke.mp3");
	precache_sound ("sounds/pu/powerup.mp3");
	precache_sound ("sounds/pu/drop.mp3");
}

//called when map loaded
void() worldspawn =
{
	precaches();

	#ifndef PSP
	#ifndef NX 		// Keep this here, we shouldn't have these on anything but PC...
					// or just define PC....
	clientstat(STAT_CURRENTMAG, EV_FLOAT, currentmag);
	clientstat(STAT_CURRENTMAG2, EV_FLOAT, currentmag2);
	clientstat(STAT_POINTS, EV_FLOAT, points);
	clientstat(STAT_WEAPON2FRAME, EV_FLOAT, weapon2frame);
	clientstat(STAT_WEAPON2MODEL, EV_STRING, weapon2model);
	clientstat(STAT_GRENADES, EV_FLOAT, primary_grenades);
	clientstat(STAT_SECGRENADES, EV_FLOAT, secondary_grenades);
	clientstat(STAT_PROGRESSBAR, EV_FLOAT, progress_bar_percent);
	clientstat(STAT_WEAPONDURATION, EV_FLOAT, weapon_animduration);
	clientstat(STAT_WEAPON2DURATION, EV_FLOAT, weapon2_animduration);
	clientstat(STAT_WEAPONZOOM, EV_FLOAT, zoom);
	clientstat(STAT_INSTA, EV_FLOAT, insta_icon);
	clientstat(STAT_X2, EV_FLOAT, x2_icon);
	clientstat(STAT_SPECTATING, EV_FLOAT, isspec);
	clientstat(STAT_PLAYERNUM, EV_FLOAT, playernum);		// literally useless but will be kept in case
	clientstat(STAT_PLAYERSTANCE, EV_FLOAT, stance);
	#endif
	#endif 
	
	mappath = strcat("maps/", mapname);
	mappath = strzone(mappath);

	LoadWaypointData();
		
	//set game elements
	G_STARTPOINTS = 500;
	G_STARTROUND = 1;
	G_PRONEPOINTS = 0;
	G_STARTWEAPON[0] = W_COLT;
	G_STARTWEAPON[1] = 8;
	G_STARTWEAPON[2] = 32;
	G_WORLDTEXT = 1;
	G_PERKS = 0;
	G_PERKPOWER = 0;
	load_nzd();
	
}

void() SpectatorConnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has joined the spectators.\n");
}

#ifdef PSP
void() RelinkZombies =
{
	entity ent,ent2;
	local float i;
	local vector min, max;
	while ((ent = find (ent, classname, "ai_zombie")))
	{
		if(ent.currentHitBoxSetup == 0)//empty bbox, we don't care to update
			continue;
		
		makevectors (ent.angles);
		
		for(i = 0; i < 3; i++)
		{
			if(i == 0)
				ent2 = ent.head;
			if(i == 1)
				ent2 = ent.larm;
			if(i == 2)
				ent2 = ent.rarm;
				
			
			if (ent2)
			{
				//setorigin (ent.head, ent.origin + v_right * ent.head.view_ofs_x + v_forward * ent.head.view_ofs_y + v_up * ent.head.view_ofs_z);
				setorigin (ent2, ent.origin);
				//fixme, move angles set and frame set to below the continue, we only want to update origin (maybe angles too?)
				ent2.angles = ent.angles;
				
				if(ent2.deadflag)
					ent2.frame = ent.frame; 
				
				//if(OnlyOrigin)
				//	continue;
					
				min = ent2.bbmins + (v_right * ent2.view_ofs_x) + (v_forward * ent2.view_ofs_y) + (v_up * ent2.view_ofs_z);
				max = ent2.bbmaxs + (v_right * ent2.view_ofs_x) + (v_forward * ent2.view_ofs_y) + (v_up * ent2.view_ofs_z);
				
				if(min_x > max_x) { min_x += max_x; max_x = min_x - max_x; min_x -= max_x; }
				if(min_y > max_y) { min_y += max_y; max_y = min_y - max_y; min_y -= max_y; }
				if(min_z > max_z) { min_z += max_z; max_z = min_z - max_z; min_z -= max_z; }
				
				setsize(ent2,min,max);
			}

		}
	}
}

void() EndFrame =
{
	RelinkZombies();
};
#endif