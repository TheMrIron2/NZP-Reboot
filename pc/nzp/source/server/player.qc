//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//


// player animations

void() playdown 	 	=[	1,		playdown1	  	] {self.frame = 32;}
void() playdown1  		=[	2,		playdown2	  	] {self.frame = 33;} 
void() playdown2  		=[	2,		playdown3	  	] {self.frame = 34;} 
void() playdown3  		=[	2,		playdown4	  	] {self.frame = 35;} 
void() playdown4  		=[	2,		playdown5	  	] {self.frame = 36;} 
void() playdown5  		=[	2,		playdown5	  	] {self.frame = 37;} 
//
void() playreload   	=[	1,		playreload1	  	] {self.frame = 11;}
void() playreload1  	=[	2,		playreload2	  	] {self.frame = 12;}
void() playreload2  	=[	3,		playreload3	  	] {self.frame = 13;}
void() playreload3  	=[	4,		playreload4	  	] {self.frame = 14;}
void() playreload4  	=[	5,		playreload5	  	] {self.frame = 15;}
void() playreload5  	=[	6,		playreload6	  	] {self.frame = 16;}
void() playreload6  	=[	7,		playreload7	  	] {self.frame = 17;}
void() playreload7  	=[	8,		playreload8	 	] {self.frame = 18;}
void() playreload8  	=[	9,		playreload9 	] {self.frame = 19;}
void() playreload9   	=[	10,		playreload10	] {self.frame = 20;}
void() playreload10 	=[	11,		playreload11	] {self.frame = 21;}
void() playreload11 	=[	12,		playreload12	] {self.frame = 22;}
void() playreload12 	=[	13,		playreload13	] {self.frame = 23;}
void() playreload13 	=[	14,		playreload13	] {self.frame = 24;}
//
void() playdownfire 	=[	1,		playdownfire1	] {self.frame = 38;}
void() playdownfire1  	=[	2,		playdownfire1	] {self.frame = 39;} 
//
void() playaim 	 		=[	1,		playaim1		] {self.frame = 8;} // naievil -- player aimin anim
void() playaim1 		=[	2,		playaim1		] {self.frame = 9;} // naievil -- second player aimin anim
//
void() playout 	  		=[	1,		playout1		] {self.frame = 10;} // naievil -- player aim out anim
void() playout1 		=[	2,		playout1		] {self.frame = 11;} // naievil -- second player aim out anim
//
void() playrun1 		=[	1,		playrun2		] {self.frame = 25;}
void() playrun2 		=[	2,		playrun3		] {self.frame = 26;}
void() playrun3		 	=[	3,		playrun4		] {self.frame = 27;}
void() playrun4 		=[	4,		playrun5		] {self.frame = 28;}
void() playrun5 		=[	5,		playrun6		] {self.frame = 29;}
void() playrun6 		=[	6,		playrun7		] {self.frame = 30;}
void() playrun7 		=[	7,		playrun8		] {self.frame = 31;}
void() playrun8 		=[	8,		playrun9		] {self.frame = 25;}
void() playrun9 		=[	9,		playrun10		] {self.frame = 26;}
void() playrun10 		=[	10,		playrun11		] {self.frame = 27;}
void() playrun11 		=[	11,		playrun12		] {self.frame = 28;}
void() playrun12 		=[	12,		playrun13		] {self.frame = 29;}
void() playrun13 		=[	13,		playrun14		] {self.frame = 30;}
void() playrun14 		=[	14,		playrun15		] {self.frame = 25;}
void() playrun15 		=[	15,		playrun16		] {self.frame = 26;}
void() playrun16 		=[	16,		playrun17		] {self.frame = 27;}
void() playrun17 		=[	17,		playrun18		] {self.frame = 28;}
void() playrun18 		=[	18,		playrun19		] {self.frame = 29;}
void() playrun19 		=[	19,		playrun20		] {self.frame = 30;}
void() playrun20 		=[	20,		playrun21		] {self.frame = 31;}
void() playrun21 		=[	21,		playrun22		] {self.frame = 25;}
void() playrun22 		=[	22,		playrun23		] {self.frame = 26;}
void() playrun23 		=[	23,		playrun24 		] {self.frame = 27;}
void() playrun24 		=[	24,		playrun25		] {self.frame = 28;}
void() playrun25 		=[	25,		playrun26		] {self.frame = 29;}
void() playrun26 		=[	26,		playrun27		] {self.frame = 30;}
void() playrun27 		=[	27,		playrun28		] {self.frame = 25;}
void() playrun28 		=[	28,		playrun29		] {self.frame = 26;}
void() playrun29 		=[	29,		playrun30		] {self.frame = 27;}
void() playrun30 		=[	30,		playrun31		] {self.frame = 28;}
void() playrun31 		=[	31,		playrun32		] {self.frame = 29;}
void() playrun32 		=[	32,		playrun33		] {self.frame = 30;}
void() playrun33 		=[	33,		playrun33		] {self.frame = 31;}
//
void() playwalk		=[   1,     playwalk1		] {if (self.velocity) { self.frame = 0; }}
void() playwalk1		=[   2,     playwalk2		] {if (self.velocity) { self.frame = 1; }}
void() playwalk2		=[   3,     playwalk3		] {if (self.velocity) { self.frame = 2; }}
void() playwalk3		=[   4,     playwalk4		] {if (self.velocity) { self.frame = 3; }}
void() playwalk4		=[   5,     playwalk5		] {if (self.velocity) { self.frame = 4; }}
void() playwalk5		=[   6,     playwalk6		] {if (self.velocity) { self.frame = 5; }}
void() playwalk6		=[   7,     playwalk7		] {if (self.velocity) { self.frame = 6; }}
void() playwalk7		=[   8,     playwalk8		] {if (self.velocity) { self.frame = 7; }}
void() playwalk8		=[   9,     playwalk8		] {if (self.velocity) { self.frame = 8; }}
//
void() playgetup 		=[	1,		playgetup1		] {self.frame = 38;}
void() playgetup1 		=[	2,		playgetup2		] {self.frame = 39;}
void() playgetup2		=[	3,		playgetup3		] {self.frame = 40;}
void() playgetup3		=[	4,		playgetup4		] {self.frame = 41;}
void() playgetup4		=[	5,		playgetup5		] {self.frame = 42;}
void() playgetup5		=[	6,		playgetup6		] {self.frame = 43;}
void() playgetup6		=[	7,		playgetup7		] {self.frame = 44;}
void() playgetup7		=[	8,		playgetup8		] {self.frame = 45;}
void() playgetup8		=[	9,		playgetup9		] {self.frame = 46;}
void() playgetup9		=[	10,		playgetup10		] {self.frame = 47;}
void() playgetup10		=[	11,		playgetup10		] {self.frame = 48;}


