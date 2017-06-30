string(float wep, float gorvmodel) GetWeaponModel;

void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	setmodel (self, self.model);
};

void() func_illusionary =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	// makestatic (self); // dr_mabuse1981: dont use makestatic, it doesnt show the HL rendermodes then.
};

// button and multiple button

void() button_wait;
void() button_return;

void() button_wait =
{
	self.state = STATE_TOP;
	self.nextthink = self.ltime + self.wait;
	self.think = button_return;
	activator = self.enemy;
	SUB_UseTargets();
	self.frame = 1;			// use alternate textures
};

void() button_done =
{
	self.state = STATE_BOTTOM;
};

void() button_return =
{
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, button_done);
	self.frame = 0;			// use normal textures
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
};


void() button_blocked =
{	// do nothing, just don't ome all the way back out
};


void() button_fire =
{
	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
};


void() button_use =
{
	self.enemy = activator;
	button_fire ();
};

void() button_touch =
{
	if (other.classname != "player")
		return;
	
	if(self.cost)
	{
		if(self.state == STATE_BOTTOM||self.state == STATE_DOWN)
		{
			centerprint(other,"Press use to buy [cost:");
			centerprint(other,ftos(self.cost));
			centerprint(other,"]\n");
			if (other.button7)
			{
				if(other.points >= self.cost)
				{
					self.enemy = other;
					addmoney(other, 0 - self.cost, FALSE);
					button_fire();
					return;
				}
				else
				{
					centerprint(other,"You do not have enough points\n");

				}
			}
		}
	}
	else
	{
	self.enemy = other;
	button_fire ();
	}
};

void() button_killed =
{
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	button_fire ();
};


