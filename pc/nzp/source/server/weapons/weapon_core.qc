void() W_PutOut;

void() ReturnWeaponModel =
{
	self.weaponmodel = GetWeaponModel(self.weapon, 0);
	if (self.weapon == W_KAR_SCOPE || self.weapon == W_HEADCRACKER) {
		self.weapon2model = "progs/VModels/v_karscope.mdl";
		UpdateV2model(self.weapon2model, 0);
	} else {
		UpdateV2model(self.weapon2model, GetWepSkin(self.weapon));
	}
		
	UpdateVmodel(self.weaponmodel, GetWepSkin(self.weapon));
}

void() W_AimIn =
{	
	if (IsDualWeapon(self.weapon) ||
		self.zoom ||
		self.reload_delay > time ||
		self.sprinting ||
		self.new_anim_stop) {
		return;
	}
	if (self.weapon == 11 || self.weapon == 19 ||
	    self.weapon == 49 || self.weapon == 51)
	{
		self.zoom = 2;
		SetUpdate(self, UT_ZOOM2, 0, 0, 0);
		self.viewzoom = 0.5;
	}
	else
	{
		self.zoom = 1;
		self.viewzoom = 0.9;
	}
	
	if (!self.downed)	
		playaim();
		
}

void() W_AimOut =
{
	if (!self.zoom ||
		self.new_anim_stop) {
		return;
	}
	if (self.weapon == 11 || self.weapon == 19 ||
	    self.weapon == 49 || self.weapon == 51)
		ReturnWeaponModel();
	
	self.zoom = 0;
	self.viewzoom = 1;
	
	if (!self.downed)
		playout();
}

void() W_SprintStop =
{
	float startframe = GetFrame(self.weapon,SPRINT_OUT_START);
	float endframe = GetFrame(self.weapon,SPRINT_OUT_END);
	string modelname = GetWeaponModel(self.weapon, 0);
	
	if (self.isBuying || self.damagetimer > time)
		return;
	
	self.viewzoom = 1;

	Set_W_Frame (startframe, endframe, 0, 0, SPRINT, SUB_Null, modelname, false, S_BOTH);
	self.sprinting = 0;
	self.into_sprint = 0;
	self.reload_delay2 = self.fire_delay2 = self.reload_delay = self.fire_delay = 0;
	
	if (self.velocity)
		playwalk();
}

void W_SprintStart () {
	
	if (self.fire_delay > time ||
		self.fire_delay2 > time ||
		self.new_anim_stop ||
		self.new_anim2_stop ||
		self.isBuying || 
		self.downed ||
		!(self.flags & FL_ONGROUND)) {
		return;
	}
		
	float startframe = GetFrame(self.weapon,SPRINT_IN_START);
	float endframe = GetFrame(self.weapon,SPRINT_IN_END);
	string modelname = GetWeaponModel(self.weapon, 0);

	self.viewzoom = 0.9;
	
	if (startframe || endframe) {
		Set_W_Frame (startframe, endframe, 0, 0, SPRINT, ContinueRun, modelname, false, S_BOTH);
	}

	self.sprinting = true;
	self.reload_delay2 = self.fire_delay2 = self.reload_delay = self.fire_delay = 0;
}

void() W_Switch =
{
	if (self.secondaryweapon && self.secondaryweapon !=0 && !self.new_anim_stop && !other.button7)
	{      
		float tempf,tempf1,tempf2;
		float startframe;
		float endframe;
		string modelname;
			
		tempf = self.currentammo;
		self.currentammo = self.secondaryammo;
		self.secondaryammo = tempf;

		tempf1 = self.currentmag;
		self.currentmag = self.secondarymag;
		self.secondarymag = tempf1;

		tempf1 = self.currentmag2;
		self.currentmag2 = self.secondarymag2;
		self.secondarymag2 = tempf1;

		tempf2 = self.weapon;
		self.weapon = self.secondaryweapon;
		self.secondaryweapon = tempf2;

		startframe = GetFrame(self.weapon,TAKE_OUT_START);
		endframe = GetFrame(self.weapon,TAKE_OUT_END);
		modelname = GetWeaponModel(self.weapon, 0);

		SwitchWeapon(self.weapon);
		
		/*if ((self.weapon == W_DB && self.secondaryweapon == W_SAWNOFF) || (self.weapon == W_SAWNOFF && self.secondaryweapon == W_DB))
      self.currentammo = self.secondaryammo;*/
		
		//UpdateWeapons(1);
		//if (self.weaponslot1.dualwield)
		//	Set_W2_Frame (self.weaponslot1.TakeWeaponStart, self.weaponslot1.TakeWeaponEnd, 0, 0, 0, SUB_Null, self.weaponslot1.v_model2, false);//FIXME
		Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);//FIXME
		
		self.reload_delay2 = self.fire_delay2 = self.reload_delay = self.fire_delay = 0;
	}
}

void() W_PutOut =
{
	if (self.downed) {
		return;
	}
	
	W_AimOut();
	self.weaponnum = !self.weaponnum;
	
	if (self.secondaryweapon && !self.new_anim_stop)
	{
		float startframe;
		float endframe;
		string modelname;
		startframe = GetFrame(self.weapon,PUT_OUT_START);
		endframe = GetFrame(self.weapon,PUT_OUT_END);
		modelname = GetWeaponModel(self.weapon, 0);
	
		Set_W_Frame (startframe, endframe, (endframe - startframe)/10, 0, SWITCHWEP, W_Switch, modelname, false, S_BOTH);//FIXME
		self.reload_delay2 = self.fire_delay2 = self.reload_delay = self.fire_delay = 0;
	}
}

