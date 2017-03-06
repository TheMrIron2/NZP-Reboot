void() ToggleMenu =
{
	if(serverkey("constate") != "disconnected")
	{
		if(in_menu == MENU_NONE)
		{
			in_menu = MENU_PAUSE;
			time_in_menu = 0;
			local float i;
			for(i = 0; i < BUTTONS_COUNT; i++)
			{
				buttons[i].active = 1;
			}
			setcursormode(TRUE,"menu/cursor");
		}
		else
		{
			in_menu = MENU_NONE;
			setcursormode(FALSE);
		}
	}
	else
	{
		in_menu = MENU_MAIN;
		time_in_menu = 0;
		setcursormode(TRUE,"menu/cursor");
	}
}

noref void(float apiver, string enginename, float enginever) CSQC_Init =
{
	registercommand("togglemenu");
	registercommand("startwalk");
	registercommand("stopwalk");
	registercommand("promptjoin");
	
	print("CSQC Started\n");
	dummy = spawn();
	if(serverkey("constate") == "disconnected")
		ToggleMenu();
	//bgpos = 0;
};

noref void() CSQC_WorldLoaded =
{
	//precache_model("models/weapons/mg/mzl.iqm");
	//precache_model("models/blood.iqm");
	
	//if(!player)
	//	player = edict_num(player_localentnum);
	if(!vmodel)
		vmodel = spawn();
	if(!v2model)
		v2model = spawn();
	if(!mzlflash)
		mzlflash = spawn();
		
	v2model.renderflags = vmodel.renderflags = RF_VIEWMODEL;
	v2model.origin = vmodel.origin = '24 -12 -18';
	v2model_targetpos = v2model_currentpos = v2model.origin = vmodel_targetpos = vmodel_currentpos = vmodel.origin;
	v2model_velocity = vmodel_velocity = '0 0 0';
	v2model_muzzleoffset = vmodel_muzzleoffset = '48 -1 2';
	setmodel(vmodel,"");
	setmodel(v2model,"");
	mzlflash.renderflags = vmodel.renderflags;
	mzlflash.origin = vmodel.origin + vmodel_muzzleoffset;
	//setmodel(mzlflash,"models/weapons/mg/mzl.iqm");
};

void() Update_Vmodel =
{
	local vector offset;
	local vector dir;
	
	offset_x = 0.6 * sin(time * 1.2);
	offset_y = 0.4 * cos(time * 1.5);
	offset_z = 0.7 * sin(1.1*time + 0.5);
	
	dir = vmodel_targetpos - vmodel_currentpos;
	if(vlen(dir) < (0.15 * 128 * frametime))
		vmodel_currentpos = vmodel_targetpos;
	else
		vmodel_currentpos += (dir * 0.15 * 128) * frametime;
	

	if(vlen(vmodel.angles) < (0.1 * 128 * frametime))
		vmodel.angles = '0 0 0';
	else
		vmodel.angles += (-vmodel.angles * 0.2 * 128) * frametime;

		
	vmodel_currentpos += (vmodel_velocity * 128) * frametime;
	vmodel_velocity *= 1 - frametime * 30;
	
	vmodel.angles += (vmodel_avelocity * 128) * frametime;
	vmodel_avelocity *= 1 - frametime * 30;
	
	vmodel.origin = vmodel_currentpos + offset;

	if(weapon == 1)
	{
		if(mzlflash.scale < 1)
			mzlflash.scale += (10 * random()) * frametime;
	}
	else if(weapon == 2)
	{
		if(mzlflash.scale < 1.5)
			mzlflash.scale += (20 * random()) * frametime;
	}
	mzlflash.origin = vmodel.origin + vmodel_muzzleoffset;
	mzlflash.alpha -= (0.15 * 100) * frametime;
	if(mzlflash.alpha < 0.1)
		mzlflash.alpha = 0.01;
}

noref void(float isnew) CSQC_Ent_Update =
{
	if(isnew)
		print(strcat(etos(self),"\n"));
}	

/*******************
*    HUD Drawing   *
*******************/

void(float width, float height) HUD_Health = 
{
	local float health;	
	float alpha;
	
	health = getstatf(STAT_HEALTH); 

	if (health < 100)
	{
		alpha = (100.0 - ((1.25 * health) - 25))/100*255;
		if (alpha <= 0.0)
			return;
		float modifier = (sin(time * 10) * 20) - 20;//always negative
		if(modifier < -35.0)
		modifier = -35.0;
    
		alpha += modifier;
    
		if(alpha < 0.0)
			return;
		float color = 255.0 + modifier;
    
		drawpic([0,0,0], "gfx/hud/blood.tga", [width, height, 0], [10,0,0], alpha/2000); // naievil -- alpha factor division here makes it easy to use legacy code
	}
	
}

void(float width, float height) HUD_Ammo =
{
	local float ammo, curmag;
	string ammostring;
	
	
	curmag = getstatf(STAT_CURRENTMAG);		
	ammo = getstatf(STAT_AMMO);	

	if (IsDualWeapon(getstatf(STAT_ACTIVEWEAPON))) {
		float curmag2 = getstatf(STAT_CURRENTMAG2);
		
		ammostring = strcat(ftos(curmag2), " ", ftos(curmag), "/", ftos(ammo));
	} else {
		ammostring = strcat(ftos(curmag), strcat("/",ftos(ammo)));
	}
	drawstring([0.75*width, 0.94*height, 0], ammostring, [0.03*width, 0.03*width, 0], [1, 1, 1], 1, 1);
}