/*QUAKED func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/

void() func_button =
{
	SetMovedir ();
	
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);

	self.blocked = button_blocked;
	self.use = button_use;
	
	if (self.health)
	{
		self.max_health = self.health;
		self.th_die = button_killed;
		self.takedamage = DAMAGE_YES;
	}
	else
		self.touch = button_touch;

	if (!self.speed)
		self.speed = 40;
	if (!self.wait)
		self.wait = 1;
	if (!self.lip)
		self.lip = 4;

	self.state = STATE_BOTTOM;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
};

void() flame_update = {		
	particle (self.origin, v_up, 111, 0);
	self.think = flame_update;
	self.nextthink = time + random()+0.1;
}
void() place_fire =
{
	particle (self.origin, v_up*8, self.frame, 0);
	self.think = flame_update;
	self.nextthink = time + random()+0.1;
};

void() place_model =
{  
  precache_model (self.model);
  setmodel (self, self.model);
  
	self.skin = 0;
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.angles = self.angles;
	self.solid = SOLID_NOT;
	self.frame = self.sequence;
	
	if (self.spawnflags & 1)
		self.effects = self.effects | EF_FULLBRIGHT;
};




void () buy_weapon_touch =
{
	entity oldent;
	local float tempf, tempf1, tempf2;
	local float startframe,endframe;
	local string modelname;

	if (other.classname != "player") {
		return;
	}
	
	if (self.weapon == other.weapon || self.weapon == other.secondaryweapon 
	|| self.weapon == EqualNonPapWeapon(other.weapon) 
	|| self.weapon == EqualNonPapWeapon(other.secondaryweapon)) {

		if (self.weapon == EqualNonPapWeapon(other.secondaryweapon) 
		|| self.weapon == EqualNonPapWeapon(other.weapon))
			useprint (other, 3, 4500, other.weapon);
		else
			useprint (other, 3, self.cost2, self.weapon);

		if (!other.button7 || other.semiuse) {
			return;
		}
		if ((self.weapon == other.weapon && other.currentammo >= getWeaponAmmo(self.weapon))
			||(self.weapon == other.secondaryweapon && other.secondaryammo >= getWeaponAmmo(self.weapon))) {
				return;
			}

		other.semiuse = true;
		if ((other.points < self.cost2 && !IsPapWeapon(other.weapon)) || (other.points < 4500 && IsPapWeapon(other.weapon))) {
			centerprint(other, "You do not have enough points\n");
			return;
		}

		if (self.weapon == other.weapon || (self.weapon == EqualNonPapWeapon(other.weapon))) {
			other.currentammo = getWeaponAmmo(self.weapon);
		} else if (self.weapon == other.secondaryweapon || (self.weapon == EqualNonPapWeapon(other.secondaryweapon)) ) {
			other.secondaryammo = getWeaponAmmo(self.weapon);
		}
		

		sound(other, 0,"sounds/misc/ching.wav", 1, 1);
		other.reload_delay = 0;
		
		if (!IsPapWeapon(other.weapon))
			addmoney(other, -1*self.cost2, 0);
		else
			addmoney(other, -1*4500, 0);
			
		if (self.enemy) {
			oldent = self;
			self = self.enemy;
			self.use();
			self = oldent;
		}
	}
	if (self.weapon == W_BETTY)
	{
		if (other.secondary_grenades < 2)
			useprint (other, 3, self.cost2, self.weapon);
		else
			return;
		if (!other.button7 || other.semiuse)
			return;
		if (other.points < self.cost2)
		{
			centerprint(other, "You do not have enough points\n");
			sound(other, 0,"sounds/misc/denybuy.wav", 1, 1);
			return;
		}
		else
		{
			other.reload_delay = 0;
			sound(other, 0,"sounds/misc/ching.wav", 1, 1);
			//other.boughtweapon = true;
			addmoney(other, 0 - self.cost2, FALSE);
			other.grenades = other.grenades | 2;
			other.secondary_grenades = 2;
			if (self.enemy)
			{
				oldent = self;
				self = self.enemy;
				self.use();
				self = oldent;
			}
		}
		other.semiuse = true;
		return;
	}
	else if (self.weapon == W_GRENADE)
	{
		if (other.primary_grenades < 4)
			useprint (other, 3, self.cost2, self.weapon);
		else
			return;
		if (!other.button7 || other.semiuse)
			return;
		if (other.points < self.cost)
		{
			centerprint(other, "You do not have enough points\n");
			sound(other, 0,"sounds/misc/denybuy.wav", 1, 1);

			return;
		}
		else
		{
			other.reload_delay = 0;
			sound(other, 0,"sounds/misc/ching.wav", 1, 1);
			//other.boughtweapon = true;
			addmoney(other, 0 - self.cost, FALSE);
			other.primary_grenades = 4;
			if (self.enemy)
			{
				oldent = self;
				self = self.enemy;
				self.use();
				self = oldent;
			}
		}
		other.semiuse = true;
		return;
	}
	else
	{
		entity tempe;
      
		//centerprint(other, self.message);
      	useprint (other, 4, self.cost, self.weapon);

		if (!other.button7 || other.semiuse) {
			return;
		}

		other.semiuse = 1;
		if (other.points < self.cost) {
			centerprint (other, "Not enough points\n");
			return;
		}

		if (other.weapon && !other.secondaryweapon) {
			tempf = other.currentammo;
			other.currentammo = other.secondaryammo;
			other.secondaryammo = tempf;

			tempf1 = other.currentmag;
			other.currentmag = other.secondarymag;
			other.secondarymag = tempf1;

			tempf2 = other.weapon;
			other.weapon = other.secondaryweapon;
			other.secondaryweapon = tempf2;
		} else if (other.weapon && other.secondaryweapon) {
		
			other.currentammo = 0;
			other.currentmag = 0;
			other.weapon = 0;
			
		}
		
		/* insert here mule kick thingy*/
		sound(other, 0,"sounds/misc/ching.wav", 1, 1);
		other.reload_delay = 0;
		addmoney(other, -1*self.cost, 0);
		if (self.enemy) {
			oldent = self;
			self = self.enemy;
			self.use();
			self = oldent;
		}
		other.weapon = self.weapon;
		
		other.currentammo = getWeaponAmmo(self.weapon);
		other.currentmag = getWeaponMag(self.weapon);
		tempe = self;
		self = other;
		startframe = GetFrame(self.weapon,TAKE_OUT_START);
		endframe = GetFrame(self.weapon,TAKE_OUT_END);
		modelname = GetWeaponModel(self.weapon, 0);
		SwitchWeapon(self.weapon);
		Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
		self = tempe;
	}
};

