/*
+----+
|Main|
+----+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Contains some 'base' subroutines. As a general rule nothing in this file   |
| does much, except to setup basic variables and entities.                   |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/
void() precaches;

void() main = {};
void() SetNewParms = {};
void() SetChangeParms = {};
void() StartFrame = 
{
};
void() worldspawn = 
{
	precaches();
	mappath = strcat("maps/", mapname);
	mappath = strzone(mappath);
	dprint("Error: file not found \n");
}

void() precaches =
{
	//models
	precache_model ("progs/player.mdl");
	//precache_model ("progs/Enemies/zombie.mdl");
	
	//precache_model ("progs/ai/zspr.spr");
	precache_model ("progs/ai/zfull.mdl");
	precache_model ("progs/ai/zb#.mdl");
	precache_model ("progs/ai/zal(.mdl");
	precache_model ("progs/ai/zar(.mdl");
	precache_model ("progs/ai/zh^.mdl");
	
	
	precache_model ("progs/ai/zcfull.mdl");
	precache_model ("progs/ai/zbc#.mdl");
	precache_model ("progs/ai/zalc(.mdl");
	precache_model ("progs/ai/zarc(.mdl");
	precache_model ("progs/ai/zhc^.mdl");
	
	
	precache_model ("progs/VModels/mzfl.mdl");
	precache_model ("progs/VModels/v_Colt.mdl");
	precache_model ("progs/VModels/v_knife.mdl");
	precache_model ("progs/VModels/v_nade.mdl");
	precache_model ("progs/VModels/v_betty.mdl");
	precache_model ("progs/GModels/g_grenade.mdl");
	precache_model ("progs/Misc/instakill!.mdl");
	precache_model ("progs/Misc/maxammo!.mdl");
	precache_model ("progs/Sprites/sprkle.spr");
	precache_model ("progs/Misc/nuke!.mdl");
	precache_model ("progs/Misc/carpenter!.mdl");
	precache_model ("progs/Misc/x2!.mdl");
	
	//sprites
	precache_model ("progs/way/current_way.spr");
	precache_model ("progs/way/current_way_door.spr");
	precache_model ("progs/way/last_way.spr");
	precache_model ("progs/way/last_way_door.spr");
	precache_model ("progs/way/normal_way.spr");
	precache_model ("progs/way/normal_way_door.spr");
	precache_model ("progs/way/way_jump.spr");
	precache_model ("progs/way/way_land.spr");
	
	//sounds
	precache_sound ("player/steps/step_1.wav");
	precache_sound ("player/steps/step_2.wav");
	precache_sound ("player/steps/step_3.wav");
	precache_sound ("player/steps/step_4.wav");
	
	precache_sound("misc/ching.wav");
	precache_sound("misc/debris.wav");
	precache_sound("misc/wood_door.wav");
	precache_sound("misc/buy.wav");
	precache_sound ("rounds/splash.wav");
	precache_sound ("rounds/nround.wav");
	precache_sound ("rounds/eround.wav");
	precache_sound ("weapons/colt/shoot.wav");
	precache_sound ("weapons/colt/magout.wav");
	precache_sound ("weapons/colt/magin.wav");
	precache_sound ("weapons/colt/slide.wav");
	precache_sound ("weapons/knife/knife_hitbod.wav");
	precache_sound ("weapons/knife/knife_hit.wav");
	precache_sound ("weapons/knife/knife.wav");
	precache_sound ("weapons/grenade/prime.wav");
	precache_sound ("weapons/grenade/throw.wav");
	
	precache_sound ("pu/double_points.wav");
	precache_sound ("pu/insta_kill.wav");
	precache_sound ("pu/maxammo.wav");
	precache_sound ("pu/nuke.wav");
	precache_sound ("pu/powerup.wav");
	precache_sound ("pu/drop.wav");
	precache_sound ("pu/pickup.wav");
	
	//OLD SOUNDS BACKUP
	/*precache_sound ("zombie/atk1.wav");
	precache_sound ("zombie/atk2.wav");
	precache_sound ("zombie/atk3.wav");
	precache_sound ("zombie/atk4.wav");
	precache_sound ("zombie/atk5.wav");
	precache_sound ("zombie/d1.wav");
	precache_sound ("zombie/d2.wav");
	precache_sound ("zombie/d3.wav");
	precache_sound ("zombie/r1.wav");
	precache_sound ("zombie/r2.wav");
	precache_sound ("zombie/w1.wav");
	precache_sound ("zombie/w2.wav");
	precache_sound ("zombie/w3.wav");
	precache_sound ("zombie/w4.wav");
	precache_sound ("zombie/w5.wav");
	precache_sound ("zombie/w6.wav");*/
	//NEW SOUNDS
	//Walk
	
	precache_sound ("zombie/w0.wav");
	precache_sound ("zombie/w1.wav");
	precache_sound ("zombie/w2.wav");
	precache_sound ("zombie/w3.wav");
	precache_sound ("zombie/w4.wav");
	precache_sound ("zombie/w5.wav");
	precache_sound ("zombie/w6.wav");
	precache_sound ("zombie/w7.wav");
	precache_sound ("zombie/w8.wav");
	precache_sound ("zombie/w9.wav");
	//Run
	precache_sound ("zombie/r0.wav");
	precache_sound ("zombie/r1.wav");
	precache_sound ("zombie/r2.wav");
	precache_sound ("zombie/r3.wav");
	precache_sound ("zombie/r4.wav");
	precache_sound ("zombie/r5.wav");
	precache_sound ("zombie/r6.wav");
	precache_sound ("zombie/r7.wav");
	precache_sound ("zombie/r8.wav");
	precache_sound ("zombie/r9.wav");
	//Attack
	precache_sound ("zombie/a0.wav");
	precache_sound ("zombie/a1.wav");
	precache_sound ("zombie/a2.wav");
	precache_sound ("zombie/a3.wav");
	precache_sound ("zombie/a4.wav");
	precache_sound ("zombie/a5.wav");
	precache_sound ("zombie/a6.wav");
	precache_sound ("zombie/a7.wav");
	//Death
	precache_sound ("zombie/d0.wav");
	precache_sound ("zombie/d1.wav");
	precache_sound ("zombie/d2.wav");
	precache_sound ("zombie/d3.wav");
	precache_sound ("zombie/d4.wav");
	precache_sound ("zombie/d5.wav");
	precache_sound ("zombie/d6.wav");
	precache_sound ("zombie/d7.wav");
	//Taunt
	precache_sound ("zombie/t0.wav");
	precache_sound ("zombie/t1.wav");
	precache_sound ("zombie/t2.wav");
	precache_sound ("zombie/t3.wav");
	precache_sound ("zombie/t4.wav");
	//Footsteps
	precache_sound ("zombie/s0.wav");
	precache_sound ("zombie/s1.wav");
	precache_sound ("zombie/sc0.wav");
	precache_sound ("zombie/sc1.wav");
	
	precache_sound ("music/end.wav");
	
	precache_sound ("null.wav");
};

void() EndFrame =
{
};