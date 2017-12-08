void() Do_Zombie_A = {};

void(entity who) makeCrawler = {};

void() spawnAllZombEnts = {};

void() Do_Zombie_AI = {};

void() set_z_health = {};

float() spawn_a_zombieA = {return 0;};

float() spawn_a_dogA = {return 0;};

void() Waypoint_Logic = {};

void() LoadWaypointData = {};

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