void() buy_weapon_link_wall =
{
	entity ent;
	
	ent = find (world, targetname, self.target);
	
	if (ent.classname == "weapon_wall")
		self.enemy = ent;
}

void() buy_weapon =
{
	local string weaponname;
	InitTrigger ();
	weaponname = GetWeaponModel (self.weapon, 0);
	if (weaponname != "")
		precache_model (weaponname);
	weaponname = GetWeaponModel(self.weapon, 1);
	if (weaponname != "")
		precache_model (weaponname);
	
	
	precache_extra (self.weapon);
	self.touch = buy_weapon_touch;
	
	self.think = buy_weapon_link_wall;
	self.nextthink = time + 0.2; 

	precache_sound("sounds/misc/ching.wav");
};



void() BarrelExplode =
{
	sound (self, CHAN_WEAPON, "sounds/weapons/grenade/explode.wav", 1, ATTN_NORM);	
	DamgageExplode (self, self.enemy, 500, 75, 200);//was 256 inch radius, kicked it down to 128 because 21 feet exploding radius is... a bit overkill...
	te_explosionquad(self.origin);

	SUB_Remove ();
};

void() barrel_hit =
{
	if (self.health <= 0) {
		BarrelExplode();
	} else if (self.health <= 200) {
		makevectors(self.angles);
		self.think = barrel_hit;
		self.nextthink = time + 0.1;
		self.health = self.health - 1;
		if (self.health > 100)
			particle (self.origin + '0 0 30', v_up*8, 111, 0);
		else
			particle (self.origin + '0 0 30', v_up*8, 112, 0);
    
	}
}

void() explosive_barrel = 
{
	precache_model ("models/props/barrel_m.mdl");

	self.movetype = MOVETYPE_NONE;	// so it doesn't get pushed by anything
	self.solid=SOLID_BBOX;
	self.classname = "explosive_barrel";
	setmodel (self, "models/props/barrel_m.mdl");
	setsize (self, '-10 -10 ', '10 10 38');

	self.takedamage = DAMAGE_YES;
	self.health = 300;
};

.float radioState;
.float length;
.string tune;
void() radioPlay =
{
	self.health = 1;

	if (self.radioState == 1) {
		sound (self, CHAN_ITEM, self.tune, 1, ATTN_NORM);
		self.nextthink = time + self.length;
		self.think = radioPlay;
	} else if (self.radioState == 0) {
		sound (self, CHAN_ITEM, "sounds/null.wav", 1, ATTN_NONE);
		self.nextthink = 0;
		self.think = SUB_Null;
	}
}

void() radio_hit =
{
	self.health = 1;

	sound (self, CHAN_ITEM, "sounds/misc/radio.wav", 1, ATTN_NORM);
	self.nextthink = time + 1;//getSoundLen("sounds/music/tune1.wav");
	self.think = radioPlay;
	
	if (self.radioState == 0)
		self.radioState = 1;
	else if (self.radioState == 1)
		self.radioState = 0;
}

void() item_radio = 
{
	precache_model ("models/props/radio.mdl");
	precache_sound ("sounds/misc/radio.wav");

	if(self.tune) {
		precache_sound (self.tune);
	}

	self.movetype = MOVETYPE_NONE;	// so it doesn't get pushed by anything
	self.solid=SOLID_BBOX;
	self.classname = "item_radio";
	setmodel (self, "models/props/radio.mdl");
	setsize (self, '-8 -8 -4', '8 8 4');

	self.takedamage = DAMAGE_YES;
	self.health = 1;
	self.radioState = 0;
	self.th_die = radio_hit;
};

.string zappername;
void()	turnswitch1	=[	1,		turnswitch2	] {self.frame = 0;};
void()	turnswitch2	=[	2,		turnswitch3	] {self.frame = 1;};
void()	turnswitch3	=[	3,		turnswitch4	] {self.frame = 2;};
void()	turnswitch4	=[	4,		SUB_Null	] {self.frame = 2;};

void()	offswitch2		=[	2,		offswitch3		] {self.frame = 2;};
void()	offswitch3		=[	3,		offswitch4		] {self.frame = 1;};
void()	offswitch4		=[	4,		SUB_Null		] {self.frame = 0;};


