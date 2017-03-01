// put custom server-only globals and fields here

#define true 1
#define false 0

const float FL_JUMPRELEASED = 4096;

float framecount;
float deathmatch;
float coop;
.vector oldvelocity;
.float lastsound_time;
.float isspec;
string mappath;


//money
.float points;
.float cost;
.float cost2;
void(entity person, float expamt , float doublepoint) addmoney;

//doors
.float state;
float STATE_TOP		= 0;
float STATE_BOTTOM	= 1;
float STATE_UP		= 2;
float STATE_DOWN		= 3;
.float /*worldtype,*/ delay, wait, lip, /*light_lev,*/ speed, style/*, skill*/;

entity activator;

//player funcs
.float zoom;
.float weaponskin;
void() sprintstop;
.float stamina;
.float into_sprint;
float yeahIamrunning;

//Weaponsystem defines
void SwitchWeapon(float to);
void Weapon_Logic();
.float downed;
.float fire_delay;
.float reload_delay;
.float currentmag;
.float secondaryammo;
.float semi;
.float semiuse;
.float semiswitch;
.float semireload;
.float secondarymag;
.float secondaryweapon;
.float NeedLoad;
.string weapon2model;
.float weapon2frame;
.float reloadinterupted;
.float hitcount;

//Knife 
.float semiknife;
.float knife_delay;
.float bowie;

//Grenades
.float grenades;
.float pri_grenade_state;
.float bk_nade;
.float grenade_delay;
.float secondary_grenades;
.float primary_grenades;
.float throw_delay;

//weapon frames
void Set_W_Frame (float startframe, float endframe, float duration, float funccalledin, float animtype, void() endanimfunc, string set_model, float dontstartnew);
.float weapon_animduration;
.float weapon_anim_type;
.float anim_weapon_time;
.float weaponframe_end;
.float callfuncat;
.float new_anim_stop;
.float anim_reversed;
.void() animend;


//Null functions
void() SUB_Null = {};
void() SUB_Null2 = {};



vector	VEC_HULL_MIN = '-16 -16 -32';
vector	VEC_HULL_MAX = '16 16 40';
vector	VEC_HULL2_MIN = '-32 -32 -24';
vector	VEC_HULL2_MAX = '32 32 64';
vector  VEC_VIEW_OFS  = '0 0 32';
vector	trace_plane_normal;


// AI definitions
//Used for global one-zombie-at-a-time type ai
void Do_Zombie_AI();
float ai_delay_time;
.string aistatus;
entity lastzombie;
//Other AI definitions
.vector box1, box2, box3;//used for windows and zombies
.vector idlebox;
.vector hop_spot;//used for windows (zombies hop to these)
.vector goalorigin;
//==== Reference Vars ====
const float WWINDOW = 1; 
const float WBOX1 = 2;
const float WBOX2 = 4;
const float WBOX3 = 8;
const float WIDLEBOX = 16;
//========================

//we're using usedent for who is currently hopping the window
//Used for windows to keep track of what zombies are at windows
.entity box1owner, box2owner, box3owner;

.entity usedent;
//.float used;//used for the window boxes//not anymore
.float outside;//used for knowing if a zomibe has hopped window yet
.float chase_enemy_time;
.float chase_time;
.float enemy_timeout;
//.float pathing;
.float calc_time; //used as a delay thing (so zombie ai doesn't run 100% of the time
.string waynum; //reserved for only waypoints, do not use on any other entities
.string target2;
.string target3;
.string target4;
.string target5;
.string target6;
.string target7;
.string target8;
.string wayTarget;
.entity active_door;//Set in waypoint mode
.string targetname;//the name of an entitys
entity lastspawn;//last spawn point used by spawning code
.entity goaldummy; //Used to store the origin of the zombies target
.float walktype;//decides animations and moving speeds for zombies
.void() th_walk;
//.void() th_run;
.void() th_die;
.void() th_melee;
.void() th_idle;
.void() th_windowhop;
.void() th_diewunder;

.void() th_fall;
.void() th_falling;
.void() th_land;

.void() th_jump;
.void() th_grabledge;
.float tries;
.float hop_step;//KEEPS TRACK OF WHERE WE ARE ON THE HOPPING PART

float INACTIVE = 1;


.float sound_time;
.float s_time;
float sounds_playing;

.float fall;
//.vector lastOrg;//Zombie's last origin, for checking stuckness
//.float OrgStuckCount;
.float crawling;

.float washit;
.float hitamount;

.float currentHitBoxSetup;
.float laststep;
.vector		bbmins, bbmaxs;		// Used for zombie hitboxes
//void(entity who) makeCrawler;
.float state;//used to delay making a crawler, ex) when zombie is rising from ground or climbing over barrier, turn zombie into a crawler afterwards

void() spawnAllZombEnts;
void() set_z_health;
float() spawn_a_zombieA;
float z_health;
.float bleedingtime;
.float time_to_die;


float crandom();


// Door
.string killtarget;
.void() think1;
.vector finaldest;
.vector pos1, pos2/*, mangle*/;
.float sequence;
.entity active_door;

//Perk and Power system
float isPowerOn;
float isBuying; // naievil -- used for checking if a perk is being consumed, limits glitching
.float perks;
.float perk_delay;
.float revivesoda;

//powerups
float instakill_finished;
float insta_blink;
float x2_finished;
float x2_blink;
float total_windows_down;
float total_powerup_points;
float powerup_activate;

//rounds
float roundinit;
float roundtype;
float Current_Zombies;
float Total_Zombies;
float Remaining_Zombies;
float Delay_Time;
float spawn_time;
float round_changetime;
float game_over;
float blink_return;
float delay_at_round;
float spawn_delay;
float maxreward;
float totalreward;
float totalpowerups;
float sounds_playing;

float		rounds;
float rounds_change;


//Waypoints
void () Waypoint_Logic;
entity current_way;
float waypoint_mode;


//FIXME(Jukki) Place in better place
void(entity to, float type, float cost, float weapon) useprint = {
	
    
    msg_entity = to;
	WriteByte(MSG_ONE, SVC_CGAMEPACKET);
	WriteByte(MSG_ONE, EVENT_USEPRINT);
	WriteByte(MSG_ONE, type);
	WriteShort(MSG_ONE, cost);
	WriteByte(MSG_ONE, weapon);
}

float() crandom =
{
	return 2*(random() - 0.5);
}

void NotifyNewRound(float to) {
	WriteByte(MSG_ALL, SVC_CGAMEPACKET);
	WriteByte(MSG_ALL, EVENT_NEWROUND);
	WriteByte(MSG_ALL, to);
}

void SetRound(entity client, float to) {
    msg_entity = client;
	WriteByte(MSG_ONE, SVC_CGAMEPACKET);
	WriteByte(MSG_ONE, EVENT_SETROUND);
	WriteByte(MSG_ONE, to);
}

//naievil (FIXME) No idea where this should go, maybe a dummys
void() SUB_Remove = {remove(self);}