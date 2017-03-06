


void () W2_Frame_Update =
{
	local void temp(optional float t);

// note: call whenever weapon frames are called!

	if (self.anim_weapon2_time > time)
		return; //don't call every frame, if it is the animations will play too fast

	
	if (self.weapon2_animduration)
	{
		if (self.weapon2_anim_type == RELOAD && self.perks & P_SPEED)
			self.anim_weapon2_time = time + self.weapon2_animduration * 0.45;
		else if (self.weapon2_anim_type == FIRE && self.perks & P_DOUBLE)
			self.anim_weapon2_time = time + self.weapon2_animduration * 0.75;
		else
			self.anim_weapon2_time = time + self.weapon2_animduration;
	}
	else if (self.weapon2_anim_type == RELOAD && self.perks & P_SPEED)
		self.anim_weapon2_time = time + 0.05;
	else if (self.weapon2_anim_type == FIRE && self.perks & P_DOUBLE)	
		self.anim_weapon2_time = time + 0.075;
	else if (self.weapon2_anim_type == REVIVE && self.perks & P_REVIVE)	
		self.anim_weapon2_time = time + 0.05;
	else if (self.weapon2_anim_type == KNIFE2)	
		self.anim_weapon2_time = time + 0.05;
	else
		self.anim_weapon2_time = time + 0.1;
	
    self.anim_weapon2_time = time + 0.1;


	if (self.weapon2frame != self.weapon2frame_end && !self.anim2_reversed)
	{   // continue an animation

        if (self.anim2_reversed) {
		    self.weapon2frame = self.weapon2frame - 1;
        } else {
		    self.weapon2frame = self.weapon2frame + 1;
        }

		if (self.callfuncat2)
		{
			if (self.weapon2frame == self.callfuncat2)
			{
				if (self.animend2)
				{
					temp = self.animend2;
					self.animend2 = SUB_Null2;
					if (temp)
						temp(S_LEFT);
				}
			}
		}
		PlayWeaponSound(self.weapon, self.weapon2_anim_type, FALSE, self.weapon2frame);
		return;
	}
	else
	{
		self.weapon2frame = self.weapon2frame_end = self.weapon2frame = GetFrame(self.weapon,BASE_FRAME);
		self.new_anim2_stop = FALSE;
		self.weapon2_anim_type = 0;
		self.weapon2_animduration = 0;
		self.callfuncat2 = 0;
		temp = self.animend2;
		self.animend2 = SUB_Null;
		if (temp)
			temp(S_LEFT);
	}
};

void () W_Frame_Update =
{
	W2_Frame_Update();
	local void temp(optional float t);

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
						temp(S_RIGHT);
				}
			}
		}
		PlayWeaponSound(self.weapon, self.weapon_anim_type, FALSE, self.weaponframe);
		return;
	}
	else
	{
		self.weaponframe_end = self.weaponframe = GetFrame(self.weapon,BASE_FRAME);
		self.new_anim_stop = FALSE;
		self.weapon_anim_type = 0;
		self.weapon_animduration = 0;
		self.callfuncat = 0;
		temp = self.animend;
		self.animend = SUB_Null;
		if (temp)
			temp(S_RIGHT);
	}
};

void Set_W_Frame (float startframe, float endframe, float duration, float funccalledin, float animtype, void(optional float t) endanimfunc, string set_model, float dontstartnew, float side) =
{
	float math, reversed;

	if (startframe >= endframe) {
		reversed = true;
	} else {
		reversed = false;
	}
	
	math = 0;
	if (duration) {
		if (startframe >= endframe)
			math = duration / ((endframe - startframe) + 1);
		else
			math = duration / ((endframe - startframe) + 1);
	}

	if (side == S_RIGHT || side == S_BOTH) {
		self.weaponframe = startframe;
		self.weaponframe_end = endframe;
		self.animend = endanimfunc;
		self.callfuncat = funccalledin;
		self.weapon_anim_type = animtype;
		self.new_anim_stop = dontstartnew;
		self.weapon_animduration = math;
		self.anim_reversed = reversed;
	}
	if (side == S_LEFT || side == S_BOTH) {
		self.weapon2frame = startframe;
		self.weapon2frame_end = endframe;
		self.weapon2_anim_type = animtype;
		self.new_anim2_stop = dontstartnew;
		self.weapon2_animduration = math;
		self.anim2_reversed = reversed;

		if (side != S_BOTH) {
			self.animend2 = endanimfunc;
			self.callfuncat2 = funccalledin;
		}
	}
	
	if (set_model && (startframe != endframe)) { // naievil -- latter used for checkhold 
		if (side == S_LEFT) {
			self.weapon2model = set_model;
			UpdateV2model(self.weapon2model, GetWepSkin(self.weapon));
		} else {
			self.weaponmodel = set_model;
			UpdateVmodel(self.weaponmodel, GetWepSkin(self.weapon));
			
			if (set_model == "progs/VModels/v_nade.mdl" || set_model == "progs/VModels/v_betty.mdl") {
				self.weapon2model = "";
				UpdateV2model(self.weapon2model, 0);
			} else if (self.weapon == W_KAR_SCOPE) {	
				self.weapon2model = "progs/Vmodels/v_karscope.mdl"; 
				UpdateV2model(self.weapon2model, 0);
			} else if (IsDualWeapon(self.weapon)) {	
				self.weapon2model = GetLeftWeaponModel(self.weapon); 
				UpdateV2model(self.weapon2model, 0);
			}
		}
	}
}