void() W_TakeOut =
{
	W_AimOut();
	
	float startframe;
	float endframe;
	string modelname;
	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	modelname = GetWeaponModel(self.weapon, 0);
	
	Set_W_Frame (startframe, endframe, (endframe - startframe)/10, 0, SWITCHWEP, SUB_Null, modelname, false, S_BOTH);//FIXME
	self.reload_delay2 = self.fire_delay2 = self.reload_delay = self.fire_delay = 0;
}



//RELOAD

void(float side) W_Give_Ammo =
{
	float ammo_shot, max_mag, loadammo;
	
	max_mag = getWeaponMag(self.weapon);

	if (side == S_LEFT) {
		ammo_shot = max_mag - self.currentmag2;
	} else {
		ammo_shot = max_mag - self.currentmag;
	}
	if (ammo_shot < self.currentammo)
	{
    	self.currentammo = self.currentammo - ammo_shot;
      
		loadammo = max_mag;
	}
	else
	{
		loadammo = self.currentmag + self.currentammo;
		self.currentammo = 0;
	}

	if (side == S_LEFT) {
		self.currentmag2 = loadammo;
	} else {
		self.currentmag = loadammo;
	}
};

void () W_LoadAmmo;
void() ContinueReload = //Special reloads
{
	if (self.new_anim_stop)
		return;
	
	if (self.weapon == W_GUT && self.currentmag == 10)
    return;

	float delay = 0;
	string modelname = GetWeaponModel(self.weapon, 0);
	float startframe = 0;
	float endframe = 0;
	void(optional float t) endanimfunc = SUB_Null;
	
	if (self.currentmag >= getWeaponMag(self.weapon) || !self.currentammo || self.reloadinterupted) {
		if (self.weapon == W_KAR_SCOPE || self.weapon == W_HEADCRACKER)
		{
			delay = 1; 
			startframe = 24;
			endframe = 28;
		} else if (self.weapon == W_TRENCH || self.weapon == W_GUT) {
			delay = 0.5; 
			startframe = 24;
			endframe = 26;
			endanimfunc = W_LoadAmmo;
		}
		self.reloadinterupted = FALSE;
	} else if (self.currentmag < getWeaponMag(self.weapon)) {
		if (self.weapon == W_BROWNING || self.weapon == W_ACCELERATOR) {
			delay = 4; 
			startframe = 45;
			endframe = 77;
			endanimfunc = W_Give_Ammo;
		} else if (self.weapon == W_KAR_SCOPE || self.weapon == W_HEADCRACKER) {
			self.currentmag++;
        	self.currentammo = self.currentammo - 1;
			delay = 0.8; 
			startframe = 19;
			endframe = 24;
			endanimfunc = ContinueReload;
		} else if (self.weapon == W_TRENCH || self.weapon == W_GUT) {
			if (self.weapon == W_GUT && self.currentammo >= 2 && self.currentmag < 9) {
				self.currentmag = self.currentmag + 2;
				self.currentammo = self.currentammo - 2;
			} else {
				self.currentmag++;
				self.currentammo = self.currentammo - 1;
			}
			delay = 0.5; 
			startframe = 18;
			endframe = 23;
			endanimfunc = ContinueReload;
		}
	}

	if (delay) {
		if (self.perks & P_SPEED) {
			delay *= 0.75;
		}
		self.reload_delay = time + delay;
		Set_W_Frame (startframe, endframe, delay, 0, RELOAD, endanimfunc, modelname, false, S_RIGHT);
	}
}

void(float side) W_Reload =
{
	self.viewzoom = 1;
	
	if (side == S_BOTH) {
		W_Reload(S_RIGHT);
		if (IsDualWeapon(self.weapon)) {
			W_Reload(S_LEFT);
		}
		return;
	}
	if (side == S_RIGHT &&
		(self.reload_delay > time ||
		self.new_anim_stop ||
		!self.currentammo || 
		self.currentmag >= getWeaponMag(self.weapon))){
		return;
	}
	if (side == S_LEFT &&
		(self.reload_delay2 > time ||
		self.new_anim2_stop || 
		!self.secondaryammo ||
		self.currentmag2 >= getWeaponMag(self.weapon))) {
		return;
	}
	W_AimOut();
	W_SprintStop();

	float endframe, startframe, reloadcancelframe, delay;
	string modelname;
	if (side == S_RIGHT) {
		modelname = GetWeaponModel(self.weapon, 0);
	} else {
		if (IsDualWeapon(self.weapon)) {
			modelname = GetLeftWeaponModel(self.weapon); 
		}
	}
	
	if (self.currentammo)
	{
		playreload();
		
		startframe = GetFrame(self.weapon,RELOAD_START);
		endframe = GetFrame(self.weapon,RELOAD_END);
		reloadcancelframe = GetFrame(self.weapon,RELOAD_CANCEL);
		delay = getWeaponDelay(self.weapon,RELOAD);
		void(optional float t) endanimfunc = SUB_Null;

		if (self.weapon == W_BROWNING || self.weapon ==  W_ACCELERATOR) {
			if (!self.currentmag) {
				startframe = 26;
				endframe = 77;
				reloadcancelframe = 45;
				delay = 6;
				endanimfunc = W_Give_Ammo;
			} else if (self.currentmag > 0) {
				startframe = 4;
				endframe = 25;
				reloadcancelframe = 0;
				delay = 3.5;
				endanimfunc = ContinueReload;
			}
		} else if (self.weapon == W_KAR_SCOPE || self.weapon == W_HEADCRACKER ){
			startframe = 14;
			endframe = 18;
			reloadcancelframe = 0;
			delay = 0.8;
			endanimfunc = ContinueReload;
		} else if (self.weapon == W_M1 || self.weapon == W_M1000) {
			if (self.currentmag > 0) {
				startframe = 4;
				endframe = 44;
				reloadcancelframe = 25;
				delay = 3.9;
				endanimfunc = W_Give_Ammo;
			} else {
				startframe = 8;
				endframe = 44;
				reloadcancelframe = 25;
				delay = 3.6;
				endanimfunc = W_Give_Ammo;
			}
		} else if (self.weapon == W_TRENCH || self.weapon == W_GUT) {
			if (self.currentmag == 0) {
				self.NeedLoad = true;
			}
			startframe = 14;
			endframe = 17;
			reloadcancelframe = 0;
			delay = 0.8;
			endanimfunc = ContinueReload;
		} else {
			endanimfunc = W_Give_Ammo;
		}

		if (self.perks & P_SPEED)
			delay = delay*0.75;
		
		if (side == S_RIGHT) {
			self.reload_delay = delay + time;
		} else {
			self.reload_delay2 = delay + time;
		}
		
		self.zoom = false;
		Set_W_Frame (startframe, endframe, delay, reloadcancelframe, RELOAD, endanimfunc, modelname, false, side);
	}
	
	if (self.weapon != W_TRENCH) {
		self.NeedLoad = false;
	}
};

