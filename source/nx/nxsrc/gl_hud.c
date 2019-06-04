/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// gl_hud.c -- status bar code

#include "quakedef.h"

extern cvar_t	waypoint_mode;

qpic_t      *b_up;
qpic_t      *b_down;
qpic_t      *b_left;
qpic_t      *b_right;
qpic_t      *b_lthumb;
qpic_t      *b_rthumb;
qpic_t      *b_lshoulder;
qpic_t      *b_rshoulder;
qpic_t      *b_abutton;
qpic_t      *b_bbutton;
qpic_t      *b_ybutton;
qpic_t      *b_xbutton;
qpic_t      *b_lt;
qpic_t      *b_rt;

qpic_t		*sb_round[5];
qpic_t		*sb_round_num[10];
qpic_t		*sb_moneyback;
qpic_t		*instapic;
qpic_t		*x2pic;
qpic_t 		*revivepic;
qpic_t		*jugpic;
qpic_t		*floppic;
qpic_t		*staminpic;
qpic_t		*doublepic;
qpic_t		*speedpic;
qpic_t		*deadpic;
qpic_t		*fragpic;
qpic_t		*bettypic;

void HUD_Init (void) {
	int		i;

	for (i=0 ; i<5 ; i++)
	{
		sb_round[i] = Draw_CachePic (va("gfx_new/hud/r%i.tga",i + 1));
	}

	for (i=0 ; i<10 ; i++)
	{
		sb_round_num[i] = Draw_CachePic (va("gfx_new/hud/r_num%i.tga",i));
	}

	sb_moneyback = Draw_CachePic ("gfx_new/hud/moneyback.tga");
	instapic = Draw_CachePic ("gfx_new/hud/in_kill.tga");
	x2pic = Draw_CachePic ("gfx_new/hud/2x.tga");

	revivepic = Draw_CachePic ("gfx_new/hud/revive.tga");
	jugpic = Draw_CachePic ("gfx_new/hud/jug.tga");
	floppic = Draw_CachePic ("gfx_new/hud/flopper.tga");
	staminpic = Draw_CachePic ("gfx_new/hud/stamin.tga");
	doublepic = Draw_CachePic ("gfx_new/hud/double.tga");
	speedpic = Draw_CachePic ("gfx_new/hud/speed.tga");
	deadpic = Draw_CachePic ("gfx_new/hud/dead.tga");
	fragpic = Draw_CachePic ("gfx_new/hud/frag.tga");
	bettypic = Draw_CachePic ("gfx_new/hud/betty.tga");

	/*
	b_lt = Draw_CachePic ("gfx_new/butticons/lt.tga");
	b_rt = Draw_CachePic ("gfx_new/butticons/rt.tga");
	b_lthumb = Draw_CachePic ("gfx_new/butticons/lthumb.tga");
	b_rthumb = Draw_CachePic ("gfx_new/butticons/rthumb.tga");
	b_lshoulder = Draw_CachePic ("gfx_new/butticons/lshoulder.tga");
	b_rshoulder = Draw_CachePic ("gfx_new/butticons/rshoulder.tga");
	*/

	b_left = Draw_CachePic ("gfx_new/butticons/left.tga");
	b_right = Draw_CachePic ("gfx_new/butticons/right.tga");
	b_up = Draw_CachePic ("gfx_new/butticons/up.tga");
	b_down = Draw_CachePic ("gfx_new/butticons/down.tga");
	b_abutton = Draw_CachePic ("gfx_new/butticons/abutton.tga");
	b_bbutton = Draw_CachePic ("gfx_new/butticons/bbutton.tga");
	b_ybutton = Draw_CachePic ("gfx_new/butticons/ybutton.tga");
	b_xbutton = Draw_CachePic ("gfx_new/butticons/xbutton.tga");
}

void HUD_Draw (void) {
	if (key_dest == key_menu_pause) {
		return;
	}

	// Naievil -- FIXME untested
	if (waypoint_mode.value) {
		Draw_String (vid.width - 112, 0, "WAYPOINTMODE");
		Draw_String (vid.width - 240, 8, "Press fire to create waypoint");
		Draw_String (vid.width - 232, 16, "Press use to select waypoint");
		Draw_String (vid.width - 216, 24, "Press aim to link waypoint");
		Draw_String (vid.width - 248, 32, "Press knife to remove waypoint");
		Draw_String (vid.width - 272, 40, "Press switch to move waypoint here");
		Draw_String (vid.width - 304, 48, "Press reload to make special waypoint");
		return;
	}

/*
	if (cl.stats[STAT_HEALTH] <= 0)
	{
		HUD_EndScreen ();
		return;
	}

	HUD_Blood();
	HUD_Rounds();
	HUD_Perks();
	HUD_Powerups();
	HUD_ProgressBar();
	if ((HUD_Change_time > Sys_FloatTime() || GetLowAmmo(cl.stats[STAT_ACTIVEWEAPON], 1) >= cl.stats[STAT_CURRENTMAG] || GetLowAmmo(cl.stats[STAT_ACTIVEWEAPON], 0) >= cl.stats[STAT_AMMO]) && cl.stats[STAT_HEALTH] >= 20)
	{ //these elements are only drawn when relevant for few seconds
		HUD_Ammo();
		HUD_Grenades();
		HUD_Weapon();
		HUD_AmmoString();
	}
	HUD_Points();
	HUD_Point_Change();
	HUD_Achievement();
*/
}