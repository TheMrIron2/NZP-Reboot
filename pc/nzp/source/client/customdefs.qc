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
