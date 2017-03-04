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
		}


		if (victim.health <= 0 || instakill_finished) {
			old_self = self;
			self = victim;
			DieHandler(attacker, d_style);
			self = old_self;
		}
	} else if (victim.classname == "player") {
		if (victim.flags & FL_GODMODE) {
			return;
		}
		
		victim.health = victim.health - damage;
		victim.health_delay = time + 2;

		if (victim.health <= 20)
		{
			old_self = self;
			self = victim;
			//GetDown();
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