

void() EndGame =
{
	local entity oldself;
	local entity who;

	self.health = 0;
	//WriteByte (MSG_ALL, SVC_INTERMISSION);
	self.origin = '0 0 0';
	setorigin (self, self.origin);
	self.velocity = '0 0 0';
	sound (self, CHAN_AUTO, "sounds/music/end.wav", 1, ATTN_NORM);

	oldself = self;
	
	who = find(world,classname,"ai_zombie");
	while(who != world)
	{
		if(who.health)
		{
			self = who;
			self.th_die();
			self = oldself;
		}
		
		who = find(who,classname,"ai_zombie");
	}
}

void() GetDown =
{
	float startframe;
	float endframe;
	local string modelname;
	entity who;
	
	self.view_ofs = '0 0 -15';
	self.velocity = '-80 0 -80';           			// Stop any old movement
	self.zoom = 0;
	self.downed = true;
	self.movetype = MOVETYPE_NONE;
	
	/* naievil -- there is a better place for this...*/
	who = find(world,classname,"player");
	while(who != world)
	{
		if(who)
		{
			coop = 1;
		}
		who = find(who,classname,"player");
	}	
	
	if (!deathmatch && !coop && !(self.perks & P_REVIVE))
	{
		game_over = true;
		self.health = 10;
		self.think = EndGame;
		self.nextthink = time + 5;
		self.weapon = 0;
		self.currentammo = 0;
		self.currentmag = 0;
		self.weaponmodel = "";
		self.weapon2model = "";
		self.animend = SUB_Null;
		self.perks = 0;
		SetPerk(self, self.perks);
		SwitchWeapon(0);

		centerprint(self, "YOU DON DEDED\n");
		
      	return;
	}
	else if (coop) {
	self.health = 19; 
	self.downed = true;
	} else {
		self.health = 19;
	}
	
	if (self.perks && P_REVIVE) {	
	self.progress_bar = 10 + time;     
	self.progress_bar_time = 10;
	self.progress_bar_percent = 1;
	self.points = 10*rint((self.points*0.95)/10);
	}
	
	self.perks = 0;
	SetPerk(self, self.perks);
	if (self.health == 10)
		return;

	self.weaponbk = self.weapon;
	self.currentammobk = self.currentammo;
	self.currentmagbk = self.currentmag;
	self.currentmagbk2 = self.currentmag2;
	
	self.weapon = W_BIATCH;
	self.currentammo = 12;
	self.currentmag = 6;
	self.currentmag2 = 6;
      
  	modelname = GetWeaponModel(self.weapon, 0);
	self.weaponmodel = modelname;
	SwitchWeapon(self.weapon);
	
	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
	
}

void () GetUp =
{
	local string modelname;
	float startframe;
	float endframe;
  
	self.view_ofs = VEC_VIEW_OFS;
	self.health = 100;
	self.downed = 0;
	self.classname = "player";
	if (self.weaponbk)
	{
		self.weapon = self.weaponbk;
		self.currentammo = self.currentammobk;
		self.currentmag = self.currentmagbk;
		self.currentmag2 = self.currentmagbk2;
	}	
	modelname = GetWeaponModel(self.weapon, 0);
	self.weaponmodel = modelname;
	SwitchWeapon(self.weapon);
	self.movetype = MOVETYPE_WALK;
  
  	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
	
};


void(entity attacker, float d_style) DieHandler =
{
    float t;

    t = random();

    if (self.classname == "ai_zombie") {
        self.th_die();
    }

    if (attacker.classname == "player") {
        if (d_style == S_NORMAL) {
            addmoney(attacker, 60, true);
            total_powerup_points = total_powerup_points + 60;
        }
    }
}

void(entity victim,entity attacker, float damage, float d_style) DamageHandler = {
	entity old_self;
	if (victim.classname == "ai_zombie") {

		if (attacker.classname == "player" && (victim.health - damage)> 0) {
			addmoney(attacker, 10, 1);
        }

		victim.health = victim.health - damage;

		if (d_style == S_EXPLOSIVE) {
			addmoney(attacker, 60, 1);
		}
		
		if (d_style == S_KNIFE) {
			addmoney(attacker, 10, 1);
		}


		if (victim.health <= 0 || instakill_finished) {
			old_self = self;
			self = victim;
			DieHandler(attacker, d_style);
			self = old_self;
		}
	} else if (victim.classname == "player" && !victim.downed) {
		if (victim.flags & FL_GODMODE) {
			return;
		}
		
		if (victim.perks & P_JUG)
			damage = ceil(damage*0.5);
		
		victim.health = victim.health - damage;
		victim.health_delay = time + 2;

		if (victim.health <= 20)
		{
			old_self = self;
			self = victim;
			GetDown();
			self = old_self;
		}
	}
}

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
	if (targ.flags == FL_GODMODE)
    return FALSE;
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
    
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};

void(entity inflictor, entity attacker, float damage2, float mindamage, float radius) DamgageExplode =
{
	local	float 	final_damage;
	local	entity	ent;

	local float multi,r;
	ent = findradius(inflictor.origin, radius);
	
	while (ent)
	{
		if(ent.classname == "player")
		{
      if (ent.perks & P_FLOP)
        final_damage = 0;
      else
      {
        final_damage = radius - vlen(inflictor.origin - ent.origin);
        if(final_damage < 0)
          continue;
        
        if (final_damage > radius * 0.6)
          final_damage = 100;
          
          if (final_damage < other.health)
          {
            addmoney(self, 10, 0);
          }
          else if (final_damage > other.health)
          {
              addmoney(self, 60, 0);
              }
        else
        {
          final_damage /= radius;
          final_damage *= 60;
        }
        DamageHandler (attacker, attacker, final_damage, S_EXPLOSIVE);
    }
		}
		else if (ent.takedamage && ent.classname != "ai_zombie_head" && ent.classname != "ai_zombie_larm" && ent.classname != "ai_zombie_rarm")
		{			
			r = rounds;
			multi = 1.07;
			while(r > 0)
			{
				multi *= 1.05;
				r --;
			}
			
			if (mindamage == 75)
        final_damage = (200 * multi) + 185;
      else
        final_damage = (mindamage + damage2)/2;
			
			if (final_damage > 0)
			{
				/* ndaekill = true; */
				if (CanDamage (ent, inflictor))
					DamageHandler (ent, attacker, final_damage, S_EXPLOSIVE);
				/* kill = false; */
			}
		}
		ent = ent.chain;
	}
};