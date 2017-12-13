void() Do_Zombie_A = {};

void () CL_SendWeaponFire =
{
	float return_time;
	vector Wep_Recoil;
	
	Wep_Recoil = GetWeaponRecoil(self.weapon);

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_WEAPONFIRE);
	return_time = getWeaponRecoilReturn(self.weapon);
	WriteLong(MSG_ONE, return_time);
	WriteCoord (MSG_ONE, Wep_Recoil_x);
	WriteCoord (MSG_ONE, Wep_Recoil_y);
	WriteCoord (MSG_ONE, Wep_Recoil_z);
	//self.punchangle = Wep_Recoil;
	self.recoil_delay = 60/return_time + time;
}

void() trigger_activator = {};

void() ParseClientCommand = {SV_ParseClientCommand(CMD_STRING);}

void() PutClientInServer;
void() InitRounds;
void() Soft_Restart = 
{
	entity who, oldself;
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
	self = oldself;
	self.downed = 0;
	game_over = false;
	rounds = 0;
	self.points = 0;
	InitRounds();
	self.isspec = false;
	PutClientInServer();
}