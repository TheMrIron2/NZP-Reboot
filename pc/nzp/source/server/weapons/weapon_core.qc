
void(float to) SwitchWeapon =
{
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_WEAPONCHANGE);
	WriteByte(MSG_MULTICAST, to);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
	
}
void() W_Switch =
{
	if (self.secondaryweapon && self.secondaryweapon !=0 && !self.new_anim_stop && !other.button1)
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
		Set_W_Frame (startframe, endframe, 0, 0, 0, SUB_Null, modelname, false);//FIXME
		
		/*self.reload_delay2 = self.fire_delay2 = */self.reload_delay = self.fire_delay = 0;
	}
}

void() W_PutOut =
{
	if (self.secondaryweapon && !self.new_anim_stop)
	{
		float startframe;
		float endframe;
		string modelname;
		startframe = GetFrame(self.weapon,PUT_OUT_START);
		endframe = GetFrame(self.weapon,PUT_OUT_END);
		modelname = GetWeaponModel(self.weapon, 0);
		//UpdateWeapons(1);
		//if (self.weaponslot1.dualwield)
		//	Set_W2_Frame (self.weaponslot1.PutOutStart, self.weaponslot1.PutOutEnd, (self.weaponslot1.PutOutEnd - self.weaponslot1.PutOutStart)/10, 0, SWITCHWEP, W_Switch, self.weaponslot1.v_model2, false);//FIXME
		Set_W_Frame (startframe, endframe, (endframe - startframe)/10, 0, SWITCHWEP, W_Switch, modelname, false);//FIXME
		/*self.reload_delay2 = self.fire_delay2 = */self.reload_delay = self.fire_delay = 0;
	}
}


//RELOAD

void() W_Give_Ammo =
{
	float ammo_shot, max_mag;
	
	max_mag = getWeaponMag(self.weapon);

	ammo_shot = max_mag - self.currentmag;
	if (ammo_shot < self.currentammo)
	{
    	self.currentammo = self.currentammo - ammo_shot;
      
		self.currentmag = max_mag;
	}
	else
	{
		self.currentmag = self.currentmag + self.currentammo;
		self.currentammo = 0;
	}
	//UpdateWeapons(0);
};

void() ContinueReload = //Special reloads
{
	float delay;
	if (self.new_anim_stop)
		return;
	string modelname;
	modelname = GetWeaponModel(self.weapon, 0);
	
	if (self.weapon == W_GUT && self.currentmag == 10)
    return;
	
	if (self.currentmag >= getWeaponMag(self.weapon) || !self.currentammo || self.reloadinterupted) {
		if (self.weapon == W_KAR_SCOPE || self.weapon == W_HEADCRACKER)
		{
			delay = 1; 
			self.reload_delay = time + delay;
			Set_W_Frame (24, 28, delay, 0, RELOAD, SUB_Null, modelname, false);
		}
		self.reloadinterupted = FALSE;
	} else if (self.currentmag < getWeaponMag(self.weapon)) {
		if (self.weapon == W_BROWNING || self.weapon == W_ACCELERATOR) {
			delay = 4; 
			self.reload_delay = time + delay;
			Set_W_Frame (45, 77, delay, 50, RELOAD, W_Give_Ammo, modelname, false);
		} else if (self.weapon == W_KAR_SCOPE || self.weapon == W_HEADCRACKER)
		{
			self.currentmag++;
        	self.currentammo = self.currentammo - 1;
			delay = 0.8; 
			self.reload_delay = time + delay;
			Set_W_Frame (19, 24, delay, 0, RELOAD, ContinueReload, modelname, false);
		}
	}
}

void() W_Reload =
{
	//blubs remove me, for testing rendering zombie models=============
	/*
	local entity z;
	z = find(world,classname,"test_zombie");
	while(z)
	{
		remove(z);
		z = find(z,classname,"test_zombie");
	}*/
	//==============================================================
	if (self.reload_delay > time || self.new_anim_stop || self.currentmag >= getWeaponMag(self.weapon))
		return;

	float endframe, startframe, reloadcancelframe;
	string modelname;
	modelname = GetWeaponModel(self.weapon, 0);
	
	if (self.currentammo)
	{
		startframe = GetFrame(self.weapon,RELOAD_START);
		endframe = GetFrame(self.weapon,RELOAD_END);
		reloadcancelframe = GetFrame(self.weapon,RELOAD_CANCEL);

		if (self.weapon == W_BROWNING || self.weapon ==  W_ACCELERATOR)
		{
			if (!self.currentmag)
			{
				Set_W_Frame (26, 77, 0, 45, RELOAD, W_Give_Ammo, modelname, false);
				self.reload_delay = 6 + time;
			}
			else if (self.currentmag > 0)
			{
				Set_W_Frame (4, 25, 0, 0, RELOAD, ContinueReload, modelname, false);
				self.reload_delay = 3.5 + time;
			}
		} else if (self.weapon == W_KAR_SCOPE || self.weapon == W_HEADCRACKER ){
			Set_W_Frame (14, 18, 0, 0, RELOAD, ContinueReload, modelname, false);
			self.reload_delay = 0.8 + time;
		} else {
			Set_W_Frame (startframe, endframe, 0, reloadcancelframe, RELOAD, W_Give_Ammo, modelname, TRUE);
			self.reload_delay = getWeaponDelay(self.weapon,RELOAD);
			self.reload_delay = self.reload_delay + time;
		}


	}
};

