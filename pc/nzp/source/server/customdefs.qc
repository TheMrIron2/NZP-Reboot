
// put custom server-only globals and fields here

#define true 1
#define false 0

const float FL_JUMPRELEASED = 4096;

float framecount;
float deathmatch;
.vector oldvelocity;
.float lastsound_time;
.float isspec;

//money
.float points;
.float cost;
.float cost2;

//doors
.float state;
float STATE_TOP		= 0;
float STATE_BOTTOM	= 1;
float STATE_UP		= 2;
float STATE_DOWN		= 3;
.float /*worldtype,*/ delay, wait, lip, /*light_lev,*/ speed, style/*, skill*/;

entity activator;



//Weaponsystem defines
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

//weapon frames
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


vector	VEC_HULL2_MIN = '-32 -32 -24';
vector	VEC_HULL2_MAX = '32 32 64';
vector  VEC_VIEW_OFS  = '0 0 32';

//AI
.string target2;
.string target3;
.string target4;
.string target5;
.string target6;
.string target7;
.string target8;
.void()		th_die;


// Door
.string killtarget;
.void() think1;
.vector finaldest;
.vector pos1, pos2/*, mangle*/;
.float sequence;
.entity active_door;

//Perk and Power system
float isPowerOn; // naievil (FIXME) implement



//FIXME(Jukki) Place in better place
void(entity client, float type, float cost, float weapon) useprint = {
    centerprint(client, "Buy dis");
}