void () W_LoadAmmoDone =
{
	self.NeedLoad = false;
}
void () W_LoadAmmo =
{
	if (!self.NeedLoad)
		return;
	if (!self.currentmag)
	{
		W_Reload(S_BOTH);
		return;
	}

	string modelname;
	float endframe, startframe, reloadcancelframe, delay;

	modelname = GetWeaponModel(self.weapon, 0);
	startframe = GetFrame(self.weapon,RELOAD_START);
	endframe = GetFrame(self.weapon,RELOAD_END);
	reloadcancelframe = GetFrame(self.weapon,RELOAD_CANCEL);
	delay = getWeaponDelay(self.weapon,RELOAD);
	void(optional float t) endanimfunc = SUB_Null;

	if (self.weapon == W_TRENCH || self.weapon == W_GUT)
	{
		startframe = 4;
		endframe = 14;
		reloadcancelframe = 12;
		delay = 1;
		endanimfunc = W_LoadAmmoDone;
	}
	else if (self.weapon == W_KAR || self.weapon == W_ARMAGEDDON || self.weapon == W_KAR_SCOPE || self.weapon == W_HEADCRACKER)
	{
		startframe = 4;
		endframe = 13;
		reloadcancelframe = 9;
		delay = 0.9;
		endanimfunc = W_LoadAmmoDone;
	}	

	if (delay) {
		
		Set_W_Frame (startframe, endframe, delay, reloadcancelframe, FIRE, W_LoadAmmoDone, modelname, false, S_RIGHT);
		self.fire_delay = delay + time;
	}
}

void () CheckReload = 
{
	if (!self.currentmag2 && IsDualWeapon(self.weapon)) {
		W_Reload(S_LEFT);
	}
	if (!self.currentmag && self.currentammo) {
		W_Reload(S_RIGHT);
	}
}

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
  local entity f;
  
  te_blood(org, vel, 1);

  
	//particle (org, vel*0.1, 73, damage*2);
	//below is for gib testing.
	//particle (org, org, 225, 1);
	
	f = find (world, classname, "player");
  f.hitcount = f.hitcount + 1;
};


void Parse_Damage () = // DO NOT TOUCH
{
	entity ent;
	float total_dmg;
	ent = findfloat (world, washit, 1);

	while (ent) {
		if (ent.classname == "ai_zombie" || ent.classname == "ai_dog") {
			total_dmg = ent.hitamount;
			//Clear hit
			ent.washit = 0;
			ent.hitamount = 0;
			
			DamageHandler(ent,self, total_dmg, S_NORMAL);
		}
		ent = findfloat (ent, washit, 1);
	}
}

void() LungeKnifeHit =
{		
	vector	source,org;
	float	f_damage;
	entity	hit_ent;

	makevectors (self.v_angle);
	source = self.origin + self.view_ofs;
	if (self.weapon == W_BK)
		traceline (source, source + v_forward*80*1.2, 0, self); // naievil -- added some extra length
	else
		traceline (source, source + v_forward*64*1.2, 0, self); // naievil -- ^^
	
	org = trace_endpos - v_forward*3; // naievil -- changed to factor of 3 from 4
	

	if (trace_ent.takedamage)
	{
		if(trace_ent.classname == "item_radio" || trace_ent.classname == "teddy_spawn")
		{
			entity oldself;
			oldself  = self;
			self = trace_ent;
			self.th_die();
			self = oldself;
			return;
		}
		sound (self, CHAN_WEAPON, "sounds/weapons/knife/knife_hitbod.wav", 1, ATTN_NORM);
		
		if (self.bowie && self.weapon == W_BK)
			f_damage = 1200;
		else if (self.bowie)
			f_damage = 1000;
		else if (self.weapon == W_BK)
			f_damage = 500;
		else
			f_damage = 150;
					
		if (trace_ent.classname == "ai_zombie_head")
		{
			hit_ent = trace_ent.owner;
			f_damage = f_damage*1.5;
		}
		else if (trace_ent.classname == "ai_zombie_larm")
		{
			hit_ent = trace_ent.owner;
		}
		else if (trace_ent.classname == "ai_zombie_rarm")
		{
			hit_ent = trace_ent.owner;
		}
		else
		{
			hit_ent = trace_ent;
		}
		
		if (hit_ent.takedamage)
		{
			org = source + (v_forward * 20);
			SpawnBlood (org, org, 50);
			//hit = 1;
		}
		
		DamageHandler (hit_ent, self, f_damage, S_KNIFE);
	}
}