void zap_zombie () {
	entity tempe;

	if (other.classname == "ai_zombie") {
		tempe = self;
		self = other;
		self.th_die();
		self = tempe;	
	} else if (other.classname == "player") {
		if (other.damagetimer < time) {
			DamageHandler (other, self, 50, S_ZAPPER);
			other.damagetimer = time + 1.5;
		}
	}
}


void zapper_play () {
	entity zents = find(world, targetname, self.target);

	if (zents) {
		te_lightning2(self, self.origin, zents.origin);
	}

	zents.touch = zap_zombie;
	
	self.think = zapper_play;
	self.nextthink = time + (1*random());
}

void zapper_stop() {
	entity zents;
	entity tempe;

	zents = find(world, zappername, self.zappername);
	while (zents)
	{
		if (zents.classname == "zapper_light") {
			zents.skin = 0;
		} else if (zents.classname == "zapper_switch") {
			tempe = self;
			self = zents;
			self.state = 0;
			offswitch2();
			self = tempe;
		} else if (zents.classname == "zapper_node" && zents.target) {
			zents.think = SUB_Null;
			zents.nextthink = 0;
		}
		zents = find(zents, zappername, self.zappername);
	}

	remove(self);
}

void zapper_start(string zapper) {
	entity zents;
	entity tempe;

	zents = find(world, zappername, zapper);
	while (zents)
	{
		if (zents.classname == "zapper_light") {
			zents.skin = 1;
		} else if (zents.classname == "zapper_switch") {
			tempe = self;
			self = zents;
			self.state = 1;
			turnswitch1();
			self = tempe;
		} else if (zents.classname == "zapper_node" && zents.target) {
			zents.think = zapper_play;
			zents.nextthink = time + 0.1;
		}
		zents = find(zents, zappername, zapper);
	}

	tempe = spawn();
	tempe.think = zapper_stop;
	tempe.nextthink = time + 30;
	tempe.zappername = zapper;
}


void zapper_touch () {
	if (other.classname != "player") {
		return;
	}	
    
	if (self.requirespower == true && !isPowerOn) {
		useprint (other, 8, 0, 0);
		return;
	}	

	if (self.state == 0) {
		useprint (other, 11, self.cost, self.weapon);

		if (!other.button7 || other.semiuse) {
			return;
		}

		other.semiuse = true;
		if (other.points < self.cost) {
			centerprint(other, "You do not have enough points\n");
			return;
		}

		zapper_start(self.zappername);
		addmoney(other, -1*self.cost, false);
	}
}


void() zapper_switch = 
{
	precache_model ("models/machines/zapper/z_switch.mdl");
	self.movetype = MOVETYPE_NONE;
	self.classname = "zapper_switch";
	setmodel(self, "models/machines/zapper/z_switch.mdl");
	setsize (self, '-4 -4 -4', '4 4 4');

	self.state = 0;
	self.solid = SOLID_TRIGGER;
	self.touch = zapper_touch;
};

void() zapper_node = 
{
	precache_model ("models/machines/zapper/z_zap.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	//self.touch = switch_touch;
	self.classname = "zapper_node";
	setmodel(self, "models/machines/zapper/z_zap.mdl");
	setsize (self, '-4 -4 -4', '4 4 4');
};

void() zapper_light = 
{
	precache_model ("models/machines/zapper/z_light.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	//self.touch = switch_touch;
	self.classname = "zapper_light";
	setmodel(self, "models/machines/zapper/z_light.mdl");
	setsize (self, '-4 -4 -4', '4 4 4');
};


void() trigger_electro =
{
	self.classname = "zapper_field";
	InitTrigger ();
	//self.touch = electro_touch;
	self.solid = SOLID_TRIGGER;
};

/* ================
   Custom Teddy Code
   ================*/

void() teddy_spawn = 
{
  precache_model ("progs/Props/teddy.mdl");

	self.movetype = MOVETYPE_NONE;	// so it doesn't get pushed by anything
	self.solid=SOLID_BBOX;
	self.classname = "teddy_spawn";
	setmodel (self, "progs/Props/teddy.mdl");
	setsize (self, '-8 -8 -4', '8 8 4');

	self.takedamage = DAMAGE_YES;
	self.health = 0;
	self.th_die = teddy_react;
};