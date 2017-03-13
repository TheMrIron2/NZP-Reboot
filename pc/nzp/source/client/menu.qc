//
//	Menu stuff
//


void() menu_single =
{
	in_menu = MENU_SINGLE;
	time_in_menu = 0;
};

void() menu_restart =
{
	in_menu = MENU_RES;
};

void() menu_resy =
{
	localcmd("restart\n");
};

void() menu_resn =
{
	in_menu = MENU_PAUSE;
};

void() menu_multi =
{
	in_menu = MENU_MULTI;
	time_in_menu = 0;
};

void() menu_settings =
{
	in_menu = MENU_SETTINGS;
	time_in_menu = 0;
};

void() menu_settings2 =
{
	in_menu = MENU_IGS;
	time_in_menu = 0;
}

void() menu_about =
{
	in_menu = MENU_ABOUT;
	time_in_menu = 0;
};

void() menu_quit =
{
	localcmd("quit\n");
};

void() menu_back =
{
	in_menu = MENU_MAIN;
	time_in_menu = 0;
};

void() menu_back2 =
{
	in_menu = MENU_PAUSE;
};

void() menu_loadndu =
{
	print("loading ndu\n");
	localcmd("map ndu\n");
};

void() menu_loadwh =
{
	print("loading warehouse\n");
	localcmd("map warehouse\n");
};

void() menu_join =
{
	setcursormode(TRUE,"menu/cursor");
	in_menu = MENU_JOIN;
};

void() game_join =
{	
	localcmd("cmd joingame\n");
	in_menu = MENU_NONE;
	setcursormode(FALSE);
};

void() game_spec =
{
	localcmd("cmd specgame\n");
	in_menu = MENU_NONE;
	setcursormode(FALSE);
};

void() menu_resume =
{
	in_menu = MENU_NONE;
	setcursormode(FALSE);
};

void() menu_main =
{
	in_menu = MENU_MAIN;
};

//struct for all buttons, note pos and scale are going to be multiplied with width/height in draw step, so keep them between 0 and 1
var struct
{
	vector pos;
	vector scale;
	string text;
	float active; //used for mouseover hilight (positive values) and alpha (negative values)
	void() action; //function that is called when the button is pressed
	float group; //a bit field, button will be usable/visible when these bits are active
} buttons[] =
{
	{[0.025, 0.500, 0], [0.25, 0.05, 0], "Solo", -1, menu_single, MENU_MAIN},
	{[0.025, 0.575, 0], [0.25, 0.05, 0], "Cooperative", -1, menu_multi, MENU_MAIN},
	{[0.025, 0.650, 0], [0.25, 0.05, 0], "Settings", -1, menu_settings, MENU_MAIN},
	{[0.025, 0.725, 0], [0.25, 0.05, 0], "Credits", -1, menu_about, MENU_MAIN},
	{[0.025, 0.925, 0], [0.25, 0.05, 0], "Quit", -1, menu_quit, MENU_MAIN},
	{[0.025, 0.925, 0], [0.25, 0.05, 0], "Back", -1, menu_back, MENU_SINGLE + MENU_MULTI + MENU_SETTINGS + MENU_ABOUT},
	{[0.025, 0.500, 0], [0.25, 0.05, 0], "NDU", -1, menu_loadndu, MENU_SINGLE},
	{[0.025, 0.575, 0], [0.25, 0.05, 0], "Warehouse", -1, menu_loadwh, MENU_SINGLE},
	{[0.475, 0.500, 0], [0.25, 0.05, 0], "Join", -1, game_join, MENU_JOIN},
	{[0.475, 0.575, 0], [0.25, 0.05, 0], "Spectate", -1, game_spec, MENU_JOIN},
	{[0.025, 0.500, 0], [0.25, 0.05, 0], "Resume", -1, menu_resume, MENU_PAUSE},
	{[0.025, 0.575, 0], [0.25, 0.05, 0], "Restart", -1, menu_restart, MENU_PAUSE},
	{[0.025, 0.650, 0], [0.25, 0.05, 0], "Settings", -1, menu_settings2, MENU_PAUSE},
	{[0.025, 0.725, 0], [0.25, 0.05, 0], "Main Menu", -1, menu_main, MENU_PAUSE},
	{[0.025, 0.925, 0], [0.25, 0.05, 0], "Back", -1, menu_back2, MENU_IGS},
	{[0.025, 0.500, 0], [0.25, 0.05, 0], "Yes", -1, menu_resy, MENU_RES},
	{[0.025, 0.575, 0], [0.25, 0.05, 0], "No", -1, menu_resn, MENU_RES},
};

