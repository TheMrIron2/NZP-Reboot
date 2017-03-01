

void () W_Frame_Update =
{
	local void temp();

// note: call whenever weapon frames are called!

	if (self.anim_weapon_time > time)
		return; //don't call every frame, if it is the animations will play too fast

	
	if (self.weapon_animduration)
	{
		if (self.weapon_anim_type == RELOAD && self.perks & P_SPEED)
			self.anim_weapon_time = time + self.weapon_animduration * 0.45;
		else if (self.weapon_anim_type == FIRE && self.perks & P_DOUBLE)
			self.anim_weapon_time = time + self.weapon_animduration * 0.75;
		else
			self.anim_weapon_time = time + self.weapon_animduration;
	}
	else if (self.weapon_anim_type == RELOAD && self.perks & P_SPEED)
		self.anim_weapon_time = time + 0.05;
	else if (self.weapon_anim_type == FIRE && self.perks & P_DOUBLE)	
		self.anim_weapon_time = time + 0.075;
	else if (self.weapon_anim_type == REVIVE && self.perks & P_REVIVE)	
		self.anim_weapon_time = time + 0.05;
	else if (self.weapon_anim_type == KNIFE2)	
		self.anim_weapon_time = time + 0.05;
	else
		self.anim_weapon_time = time + 0.1;
	
    self.anim_weapon_time = time + 0.1;



	if (self.weaponframe != self.weaponframe_end && !self.anim_reversed)
	{   // continue an animation

        if (self.anim_reversed) {
		    self.weaponframe = self.weaponframe - 1;
        } else {
		    self.weaponframe = self.weaponframe + 1;
        }

		if (self.weaponmodel == "models/weapons/kar/v_kar.mdl" && (self.weapon == W_KAR_SCOPE ||  self.weapon == W_HEADCRACKER))
		{
			self.weapon2model = "models/weapons/kar/v_karscope.mdl";
			self.weapon2frame = self.weaponframe;
			//self.weapon2skin = self.weaponskin;
		}

		if (self.callfuncat)
		{
			if (self.weaponframe == self.callfuncat)
			{
				if (self.animend)
				{
					temp = self.animend;
					self.animend = SUB_Null;
					if (temp)
						temp();
				}
			}
		}
		PlayWeaponSound(self.weapon, self.weapon_anim_type, FALSE, self.weaponframe);
		return;
	}
	else
	{
		self.weapon2frame = self.weaponframe_end = self.weaponframe = GetFrame(self.weapon,BASE_FRAME);
		self.new_anim_stop = FALSE;
		self.weapon_anim_type = 0;
		self.weapon_animduration = 0;
		self.callfuncat = 0;
		temp = self.animend;
		self.animend = SUB_Null;
		if (temp)
			temp();
	}
};

void(string to) UpdateVmodel =
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_UPDATEVMODEL);
	WriteString(MSG_MULTICAST, to);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
}

void(string to) UpdateV2model =
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_UPDATEV2MODEL);
	WriteString(MSG_MULTICAST, to);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
}

void Set_W_Frame (float startframe, float endframe, float duration, float funccalledin, float animtype, void() endanimfunc, string set_model, float dontstartnew) =
{
	self.weaponframe = startframe;
	self.weaponframe_end = endframe;
	self.animend = endanimfunc;
	self.callfuncat = funccalledin;
	self.weapon_anim_type = animtype;
	self.new_anim_stop = dontstartnew;
	if (startframe >= endframe)
		self.anim_reversed = 1;
	else
		self.anim_reversed = 0;
	if (duration)
	{
		local float math;
		if (startframe >= endframe)
			math = (startframe - endframe) + 1;
		else
			math = (endframe - startframe) + 1;
		self.weapon_animduration = (duration / math);
	}
	else
	{
		self.weapon_animduration = 0;
	}
	
	if (set_model && (startframe != endframe)) // naievil -- latter used for checkhold 
	{
		self.weaponmodel = set_model;
		UpdateVmodel(self.weaponmodel);
		
		if (set_model == "progs/VModels/v_nade.mdl" || set_model == "progs/VModels/v_betty.mdl")
		{
			self.weapon2model = "";
			UpdateV2model(self.weapon2model);
		}
		else if (self.weapon == W_KAR_SCOPE)
		{	
			self.weapon2model = "progs/Vmodels/v_karscope.mdl"; 
			UpdateV2model(self.weapon2model);		// naievil (FIXME) probably better way to do this
		}
	}
}