void(float width, float height) HUD_Points =
{
	local float points, pointlength = 0, increm = 10;
	
	points = getstatf(STAT_POINTS);
	
	while (increm < 100000000)
	{
		if (points >= increm)
			pointlength = pointlength + 1;
		
		increm = increm * 10;
	}
		
	drawpic([0.8*width,0.70*height,0], "gfx/hud/moneyback.tga", [128, 32, 0], [1,1,1], 1);
	drawstring([.9414*width - pointlength*10, 0.70*height + 5, 0], ftos(points), [0.025*width, 0.025*width, 0], [1, 1, 1], 1, 1);   // naievil (FIXME) real offset needed (pointlength)
}

void(float width, float height) HUD_Grenades =
{
	local float grenades;

	grenades = getstatf(STAT_GRENADES);
	drawpic([0.9*width,0.825*height,0], "gfx/hud/frag.tga", [50, 50, 0], [1,1,1], 1);
	drawstring([0.9*width + 28, 0.825*height + 32, 0], ftos(grenades), [0.025*width, 0.025*width, 0], [1, 1, 1], 1, 1);
}

float 	color_shift[3];
float 	color_shift_end[3];
float 	color_shift_steps[3];
int		color_shift_init;
int 	blinking;
string sb_round[5];
string sb_round_num[10];
int alphabling;
float round_center_x;
float round_center_y;
float endroundchange;

