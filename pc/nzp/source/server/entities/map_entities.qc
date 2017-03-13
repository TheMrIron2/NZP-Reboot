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

//weapon buying code
void(entity person, float expamt , float doublepoint) addmoney =
{
	if (person.classname != "player")
		return;

	if (expamt > 0 && doublepoint == TRUE && x2_finished> time)
		person.points = person.points + expamt*2;
	else
		person.points = person.points + expamt;
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
	particle (self.origin, v_up*8, 111, 0);
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
  //beta_removal();
  
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
	
	if (self.weapon == other.weapon || self.weapon == other.secondaryweapon) {

		useprint (other, 3, self.cost2, self.weapon);

		if (!other.button7 || other.semiuse) {
			return;
		}
		if ((self.weapon == other.weapon && other.currentammo >= getWeaponAmmo(self.weapon))
			||(self.weapon == other.secondaryweapon && other.secondaryammo >= getWeaponAmmo(self.weapon))) {
				return;
			}

		other.semiuse = true;
		if (other.points < self.cost2) {
			centerprint(other, "You do not have enough points\n");
			return;
		}

		if (self.weapon == other.weapon) {
			other.currentammo = getWeaponAmmo(self.weapon);
		} else if (self.weapon == other.secondaryweapon) {
			other.secondaryammo = getWeaponAmmo(self.weapon);
		}

		sound(other, 0,"sounds/misc/ching.wav", 1, 1);
		other.reload_delay = 0;
		addmoney(other, -1*self.cost2, 0);
		if (self.enemy) {
			oldent = self;
			self = self.enemy;
			self.use();
			self = oldent;
		}
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