void(float damage, vector dir, vector org, vector plane, entity hit_ent) TraceAttack =
{
	vector  vel;
	float f_damage;
  
	vel = normalize(dir);
	vel = vel + 2*plane;
	vel = vel * 200;

	if (hit_ent.takedamage) {
		if (trace_fraction >= 1) {
			return;
		}
		if(hit_ent.classname == "item_radio" || hit_ent.classname == "teddy_spawn")
		{
			entity oldself;
			oldself  = self;
			self = hit_ent;
			self.th_die();
			self = oldself;
			return;
		} else if (hit_ent.classname == "explosive_barrel") {
			hit_ent.enemy = self;
			oldself  = self;
			self = hit_ent;
			self.health = self.health - damage;
			barrel_hit ();
			self = oldself;
			return;
		}
		
		SpawnBlood (org, vel, damage*10);
		

		f_damage = damage;

		hit_ent.washit = 1;
		hit_ent.hitamount = hit_ent.hitamount + f_damage;
		
		SetUpdate(self, UT_HM, 0, 0, 0);
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_PISTOLFIRE);
	WriteEntity(MSG_MULTICAST, self);
	WriteCoord(MSG_MULTICAST, org_x);
	WriteCoord(MSG_MULTICAST, org_y);
	WriteCoord(MSG_MULTICAST, org_z);
	WriteCoord(MSG_MULTICAST, plane_x);
	WriteCoord(MSG_MULTICAST, plane_y);
	WriteCoord(MSG_MULTICAST, plane_z);
	WriteEntity(MSG_MULTICAST, hit_ent);
	multicast(trace_endpos, MULTICAST_PHS);
};

void (float shotcount, float sprd, float Damage/*, float headmulti, float legmulti*/) FireTrace =
{
	float count, r, ru, penetration_times, do_break;
	vector dir, src, trace_start_org;
	entity hitent;
	
	makevectors(self.v_angle);
	
	src = self.origin + self.view_ofs;

	while (count < shotcount)
	{
		dir = aim (self,0);
		r = random() * sprd*10;
		if (random() < 0.5)
			r = r*-1;
		ru = random() * sprd*10;
		if (random() < 0.5)
			ru = ru*-1;

		dir = dir*2048;
		dir = dir + v_right*r + v_up*ru;
		trace_start_org = src;
		trace_ent = self;
		do_break = 0;
		penetration_times = 0;
		hitent = world;
		while (!do_break && random() < getWeaponPenetration(self.weapon, penetration_times))
		{
			while (1)
			{
				traceline (trace_start_org, trace_start_org + dir, MOVE_HITMODEL, trace_ent);
				if (hitent == world)
					break;
				/*if (hitent.larm == trace_ent || hitent.rarm == trace_ent || hitent.head == trace_ent)
				{
					hitent = trace_ent;
					trace_start_org = trace_endpos + normalize(dir)*10;
					//break;
				}*/
				else
					break;
			}
			
			if (trace_fraction != 1.0)
				TraceAttack (Damage, dir, trace_endpos, trace_plane_normal, trace_ent);
			trace_start_org = trace_endpos;
			penetration_times++;
			if (!trace_ent.takedamage)
				do_break = 1;
			
			if (trace_ent.classname == "ai_zombie_head" || trace_ent.classname == "ai_zombie_larm" || trace_ent.classname == "ai_zombie_rarm")
				hitent = trace_ent.owner;
			else
				hitent = trace_ent;

		}
		hitent = world;

		count++;
	}
	Parse_Damage();

}


