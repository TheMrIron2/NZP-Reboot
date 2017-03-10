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

vector	VEC_HULL_MIN = '-16 -16 -32';
vector	VEC_HULL_MAX = '16 16 40';
vector	VEC_HULL2_MIN = '-32 -32 -24';
vector	VEC_HULL2_MAX = '32 32 64';
vector  VEC_VIEW_OFS  = '0 0 32';



float useprint_type;
float useprint_weapon;
float useprint_cost;
float useprint_time;

float weaponframetime;
float oldweaponframe;
float curweaponframe;
float interpolating;


float rounds;


#define printf(x, ...) print(sprintf(x, __VA_ARGS__))

//Navmesh defs
float navmesh_mode;
void() toggle_navmesh_editor;
void() navmesh_editor_draw;
void() navmesh_place_vert;
void() navmesh_delete_verts;
//Vertex selection functions
void() navmesh_select_vert;
void() navmesh_deselect_vert;
void() navmesh_deselect_all;
void() navmesh_make_poly;
void() navmesh_delete_poly;
void() navmesh_resolve_corner;
void() navmesh_place_corner;
void() navmesh_cancel_corner;
void() navmesh_confirm_corner;
void(float poly_index) navmesh_delete_poly_at_index;
void() navmesh_calc_connected_polies;
void() navmesh_calc_polies_centers;
//Methods for testing pathfinding
void() navmesh_place_test_goalent;
void() navmesh_place_test_startent;
void(float is_goal) navmesh_draw_test_ent;
float(vector pos) navmesh_get_containing_poly;
float(float start, float goal, vector start_pos, vector end_pos) pathfind_start;

void() pathfind_draw_result_node_path;
void() pathfind_draw_result_path;
void() pathfind_draw_result_portals;
