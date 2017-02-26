
void(float to) SwitchWeapon =
{
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_WEAPONCHANGE);
	WriteByte(MSG_MULTICAST, to);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
	
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
		
		FireTrace(shotcount, spread, damage/* , self.weaponslot1.headx, self.weaponslot1.legx */);

		self.semi = TRUE;
	}


	//Play weapon animation and sound
	startframe = GetFrame(self.weapon,FIRE_START);
	endframe = GetFrame(self.weapon,FIRE_END);
	Set_W_Frame (startframe, endframe, delay, 0, FIRE, CheckReload, modelname, FALSE);
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

	if (self.button5 && !self.semireload)
	{
		W_Reload();
		self.semireload = true;
	}
	else if (!self.button5)
		self.semireload = false;
}