void(float side) W_Fire =
{
	//First check that we can actualy fire
	if (side == S_RIGHT &&
		(time < self.fire_delay ||
		self.new_anim_stop ||
		self.reload_delay > time || (!self.currentammo && !self.currentmag))) {
		return;
	}

	if (side == S_LEFT &&
		(time < self.fire_delay2 ||
		self.new_anim2_stop ||
		self.reload_delay2 > time)) {
		return;
	}

	if (self.sprinting) {
		W_SprintStop();
		return;
	}

	float startframe;
	float endframe;
	float firetype;
	float damage;
	float shotcount;
	string modelname;
	string soundname;
	float spread;
	float delay;

	//Update the basic vectors
	makevectors(self.v_angle);

	//make sure magazine is loading
	if (!self.currentmag && side == S_RIGHT)
	{
		W_Reload(S_RIGHT);
		return;
	} else if (!self.currentmag2 && side == S_LEFT)
	{
		W_Reload(S_LEFT);
		return;
	}

	//Dont fire if the gun has to cycle
	if (self.NeedLoad && (self.weapon == W_TRENCH || self.weapon == W_GUT || self.weapon == W_KAR_SCOPE || self.weapon == W_KAR || self.weapon == W_ARMAGEDDON || self.weapon == W_HEADCRACKER))
	{
		W_LoadAmmo();
		return;
	}
	
	//get some basic info
	damage = getWeaponDamage(self.weapon);   
	firetype = GetFiretype (self.weapon);
	if (side == S_RIGHT) {
		modelname = GetWeaponModel(self.weapon, 0);
	} else {
		if (IsDualWeapon(self.weapon)) {
			modelname = GetLeftWeaponModel(self.weapon); 
		}
	}
	shotcount = GetWeaponShotcount(self.weapon);
    soundname = GetWeaponSound(self.weapon);
	delay = getWeaponDelay(self.weapon, FIRE);
	spread = 1.5*GetWeaponSpread(self.weapon);

	if (self.zoom == 1) {
		if (self.weapon == W_TRENCH ||
			self.weapon == W_DB ||
			self.weapon == W_SAWNOFF ||
			self.weapon == W_GUT ||
			self.weapon == W_BORE) {
				spread = spread * 0.75;
			} else {
				spread = spread * 0.1;
			}
	} else if (self.zoom == 2)
		spread = spread * 0.05;

	if (self.downed)
		playdownfire();

	//Fire weapons
	if (firetype == 1)
	{
		if (side == S_RIGHT) {
			if (self.semi) {
				return;
			}
			self.semi = TRUE;
		} else if (side == S_LEFT) {
			if (self.semi2) {
				return;
			}
			self.semi2 = TRUE;
		}
	}

	FireTrace(shotcount, spread, damage/* , self.weaponslot1.headx, self.weaponslot1.legx */);


	//Play weapon animation and sound
	startframe = GetFrame(self.weapon,FIRE_START);
	endframe = GetFrame(self.weapon,FIRE_END);

	if (self.perks & P_DOUBLE) {
		delay *=0.5;
	}

	if (self.weapon == W_GUT || self.weapon == W_KAR_SCOPE || self.weapon == W_TRENCH || self.weapon == W_KAR || self.weapon == W_ARMAGEDDON || self.weapon == W_HEADCRACKER)
	{
		Set_W_Frame (startframe, endframe, delay, 0, FIRE, W_LoadAmmo, modelname, FALSE, side);
		self.NeedLoad = true;
	} else {
		Set_W_Frame (startframe, endframe, delay, 0, FIRE, CheckReload, modelname, FALSE, side);
	}


	sound (self, CHAN_WEAPON, soundname, 1, ATTN_NORM);

	if (side == S_RIGHT) {
		self.currentmag = self.currentmag - 1;
		self.fire_delay = getWeaponDelay(self.weapon, FIRE) + time;
	} else {
		self.currentmag2 = self.currentmag2 - 1;
		self.fire_delay2 = getWeaponDelay(self.weapon, FIRE) + time;
	}

	if (IsPapWeapon(self.weapon)) {
		sound (self, 0, "sounds/weapons/papfire.wav", 1, ATTN_NORM);
	}
	
	SetUpdate(self, UT_HUD, 6, 0, 0);
	SetUpdate(self, UT_CROSSHAIR, 5, 0, 0);
}


/******************************
* W_Knife                     *
******************************/

void () W_Knife =
{
	if (time < self.knife_delay || self.new_anim_stop ||
	  self.zoom == 2 || self.zoom == 3 || self.health == 10 || 
	  (!(self.flags & FL_ONGROUND)))
		return;

	vector	source;
	entity	hit_ent = world;
	//entity	oldself;
	float	r;
	vector	org;
	float hit = false;
	
	if (self.sprinting) {
		W_SprintStop();
	}
	
	sound (self, CHAN_WEAPON, "sounds/weapons/knife/knife.wav", 1, ATTN_NORM);
	makevectors (self.v_angle);
	source = self.origin + self.view_ofs;
	if (self.weapon == W_BK)
		traceline (source, source + v_forward*128, 0, self);
	else
		traceline (source, source + v_forward*100, 0, self);
	
	org = trace_endpos - v_forward*4;

	r = fabs(vlen(source - org));

	if (trace_ent.takedamage)
	{
		if (trace_ent.classname == "ai_zombie_head")
			hit_ent = trace_ent.owner;
		else if (trace_ent.classname == "ai_zombie_larm")
			hit_ent = trace_ent.owner;
		else if (trace_ent.classname == "ai_zombie_rarm")
			hit_ent = trace_ent.owner;
		else
			hit_ent = trace_ent;
		if (hit_ent.classname == "ai_zombie")
			hit = true;
	}
	else if (trace_fraction < 1.0)
	{	// hit wall
		sound (self, CHAN_WEAPON, "sounds/weapons/knife/knife_hit.wav", 1, ATTN_NORM);			
		
		/* naievil (FIXME) add weapon decal here */
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_PISTOLFIRE);
	WriteEntity(MSG_MULTICAST, self);
	WriteCoord(MSG_MULTICAST, org_x);
	WriteCoord(MSG_MULTICAST, org_y);
	WriteCoord(MSG_MULTICAST, org_z);
	WriteCoord(MSG_MULTICAST, trace_plane_normal_x);
	WriteCoord(MSG_MULTICAST, trace_plane_normal_y);
	WriteCoord(MSG_MULTICAST, trace_plane_normal_z);
	WriteEntity(MSG_MULTICAST, hit_ent);
	multicast(trace_endpos, MULTICAST_PHS);
	}

	if (r > 40 && hit)//lunge
	{
		if (self.weapon == W_BK)
		{
			Set_W_Frame (14, 24, 1.4, 0, KNIFE, SUB_Null, "progs/VModels/v_bk.mdl", false, S_RIGHT);
			self.fire_delay = time + 1.5;
			self.knife_delay = time + 1.75;
		}
		else if (self.bowie)
		{
			Set_W_Frame (4, 10, 0.7, 0, KNIFE, ReturnWeaponModel, "progs/VModels/v_bowie.mdl", false, S_RIGHT);
			self.fire_delay = time + 0.8;
			self.knife_delay = time + 1.3;
		}
		else
		{
			Set_W_Frame (4, 12, 0.7, 0, KNIFE, ReturnWeaponModel, "progs/VModels/v_knife.mdl", false, S_RIGHT);
			self.fire_delay = time + 0.8;
			self.knife_delay = time + 1;
		}
		self.velocity = v_forward * 200;
		
	}
	else
	{
		if (self.weapon == W_BK)//slash
		{
			Set_W_Frame (8, 13, 0, 0.4, KNIFE, SUB_Null, "progs/VModels/v_bk.mdl", false, S_RIGHT);
			self.fire_delay = time + 0.5;
			self.knife_delay = time + 0.8;
		}
		else if (self.bowie)
		{
			Set_W_Frame (0, 3, 0.3, 0, KNIFE, ReturnWeaponModel, "progs/VModels/v_bowie.mdl", false, S_RIGHT);
			self.fire_delay = time + 0.4;
			self.knife_delay = time + 0.9;
		}
		else
		{
			self.punchangle_x = -5;
			self.punchangle_y = -10;
			//self.punchangle_z = 5;
			Set_W_Frame (0, 3, 0.3, 0, KNIFE, ReturnWeaponModel, "progs/VModels/v_knife.mdl", false, S_RIGHT);
			self.fire_delay = time + 0.4;
			self.knife_delay = time + 0.7;
		}
	}
	self.reload_delay2 = self.reload_delay = 0;
	
	LungeKnifeHit();

	};




