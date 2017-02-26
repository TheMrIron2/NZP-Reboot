

void () W_Frame_Update =
{
	local void temp();

// note: call whenever weapon frames are called!

	if (self.anim_weapon_time > time)
		return; //don't call every frame, if it is the animations will play too fast

	
	if (self.weapon_animduration)
	{
		self.anim_weapon_time = time + self.weapon_animduration;
	}
	
    self.anim_weapon_time = time + 0.1;



	if (self.weaponframe != self.weaponframe_end && !self.anim_reversed)
	{   // continue an animation

        if (self.anim_reversed) {
		    self.weaponframe = self.weaponframe - 1;
        } else {
		    self.weaponframe = self.weaponframe + 1;
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

void Set_W_Frame (float startframe, float endframe, float duration, float funccalledin, float animtype, void() endanimfunc, string set_model, float dontstartnew) = //FIXME
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
	if (set_model)
		self.weaponmodel = set_model;

}