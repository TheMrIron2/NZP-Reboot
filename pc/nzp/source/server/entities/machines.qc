float isBuying;
float backupWepSkin;
float sound_perk_delay; 
void() W_Switch;
void() give_revive =
{ 
  sound_perk_delay = time + 4.5;
  
	isBuying = false;
	string modelname;
	float startframe;
	float endframe;
	self.perks = self.perks | 8;
	self.weaponskin = backupWepSkin;
	self.perk_delay = self.fire_delay;
	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	modelname = GetWeaponModel(self.weapon, 0);
	Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
	
	SetPerk(self, self.perks);
}
void() give_juggernog =
{

  sound_perk_delay = time + 4.5;

	isBuying = false;
	string modelname;
	float startframe;
	float endframe;
	self.perks = self.perks | 1;
	self.weaponskin = backupWepSkin;
	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	modelname = GetWeaponModel(self.weapon, 0);
	Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
		
	SetPerk(self, self.perks);
}

void() give_doubletap =
{

  sound_perk_delay = time + 4.5;

	isBuying = false;
  string modelname;
	float startframe;
	float endframe;
	self.perks = self.perks | 2;
	self.weaponskin = backupWepSkin;
	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	modelname = GetWeaponModel(self.weapon, 0);
	Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
		
	SetPerk(self, self.perks);
}
void() give_speedcola =
{
  sound_perk_delay = time + 4.5;

	isBuying = false;
	string modelname;
	float startframe;
	float endframe;
	self.perks = self.perks | 4;
	self.weaponskin = backupWepSkin;
	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	modelname = GetWeaponModel(self.weapon, 0);
	Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
		
	SetPerk(self, self.perks);
}
void() give_flopper =
{

  sound_perk_delay = time + 4.5;

	isBuying = false;
	string modelname;
	float startframe;
	float endframe;
	self.perks = self.perks | 16;
	self.weaponskin = backupWepSkin;
	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	modelname = GetWeaponModel(self.weapon, 0);
	Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
		
	SetPerk(self, self.perks);
}
void() give_staminup =
{

  sound_perk_delay = time + 4.5;

	isBuying = false;
	string modelname;
	float startframe;
	float endframe;
	self.perks = self.perks | 32;
	self.weaponskin = backupWepSkin;
	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	modelname = GetWeaponModel(self.weapon, 0);
	Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
		
	SetPerk(self, self.perks);
}