void() PlayerJump =
{
	if (!(self.flags & FL_ONGROUND) 
	    || !(self.flags & FL_JUMPRELEASED)
		|| self.downed) {
		return;
	}
			
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	sound(self, CHAN_VOICE, "sounds/player/jump.wav", 1, 1.75);
	self.button2 = 0;
}

void() PlayerPreThink =
{

	if (self.downed) {
		self.maxspeed = 30;
	} else {
		self.maxspeed = 175;
		if (self.sprinting) {
			playrun1();
			self.maxspeed *= 1.66;
		} else if (self.zoom == 1) {
			self.maxspeed *= 0.5;
		} if (self.damagetimer > time) {
			self.maxspeed *= 0.5;
		}

		self.maxspeed *= GetWeaponWalkSpeed(self.weapon);
	}
	if(self.isspec != 0 && !self.downed)
	{
		if(self.button0)
		{
			self.aiment = find(self.aiment, classname, "player");
			if(self.aiment != world)
			{
				sprint(self, PRINT_HIGH, "Now spectating ");
				sprint(self, PRINT_HIGH, self.aiment.netname);
				sprint(self, PRINT_HIGH, "\n");
				
				self.solid = SOLID_NOT;
				self.movetype = MOVETYPE_NONE;
			}
			else
			{
				sprint(self, PRINT_HIGH, "Freefly spectate\n");
				self.movetype = MOVETYPE_FLY;
			}
		}
		if(self.aiment != world)
		{
			self.origin = self.aiment.origin;
			self.angles = self.aiment.v_angle;
			self.velocity = self.aiment.velocity;
			self.fixangle = TRUE;
		}
		return;
	}
	
	if (cvar("waypoint_mode")) {
		Waypoint_Logic();
	} else {
		Weapon_Logic();
	}
	

	if(self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;
};

void() PlayerPostThink =
{
	if(self.isspec)
		return;
	
	//landsound
	if((self.oldvelocity_z < -10) && (self.flags & FL_ONGROUND))
	{
		if(self.oldvelocity_z < -270)
			sound(self, CHAN_BODY, "sounds/player/land.wav", 1, 1.75);
		self.lastsound_time = time - 0.15;
	}
	
	//footsteps
	if((vlen(self.velocity) > 100) &&(( time - self.lastsound_time > 0.4) || (time - self.lastsound_time > 0.3 && self.sprinting)) && (self.flags & FL_ONGROUND))
	{
		local float movelen = vlen(input_movevalues);
		if(movelen > 300)
		{
			if (!self.sprinting)
				playwalk();
				
			local float ran = random();
			if(ran > 0.8)
				sound(self, CHAN_BODY, "sounds/player/footstep1.wav", 0.8, 2.5);
			else if(ran > 0.6)
				sound(self, CHAN_BODY, "sounds/player/footstep2.wav", 0.8, 2.5);
			else if(ran > 0.4)
				sound(self, CHAN_BODY, "sounds/player/footstep3.wav", 0.8, 2.5);
			else if(ran > 0.2)
				sound(self, CHAN_BODY, "sounds/player/footstep4.wav", 0.8, 2.5);
			else
				sound(self, CHAN_BODY, "sounds/player/footstep5.wav", 0.8, 2.5);
			self.lastsound_time = time;
		}
	}
	
	if (self.health_delay < time && self.health != self.max_health && !self.downed)
	{
		self.health = self.health + 5;
		if (self.max_health < self.health)
			self.health = self.max_health;
	}
	
	if (self.progress_bar) {
		if (self.progress_bar < time) {
			if (self.downed)
				GetUp();
			
			if (self.reviving)
				self.revived = 1;
			
			self.progress_bar = 0;
			self.progress_bar_time = 0;
			self.progress_bar_percent = 0;
			
				
		} else {
			float remaining = self.progress_bar - time;
			self.progress_bar_percent = invertfloat((remaining / self.progress_bar_time));
		}
	}


	if (self.sprinting) {
		if (!self.velocity) {
			W_SprintStop();
		}
		
		if (self.perks & P_STAMIN) {
			self.stamina = self.stamina - 5*frametime;
		} else {
			self.stamina = self.stamina - (10*frametime);
		}

		if (self.stamina <= 0) {
			W_SprintStop();
		}
	} else if (self.stamina < 3) 	{
		self.stamina = self.stamina + 10*frametime;
		if (self.stamina > 3) {
			self.stamina = 3;
		}
	}

	self.oldvelocity = self.velocity;
};

void() ClientKill =
{
};

//called when a client connects to the server
void() ClientConnect =
{
	if (mapname == "ndu")	{			// the only one we REALLY need to fix is NDU since I don't want to edit the file
		stuffcmd(self, "sky sky\n");
		stuffcmd(self, "fog 0.075\n"); // naievil -- temp reliable fog
	}
	
	bprint(PRINT_HIGH, self.netname); //print player name
	bprint(PRINT_HIGH, " connected.\n");
};

void() PollPlayerPoints =
{
	float i, breakpoint;
	entity pollent;
	breakpoint = 0;
	
	for (i = 1; i <= 4 && !breakpoint; i++)
	{
		pollent = findfloat(world, playernum, i);
		
		if (pollent == world) {
			breakpoint = 1;
			break;
		}
		
		
		UpdatePlayerPoints(i, pollent.points, pollent.netname, pollent);
	}
}

void() PlayerSpawn =
{	
	local entity spawnpoint;
	
	spawnpoint = find(world, classname, "info_player_start");
	
	self.isspec = FALSE;
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/player.mdl");
	self.movetype = MOVETYPE_WALK;
	self.max_health = self.health = 100;
	
	entity who = find(world,classname,"player");
	while(who != self && !self.playernum)
	{
		if(who)
		{
			coop = 1;	
			player_count++;
			break;
		}
	}

	switch(player_count) {
		default: spawnpoint = find(world, classname, "info_player_start"); if (!spawnpoint) {spawnpoint = find(world, classname, "info_player_start");} break;
		case 1: spawnpoint = find(world, classname, "info_player_nikolai");  if (!spawnpoint) {spawnpoint = find(world, classname, "info_player_start");} break;
		case 2: spawnpoint = find(world, classname, "info_player_takeo");  if (!spawnpoint) {spawnpoint = find(world, classname, "info_player_start");} break;
		case 3: spawnpoint = find(world, classname, "info_player_doctor");  if (!spawnpoint) {spawnpoint = find(world, classname, "info_player_start");}  break;
	}
	
	if (self.playernum) {
		switch(self.playernum) {
			default: spawnpoint = find(world, classname, "info_player_start"); if (!spawnpoint) {spawnpoint = find(world, classname, "info_player_start");} break;
			case 1: spawnpoint = find(world, classname, "info_player_nikolai");  if (!spawnpoint) {spawnpoint = find(world, classname, "info_player_start");} break;
			case 2: spawnpoint = find(world, classname, "info_player_takeo");  if (!spawnpoint) {spawnpoint = find(world, classname, "info_player_start");} break;
			case 3: spawnpoint = find(world, classname, "info_player_doctor");  if (!spawnpoint) {spawnpoint = find(world, classname, "info_player_start");}  break;
	    }
	}
	
	self.origin = spawnpoint.origin + [0,0,1];
	self.angles = spawnpoint.angles;
	self.fixangle = TRUE;
	setsize(self, [-16, -16, -24], [16, 16, 32]);
	self.view_ofs = VEC_VIEW_OFS; // naievil -- set view_ofs to 32 to maintain half life (64) sizes

	self.currentammo = 32;
	self.currentmag = 8;
	self.weapon = W_COLT;
	
	self.grenades = self.grenades | 1;  // add frag grenades to player inventory
	
	if (rounds)
		self.primary_grenades = 2;
	else
		self.primary_grenades = 0; 		// start off without grenades
		
	self.pri_grenade_state = 0; 		// defines that frag grenades are for player first, not betty
	self.secondary_grenades = -1;		// shows that we both don't have betties AND shouldn't draw the image onscreen

	/*self.secondaryweapon = W_KAR_SCOPE;
	self.secondaryammo = getWeaponAmmo(self.secondaryweapon);
	self.secondarymag = getWeaponMag(self.secondaryweapon);*/
	//self.secondarymag2 = getWeaponMag(self.secondaryweapon);

	if (!self.points)
		addmoney(self, 500, 0);

	self.weaponmodel = GetWeaponModel(self.weapon, 0);// Give weapon model

	SwitchWeapon(self.weapon);
	UpdateV2model("", 0);
	stuffcmd(self, "cl_gunx 8;cl_guny 16;cl_gunz 25\n");

	SetRound(self, rounds);

	self.stamina = 3;
	self.reviving = 0;
	self.weaponnum = 0;
	
	if (!self.playernum)
		self.playernum = player_count + 1;

	if (rounds < 1) {
		sound (self, CHAN_AUTO, "sounds/rounds/splash.wav", 1, ATTN_NONE);//temporarily here.
	}
	
	PollPlayerPoints();
	PromptLevelChange(self.nextthink + 3, 1, self);
};

void() SpectatorSpawn =
{
	local entity spawnpoint;
	spawnpoint = find(world, classname, "info_player_start");
	
	self.isspec = TRUE;
	self.classname = "spectator";
	self.solid = SOLID_NOT;
	setmodel(self, "");
	self.movetype = MOVETYPE_FLY;
	self.origin = spawnpoint.origin + [0,0,1];
	self.fixangle = TRUE;
	setsize(self, [-16, -16, -24], [16, 16, 32]);
	self.view_ofs = '0 0 22';
	self.aiment = world;
};

//called when a client loads a map
void() PutClientInServer =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has joined the game.\n");
	
	if (spawn_time > time || !rounds)
		PlayerSpawn();
	else 
		SpectatorSpawn();
	
	/*stuffcmd(self, "promptjoin\n");
	SpectatorSpawn();*/
};