void(float width, float height) HUD_Rounds =
{

	float roundheight = 48/272*height;
	float roundwidth = 0.02291666*width;
	
	float roundwidth_4 = (60/480)*width;
	float roundheight_4 = (48/272)*height;
	
	float roundheight_num = 48/272*height;
	float roundwidth_num = 48/480*height; // naievil -- was 32, but more square makes it look better

	drawstring([0.01*width, 0.70*height, 0], ftos(rounds_change), [0.03*width, 0.03*width, 0], [1, 1, 1], 1, 1); // draw roundchange

	int i, x_offset, icon_num, savex;
	int num[3];
	x_offset = 0;
	savex = 0;
	
	sb_round[0] = "gfx/hud/r1.tga";
	sb_round[1] = "gfx/hud/r2.tga";
	sb_round[2] = "gfx/hud/r3.tga";
	sb_round[3] = "gfx/hud/r4.tga";
	sb_round[4] = "gfx/hud/r5.tga";
	
	sb_round_num[0] = "gfx/hud/r_num0.tga";
	sb_round_num[1] = "gfx/hud/r_num1.tga";
	sb_round_num[2] = "gfx/hud/r_num2.tga";
	sb_round_num[3] = "gfx/hud/r_num3.tga";
	sb_round_num[4] = "gfx/hud/r_num4.tga";
	sb_round_num[5] = "gfx/hud/r_num5.tga";
	sb_round_num[6] = "gfx/hud/r_num6.tga";
	sb_round_num[7] = "gfx/hud/r_num7.tga";
	sb_round_num[8] = "gfx/hud/r_num8.tga";
	sb_round_num[9] = "gfx/hud/r_num9.tga";

	if (rounds_change == 1)//this is the rounds icon at the middle of the screen
	{
		//draw_colorpic ((width - sb_round[0]->width) /2, (height - sb_round[0]->height) /2, sb_round[0], 107, 1, 0, alphabling);	
		
		alphabling = alphabling + 15;

		if (alphabling < 0)
			alphabling = 0;
		else if (alphabling > 255)
			alphabling = 255;
		
		drawpic([round_center_x,round_center_y,0], sb_round[0], [roundwidth, roundheight, 1], [107/255,1/255,0], alphabling/255);

	}
	else if (rounds_change == 2)//this is the rounds icon moving from middle
	{
		//draw_colorpic (round_center_x, round_center_y, sb_round[0], 107, 1, 0, 255);
		float round_center_y_offset, round_center_x_offset;
				
		drawpic([round_center_x + round_center_x_offset,round_center_y + round_center_y_offset,0], sb_round[0], [roundwidth,roundheight, 1], [107/255,(1/255),0], 1);
		
		round_center_x = round_center_x - (((229/108)*2 - 0.2)*(width/480)/8);
		round_center_y = round_center_y + ((2*(height/272))/8);
		if (round_center_x <= (5/480)*height)
			round_center_x = (5/480)*height;
		if (round_center_y >= (220/272)*height)
			round_center_y = (220/272)*height;
					
	}
	else if (rounds_change == 3)//shift to white
	{
		if (!color_shift_init)
		{
			color_shift[0] = 107;
			color_shift[1] = 1;
			color_shift[2] = 0;
			for (i = 0; i < 3; i = i + 1)
			{
				color_shift_end[i] = 255;
				color_shift_steps[i] = (color_shift_end[i] - color_shift[i])/60;
			}
			color_shift_init = 1;
		}
		for (i = 0; i < 3; i = i + 1)
		{
			if (color_shift[i] < color_shift_end[i])
				color_shift[i] = color_shift[i] + color_shift_steps[i];

			if (color_shift[i] >= color_shift_end[i])
				color_shift[i] = color_shift_end[i];
		}
		if (rounds > 0 && rounds < 11)
		{

			for (i = 0; i < rounds; i = i + 1)
			{
				if (i == 4)
				{ // here
					//draw_colorpic (5, vid.height - sb_round[4]->height - 4, sb_round[4], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
					drawpic([5,height - roundheight, 0], sb_round[4], [roundwidth_4,roundheight_4, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);
					
					savex = x_offset + (10*width/480);
					x_offset = x_offset + (10*width/480);
					continue;
				}
				if (i == 9)
				{
					//draw_colorpic (5 + savex, vid.height - sb_round[4]->height - 4, sb_round[4], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
					drawpic([5 + savex, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);
					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				//draw_colorpic (5 + x_offset, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
				drawpic([5 + x_offset, height - roundheight - (4*height/272),0], sb_round[icon_num], [roundwidth,roundheight, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);

				x_offset = x_offset +  roundwidth + (3*width/480);
			}
		}
		else
		{
			if (rounds >= 100)
			{
				num[2] = (int)(rounds/100);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
				drawpic([5 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[2]], [roundwidth_num, roundheight_num, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);
								
				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[2] = 0;
			if (rounds >= 10)
			{
				num[1] = (int)((rounds - num[2]*100)/10);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
				drawpic([5 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[1]], [roundwidth_num,roundheight_num, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);

				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[1] = 0;

			num[0] = rounds - num[2]*100 - num[1]*10;
			//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
				drawpic([5 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[0]], [roundwidth_num,roundheight_num, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);

			x_offset = x_offset +  roundwidth_num - (8*width/480);
		}
	}
	else if (rounds_change == 4)//blink white
	{
	
		if (endroundchange > time)
		{
			blinking = ((int)(time*1000)&510) - 255;
			blinking = fabs(blinking);
		}
		else
		{
			if (blinking)
				blinking = blinking - 1;
			else
				blinking = 0;
		}
			
	
		if (rounds > 0 && rounds < 11)
		{
			for (i = 0; i < rounds; i = i + 1)
			{
				if (i == 4)
				{
					//draw_colorpic (5, vid.height - sb_round[4]->height - 4, sb_round[4], 255, 255, 255, blinking);
					drawpic([5, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [1,1,1], blinking/255);

					savex = x_offset + (10*width/480);
					x_offset = x_offset + (10*width/480);
					continue;
				}
				if (i == 9)
				{
					//draw_colorpic (5 + savex, vid.height - sb_round[4]->height - 4, sb_round[4], 255, 255, 255, blinking);
					drawpic([5 + savex, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [1,1,1], blinking/255);

					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				//draw_colorpic (5 + x_offset, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], 255, 255, 255, blinking);
					drawpic([5 + x_offset, height - roundheight - (4*height/272),0], sb_round[icon_num], [roundwidth,roundheight, 1], [1,1,1], blinking/255);

				x_offset = x_offset +  roundwidth + (3*width/480);
			}
		}
		else
		{
			if (rounds >= 100)
			{
				num[2] = (int)(rounds/100);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], 255, 255, 255, blinking);
					drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[2]], [roundwidth_num,roundheight_num, 1], [1,1,1], blinking/255);
					
				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[2] = 0;
			if (rounds >= 10)
			{
				num[1] = (int)((rounds - num[2]*100)/10);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], 255, 255, 255, blinking);
				drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[1]], [roundwidth_num,roundheight_num, 1], [1,1,1], blinking/255);
				
				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[1] = 0;

			num[0] = rounds - num[2]*100 - num[1]*10;
			//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], 255, 255, 255, blinking);
			drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[0]], [roundwidth_num,roundheight_num, 1], [1,1,1], blinking/255);
			
			x_offset = x_offset +  roundwidth_num - (8*width/480);
		}
		
		if (endroundchange == 0)
			endroundchange = time + 2;
	}
	else if (rounds_change == 5)//blink white
	{
		if (blinking > 0)
			blinking = blinking - 10;
		if (blinking < 0)
			blinking = 0;
		if (rounds > 0 && rounds < 11)
		{
			for (i = 0; i < rounds; i = i + 1)
			{
				if (i == 4)
				{
					//draw_colorpic (5, vid.height - sb_round[4]->height - 4, sb_round[4], 255, 255, 255, blinking);
					drawpic([5, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [1,1,1], blinking/255);

					savex = x_offset + (10*width/480);
					x_offset = x_offset + (10*width/480);
					continue;
				}
				if (i == 9)
				{
					//draw_colorpic (5 + savex, vid.height - sb_round[4]->height - 4, sb_round[4], 255, 255, 255, blinking);
					drawpic([5 + savex, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [1,1,1], blinking/255);
					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				//draw_colorpic (5 + x_offset, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], 255, 255, 255, blinking);
				drawpic([5 + x_offset, height - roundheight - (4*height/272),0], sb_round[icon_num], [roundwidth,roundheight, 1], [1,1,1], blinking/255);

				x_offset = x_offset +  roundwidth + (3*width/480);
			}
		}
		else
		{
			if (rounds >= 100)
			{
				num[2] = (int)(rounds/100);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], 255, 255, 255, blinking);
				drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[2]], [roundwidth_num,roundheight_num, 1], [1,1,1], blinking/255);

				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[2] = 0;
			if (rounds >= 10)
			{
				num[1] = (int)((rounds - num[2]*100)/10);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], 255, 255, 255, blinking);
				drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[1]], [roundwidth_num,roundheight_num, 1], [1,1,1], blinking/255);

				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[1] = 0;

			num[0] = rounds - num[2]*100 - num[1]*10;
			//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], 255, 255, 255, blinking);
			drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[0]], [roundwidth_num,roundheight_num, 1], [1,1,1], blinking/255);

			x_offset = x_offset +  roundwidth_num - (8*width/480);
		}
	}
	else if (rounds_change == 6)//blink white while fading back
	{
		endroundchange = 0;
		
		color_shift_init = 0;
		blinking = ((int)(time*1000)&510) - 255;
		
		blinking = fabs(blinking);
			
		if (rounds > 0 && rounds < 11)
		{
			for (i = 0; i < rounds; i = i + 1)
			{
				if (i == 4)
				{
					//draw_colorpic (5, vid.height - sb_round[4]->height - 4, sb_round[4], 255, 255, 255, blinking);
					drawpic([5, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [1,1,1], blinking/255);
								
					savex = x_offset + (10*width/480);
					x_offset = x_offset + (10*width/480);
					continue;
				}
				if (i == 9)
				{
					//draw_colorpic (5 + savex, vid.height - sb_round[4]->height - 4, sb_round[4], 255, 255, 255, blinking);
					drawpic([5 + savex, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [1,1,1], blinking/255);

					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				//draw_colorpic (5 + x_offset, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], 255, 255, 255, blinking);
				drawpic([5 + x_offset, height - roundheight - (4*height/272),0], sb_round[icon_num], [roundwidth,roundheight, 1], [1,1,1], blinking/255);

				x_offset = x_offset +  roundwidth + (3*width/480);
			}
		}
		else
		{
			if (rounds >= 100)
			{
				num[2] = (int)(rounds/100);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], 255, 255, 255, blinking);
				drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[2]], [roundwidth_num,roundheight_num, 1], [1,1,1], blinking/255);
				
				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[2] = 0;
			if (rounds >= 10)
			{
				num[1] = (int)((rounds - num[2]*100)/10);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], 255, 255, 255, blinking);
				drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[1]], [roundwidth_num,roundheight_num, 1], [1,1,1], blinking/255);

				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[1] = 0;

			num[0] = rounds - num[2]*100 - num[1]*10;
			//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], 255, 255, 255, blinking);
			drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[0]], [roundwidth_num,roundheight_num, 1], [1,1,1], blinking/255);

			x_offset = x_offset +  roundwidth_num - (8*width/480);
		}
	}
	else if (rounds_change == 7)//blink white while fading back
	{
		if (!color_shift_init)
		{
			color_shift_end[0] = 107;
			color_shift_end[1] = 1;
			color_shift_end[2] = 0;
			for (i = 0; i < 3; i = i + 1)
			{
				color_shift[i] = 255;
				color_shift_steps[i] = (color_shift[i] - color_shift_end[i])/60;
			}
			color_shift_init = 1;
		}
		for (i = 0; i < 3; i = i + 1)
		{
			if (color_shift[i] > color_shift_end[i])
				color_shift[i] = color_shift[i] - color_shift_steps[i];

			if (color_shift[i] < color_shift_end[i])
				color_shift[i] = color_shift_end[i];
		}
		if (rounds > 0 && rounds < 11)
		{
			for (i = 0; i < rounds; i = i + 1)
			{
				if (i == 4)
				{
					//draw_colorpic (5, vid.height - sb_round[4]->height - 4, sb_round[4], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
					drawpic([5, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);

					savex = x_offset + (10*width/480);
					x_offset = x_offset + (10*width/480);
					continue;
				}
				if (i == 9)
				{
					//draw_colorpic (5 + savex, vid.height - sb_round[4]->height - 4, sb_round[4], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
					drawpic([5 + savex, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);

					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				//draw_colorpic (5 + x_offset, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
				drawpic([5 + x_offset, height - roundheight - (4*height/272),0], sb_round[icon_num], [roundwidth,roundheight, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);

				x_offset = x_offset +  roundwidth + (3*width/480);
			}
		}
		else
		{
			if (rounds >= 100)
			{
				num[2] = (int)(rounds/100);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
				drawpic([2+x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[2]], [roundwidth_num,roundheight_num, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);

				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[2] = 0;
			if (rounds >= 10)
			{
				num[1] = (int)((rounds - num[2]*100)/10);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
				drawpic([2+x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[1]], [roundwidth_num,roundheight_num, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);

				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[1] = 0;

			num[0] = rounds - num[2]*100 - num[1]*10;
			//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], (int)color_shift[0], (int)color_shift[1], (int)color_shift[2], 255);
			drawpic([2+x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[0]], [roundwidth_num,roundheight_num, 1], [color_shift[0]/255,color_shift[1]/255,color_shift[2]/255], 1);

			x_offset = x_offset +  roundwidth_num - (8*width/480);
		}
	}
	else
	{
		color_shift[0] = 107;
		color_shift[1] = 1;
		color_shift[2] = 0;
		color_shift_init = 0;
		alphabling = 0;
		if (rounds > 0 && rounds < 11)
		{
			for (i = 0; i < rounds; i = i + 1)
			{
				if (i == 4)
				{
					//draw_colorpic (5, vid.height - sb_round[4]->height - 4, sb_round[4], 107, 1, 0, 255);
					drawpic([5, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [107/255,1/255,0], 1);

					savex = x_offset + (10*width/480);
					x_offset = x_offset + (10*width/480);
					continue;
				}
				if (i == 9)
				{
					//draw_colorpic (5 + savex, vid.height - sb_round[4]->height - 4, sb_round[4], 107, 1, 0, 255);
					drawpic([5 + savex, height - roundheight - (4*height/272),0], sb_round[4], [roundwidth_4,roundheight_4, 1], [107/255,1/255,0], 1);

					continue;
				}
				if (i > 4)
					icon_num = i - 5;
				else
					icon_num = i;

				//draw_colorpic (5 + x_offset, vid.height - sb_round[icon_num]->height - 4, sb_round[icon_num], 107, 1, 0, 255);
				drawpic([5 + x_offset, height - roundheight - (4*height/272),0], sb_round[icon_num], [roundwidth,roundheight, 1], [107/255,1/255,0], 1);

				x_offset = x_offset +  roundwidth + (3*width/480);
			}
		}
		else
		{
			if (rounds >= 100)
			{
				num[2] = (int)(rounds/100);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[2]]->height - 4, sb_round_num[num[2]], 107, 1, 0, 255);
				drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[2]], [roundwidth_num,roundheight_num, 1], [107/255,1/255,0], 1);

				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[2] = 0;
			if (rounds >= 10)
			{
				num[1] = (int)((rounds - num[2]*100)/10);
				//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[1]]->height - 4, sb_round_num[num[1]], 107, 1, 0, 255);
				drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[1]], [roundwidth_num,roundheight_num, 1], [107/255,1/255,0], 1);

				x_offset = x_offset +  roundwidth_num - (8*width/480);
			}
			else
				num[1] = 0;

			num[0] = rounds - num[2]*100 - num[1]*10;
			
			if(rounds == 0)
				return;
			
			//draw_colorpic (2 + x_offset, vid.height - sb_round_num[num[0]]->height - 4, sb_round_num[num[0]], 107, 1, 0, 255);
			drawpic([2 + x_offset, height - roundheight - (4*height/272),0], sb_round_num[num[0]], [roundwidth_num,roundheight_num, 1], [107/255,1/255,0], 1);

			x_offset = x_offset +  roundwidth_num - (8*width/480);
		}
	}
}

void(float width, float height) HUD_Useprint =
{

		string usestring, usebutton;
		float print_width, x;
		
		tokenize(findkeysforcommand("+button7"));
		usebutton = strtoupper(keynumtostring(stof(argv(0))));
		//usebutton = keynumtostring(-1);

		switch (useprint_type) {
			case 0://clear
				usestring = "";
				break;
			case 1://door
				usestring = strcat("Hold ",usebutton, " to open door [Cost:", ftos(useprint_cost),"]");
				break;
			case 2://debris
				usestring = strcat("Hold ",usebutton, " to remove debris [Cost:", ftos(useprint_cost),"]");
				break;
			case 3://ammo
				usestring = strcat("Hold ",usebutton, " to buy ammo for ", GetWeaponName(useprint_weapon), " [Cost:", ftos(useprint_cost),"]");
				break;
			case 4://weapon
				usestring = strcat("Hold ",usebutton, " to buy ", GetWeaponName(useprint_weapon), " [Cost:", ftos(useprint_cost),"]");
				break;
			case 5://window
				usestring = strcat("Hold ",usebutton, " to Rebuild Barrier");
				break;
			case 6://box
				usestring = strcat("Hold ",usebutton, " to buy a random weapon [Cost:", ftos(useprint_cost),"]");
				break;
			case 7://box take
				usestring = strcat("Hold ",usebutton, " to take weapon");
				break;
			case 8://power
				usestring = "The power must be activated first";
				break;
			case 9://perk
				usestring = strcat("Hold ",usebutton, " to buy ", GetPerkName(useprint_weapon), " [Cost:", ftos(useprint_cost),"]");
				break;
			case 10://turn on power
				usestring = strcat("Hold ",usebutton, " to turn on the power");
				break;
			case 12://turn on power
				usestring = strcat("Hold ",usebutton, " to Pack a Punch [Cost:", ftos(useprint_cost), "]");
				break;
			default:
				usestring = "This should not happen you dum fuck";
				break;
		}
			print_width = stringwidth (usestring, 0, [0.015*width, 0.015*width, 0]);
			x = (width - print_width)/2;
			drawstring([x, 0.70*height, 0], usestring, [0.015*width, 0.015*width, 0], [1, 1, 1], 1, 1);

}

#define 	P_JUG		1
#define 	P_DOUBLE	2
#define 	P_SPEED		4
#define 	P_REVIVE	8
#define 	P_FLOP		16
#define 	P_STAMIN	32

int perk_order[9];
int current_perk_order;
	
void(float width, float height) HUD_Perks =
{
	
	int i, s;
	int y = height - 100 - 22/*sb_round[1]->height - 22 //(round height minus perk icon height)*/;	

	//drawstring([0.01*width, 0.10*height, 0], ftos(perks), [0.03*width, 0.03*width, 0], [1, 1, 1], 1, 1);
			
	for (i = 0; i < 8; i = i + 1)
	{
		if (perk_order[i])
		{
			if (perk_order[i] == P_JUG)
			{
				drawpic([2,y,0], "gfx/hud/jug.lmp", [20, 20, 1], [1,1,1], 1);
				y = y - 22;
			}
			else if (perk_order[i] == P_DOUBLE)
			{
				drawpic([2,y,0], "gfx/hud/double.lmp", [20, 20, 1], [1,1,1], 1);
				y = y - 22;
			}
			else if (perk_order[i] == P_SPEED)
			{
				drawpic([2,y,0], "gfx/hud/speed.lmp", [20, 20, 1], [1,1,1], 1);
				y = y - 22;
			}
			else if (perk_order[i] == P_REVIVE)
			{
				drawpic([2,y,0], "gfx/hud/revive.lmp", [20, 20, 1], [1,1,1], 1);
				y = y - 22;
			}
			else if (perk_order[i] == P_FLOP)
			{
				drawpic([2,y,0], "gfx/hud/flopper.lmp", [20, 20, 1], [1,1,1], 1);
				y = y - 22;
			}
			else if (perk_order[i] == P_STAMIN)
			{
				drawpic([2,y,0], "gfx/hud/stamin.lmp", [20, 20, 1], [1,1,1], 1);
				y = y - 22;
			}
		}
	}
}

void(float width, float height) HUD_Weaponstring =
{
	string weaponstring; 
	local float ws_offset;
	
	weaponstring = GetWeaponName(getstatf(STAT_ACTIVEWEAPON));
	ws_offset = (strlen(weaponstring) - 2);
	
	drawstring([0.925*width - ws_offset*9.5, 0.75*height + 10, 0], weaponstring, [0.0175*width, 0.018*width, 0], [1, 1, 1], 1, 1); // naievil (FIXME) exact location later
}

void(float width, float height) HUD_Progressbar =
{
	float percent = getstatf(STAT_PROGRESSBAR);
	if (!percent) {
		return;
	}

	string progress; 
	local float ws_offset;
	
	progress = ftos(percent);
	ws_offset = (strlen(progress) - 1);

	float bar_width = 0.0175*width * 20;
	float bar_height = 0.0175*width;
	float bar_x = (width - bar_width)/2;
	float bar_y = height*0.75;

	drawfill ([bar_x - 1, bar_y - 1, 0], [bar_width+2, bar_height, 0], [0, 0, 0], 0.4);
	drawfill ([bar_x, bar_y, 0], [bar_width * percent, bar_height-2, 0], [1, 1, 1], 0.4);
	
	drawstring([(width - (88))/2, height*0.75 + 10, 0], "Reviving...", [0.0175*width, 0.0175*width, 0], [1, 1, 1], 1, 1); // naievil (FIXME) exact location later
}

void(float width, float height) HUD_Draw = 
{
	if (time <= 1)
	{
		round_center_x = (width - (11*width/480)) /2;
		round_center_y = (height - (48*height/272)) /2;
	}
	
	HUD_Health(width, height);
	
	if (HUD_Change_time > time)
	{
		HUD_Ammo(width, height);
		HUD_Grenades(width, height);
		HUD_Weaponstring(width, height);
	}
	HUD_Points(width, height);
	HUD_Rounds(width, height);
	HUD_Perks(width, height);
	HUD_Progressbar(width, height);
		
	// fix me: change the 51 and 50 to human readable const floats like STAT_PISTOLAMMO, STAT_MGAMMO or something	

	if (useprint_time > time) 
		HUD_Useprint(width, height);

}


// CALLED EVERY CLIENT RENDER FRAME
noref void(float width, float height, float menushown) CSQC_UpdateView =
{
	//clear and update our global screen resolution vars
	clearscene();
	g_width = width;
	g_height = height;

	//disable quake status bar and quake crosshair
	setviewprop(VF_DRAWENGINESBAR, 0);	
	setviewprop(VF_DRAWCROSSHAIR, 1);
	
	//autoadd entities received from servers for drawing	
	addentities(MASK_ENGINE);

	//do viewmodel manipulation, purely cosmetic stuff
	if(vmodel)
	{
		Update_Vmodel();
		local vector vorg;
		local vector vang;
		vorg = getviewprop(VF_ORIGIN);
		vang = getviewprop(VF_ANGLES);
		//vmodel.origin += vorg;
		//vmodel.angles += vang;
		addentity(vmodel);
		addentity(v2model);
		//vmodel.origin -= vorg;
		//vmodel.angles -= vang;
		//addentity(vmodel);
		float weaponframe, weapon2frame;
		weaponframe = getstatf(STAT_WEAPONFRAME);

		float duration = getstatf(STAT_WEAPONDURATION);

		if (!duration) {
			duration = 0.1;
		}
		
		if (curweaponframe != weaponframe) {
			interpolating = TRUE;
			vmodel.lerpfrac = 0;
			curweaponframe = weaponframe;
		}
		
		if (interpolating == TRUE) {
			vmodel.lerpfrac += frametime * (1/duration);

			if (vmodel.lerpfrac >= 1.0) {
				oldweaponframe = curweaponframe;
				vmodel.lerpfrac = 0;
				interpolating = FALSE;	
			}
			
		}
		vmodel.frame = oldweaponframe;
		vmodel.frame2 = curweaponframe;

		if (IsDualWeapon(getstatf(STAT_ACTIVEWEAPON))) {
			float duration2 = getstatf(STAT_WEAPON2DURATION);
			if (!duration2) {
				duration2 = 0.1;
			}
			weapon2frame = getstatf(STAT_WEAPON2FRAME);
			if (curweapon2frame != weapon2frame) {
				interpolating2 = TRUE;
				v2model.lerpfrac = 0;
				curweapon2frame = weapon2frame;
			}
			
			if (interpolating2 == TRUE) {
				v2model.lerpfrac += frametime * (1/duration2);

				if (v2model.lerpfrac >= 1.0) {
					oldweapon2frame = curweapon2frame;
					v2model.lerpfrac = 0;
					interpolating2 = FALSE;	
				}
				
			}

			v2model.frame = oldweapon2frame;
			v2model.frame2 = curweapon2frame;

		} else {
			//v2model.frame = getstatf(STAT_WEAPON2FRAME);
			v2model.lerpfrac = vmodel.lerpfrac;
			v2model.frame = oldweaponframe;
			v2model.frame2 = curweaponframe;
		}
		v2model.angles = vmodel.angles;
		v2model.origin = vmodel.origin;
		if(mzlflash.alpha > 0.09)
		{
			makevectors(view_angles);
			local vector offset = vmodel.origin + vmodel_muzzleoffset;
			local vector muzzlepos;
			muzzlepos = getviewprop(VF_ORIGIN);
			muzzlepos += v_forward * offset_x;
			muzzlepos -= v_right * offset_y;
			muzzlepos += v_up * (offset_z + 6);

			dynamiclight_add(muzzlepos, 128 * mzlflash.alpha, '1.2 0.7 0.2' * mzlflash.alpha);
			addentity(mzlflash);
		}
	}
	
	//deltalisten makes engine call the "add_outline" func for each entity with the set model every frame
	/*deltalisten("models/mg_ammo.iqm", add_outline, 0);
	deltalisten("models/weapons/mg/mg.iqm", add_outline, 0);
	deltalisten("models/weapons/pistol/pistol.iqm", add_outline, 0);*/
	//deltalisten("models/humanoid_simplerig.iqm", add_outline, 0);
	
	//does what you think it does
	renderscene();
	
	if(in_menu)
	{
		//in menu.qc
		Draw_Menu();
	}
	else
	{
		HUD_Draw(g_width, g_height);
	}
	if(serverkey("constate") != "active" && serverkey("disconnected"))
	{
		drawfill('0 0 0',  [width, height, 0], '0.2 0.4 0.7', 1);
		drawstring([width/2 - 60, height/2, 0], "Loading...", [16,16,0],[1,1,1],1,1);
	}
};

noref float(string cmd) CSQC_ConsoleCommand =
{
	//self = theplayer;
	//if (!self)
	//	return FALSE;

	tokenize(cmd);
	switch(argv(0))
	{
		case "togglemenu":
			ToggleMenu();
			return TRUE;
			break;
		case "map":
			return FALSE;
			break;
		case "startwalk":
			walk = TRUE;
			return FALSE;
		case "stopwalk":
			walk = FALSE;
			return FALSE;
		case "promptjoin":
			menu_join();
			return TRUE;
		default:
			return FALSE;
	}
	return FALSE;
};

noref float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	switch(evtype)
	{
	case IE_KEYDOWN:
		if(in_menu != MENU_NONE)
		{
			if(scanx == K_MOUSE1)
			{
				Menu_Click();
				return TRUE;
			}
		}
		return FALSE;
	case IE_KEYUP:
		return FALSE;
	case IE_MOUSEDELTA:
		return FALSE;
	case IE_MOUSEABS:
		//if(devid != 0 && devid != 1)
		//	return FALSE;
		cursor_pos_x = scanx;
		cursor_pos_y = chary;
		return FALSE;
	}
	return FALSE;
};

noref void() CSQC_Input_Frame =
{
	if(walk)
	{
		input_movevalues *= 0.5;
	}
}

float() tracerthink =
{
	//makevectors(self.angles);
	local vector cross1 = normalize(crossproduct( getviewprop(VF_ORIGIN) - self.targetpos, self.targetpos - self.origin));
	local vector cross2 = normalize(crossproduct( getviewprop(VF_ORIGIN) - self.origin, self.targetpos - self.origin));
	R_BeginPolygon("tracers/mg");
	
	R_PolygonVertex(self.origin + cross2, '0 1 0', '1 1 1', self.alpha - 0.6);
	R_PolygonVertex(self.origin - cross2, '0 0 0', '1 1 1', self.alpha - 0.6);
	R_PolygonVertex(self.targetpos - cross1, '1 0 0', '1 1 1', self.alpha);

	R_PolygonVertex(self.targetpos + cross1, '1 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + cross2, '0 1 0', '1 1 1', self.alpha - 0.6);
	R_PolygonVertex(self.targetpos - cross1, '1 0 0', '1 1 1', self.alpha);

	/*R_PolygonVertex(self.origin + v_right, '0 1 0', '1 1 1', self.alpha - 0.4);
	R_PolygonVertex(self.origin - v_right, '0 0 0', '1 1 1', self.alpha - 0.4);
	R_PolygonVertex(self.targetpos - v_right, '1 0 0', '1 1 1', self.alpha);

	R_PolygonVertex(self.targetpos + v_right, '1 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + v_right, '0 1 0', '1 1 1', self.alpha - 0.4);
	R_PolygonVertex(self.targetpos - v_right, '1 0 0', '1 1 1', self.alpha);*/


	R_EndPolygon();

	self.alpha -= (frametime * self.rate);
	if(self.alpha <= 0)
		remove(self);

	return 0;
}

float() alphafade =
{
	
	self.alpha -= (frametime * 3);
	self.scale += (frametime * 9);
	if(self.alpha <= 0.05)
		remove(self);
	
	local vector cross1 = 10 * self.scale * normalize(crossproduct( getviewprop(VF_ORIGIN) - self.origin + self.targetpos * self.scale, self.targetpos * self.scale));
	local vector cross2 = 10 * self.scale * normalize(crossproduct( getviewprop(VF_ORIGIN) - self.origin, self.targetpos * self.scale));
	R_BeginPolygon("bloodsplat2");
	
	R_PolygonVertex(self.origin + cross2, '0 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin - cross2, '0 0 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + (self.targetpos*self.scale*18) - cross1, '1 0 0', '1 1 1', self.alpha);

	R_PolygonVertex(self.origin + (self.targetpos*self.scale*18) + cross1, '1 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + cross2, '0 1 0', '1 1 1', self.alpha);
	R_PolygonVertex(self.origin + (self.targetpos*self.scale*18) - cross1, '1 0 0', '1 1 1', self.alpha);
	
	R_EndPolygon();
	
	return 0;
}

noref void() CSQC_Parse_Event =
{
	local float first = readbyte();
	if(first == EVENT_PISTOLFIRE)
	{
		local float entnum, traceent;
		local vector pos, norm;
		entnum = readentitynum();
		
		pos_x = readcoord();
		pos_y = readcoord();
		pos_z = readcoord();
		norm_x = readcoord();
		norm_y = readcoord();
		norm_z = readcoord();
		
		traceent = readentitynum();

		if(entnum == player_localentnum)
		{
			tracercounter += 1;
			if(tracercounter == 3)
			{
				tracercounter = 0;
				makevectors(view_angles);
				local vector offset = vmodel.origin + vmodel_muzzleoffset;
				local vector muzzlepos;
				muzzlepos = getviewprop(VF_ORIGIN);
				muzzlepos += v_forward * offset_x;
				muzzlepos -= v_right * offset_y;
				muzzlepos += v_up * offset_z;

				local entity tracer = spawn();
				tracer.alpha = 1;
				tracer.origin = muzzlepos;
				tracer.targetpos = pos;
				tracer.rate = 1/0.05;
				tracer.angles = view_angles;
				tracer.predraw = tracerthink;
				tracer.drawmask = 1;
			}

			
			//mzlflash.alpha = 1;

			mzlflash.angles_z = random() * 360;
		}
		
		if(traceent == 0)
		{
			pointparticles(particleeffectnum("weapons.impact"), pos, norm*24, 1);
			pointparticles(particleeffectnum("weapons.impact_decal"), pos, '0 0 0', 1);
		}
		else
		{
			local vector entorg;
			entorg = getentity(traceent, GE_ORIGIN);
			norm = (norm * 0.25) + (normalize(pos - (entorg + '0 0 12')) * 0.75);
			local entity splat = spawn();
//			setorigin(splat, pos + '0 0 0');
			splat.drawmask = 1;
			splat.alpha = 1;
			splat.scale = 0.05;
			splat.angles = [random()*360, random()*360, random()*360];
			splat.targetpos = norm * 1.5;
			splat.predraw = alphafade;
		}
		
	}
	else if(first == EVENT_WEAPONCHANGE)
	{
		local float to;
		to = readbyte();
		setmodel(vmodel,GetWeaponModel(to, FALSE));

		if (to == W_KAR_SCOPE && vmodel.model == "models/weapons/kar/v_kar.mdl") {
			setmodel(v2model,"models/weapons/kar/v_karscope.mdl");
		} else {
			setmodel(v2model,"");
		}

		v2model.origin = vmodel.origin = '0 0 0';
		v2model.angles = vmodel.angles = '-60 0 0';
		v2model_currentpos = vmodel_currentpos = vmodel.origin + '0 0 -24';
		v2model_targetpos = vmodel_targetpos = vmodel.origin;
		v2model_muzzleoffset = vmodel_muzzleoffset = '12 0 1';
		weapon = to;
		
		HUD_Change_time = time + 6;
	}
	else if(first == EVENT_UPDATEVMODEL)
	{
		local string new;
		local float skin2;
		new = readstring();
		setmodel(vmodel,new);
		vmodel.skin = readbyte();
	}
	else if(first == EVENT_UPDATEV2MODEL)
	{
		local string new2;
		new2 = readstring();
		setmodel(v2model,new2);
		v2model.skin = readbyte();
	}
	else if(first == EVENT_USEPRINT) {
		useprint_type = readbyte();
		useprint_cost = readshort();
		useprint_weapon = readbyte();

		useprint_time = time + 0.1;
		
	} else if(first == EVENT_NEWROUND) {
		rounds = readbyte();
		HUD_Change_time = time + 6;
	} else if (first == EVENT_SETROUND) {
		rounds = readbyte();
	}
	else if (first == EVENT_PERK) 
	{
		float newperks, s;
		
		newperks = readlong();
				
		if (newperks & P_JUG && !(perks & P_JUG))
		{
			perk_order[current_perk_order] = P_JUG;
			current_perk_order = current_perk_order + 1;
		}
		if (newperks & P_DOUBLE && !(perks & P_DOUBLE))
		{
			perk_order[current_perk_order] = P_DOUBLE;
			current_perk_order = current_perk_order + 1;
		}
		if (newperks & P_SPEED && !(perks & P_SPEED))
		{
			perk_order[current_perk_order] = P_SPEED;
			current_perk_order = current_perk_order + 1;
		}
		if (newperks & P_REVIVE && !(perks & P_REVIVE))
		{
			perk_order[current_perk_order] = P_REVIVE;
			current_perk_order = current_perk_order + 1;
		}
		if (newperks & P_FLOP && !(perks & P_FLOP))
		{
			perk_order[current_perk_order] = P_FLOP;
			current_perk_order = current_perk_order + 1;
		}
		if (newperks & P_STAMIN && !(perks & P_STAMIN))
		{
			perk_order[current_perk_order] = P_STAMIN;
			current_perk_order = current_perk_order + 1;
		}
		if (perks & P_JUG && !(newperks & P_JUG))
		{
			for (s = 0; s < 8; s++)
			{
				if (perk_order[s] == P_JUG)
				{
					perk_order[s] = 0;
					while (perk_order[s+1])
					{
						perk_order[s] = perk_order[s+1];
						perk_order[s+1] = 0;
					}
					break;
				}
			}
			current_perk_order = current_perk_order - 1;
		}
		if (perks & P_DOUBLE && !(newperks & P_DOUBLE))
		{
			for (s = 0; s < 8; s++)
			{
				if (perk_order[s] == P_DOUBLE)
				{
					perk_order[s] = 0;
					while (perk_order[s+1])
					{
						perk_order[s] = perk_order[s+1];
						perk_order[s+1] = 0;
					}
					break;
				}
			}
			current_perk_order = current_perk_order - 1;
		}
		if (perks & P_SPEED && !(newperks & P_SPEED))
		{
			for (s = 0; s < 8; s++)
			{
				if (perk_order[s] == P_SPEED)
				{
					perk_order[s] = 0;
					while (perk_order[s+1])
					{
						perk_order[s] = perk_order[s+1];
						perk_order[s+1] = 0;
					}
					break;
				}
			}
			current_perk_order = current_perk_order - 1;
		}
		if (perks & P_REVIVE && !(newperks & P_REVIVE))
		{
			for (s = 0; s < 8; s++)
			{
				if (perk_order[s] == P_REVIVE)
				{
					perk_order[s] = 0;
					while (perk_order[s+1])
					{
						perk_order[s] = perk_order[s+1];
						perk_order[s+1] = 0;
					}
					break;
				}
			}
			current_perk_order = current_perk_order - 1;
		}
		if (perks & P_FLOP && !(newperks & P_FLOP))
		{
			for (s = 0; s < 8; s++)
			{
				if (perk_order[s] == P_FLOP)
				{
					perk_order[s] = 0;
					while (perk_order[s+1])
					{
						perk_order[s] = perk_order[s+1];
						perk_order[s+1] = 0;
					}
					break;
				}
			}
			current_perk_order = current_perk_order - 1;
		}
		if (perks & P_STAMIN && !(newperks & P_STAMIN))
		{
			for (s = 0; s < 8; s++)
			{
				if (perk_order[s] == P_STAMIN)
				{
					perk_order[s] = 0;
					while (perk_order[s+1])
					{
						perk_order[s] = perk_order[s+1];
						perk_order[s+1] = 0;
					}
					break;
				}
			}
			current_perk_order = current_perk_order - 1;
		}
		
		perks = newperks;
	}
	else if (first == EVENT_UPDATE) 
	{
		float updatetype = readbyte();
		float var_1 = readbyte();
		float var_2 = readbyte();
		float var_3 = readbyte();
		
		switch (updatetype)
		{
			case 1: 
				HUD_Change_time = time + var_1; 
				break;
			case 2:
				rounds_change = var_1;
			default: 
				break;
		}
		
	}
}