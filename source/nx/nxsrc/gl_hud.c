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

qpic_t      *fx_blood_lu;

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

	b_lt = Draw_CachePic ("gfx_new/butticons/lt.tga");
	b_rt = Draw_CachePic ("gfx_new/butticons/rt.tga");
	b_lthumb = Draw_CachePic ("gfx_new/butticons/lthumb.tga");
	b_rthumb = Draw_CachePic ("gfx_new/butticons/rthumb.tga");
	b_lshoulder = Draw_CachePic ("gfx_new/butticons/lshoulder.tga");
	b_rshoulder = Draw_CachePic ("gfx_new/butticons/rshoulder.tga");
	
	b_left = Draw_CachePic ("gfx_new/butticons/left.tga");
	b_right = Draw_CachePic ("gfx_new/butticons/right.tga");
	b_up = Draw_CachePic ("gfx_new/butticons/up.tga");
	b_down = Draw_CachePic ("gfx_new/butticons/down.tga");
	b_abutton = Draw_CachePic ("gfx_new/butticons/abutton.tga");
	b_bbutton = Draw_CachePic ("gfx_new/butticons/bbutton.tga");
	b_ybutton = Draw_CachePic ("gfx_new/butticons/ybutton.tga");
	b_xbutton = Draw_CachePic ("gfx_new/butticons/xbutton.tga");

	fx_blood_lu = Draw_CachePic ("gfx_new/hud/blood.tga");
}

//=============================================================================

int		pointsort[MAX_SCOREBOARD];

char	scoreboardtext[MAX_SCOREBOARD][20];
int		scoreboardtop[MAX_SCOREBOARD];
int		scoreboardbottom[MAX_SCOREBOARD];
int		scoreboardcount[MAX_SCOREBOARD];
int		scoreboardlines;

/*
===============
HUD_Sorpoints
===============
*/
void HUD_Sortpoints (void)
{
	int		i, j, k;

// sort by points
	scoreboardlines = 0;
	for (i=0 ; i<cl.maxclients ; i++)
	{
		if (cl.scores[i].name[0])
		{
			pointsort[scoreboardlines] = i;
			scoreboardlines++;
		}
	}

	for (i=0 ; i<scoreboardlines ; i++)
		for (j=0 ; j<scoreboardlines-1-i ; j++)
			if (cl.scores[pointsort[j]].points < cl.scores[pointsort[j+1]].points)
			{
				k = pointsort[j];
				pointsort[j] = pointsort[j+1];
				pointsort[j+1] = k;
			}
}

/*
===============
HUD_EndScreen
===============
*/
void HUD_EndScreen (void)
{
	scoreboard_t	*s;
	char			str[80];
	int				i, k, l;
	int				y, x, d;

	HUD_Sortpoints ();

	l = scoreboardlines;

	Draw_String ((vid.width/2 - 9*8)/2, vid.height/2 + (vid.height)*40/272, "GAME OVER");

	sprintf (str,"You survived %3i rounds", 0);//cl.stats[STAT_ROUNDS]);
	Draw_String ((vid.width/2 - strlen (str)*8)/2, vid.height/2 + (vid.height)*48/272, str);

	sprintf (str,"Name           Kills     Points");
	x = (vid.width/2 - strlen (str)*8)/2;

	Draw_String (x, vid.height/2 + vid.height*68/272, str);
	y = 0;
	for (i=0; i<l ; i++)
	{
		k = pointsort[i];
		s = &cl.scores[k];
		if (!s->name[0])
			continue;

		Draw_String (x, vid.height/2 + vid.height*78/272 + y, s->name);

		d = strlen (va("%i",s->kills));
		Draw_String (x + (20 - d)*8, vid.height/2 + (vid.height)*78/272 + y, va("%i",s->kills));

		d = strlen (va("%i",s->points));
		Draw_String (x + (31 - d)*8, vid.height/2 + (vid.height)*78/272 + y, va("%i",s->points));
		y += 20;
	}

}


//=============================================================================


/*
==================
HUD_Blood

==================
*/
void HUD_Blood (void)
{
    float alpha;
	//blubswillrule:
	//this function scales linearly from health = 0 to health = 100
	//alpha = (100.0 - (float)cl.stats[STAT_HEALTH])/100*255;
	//but we want the picture to be fully visible at health = 20, so use this function instead
	alpha = (100.0 - ((1.25 * (float) cl.stats[STAT_HEALTH]) - 25))/100;

    if (alpha <= 0.0)
        return;
    
    float modifier = (sin(cl.time * 10) * 20) - 20;//always negative
    if(modifier < -35.0)
	modifier = -35.0;
    
    alpha += (modifier/255);

    if (alpha > 1) {
    	alpha = 1;
    }
    
    if(alpha < 0.0)
	    return;
    
    Draw_AlphaPic (0, vid.height/2, fx_blood_lu, alpha);
}

//=============================================================================

void HUD_Rounds (void) {
	Draw_String (0, vid.height/2, va("Round %d\n", cl.stats[STAT_ROUNDS]));
	Draw_String (0, vid.height/2 + 8, va("Round change: %d\n", cl.stats[STAT_ROUNDCHANGE]));
}

//=============================================================================

void HUD_Draw (void) {
	if (key_dest == key_menu_pause) {
		return;
	}

	GL_SetCanvas(CANVAS_USEPRINT);

	if (waypoint_mode.value) {
		Draw_String (vid.width/2 - 112, vid.height/2 + 0, "WAYPOINTMODE");
		Draw_String (vid.width/2 - 240, vid.height/2 + 8, "Press fire to create waypoint");
		Draw_String (vid.width/2 - 232, vid.height/2 + 16, "Press use to select waypoint");
		Draw_String (vid.width/2 - 216, vid.height/2 + 24, "Press aim to link waypoint");
		Draw_String (vid.width/2 - 248, vid.height/2 + 32, "Press knife to remove waypoint");
		Draw_String (vid.width/2 - 272, vid.height/2 + 40, "Press switch to move waypoint here");
		Draw_String (vid.width/2 - 304, vid.height/2 + 48, "Press reload to make special waypoint");
		GL_SetCanvas (CANVAS_DEFAULT);
		return;
	}

	if (cl.stats[STAT_HEALTH] <= 0)
	{
		HUD_EndScreen ();
		GL_SetCanvas(CANVAS_DEFAULT);
		return;
	}

	HUD_Blood(); 
	HUD_Rounds();/*
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

	GL_SetCanvas(CANVAS_DEFAULT);
}