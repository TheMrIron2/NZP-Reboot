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

int old_points;
int current_points;
int point_change_interval;
int point_change_interval_neg;
int alphabling = 0;
float round_center_x;
float round_center_y;

typedef struct
{
	int points;
	int negative;
	float x;
	float y;
	float move_x;
	float move_y;
	double alive_time;
} point_change_t;

point_change_t point_change[10];

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

/*
===============
HUD_NewMap
===============
*/
void HUD_NewMap (void)
{
	int i;
	alphabling = 0;

	for (i=0 ; i<10 ; i++)
	{
		point_change[i].points = 0;
		point_change[i].negative = 0;
		point_change[i].x = 0.0;
		point_change[i].y = 0.0;
		point_change[i].move_x = 0.0;
		point_change[i].move_y = 0.0;
		point_change[i].alive_time = 0.0;
	}

	old_points = 500;
	current_points = 500;
	point_change_interval = 0;
	point_change_interval_neg = 0;

	round_center_x = (vid.width/2 - sb_round[0]->width) /2;
	round_center_y = vid.height*3/4 - sb_round[0]->height/2;
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

	sprintf (str,"You survived %3i rounds", cl.stats[STAT_ROUNDS]);
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

/*
===============
HUD_Rounds
===============
*/

float 	color_shift[3];
float 	color_shift_end[3];
float 	color_shift_steps[3];
int		color_shift_init;
float 	blinking;
void HUD_Rounds (void)
{
	int i, x_offset, icon_num, savex;
	int num[3];
	x_offset = 0;
	savex = 0;

	if (cl.stats[STAT_ROUNDCHANGE] == 1)//this is the rounds icon at the middle of the screen
	{
		Draw_ColorPic ((vid.width/2 - sb_round[0]->width) /2, vid.height*3/4 - sb_round[0]->height/2, sb_round[0], 0.4196, 0.004, 0, alphabling/255);

		alphabling = alphabling + 15;

		if (alphabling < 0)
			alphabling = 0;
		else if (alphabling > 255)
			alphabling = 255;
	}
	else if (cl.stats[STAT_ROUNDCHANGE] == 2)//this is the rounds icon moving from middle
	{
		Draw_ColorPic (round_center_x, round_center_y, sb_round[0], 0.4196, 0.004, 0, 1);
		round_center_x = round_center_x - ((229/108)*2 - 0.2)*(vid.width/2)/480;
		round_center_y = round_center_y + ((vid.height*1.015)/272);
		if (round_center_x <= 5)
			round_center_x = 5;
		if (round_center_y >= 250*vid.height/272)
			round_center_y = 250*vid.height/272;
	}
	else if (cl.stats[STAT_ROUNDCHANGE] == 3)//shift to white
	{
		if (!color_shift_init)
		{
			color_shift[0] = 107;
			color_shift[1] = 1;
			color_shift[2] = 0;
			for (i = 0; i < 3; i++)
			{
				color_shift_end[i] = 255;
				color_shift_steps[i] = (color_shift_end[i] - color_shift[i])/60;
			}
			color_shift_init = 1;
		}
		for (i = 0; i < 3; i++)
		{
			if (color_shift[i] < color_shift_end[i])
				color_shift[i] = color_shift[i] + color_shift_steps[i];

			if (color_shift[i] >= color_shift_end[i])
				color_shift[i] = color_shift_end[i];
		}
		if (cl.stats[STAT_ROUNDS] > 0 && cl.stats[STAT_ROUNDS] < 11)
		{

			for (i = 0; i < cl.stats[STAT_ROUNDS]; i++)
			{
				if (i == 4)
				{
					Draw_ColorPic (5*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
					savex = x_offset + 10;
					x_offset = x_offset + 10;
					continue;
				}
				if (i == 9)
				{
					Draw_ColorPic ((5 + savex/2)*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				Draw_ColorPic ((5 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);

				x_offset = x_offset + sb_round[icon_num]->width + 3;
			}
		}
		else
		{
			if (cl.stats[STAT_ROUNDS] >= 100)
			{
				num[2] = (int)(cl.stats[STAT_ROUNDS]/100);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
				x_offset = x_offset + sb_round_num[num[2]]->width - 8;
			}
			else
				num[2] = 0;
			if (cl.stats[STAT_ROUNDS] >= 10)
			{
				num[1] = (int)((cl.stats[STAT_ROUNDS] - num[2]*100)/10);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
				x_offset = x_offset + sb_round_num[num[1]]->width - 8;
			}
			else
				num[1] = 0;

			num[0] = cl.stats[STAT_ROUNDS] - num[2]*100 - num[1]*10;
			Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
			x_offset = x_offset + sb_round_num[num[0]]->width - 8;
		}
	}
	else if (cl.stats[STAT_ROUNDCHANGE] == 4)//blink white
	{
		blinking = (float)(((int)(realtime*1000)&510) - 255);
		blinking = abs(blinking);
		if (cl.stats[STAT_ROUNDS] > 0 && cl.stats[STAT_ROUNDS] < 11)
		{
			for (i = 0; i < cl.stats[STAT_ROUNDS]; i++)
			{
				if (i == 4)
				{
					Draw_ColorPic (5*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], 1, 1, 1, blinking/255);
					savex = x_offset + 10;
					x_offset = x_offset + 10;
					continue;
				}
				if (i == 9)
				{
					Draw_ColorPic ((5 + savex/2)*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], 1, 1, 1, blinking/255);
					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				Draw_ColorPic ((5 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], 1, 1, 1, blinking/255);

				x_offset = x_offset + sb_round[icon_num]->width + 3;
			}
		}
		else
		{
			if (cl.stats[STAT_ROUNDS] >= 100)
			{
				num[2] = (int)(cl.stats[STAT_ROUNDS]/100);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], 1, 1, 1, blinking/255);
				x_offset = x_offset + sb_round_num[num[2]]->width - 8;
			}
			else
				num[2] = 0;
			if (cl.stats[STAT_ROUNDS] >= 10)
			{
				num[1] = (int)((cl.stats[STAT_ROUNDS] - num[2]*100)/10);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], 1, 1, 1, blinking/255);
				x_offset = x_offset + sb_round_num[num[1]]->width - 8;
			}
			else
				num[1] = 0;

			num[0] = cl.stats[STAT_ROUNDS] - num[2]*100 - num[1]*10;
			Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], 1, 1, 1, blinking/255);
			x_offset = x_offset + sb_round_num[num[0]]->width - 8;
		}
	}
	else if (cl.stats[STAT_ROUNDCHANGE] == 5)//blink white
	{
		if (blinking > 0)
			blinking = blinking - 10;
		if (blinking < 0)
			blinking = 0;
		if (cl.stats[STAT_ROUNDS] > 0 && cl.stats[STAT_ROUNDS] < 11)
		{
			for (i = 0; i < cl.stats[STAT_ROUNDS]; i++)
			{
				if (i == 4)
				{
					Draw_ColorPic (5*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], 1, 1, 1, blinking/255);
					savex = x_offset + 10;
					x_offset = x_offset + 10;
					continue;
				}
				if (i == 9)
				{
					Draw_ColorPic ((5 + savex/2)*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], 1, 1, 1, blinking/255);
					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				Draw_ColorPic ((5 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], 1, 1, 1, blinking/255);

				x_offset = x_offset + sb_round[icon_num]->width + 3;
			}
		}
		else
		{
			if (cl.stats[STAT_ROUNDS] >= 100)
			{
				num[2] = (int)(cl.stats[STAT_ROUNDS]/100);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], 1, 1, 1, blinking/255);
				x_offset = x_offset + sb_round_num[num[2]]->width - 8;
			}
			else
				num[2] = 0;
			if (cl.stats[STAT_ROUNDS] >= 10)
			{
				num[1] = (int)((cl.stats[STAT_ROUNDS] - num[2]*100)/10);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], 1, 1, 1, blinking/255);
				x_offset = x_offset + sb_round_num[num[1]]->width - 8;
			}
			else
				num[1] = 0;

			num[0] = cl.stats[STAT_ROUNDS] - num[2]*100 - num[1]*10;
			Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], 1, 1, 1, blinking/255);
			x_offset = x_offset + sb_round_num[num[0]]->width - 8;
		}
	}
	else if (cl.stats[STAT_ROUNDCHANGE] == 6)//blink white while fading back
	{
		color_shift_init = 0;
		blinking = ((int)(realtime*1000)&510) - 255;
		blinking = abs(blinking);
		if (cl.stats[STAT_ROUNDS] > 0 && cl.stats[STAT_ROUNDS] < 11)
		{
			for (i = 0; i < cl.stats[STAT_ROUNDS]; i++)
			{
				if (i == 4)
				{
					Draw_ColorPic (5*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], 1, 1, 1, blinking/255);
					savex = x_offset + 10;
					x_offset = x_offset + 10;
					continue;
				}
				if (i == 9)
				{
					Draw_ColorPic ((5 + savex/2)*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], 1, 1, 1, blinking/255);
					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				Draw_ColorPic ((5 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], 1, 1, 1, blinking/255);

				x_offset = x_offset + sb_round[icon_num]->width + 3;
			}
		}
		else
		{
			if (cl.stats[STAT_ROUNDS] >= 100)
			{
				num[2] = (int)(cl.stats[STAT_ROUNDS]/100);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], 1, 1, 1, blinking/255);
				x_offset = x_offset + sb_round_num[num[2]]->width - 8;
			}
			else
				num[2] = 0;
			if (cl.stats[STAT_ROUNDS] >= 10)
			{
				num[1] = (int)((cl.stats[STAT_ROUNDS] - num[2]*100)/10);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], 1, 1, 1, blinking/255);
				x_offset = x_offset + sb_round_num[num[1]]->width - 8;
			}
			else
				num[1] = 0;

			num[0] = cl.stats[STAT_ROUNDS] - num[2]*100 - num[1]*10;
			Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], 1, 1, 1, blinking/255);
			x_offset = x_offset + sb_round_num[num[0]]->width - 8;
		}
	}
	else if (cl.stats[STAT_ROUNDCHANGE] == 7)//blink white while fading back
	{
		if (!color_shift_init)
		{
			color_shift_end[0] = 107;
			color_shift_end[1] = 1;
			color_shift_end[2] = 0;
			for (i = 0; i < 3; i++)
			{
				color_shift[i] = 255;
				color_shift_steps[i] = (color_shift[i] - color_shift_end[i])/60;
			}
			color_shift_init = 1;
		}
		for (i = 0; i < 3; i++)
		{
			if (color_shift[i] > color_shift_end[i])
				color_shift[i] = color_shift[i] - color_shift_steps[i];

			if (color_shift[i] < color_shift_end[i])
				color_shift[i] = color_shift_end[i];
		}
		if (cl.stats[STAT_ROUNDS] > 0 && cl.stats[STAT_ROUNDS] < 11)
		{
			for (i = 0; i < cl.stats[STAT_ROUNDS]; i++)
			{
				if (i == 4)
				{
					Draw_ColorPic (5*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
					savex = x_offset + 10;
					x_offset = x_offset + 10;
					continue;
				}
				if (i == 9)
				{
					Draw_ColorPic ((5 + savex/2)*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				Draw_ColorPic ((5 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);

				x_offset = x_offset + sb_round[icon_num]->width + 3;
			}
		}
		else
		{
			if (cl.stats[STAT_ROUNDS] >= 100)
			{
				num[2] = (int)(cl.stats[STAT_ROUNDS]/100);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
				x_offset = x_offset + sb_round_num[num[2]]->width - 8;
			}
			else
				num[2] = 0;
			if (cl.stats[STAT_ROUNDS] >= 10)
			{
				num[1] = (int)((cl.stats[STAT_ROUNDS] - num[2]*100)/10);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
				x_offset = x_offset + sb_round_num[num[1]]->width - 8;
			}
			else
				num[1] = 0;

			num[0] = cl.stats[STAT_ROUNDS] - num[2]*100 - num[1]*10;
			Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], (color_shift[0]/255), (color_shift[1]/255), (color_shift[2]/255), 1);
			x_offset = x_offset + sb_round_num[num[0]]->width - 8;
		}
	}
	else
	{
		color_shift[0] = 107;
		color_shift[1] = 1;
		color_shift[2] = 0;
		color_shift_init = 0;
		alphabling = 0;
		if (cl.stats[STAT_ROUNDS] > 0 && cl.stats[STAT_ROUNDS] < 11)
		{
			for (i = 0; i < cl.stats[STAT_ROUNDS]; i++)
			{
				if (i == 4)
				{
					Draw_ColorPic (5*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], 0.4196, 0.004, 0, 1);
					savex = x_offset + 10;
					x_offset = x_offset + 10;
					continue;
				}
				if (i == 9)
				{
					Draw_ColorPic ((5 + savex/2)*(vid.width/2)/272, vid.height - sb_round[4]->height - 4, sb_round[4], 0.4196, 0.004, 0, 1);
					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				Draw_ColorPic ((5 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], 0.4196, 0.004, 0, 1);

				x_offset = x_offset + sb_round[icon_num]->width + 3;
			}
		}
		else
		{
			if (cl.stats[STAT_ROUNDS] >= 100)
			{
				num[2] = (int)(cl.stats[STAT_ROUNDS]/100);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], 0.4196, 0.004, 0, 1);
				x_offset = x_offset + sb_round_num[num[2]]->width - 8;
			}
			else
				num[2] = 0;
			if (cl.stats[STAT_ROUNDS] >= 10)
			{
				num[1] = (int)((cl.stats[STAT_ROUNDS] - num[2]*100)/10);
				Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], 0.4196, 0.004, 0, 1);
				x_offset = x_offset + sb_round_num[num[1]]->width - 8;
			}
			else
				num[1] = 0;

			num[0] = cl.stats[STAT_ROUNDS] - num[2]*100 - num[1]*10;
			
			if(cl.stats[STAT_ROUNDS] == 0)
				return;
			
			Draw_ColorPic ((2 + x_offset/2)*(vid.width/2)/272, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], 0.4196, 0.004, 0, 1);
			x_offset = x_offset + sb_round_num[num[0]]->width - 8;
		}
	}
}