//REMEMBER TO UPDATE THIS CONST IF YOU ADD BUTTONS
const float BUTTONS_COUNT = 17;


//this function handles drawing the buttons and checking if they should be active/hilighted
void(float index) Update_Button = 
{
	if(in_menu != in_menu & buttons[index].group)
		buttons[index].active = -1;
		
	if(buttons[index].active == -1)
	{
		if(in_menu == in_menu & buttons[index].group)
			buttons[index].active = 1;
		else
			return;
	}
	
	local vector pos = buttons[index].pos;
	pos_x *= g_width;
	pos_y *= g_height;
	local vector scale = buttons[index].scale;
	scale_x *= g_width;
	scale_y *= g_height;
	
	local float alphafactor;
	
	if(buttons[index].active > 0)
		alphafactor = 1;
	else
		alphafactor = buttons[index].active + 1; //-1 invis, 0 normal
	
	if(cursor_pos_x > pos_x && cursor_pos_x < pos_x + scale_x && cursor_pos_y > pos_y && cursor_pos_y < pos_y + scale_y )
		buttons[index].active = 1;
	
	drawfill(pos, scale, [0.6,0.6,0.6] + [0.15,0.15,0.15]*buttons[index].active, 0.3 * alphafactor);
	drawline(1, pos, [pos_x + scale_x, pos_y, 0], [255,255,0], 1.5, 1); //top outline
	//drawline(1, pos, [pos_x, pos_y + scale_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //left outline
	drawline(1, [pos_x, pos_y + scale_y, 0], [pos_x + scale_x, pos_y + scale_y, 0], [255,255,0], 1.5, 1); //bottom outline
	//drawline(1, [pos_x + scale_x, pos_y, 0], [pos_x + scale_x, pos_y + scale_y, 0], [0.6, 0.6, 0.6], 0.5, 1); //right outline
	drawstring(pos + [scale_x*0.05, scale_y*0.25, 0], buttons[index].text, [scale_y*0.5, scale_y*0.5, 1], [0.8,0.8,0.8], 1 * alphafactor, 1);
	
	if(buttons[index].active > 0)
	{
		buttons[index].active -= frametime * 5;
		if(buttons[index].active < 0)
			buttons[index].active = 0;
	}
};


void(float index) Button_Click = 
{
	//don't click if not active
	if(buttons[index].active == -1)
		return;
		
	local vector pos = buttons[index].pos;
	pos_x *= g_width;
	pos_y *= g_height;
	local vector scale = buttons[index].scale;
	scale_x *= g_width;
	scale_y *= g_height;
	
	if(cursor_pos_x > pos_x && cursor_pos_x < pos_x + scale_x && cursor_pos_y > pos_y && cursor_pos_y < pos_y + scale_y )
	{
		buttons[index].action(); //do whatever this button is supposed to do
		sound(self, 0, "sounds/menu/enter.wav", 1, ATTN_NONE);
	}
};


void() Menu_Click =
{
	float i;
	for(i = 0; i < BUTTONS_COUNT; i++)
	{
		Button_Click(i);
	}
};