void () W_LoadAmmoDone =
{
	self.NeedLoad = false;
}
void () W_LoadAmmo =
{
	string modelname;
	if (!self.NeedLoad)
		return;
	if (!self.currentmag)
	{
		W_Reload();
		return;
	}

	modelname = GetWeaponModel(self.weapon, 0);

	if (self.weapon == W_TRENCH || self.weapon == W_GUT)
	{
		Set_W_Frame (4, 14, 0, 12, FIRE, W_LoadAmmoDone, modelname, false);
		self.fire_delay = 1 + time;
	}
	else if (self.weapon == W_KAR || self.weapon == W_ARMAGEDDON || self.weapon == W_KAR_SCOPE || self.weapon == W_HEADCRACKER)
	{
		Set_W_Frame (4, 13, 1.1, 9, FIRE, W_LoadAmmoDone, modelname, false);
		self.fire_delay = 0.9 + time;
	}	
}

void () CheckReload = 
{
	if (!self.currentmag) {
		W_Reload();
	}
}


void Parse_Damage () = // DO NOT TOUCH
{
}

void(float Damage, vector dir, vector org, vector plane, entity hit_ent) TraceAttack =
{
	vector  vel;
  
	vel = normalize(dir);
	vel = vel + 2*plane;
	vel = vel * 200;

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
	float count, r, ru, do_break, penetration_times;
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
				traceline (trace_start_org, trace_start_org + dir, 0, trace_ent);
				if (hitent == world)
					break;
				
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


void() W_Fire =
{
	//First check that we can actualy fire
	if (time < self.fire_delay || self.new_anim_stop || self.reload_delay > time || self.weapon == 0)
		return;

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
	if (!self.currentmag)
	{
		W_Reload();
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
	modelname = GetWeaponModel(self.weapon, 0);
	shotcount = GetWeaponShotcount(self.weapon);
    soundname = GetWeaponSound(self.weapon);
	delay = getWeaponDelay(self.weapon, FIRE);
	spread = GetWeaponSpread(self.weapon);


	//Fire weapons
	if (firetype == 1)
	{
		if (self.semi)
			return;
		
		self.semi = TRUE;
	}

	FireTrace(shotcount, spread, damage/* , self.weaponslot1.headx, self.weaponslot1.legx */);


	//Play weapon animation and sound
	startframe = GetFrame(self.weapon,FIRE_START);
	endframe = GetFrame(self.weapon,FIRE_END);
	if (self.weapon == W_GUT || self.weapon == W_KAR_SCOPE || self.weapon == W_TRENCH || self.weapon == W_KAR || self.weapon == W_ARMAGEDDON || self.weapon == W_HEADCRACKER)
	{
		Set_W_Frame (startframe, endframe, delay, 0, FIRE, W_LoadAmmo, modelname, FALSE);
		self.NeedLoad = true;
	} else {
		Set_W_Frame (startframe, endframe, delay, 0, FIRE, CheckReload, modelname, FALSE);
	}


	sound (self, CHAN_WEAPON, soundname, 1, ATTN_NORM);

	self.currentmag = self.currentmag - 1;
	self.fire_delay = getWeaponDelay(self.weapon, FIRE) + time;
}

void () Weapon_Logic =
{
	W_Frame_Update ();

	if (self.button0) {
		W_Fire();
	} else {
		self.semi = FALSE;
	}
	
	if (!self.button1) {
		self.semiuse = false;
	}

	
	if (self.button4 && !self.semiswitch && self.secondaryweapon && self.secondaryweapon !=0)
	{
		W_PutOut();
		self.semiswitch = true;
	} else if (!self.button4) {
		self.semiswitch = false;
	}

	if (self.button5 && !self.semireload)
	{
		W_Reload();
		self.semireload = TRUE;
	}
	else if (!self.button5) {
		self.semireload = FALSE;
	}
}