//=============================================================================

/*
===============
HUD_Perks
===============
*/
#define 	P_JUG		1
#define 	P_DOUBLE	2
#define 	P_SPEED		4
#define 	P_REVIVE	8
#define 	P_FLOP		16
#define 	P_STAMIN	32
#define 	P_DEAD 		64

int perk_order[8];
int current_perk_order;

void HUD_Perks (void)
{
	int i;
	int y;
	y = vid.height - sb_round[1]->height - jugpic->height - 14;

	for (i = 0; i < 8; i++)
	{
		if (perk_order[i])
		{
			if (perk_order[i] == P_JUG)
			{
				Draw_Pic (2, y, jugpic);
				y = y - 34;
			}
			else if (perk_order[i] == P_DOUBLE)
			{
				Draw_Pic (2, y, doublepic);
				y = y - 34;
			}
			else if (perk_order[i] == P_SPEED)
			{
				Draw_Pic (2, y, speedpic);
				y = y - 34;
			}
			else if (perk_order[i] == P_REVIVE)
			{
				Draw_Pic (2, y, revivepic);
				y = y - 34;
			}
			else if (perk_order[i] == P_FLOP)
			{
				Draw_Pic (2, y, floppic);
				y = y - 34;
			}
			else if (perk_order[i] == P_STAMIN)
			{
				Draw_Pic (2, y, staminpic);
				y = y - 34;
			}
			else if (perk_order[i] == P_DEAD)
			{
				Draw_Pic (2, y, deadpic);
				y = y - 34;
			}
		}
	}
}

//=============================================================================

/*
===============
HUD_Powerups
===============
*/
void HUD_Powerups (void)
{
	if(cl.stats[STAT_X2])
		Draw_Pic ((vid.width/4) - 32, vid.height/2, x2pic);
	if(cl.stats[STAT_INSTA])
		Draw_Pic ((vid.width/4) + 2, vid.height/2, instapic);
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
	HUD_Rounds();
	HUD_Perks();
	HUD_Powerups();/*
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