/******************************
* W_Grenade                   *
******************************/

void() switch_nade = 
{ 
	if (self.downed || self.isBuying || !(self.grenades & 2) || self.semiswitch)
      return;

	if (self.pri_grenade_state == 0)
	{
		centerprint (self, "Bouncing Betties Selected");
		self.bk_nade = 1;
    }
    if (self.pri_grenade_state == 1)
    {
		centerprint (self, "Frag Grenades Selected");
		self.bk_nade = 0;
    }  	
	
	self.pri_grenade_state = self.bk_nade;

};

void() GrenadeExplode =
{
	sound (self, CHAN_WEAPON, "sounds/weapons/grenade/explode.wav", 1, ATTN_NORM);	
	DamgageExplode (self, self.owner, 225, 75, 128);//was 256 inch radius, kicked it down to 128 because 21 feet exploding radius is... a bit overkill...	
	te_explosionquad(self.origin);
	SUB_Remove ();
};
void() NadeStraighten =
{
	self.angles_x = (self.angles_x > 0) ? 90 : -90;	
	
	if (self.pri_grenade_state == 1)
    return;
};
void() Velocity_reduce =
{
	if (!other.solid || other.solid == SOLID_TRIGGER)
		if (other != world)
			return;

	self.velocity = self.velocity*0.5;
	
	NadeStraighten();
};

void() betty_touch = 
{
  //centerprint (other, "wow\n");
  if (other == self.owner || other.solid == SOLID_TRIGGER)
    if (other != world)
      return;
  
  GrenadeExplode();
}

void() W_ThrowGrenade =
{
	string modelname;
	float startframe;
	float endframe;
	local	entity nade;
	local entity betty;

	if (self.pri_grenade_state == 0) {
		nade = spawn ();
		nade.owner = self;
		nade.grenade_delay = nade.owner.grenade_delay;
		nade.owner.grenade_delay = 0;
		nade.movetype = MOVETYPE_BOUNCE;
		nade.solid = SOLID_BBOX;
		nade.classname = "grenade";

		// set nade speed	

		makevectors (self.v_angle);

		nade.velocity = v_forward*500;

		nade.avelocity = '400 -400 400';

		//nade.angles = vectoangles(nade.velocity);
		//nade.angles_z += (nade.angles_z + 180 < 360)? 180 : -180;
		nade.angles = vectoangles(v_forward);
		nade.angles_z -= 15;
		// set nade duration
		nade.nextthink = nade.grenade_delay;
		nade.think = GrenadeExplode;

		nade.touch = Velocity_reduce;
		setmodel (nade, "progs/GModels/g_grenade.mdl");
		setsize (nade, '0 0 0', '0 0 0');
		nade.origin = self.origin + self.view_ofs;
		nade.origin += v_forward * 12;
		setorigin (nade, nade.origin);

		self.animend = ReturnWeaponModel;
		self.callfuncat = 0;
		self.isBuying = false;
	} else if (self.pri_grenade_state == 1) {
		if (!(self.flags & FL_ONGROUND)) {
			self.semiswitch = false;
			centerprint (self, "You cannot place a bouncing betty here");
			self.animend = ReturnWeaponModel;
			self.callfuncat = 0;
			self.isBuying = false; 
		}
		if (self.flags & FL_ONGROUND) {
			betty = spawn ();
			betty.owner = self;
			betty.grenade_delay = betty.owner.grenade_delay;
			betty.owner.grenade_delay = 0;
			betty.movetype = MOVETYPE_NONE;
			betty.solid = SOLID_TRIGGER;
			betty.classname = "betty";

			// set betty speed	
			betty.velocity = v_forward*0;

			//nade.angles = vectoangles(nade.velocity);
			//nade.angles_z += (nade.angles_z + 180 < 360)? 180 : -180;
			// set nade duration
			betty.think = GrenadeExplode;

			betty.touch = betty_touch;
			setmodel (betty, "progs/GModels/g_betty.mdl");
			setsize (betty, '-16 -16 -4', '16 16 1');
			betty.origin = betty.owner.origin - self.view_ofs + '0 0 1';
			betty.origin += v_forward * 0;
			setorigin (betty, betty.origin);

			self.animend = ReturnWeaponModel;
			self.callfuncat = 0;
			self.isBuying = false;  
		}
	} else  {
		centerprint (other, "No grenadetype defined...\n");
	}

	if (!(self.flags & FL_ONGROUND)) {
		self.secondary_grenades = self.secondary_grenades + 1;
	}

	startframe = GetFrame(self.weapon,TAKE_OUT_START);
	endframe = GetFrame(self.weapon,TAKE_OUT_END);
	modelname = GetWeaponModel(self.weapon, 0);
	Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false, S_BOTH);
	self.semiswitch = false;

	SetUpdate(self, UT_HUD, 6, 0, 0);
}

