void(entity where) spawn_a_dogB =
{
	local entity sdog;//USED FOR WHAT TO SPAWN
	
	sdog = getFreeZombieEnt(self);
	if(sdog == world)
	{
		return;
	}

	sdog.origin = where.origin;
	sdog.frame = 0;
	
	sdog.target = where.target;	
	
	sdog.solid = SOLID_SLIDEBOX;
	sdog.movetype = MOVETYPE_WALK;
	setmodel(sdog, "models/ai/dog.mdl");
	sdog.hop_step = 0;
	sdog.gravity = 1.0;
	
	sdog.mins = '-8 -8 -32';//-16 16 -32
	sdog.maxs = '8 8 30';//16 16 40
	setsize (sdog, sdog.mins, sdog.maxs);
	
	local float tex;
	tex = random();
	sdog.skin = 0;
	/*if(tex < 0.25)
		sdog.skin = 0;
	else if(tex < 0.5)
		sdog.skin = 1;
	else if(tex < 0.75)
		sdog.skin = 2;
	else if(tex <= 1)
		sdog.skin = 3;*/
	// naievil -- FIXME
		
	if(pointcontents(sdog.origin - '0 0 36') == -2)
	{
		while(pointcontents (sdog.origin - '0 0 36') == -2)
		{
			sdog.origin = sdog.origin + '0 0 1';
			setorigin(sdog,sdog.origin );
		}
	}

	sdog.classname = "ai_dog";
	sdog.aistatus = "1";
	setorigin (sdog.goaldummy, '0 0 0');
	sdog.origin_z = sdog.origin_z + 1;
	sdog.outside = true;
	sdog.takedamage = DAMAGE_YES;
	setorigin(sdog, sdog.origin);
	sdog.flags = sdog.flags | FL_PARTIALGROUND | FL_MONSTER;

	sdog.spawnflags = where.spawnflags;
	
	sdog.ideal_yaw = sdog.angles_y;
	sdog.yaw_speed = 20;
	sdog.health = z_health;
	/*sdog.th_die = Zombie_Death;
	sdog.th_walk = Zombie_Walk_Setup;
	sdog.th_melee = zombie_attack;
	sdog.th_idle = zombie_idle;
	sdog.th_windowhop = zombie_hop1;
	
	sdog.th_fall = zombie_fall1;
	sdog.th_land = zombie_land1;*/
	
	//SetZombieWalk(sdog);
	
	sdog.reload_delay = 30 + time;//save  floats, equals respawn time.
	local entity old_self;
	old_self = self;
	self = sdog;
	//droptofloor();
	//self.th_walk();
	self = old_self;
};

float() spawn_a_dogA =
{
	local float pcount;
	local entity thing, szombie;
	local float FAIL;
	
	FAIL = false;
	pcount = 0;
	szombie = getFreeZombieEnt(self);
	if(szombie == world)
	{
		return 0;
	}
	lastspawn = find(lastspawn, classname, "spawn_dog");
	while (random() < 0.4)
	{
		lastspawn = find(lastspawn, classname, "spawn_dog");
	}
	
	while(lastspawn)
	{
		thing = findradius(lastspawn.origin, 60);
		while (thing)
		{
			pcount = 0;
			if (thing.classname == "ai_dog")
			{
				pcount = 1;
				break;
			}
			thing = thing.chain;
		}
		if (!pcount && random() < 0.6)
		{
			spawn_a_dogB(lastspawn);
			spawn_delay = time + delay_at_round;
			return true;
		}
		lastspawn = find(lastspawn, classname, "spawn_dog");
	}
	return 0; //no free locations fround
};

void() spawn_dog =
{
	setsize(self, '0 0 0', '0 0 0');
	if (self.spawnflags & INACTIVE)
	{
		if (cvar("developer"))
			setmodel(self, "models/player.mdl");
		self.classname = "spawn_dog_in";
	}
	else
	{
		if (cvar("developer"))
			setmodel(self, "models/ai/dog.mdl");
		self.classname = "spawn_dog";
	}
	
	self.solid = SOLID_NOT;
};