.float requirespower;
void() touch_perk =
{  
	entity tempe;
	if (other.classname != "player" || other.downed)
		return;

	if (isBuying == true)
    return;
  
	if (self.requirespower == true && !isPowerOn)
	{
		useprint (other, 8, 0, 0);
		return;
	}
	  if (other.weaponskin == 0)
      backupWepSkin = 0;
    else 
      backupWepSkin = 1;

	
	if (self.classname == "perk_revive" && !(other.perks & P_REVIVE) && self.fire_delay < time)
	{
		if (!deathmatch && !coop)
		{
			useprint (other, 9, 500, 1);
		}
		else if ((coop || deathmatch))
		{
			useprint (other, 9, 1500, 1);
		}
		if (!deathmatch && !coop && other.points >= 500 && other.button7)
		{
			isBuying = true;
			self.fire_delay = time + 4.5;
			addmoney (other, -500, 0);
			tempe = self;
			self = other;
			sprintstop();
			self.reload_delay2 = self.fire_delay2 = self.fire_delay = self.reload_delay = 4.5 + time;	
			other.weaponskin = 3;			
			Set_W_Frame (0, 22, 0, 0, PERK, give_revive, "models/machines/v_perk.mdl", true, S_RIGHT);
			self = tempe;
			sound (other, CHAN_ITEM, "sounds/machines/perk_drink.wav", 1, ATTN_NORM);
			self.revivesoda++;
			if (self.revivesoda == 3)
				remove (self);
		}
		else if ((coop || deathmatch) && other.points >= 1500 && other.button7)
		{
			isBuying = true;
			self.fire_delay = time + 4;
			addmoney (other, -1500, 0);
			tempe = self;
			self = other;
			sprintstop();
			self.reload_delay2 = self.fire_delay2 = self.fire_delay = self.reload_delay = 4.0 + time;
			other.weaponskin = 3;
			Set_W_Frame (0, 39, 0, 0, PERK, give_revive, "models/machines/v_perk.mdl", true, S_RIGHT);
			self = tempe;
			sound (other, CHAN_ITEM, "sounds/machines/perk_drink.wav", 1, ATTN_NORM);
		}
		else if (other.button7)
		{
			centerprint (other, "Not enough points\n");
		}
	}
	if (self.classname == "perk_flopper" && !(other.perks & P_FLOP) && self.fire_delay < time)
	{
		useprint (other, 9, 2000, 6);
		if (other.points >= 2000 && other.button7)
		{
			isBuying = true;
			self.fire_delay = time + 3;
			addmoney (other, -2000, 0);
			tempe = self;
			self = other;
			sprintstop();
			self.reload_delay2 = self.fire_delay2 = self.fire_delay = self.reload_delay = 4.0 + time;
			other.weaponskin = 4;
			Set_W_Frame (0, 39, 0, 0, PERK, give_flopper, "models/machines/v_perk.mdl", true, S_RIGHT);
			self = tempe;
			sound (other, CHAN_ITEM, "sounds/machines/perk_drink.wav", 1, ATTN_NORM);
		}
		else if (other.button7)
		{
			centerprint (other, "Not enough points\n");
		}
	}
	if (self.classname == "perk_juggernog" && !(other.perks & P_JUG) && self.fire_delay < time)
	{
		useprint (other, 9, 2500, 2);
		if (other.points >= 2500 && other.button7)
		{
			isBuying = true;
			self.fire_delay = time + 3;
			addmoney (other, -2500, 0);
			tempe = self;
			self = other;
			sprintstop();
			self.reload_delay2 = self.fire_delay2 = self.fire_delay = self.reload_delay = 4.0 + time;
			other.weaponskin = 2;
			Set_W_Frame (0, 39, 0, 0, PERK, give_juggernog, "models/machines/v_perk.mdl", true, S_RIGHT);
			self = tempe;
			sound (other, CHAN_ITEM, "sounds/machines/perk_drink.wav", 1, ATTN_NORM);
		}
		else if (other.button7)
		{
			centerprint (other, "Not enough points\n");
		}
	}
	if (self.classname == "perk_staminup" && !(other.perks & P_STAMIN) && self.fire_delay < time)
	{
		useprint (other, 9, 2000, 5);
		if (other.points >= 2000 && other.button7)
		{
			isBuying = true;
			self.fire_delay = time + 3;
			addmoney (other, -2000, 0);
			tempe = self;
			self = other;
			sprintstop();
			self.reload_delay2 = self.fire_delay2 = self.fire_delay = self.reload_delay = 4.0 + time;
			other.weaponskin = 2;
			Set_W_Frame (0, 39, 0, 0, PERK, give_staminup, "models/machines/v_perk.mdl", true, S_RIGHT);
			self = tempe;
			other.weaponskin = 0;
			sound (other, CHAN_ITEM, "sounds/machines/perk_drink.wav", 1, ATTN_NORM);
		}
		else if (other.button7)
		{
			centerprint (other, "Not enough points\n");
		}
	}
	if (self.classname == "perk_speed" && !(other.perks & P_SPEED) && self.fire_delay < time)
	{
		useprint (other, 9, 3000, 3);
		if (other.points >= 3000 && other.button7)
		{
			isBuying = true;
			self.fire_delay = time + 3;
			addmoney (other, -3000, 0);
			tempe = self;
			self = other;
			sprintstop();
			self.reload_delay2 = self.fire_delay2 = self.fire_delay = self.reload_delay = 4.0 + time;
			other.weaponskin = 1;
			Set_W_Frame (0, 39, 0, 0, PERK, give_speedcola, "models/machines/v_perk.mdl", true, S_RIGHT);
			self = tempe;
			sound (other, CHAN_ITEM, "sounds/machines/perk_drink.wav", 1, ATTN_NORM);
		}
		else if (other.button7)
		{
			centerprint (other, "Not enough points\n");
		}
	}
	if (self.classname == "perk_double" && !(other.perks & P_DOUBLE) && self.fire_delay < time)
	{
		useprint (other, 9, 2000, 4);
		if (other.points >= 2000 && other.button7)
		{
			isBuying = true;
			self.fire_delay = time + 3;
			addmoney (other, -2000, 0);
			tempe = self;
			self = other;
			sprintstop();
			self.reload_delay2 = self.fire_delay2 = self.fire_delay = self.reload_delay = 4.0 + time;
			other.weaponskin = 0;
			Set_W_Frame (0, 39, 0, 0, PERK, give_doubletap, "models/machines/v_perk.mdl", true, S_RIGHT);
			self = tempe;
			sound (other, CHAN_ITEM, "sounds/machines/perk_drink.wav", 1, ATTN_NORM);
		}
		else if (other.button7)
		{
			centerprint (other, "Not enough points\n");
		}
	}
}