void() checkHold =
{
 if (self.pri_grenade_state == 0)
 {
	if (!self.button3 || self.grenade_delay < time)
	{
		if(self.grenade_delay < time)
			self.grenade_delay = time + 0.05;
			
		self.isBuying = true;  
		Set_W_Frame (3, 6, 0, 5, GRENADE, W_ThrowGrenade, "progs/VModels/v_nade.mdl", true, S_RIGHT);
		sound (self, CHAN_WEAPON, "sounds/weapons/grenade/throw.wav", 1, ATTN_NORM);
		self.reload_delay2 = self.fire_delay2 = self.reload_delay = self.fire_delay = time + 0.4;
		self.throw_delay = time + 0.9;
	}
	else
	{
    	self.isBuying = true;
		Set_W_Frame (2, 2, 0, 0, GRENADE, checkHold, "progs/VModels/v_nade.mdl", true, S_RIGHT);
		//self.weaponframe = 12;
		//self.weapon_anim_end = 12;
		//self.animend = checkHold;
		//self.weapon_anim_type = GRENADE;
	}
 }
  else if (self.pri_grenade_state == 1)
 {    
	if (!self.button3)
	{
		if(self.grenade_delay < time)
			self.grenade_delay = time + 0.05;
		self.isBuying = true;
		Set_W_Frame (18, 23, 0, 5, GRENADE, W_ThrowGrenade, "progs/VModels/v_betty.mdl", true, S_RIGHT);
		sound (self, CHAN_WEAPON, "sounds/weapons/grenade/throw.wav", 1, ATTN_NORM);
		self.reload_delay2 = self.fire_delay2 = self.reload_delay = self.fire_delay = time + 0.4;
		self.throw_delay = time + 0.9;
	}
	else
	{    
		self.isBuying = true;
		Set_W_Frame (18, 18, 0, 0, GRENADE, checkHold, "progs/VModels/v_betty.mdl", true, S_RIGHT);
	}
 }
 else
	centerprint (other, "grenades switched up...\n");
		
}

void() W_Grenade =
{
	if (self.throw_delay > time || self.zoom || self.downed)
		return;

	if (self.primary_grenades > 0 || self.secondary_grenades > 0)
  {         
	  if (self.pri_grenade_state == 0 && self.primary_grenades > 0)
      {
		Set_W_Frame (0, 2, 0, 0, GRENADE, checkHold, "progs/VModels/v_nade.mdl", true, S_RIGHT);
		sound (self, CHAN_WEAPON, "sounds/weapons/grenade/prime.wav", 1, ATTN_NORM);	
		self.primary_grenades = self.primary_grenades - 1;
		self.reload_delay2 = self.fire_delay2 = self.throw_delay = self.reload_delay = self.fire_delay = time + 6;
		self.grenade_delay = time + 5;
		//self.holdnade = TRUE;
      }
    else if (self.pri_grenade_state == 1 && self.secondary_grenades > 0)
      {  
		Set_W_Frame (0, 18, 0, 0, GRENADE, checkHold, "progs/VModels/v_betty.mdl", true, S_RIGHT);
		sound (self, CHAN_WEAPON, "sounds/weapons/grenade/prime.wav", 1, ATTN_NORM);	
		self.secondary_grenades = self.secondary_grenades - 1;
		self.reload_delay2 = self.fire_delay2 = self.throw_delay = self.reload_delay = self.fire_delay = time + 6;
//	 	self.grenade_delay = time + 5;
      //self.holdnade = TRUE;
      }
    self.semiswitch = true;
   }    
}

void() CheckButtonOne = {if (self.weaponnum == 1){W_PutOut();}}		// weapon switch to two if 1
void() CheckButtonTwo = {if (self.weaponnum == 0) {W_PutOut();}}	// weapon switch to one if 2

