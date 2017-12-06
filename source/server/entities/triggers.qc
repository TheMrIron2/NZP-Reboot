void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
};

void() InitTrigger =
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
};

void() use_wall_weapon =
{
	if (self.enemy)
		return;
	entity newent;
	
	newent = spawn();

	newent.movetype = MOVETYPE_NONE;	// so it doesn't get pushed by anything
	newent.solid=SOLID_NOT;
	newent.classname = "wall_weapon";
	setorigin(newent, self.origin);
	setmodel (newent, GetWeaponModel(self.sequence + 1, 1));
	setsize (newent, VEC_HULL2_MIN, VEC_HULL2_MAX);
	newent.angles = self.angles;
	
	self.enemy = newent;
}

void() weapon_wall =
{
	string temps;
	
	precache_model ("models/misc/chalk.mdl");
	temps = GetWeaponModel(self.sequence + 1, 1);
	precache_model (temps);

	setmodel (self, "models/misc/chalk.mdl");
	self.skin = 0;
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	self.frame = self.sequence;
	self.use = use_wall_weapon;
	self.classname = "weapon_wall";
	//self.effects = EF_WEPLIGHT;
  
}

/* ===================
   Custom Teddy Triggers
   ===================*/

void() teddy_react =
{
  local entity t;
  
	if (self.spawnflags & 1)
  {
   t = find (world, teddyremovetarget, self.target);
    
   if (!t)
      objerror ("couldn't find target");
      
    remove(t); 
  }
 /* if (self.noise)
    sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);*/
}