//called when client disconnects from the server
void() ClientDisconnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has left the game.\n");
	remove(self);
};


void() SetNewParms =
{
};

void() SetChangeParms =
{
};


void(string com) SV_ParseClientCommand =
{
	if(com == "joingame")
	{
		if(self.isspec)
		{
			bprint(PRINT_HIGH, self.netname);
			bprint(PRINT_HIGH, " has joined the game.\n");
			PlayerSpawn();
		}
		else
			sprint(self, PRINT_HIGH, "You're already in game!\n");
	}
	else if(com == "specgame")
	{
		if(self.isspec)
			return;
		else
		{
			coop = 1;

			/*SpectatorSpawn();
			bprint(PRINT_HIGH, self.netname); //print player name
			bprint(PRINT_HIGH, " has joined the spectators.\n");*/
			
			PlayerSpawn();
		}
	}
	else if(com == "pause")
	{
		static float paused;
		paused = !paused;
		setpause(paused);
	}
	else if (com == "noclip")
	{
		if (self.movetype == MOVETYPE_WALK)
			self.movetype = MOVETYPE_NOCLIP;
		else
			self.movetype = MOVETYPE_WALK;
	}
	else
	{
		tokenize(com);

		switch(argv(0))
		{
			case "give":
				float wep = stof(argv(1));

				if (wep) {
					if (!self.secondaryweapon) {
						WeaponSwitch(self);
					}
					float startframe, endframe;
					string modelname;

					self.weapon = wep;
					self.currentammo = getWeaponAmmo(wep);
					self.currentmag = getWeaponMag(wep);
					if (IsDualWeapon(wep)) {
						self.currentmag2 = self.currentmag;
					}

					startframe = GetFrame(self.weapon,TAKE_OUT_START);
					endframe = GetFrame(self.weapon,TAKE_OUT_END);
					modelname = GetWeaponModel(wep, 0);

					SwitchWeapon(wep);
					
					Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);
					
					self.reload_delay2 = self.fire_delay2 = self.reload_delay = self.fire_delay = 0;
				}
			break;
			case "god":
					if (!(self.flags & FL_GODMODE))
						self.flags = self.flags | FL_GODMODE;
					else
						self.flags = self.flags & (~FL_GODMODE);
					break;
		}
	}
};

void() SV_RunClientCommand =
{
	runstandardplayerphysics(self);
}