void() Draw_Menu =
{
	precache_sound("sounds/menu/enter.wav");
	
	//Background picture with a nice scrolling effect, scrolling happens in the shader in scripts/menu.shader
	if(serverkey("constate") == "disconnected")
	{
		if(g_width <= g_height * 1.77778)
			drawpic([0,0,0], "menu/bg", [g_height * 1.77778, g_height, 1], [1, 1, 1], 1);
		else
			drawpic([0,0,0], "menu/bg", [g_width, g_height, 1], [1, 1, 1], 1);
	}

		
	//Gradient on the background
	drawpic([0,0,0], "menu/gradient_l2r", [0.75*g_width, g_height, 1], [1, 1, 1], 1);
	

	//Title with a simple but nice animation
	local string title = "";
	switch(in_menu)
	{
		case MENU_MAIN:
			title = "NAZI ZOMBIES: PORTABLE";
			break;
		case MENU_SINGLE:
			title = "SOLO";
			break;
		case MENU_MULTI:
			title = "COOP";
			break;
		case MENU_SETTINGS:
			title = "SETTINGS";
			break;
		case MENU_ABOUT:
			title = "CREDITS";
			break;
		case MENU_PAUSE:
			title = "PAUSED";
			break;
		case MENU_IGS:
			title = "SETTINGS";
			break;
		case MENU_RES:
			title = "RESTART";
			break;
		default:
			title = "Nazi Zombies: Portable";
	}

	local float chars_to_keep;
	time_in_menu += frametime;
	
	if(time_in_menu < 0.5)
	{
		chars_to_keep = time_in_menu * 2;
		chars_to_keep = rint(chars_to_keep * strlen(title));
	}
	else
		chars_to_keep = strlen(title);
	
	drawstring([0.025*g_width, 0.05*g_height, 0], substring(title, 0, chars_to_keep), [g_height * 0.05, g_height * 0.05, 1], [0.8, 0.8, 0.8], 1, 1);
	
	//Credits
	local string name1 = "", name2 = "", name3 = "", name4 = "", name5 = "", name6 = "", name7 = "", name8 = "", name9 = "", name10 = "", name11 = "", name12 = "", name13 = "", name14 = "", name15 = "", name16 = "";
	local string role1 = "", role2 = "", role3 = "", role4 = "", role5 = "", role6 = "";
	
	switch(in_menu)
	{
		case MENU_ABOUT:/*
			role1 = "PROGRAMMERS";
			name1 = "- MotoLegacy";
			name2 = "- Jukki";
			name3 = "- G33420";
			name4 = "- Shadow";
			role2 = "MODELERS";
			name5 = "- Derped_Crusader";
			role3 = "SOUND DESIGNERS";
			name6 = "- Slugparty";
			role4 = "ASSET CREATORS";
			name7 = "- Leo 'Crow' Massie";
			role5 = "MAPPERS";
			name8 = "- mofu23";
			name9 = "- Call16-Podolski";
			name10 = "- Douch_Dagger";
			role6 = "SPECIAL THANKS";
			name11 = "- Naievil";
			name12 = "- PerikiyoXD";
			name13 = "- drmabuse1981";
			name14 = "- Spike";
			name15 = "- shpuld";
			name16 = "- blubswillrule";
			break;*/
			
			// naievil -- changed credits
			drawstring([0.03*g_width, 0.15*g_height, 0], "Blubswillrule: Coding, Models, GFX, Sounds,", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawstring([0.03*g_width, 0.185*g_height, 0], "               Animations, Music", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawfill ([.03*g_width, 0.15*g_height + g_height*0.025 + 3, 0], [strlen("Blubswillrule")*12.5, 0.0025*g_height, 0], [0.8, 0.8, 0.8], 1);
			
			drawstring([0.03*g_width, 0.25*g_height, 0], "Ju[s]tice:     Maps, Models, GFX", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawfill ([.03*g_width, 0.25*g_height + g_height*0.025 + 3, 0], [strlen("Ju[s]tice")*12.5, 0.0025*g_height, 0], [0.8, 0.8, 0.8], 1);

				
			drawstring([0.03*g_width, 0.35*g_height, 0], "Jukki:         Coding", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawfill ([.03*g_width, 0.35*g_height + g_height*0.025 + 3, 0], [strlen("Jukki")*12.5, 0.0025*g_height, 0], [0.8, 0.8, 0.8], 1);
												
			drawstring([0.03*g_width, 0.45*g_height, 0], "Special Thanks:", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawfill ([.03*g_width, 0.45*g_height + g_height*0.025 + 3, 0], [strlen("Special Thanks")*12.5, 0.0025*g_height, 0], [0.8, 0.8, 0.8], 1);
			
			drawstring([0.25*g_width, 0.525*g_height, 0], "- Spike", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawstring([0.25*g_width, 0.575*g_height, 0], "- Shpuld", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawstring([0.25*g_width, 0.625*g_height, 0], "- DR_Mabuse1981", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawstring([0.25*g_width, 0.675*g_height, 0], "- Naievil", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1); 
			drawstring([0.25*g_width, 0.725*g_height, 0], "- Biodude", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
			drawstring([0.25*g_width, 0.775*g_height, 0], "- MotoLegacy", [g_height * 0.025, g_height * 0.025, 1], [0.8, 0.8, 0.8], 1, 1);
		default:
			break;
	}

	local float chars_to_keep2;
	time_in_menu += frametime;
	
	chars_to_keep2 = 90;
	
	/*drawstring([0.025*g_width, 0.15*g_height, 0], substring(role1, 0, chars_to_keep2), [g_height * 0.03, g_height * 0.03, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.025*g_width, 0.25*g_height, 0], substring(name1, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.025*g_width, 0.3*g_height, 0], substring(name2, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.025*g_width, 0.35*g_height, 0], substring(name3, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.025*g_width, 0.4*g_height, 0], substring(name4, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.025*g_width, 0.5*g_height, 0], substring(role2, 0, chars_to_keep2), [g_height * 0.03, g_height * 0.03, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.025*g_width, 0.55*g_height, 0], substring(name5, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.025*g_width, 0.65*g_height, 0], substring(role3, 0, chars_to_keep2), [g_height * 0.03, g_height * 0.03, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.025*g_width, 0.7*g_height, 0], substring(name6, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.15*g_height, 0], substring(role4, 0, chars_to_keep2), [g_height * 0.03, g_height * 0.03, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.25*g_height, 0], substring(name7, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.35*g_height, 0], substring(role5, 0, chars_to_keep2), [g_height * 0.03, g_height * 0.03, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.4*g_height, 0], substring(name8, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.45*g_height, 0], substring(name9, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.5*g_height, 0], substring(name10, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.55*g_height, 0], substring(role6, 0, chars_to_keep2), [g_height * 0.03, g_height * 0.03, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.6*g_height, 0], substring(name11, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.65*g_height, 0], substring(name12, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.7*g_height, 0], substring(name13, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.75*g_height, 0], substring(name14, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.8*g_height, 0], substring(name15, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.5*g_width, 0.85*g_height, 0], substring(name16, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);*/

	//Restart Confirmation
	local string confirm = "";
	local string confirm2 = "";
	switch(in_menu)
	{
		case MENU_RES:
			confirm = "Are you sure you want to restart?";
			confirm2 = "Your current progress will be lost!";
		default:
			break;
	}

	drawstring([0.025*g_width, 0.25*g_height, 0], substring(confirm, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);
	drawstring([0.025*g_width, 0.3*g_height, 0], substring(confirm2, 0, chars_to_keep2), [g_height * 0.015, g_height * 0.015, 1], [0.8, 0.8, 0.8], 1, 1);

	//Update buttons
	local float i;

	for(i = 0; i < BUTTONS_COUNT; i++)
	{
		Update_Button(i);
	}
};