void() setup_perk =
{
	if (find (world, classname, "power_switch"))
	{
		if (self.classname == "perk_revive" && !coop && !deathmatch)
			self.effects = EF_BLUE;
		else
			self.requirespower = true;
	}/*
	else
	{
		if (self.classname == "perk_revive")
			self.effects = EF_BLUE;
		else if (self.classname == "perk_flopper")
			self.effects = EF_PURPLELIGHT;
		else if (self.classname == "perk_juggernog")
			self.effects = EF_REDLIGHT;
		else if (self.classname == "perk_staminup")
			self.effects = EF_ORANGELIGHT;
		else if (self.classname == "perk_speed")
			self.effects = EF_GREENLIGHT;
		else if (self.classname == "perk_double")
			self.effects = EF_ORANGELIGHT;
	} */
	
		// naievil (FIXME) light effects 
}
void() perk_revive =
{
	self.solid = SOLID_TRIGGER;
	precache_model ("models/machines/quick_revive.mdl");
	precache_model ("models/machines/v_perk.mdl");
	precache_sound ("sounds/machines/perk_drink.wav");
  	precache_sound ("sounds/weapons/papfire.wav");
	setorigin (self, self.origin);
	setmodel (self, "models/machines/quick_revive.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.classname = "perk_revive";
	self.touch = touch_perk;

	self.think = setup_perk;
	self.nextthink = time + 0.1;
};
void() perk_flopper =
{
	self.solid = SOLID_TRIGGER;
	precache_model ("models/machines/flopper.mdl");
	precache_model ("models/machines/v_perk.mdl");
	precache_sound ("sounds/machines/perk_drink.wav");
	setorigin (self, self.origin);
	setmodel (self, "models/machines/flopper.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.classname = "perk_flopper";
	self.touch = touch_perk;

	self.think = setup_perk;
	self.nextthink = time + 0.1;
};

void() perk_juggernog =
{
	self.solid = SOLID_TRIGGER;
	precache_model ("models/machines/juggernog.mdl");
	precache_model ("models/machines/v_perk.mdl");
	precache_sound ("sounds/machines/perk_drink.wav");
	setorigin (self, self.origin);
	setmodel (self, "models/machines/juggernog.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.classname = "perk_juggernog";
	self.touch = touch_perk;

	self.think = setup_perk;
	self.nextthink = time + 0.1;
};

void() perk_staminup =
{
	self.solid = SOLID_TRIGGER;
	precache_model ("models/machines/staminup.mdl");
	precache_model ("models/machines/v_perk.mdl");
	precache_sound ("sounds/machines/perk_drink.wav");
	setorigin (self, self.origin);
	setmodel (self, "models/machines/staminup.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.classname = "perk_staminup";
	self.touch = touch_perk;

	self.think = setup_perk;
	self.nextthink = time + 0.1;
};

void() perk_speed =
{
	self.solid = SOLID_TRIGGER;
	precache_model ("models/machines/speed_cola.mdl");
	precache_model ("models/machines/v_perk.mdl");
	precache_sound ("sounds/machines/perk_drink.wav");
	precache_sound("player/talk/fast.wav");//FIXME(Jukki)
	setorigin (self, self.origin);
	setmodel (self, "models/machines/speed_cola.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.classname = "perk_speed";
	self.touch = touch_perk;

	self.think = setup_perk;
	self.nextthink = time + 0.1;
};

void() perk_double =
{
	self.solid = SOLID_TRIGGER;
	precache_model ("models/machines/double_tap.mdl");
	precache_model ("models/machines/v_perk.mdl");
	precache_sound ("sounds/machines/perk_drink.wav");
	setorigin (self, self.origin);
	setmodel (self, "models/machines/double_tap.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.classname = "perk_double";
	self.touch = touch_perk;

	self.think = setup_perk;
	self.nextthink = time + 0.1;
};

void()	turnpower1	=[	1,		turnpower2	] {self.frame = 1;};
void()	turnpower2	=[	2,		turnpower3	] {self.frame = 2;};
void()	turnpower3	=[	3,		turnpower4	] {self.frame = 3;};
void()	turnpower4	=[	4,		SUB_Null	] {self.frame = 4;};

void() Turn_Lights =
{
	/*entity tempe;
	SUB_UseTargets();

	tempe = findfloat (world, requirespower, 1);// trigger all paired doors
	while (tempe)
	{
		if (tempe.classname == "perk_revive")
			tempe.effects = EF_BLUE;
		else if (tempe.classname == "perk_flopper")
			tempe.effects = EF_PURPLELIGHT;
		else if (tempe.classname == "perk_juggernog")
			tempe.effects = EF_REDLIGHT;
		else if (tempe.classname == "perk_staminup")
			tempe.effects = EF_ORANGELIGHT;
		else if (tempe.classname == "perk_speed")
			tempe.effects = EF_GREENLIGHT;
		else if (tempe.classname == "perk_double")
			tempe.effects = EF_ORANGELIGHT;
      
		tempe = findfloat (tempe, requirespower, 1);// trigger all paired doors
	} */ // naievil (FIXME) redo light effects 
} 

void() touch_power_Switch =
{
	entity tempe;
	entity old_self;

	if (other.classname != "player" || other.downed)
		return;

	if (isPowerOn == true)
    return;
	useprint (other, 10, 0, 0);
	if (other.button7 && !isPowerOn)
	{
		turnpower1();
		isPowerOn = true;
		sound (self, CHAN_ITEM, "sounds/machines/power.wav", 1, ATTN_NONE);

		tempe = find (world, classname, "door_nzp");// trigger all paired doors
		while (tempe)
		{
			local entity starte;

      if (!tempe.targetname)
      {
        if (!tempe.cost)
        {
          old_self = self;
          self = tempe;
          starte = self;
          door_go_up ();
          tempe.classname = "door_open";
          tempe = find (tempe, classname, "door_nzp");// trigger all paired doors
          self = old_self;
        }
      }
      if (tempe.targetname)
      {
        old_self = self;
        self = tempe;
        remove(self);
        self = old_self;
        tempe = find (tempe, classname, "door_nzp");// trigger all paired doors
       }
		}

		Turn_Lights ();
		
	}
}
void() power_switch =
{
	self.solid = SOLID_TRIGGER;
	precache_model ("models/machines/power_switch.mdl");
	precache_sound ("sounds/machines/power.wav");
	setorigin (self, self.origin);
	setmodel (self, "models/machines/power_switch.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.classname = "power_switch";
	isPowerOn = false;
	self.touch = touch_power_Switch;
}