void () Impulse_Functions =
{
	if (!self.impulse)
		return;
		
	switch (self.impulse)
	{		
		case 22:
			addmoney(self, 10000, 0);
			rounds += 4;
			break;
		case 23:
			W_SprintStart();
			break;
		case 24:
			W_SprintStop();
			break;
		case 25:
			switch_nade();
			break;
		case 110:
			CheckButtonOne();
			break;
		case 111:
			CheckButtonTwo();
			break;		
		default:
			bprint(PRINT_HIGH, "Unknown impulse: ", ftos(self.impulse));
			break;
	}
	
	self.impulse = 0;
};

void() CheckImpulses =
{
	self.impulse = 0;
}

void(entity ent) CheckPowerups =
{
	if (instakill_finished >= time)
	{
		if (instakill_finished < 4 + time)
		{
			if (insta_blink< time - 0.25)
				insta_blink = time + 0.25;
		}
		else if (instakill_finished < 7 + time)
		{
			if (insta_blink< time - 0.5)
				insta_blink = time + 0.5;
		}
		else if (instakill_finished < 10 + time)
		{
			if (insta_blink< time - 1)
				insta_blink = time + 1;
		}
		if (insta_blink < time)
			ent.insta_icon = true;
		else 
			ent.insta_icon = false;			
	}
	else if(instakill_finished)
	{
		instakill_finished = 0;
		ent.insta_icon = false;
	}
	
	if (x2_finished > time)
	{
		if (x2_finished < 4 + time)
		{
			if (x2_blink< time - 0.25)
				x2_blink = time + 0.25;
		}
		else if (x2_finished < 7 + time)
		{
			if (x2_blink< time - 0.5)
				x2_blink = time + 0.5;
		}
		else if (x2_finished < 10 + time)
		{
			if (x2_blink< time - 1)
				x2_blink = time + 1;
		}
		if (x2_blink < time)
			ent.x2_icon = true;
		else 
			ent.x2_icon = false;

		
	}
	else if(x2_finished)
	{
		x2_finished = 0;
		ent.x2_icon = false;
	}

}

void() CheckPlayer = 
{
	CheckPowerups(self);
	CheckRevive(self);
	
	entity ent;
	ent = findradius(self.origin, 70);
		
	while(ent)
	{
		if(ent.classname == "player" && ent != self && ent.downed && !self.downed)
		{
			useprint (self, 13, 0, 0);
			
			if (self.button7 && !ent.invoke_revive) {
				centerprint(ent, "Another player is reviving you...");
				ent.beingrevived = true;
				
				if (!self.progress_bar_percent) {
					self.movetype = MOVETYPE_NONE;
					Set_W_Frame (0, 21, 0, 0, SPRINT, SUB_Null, "models/v_morphine.mdl", false, S_BOTH);
					
					if !(self.perks & P_REVIVE)
						self.progress_bar_time = 4;
					else
						self.progress_bar_time = 2;
					
					self.progress_bar = self.progress_bar_time + time;     
					self.progress_bar_percent = 1;
					self.reviving = true;
				}
				
				if (self.revived) {
					self.movetype = MOVETYPE_WALK;
					W_TakeOut();
					ent.invoke_revive = 1;
					ent.beingrevived = false;
					self.reviving = 0;
					self.progress_bar = 0;
					self.progress_bar_time = 0;
					self.progress_bar_percent = 0;
					self.revived = 0;
				}
			}
			else if (!self.button7 && self.reviving) {
				self.movetype = MOVETYPE_WALK;
				ent.beingrevived = false;
				W_TakeOut();
				self.progress_bar = 0;
				self.progress_bar_time = 0;
				self.progress_bar_percent = 0;
				self.revived = 0;
				self.reviving = 0;
			}
		}
		else if(ent.classname == "player" && ent != self && !ent.downed) // small player push 
		{
			vector push;
			push =  ent.origin - self.origin;
			push_z = 0;
			push = normalize(push) * 0.5;
			
			ent.velocity += push;
		}
		ent = ent.chain;
	}
}

void () Weapon_Logic =
{
	W_Frame_Update ();
	Impulse_Functions();

	if (IsDualWeapon(self.weapon)) { 
		if (self.button0) {
			W_Fire(S_LEFT);
		} else {
			self.semi2 = FALSE;
		}

		if (self.button8) {
			W_Fire(S_RIGHT);
		} else {
			self.semi = FALSE;
		}
	} else {
		if (self.button0) {
			W_Fire(S_RIGHT);
		} else {
			self.semi = FALSE;
		}

		if (self.button8 && !self.zoom) {
			W_AimIn();
		} else if (!self.button8 && self.zoom) {
			W_AimOut();
		}
	}

	
	if (!self.button7) {
		self.semiuse = false;
	}
	
	if (self.button4 && !self.semiswitch && self.secondaryweapon && self.secondaryweapon !=0 && !self.zoom)
	{
		W_PutOut();
		self.semiswitch = true;
	} else if (!self.button4) {
		self.semiswitch = false;
	}
	
	if (self.button3 && self.isBuying != true && self.semiswitch != true)
	{
		W_Grenade();
		self.semiswitch = true;
	}
	else if (!self.button3)
		self.semiswitch = false;

	if (self.button5 && !self.semireload)
	{
		W_Reload(S_BOTH);
		self.semireload = TRUE;
	}
	else if (!self.button5) {
		self.semireload = FALSE;
	}
	
	if (self.button6 && !self.semiknife)
	{ 
		W_Knife();
		self.semiknife = true;
	}
	else if (!self.button6)
		self.semiknife = false;
	
	CheckImpulses();
	CheckPlayer();
}