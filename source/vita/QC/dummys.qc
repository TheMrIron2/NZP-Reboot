void() light = {};
void() light_torch_small_walltorch = {};
void() func_door_nzp = {};
void() spawn_zombie = {};
void() item_barricade = {};
void() mystery_box = {};
void() path_corner = {};
void() light_environment = {};

float() spawn_a_zombieA = {return 0;};
void() set_z_health = {};
void() W_SprintStop = {};
void() Weapon_Logic = {};
void Set_W_Frame (float startframe, float endframe, float duration, float funccalledin, float animtype, void(optional float t) endanimfunc, string set_model, float dontstartnew, float side) = {};
void() Do_Zombie_AI = {};
float(vector start, vector min, vector max, vector end, float nomonsters, entity forent) tracemove = {return 0;};
void(entity who) makeCrawler = {};
void() spawnAllZombEnts = {};

// Fixme: change these to pr cmds
void(string com) tokenize = {};
string(float num) argv = {return "";};


void(vector where, float type) Spawn_Powerup = {};
void() Soft_Restart = {};
void(entity e, float type, float cost, float wep) useprint = {};
void() ReturnWeaponModel = {};
