
// put custom server-only globals and fields here

const float FL_JUMPRELEASED = 4096;

float framecount;
float deathmatch;
.vector oldvelocity;
.float lastsound_time;
.float isspec;




//Weaponsystem defines
.float fire_delay;
.float reload_delay;
.float currentmag;
.float semi;
.float semireload;

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