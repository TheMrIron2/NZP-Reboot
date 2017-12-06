//Various globals that are used in this FTEQW example are defined here, they are not used by the engine itself

#pragma warning disable Q302
vector cursor_pos; /* Current mouse cursor position, updated in csqc_inputevent */
float g_width, g_height; /* Globals for screen width and height */

float walk;

//Menu stuff
float in_menu; //what menu are we in
float time_in_menu;

entity player;
entity vmodel;
entity v2model;
entity mzlflash;
entity dummy;

float weapon;

float tracercounter;
.float rate;
.vector targetpos;

vector vmodel_targetpos;
vector v2model_targetpos;
vector vmodel_currentpos;
vector v2model_currentpos;
vector vmodel_velocity;
vector v2model_velocity;
vector vmodel_avelocity;
vector v2model_avelocity;
vector vmodel_muzzleoffset;
vector v2model_muzzleoffset;

const float MENU_NONE = 0;
const float MENU_MAIN = 1;
const float MENU_SINGLE = 2;
const float MENU_MULTI = 4;
const float MENU_SETTINGS = 8;
const float MENU_ABOUT = 16;
const float MENU_JOIN = 32;
const float MENU_PAUSE = 64;
const float MENU_IGS = 128;
const float MENU_RES = 256;


float useprint_type;
float useprint_weapon;
float useprint_cost;
float useprint_time;

float HUD_Change_time; 
float Hitmark_time;
float crosshair_spread_time;
float zoom_2_time;
float broadcast_time;
float broadcast_type;

float weaponframetime;
float weapon2frametime;
float oldweaponframe;
float oldweapon2frame;
float curweaponframe;
float curweapon2frame;
float interpolating;
float interpolating2;


float rounds;
float perks;
float rounds_change;

float playerpoints[4]; 			// player point holders, player 1 points are index 0, player 2 at 1...
string playernames[4]; 			// player name holders, player 1 name at index 0, player 2 at 1...
float score_show;


float K_LEFTDOWN, K_RIGHTDOWN, K_BACKDOWN, K_FORWARDDOWN;

#define 	P_JUG		1
#define 	P_DOUBLE	2
#define 	P_SPEED		4
#define 	P_REVIVE	8
#define 	P_FLOP		16
#define 	P_STAMIN	32

vector TEXT_LIGHTBLUE = [(2/255), (118/255), (181/255)];
vector TEXT_ORANGE    = [(235/255), (189/255), 0];
vector TEXT_GREEN     = [0, (230/255), (34/255)];

float fade_time;
float fade_type;