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
	localcmd("disconnect\n");
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
	{[0.025, 0.175, 0], [0.325, 0.06, 0], " Solo", -1, menu_single, MENU_MAIN},
	{[0.025, 0.250, 0], [0.325, 0.06, 0], " Cooperative", -1, menu_multi, MENU_MAIN},
	{[0.025, 0.325, 0], [0.325, 0.06, 0], " Settings", -1, menu_settings, MENU_MAIN},
	{[0.025, 0.400, 0], [0.325, 0.06, 0], " Achievements", -1, menu_main, MENU_MAIN},
	{[0.025, 0.475, 0], [0.325, 0.06, 0], " Credits", -1, menu_about, MENU_MAIN},
	{[0.025, 0.550, 0], [0.325, 0.06, 0], " Quit", -1, menu_quit, MENU_MAIN},
	{[0.025, 0.900, 0], [0.325, 0.06, 0], "Back", -1, menu_back, MENU_SINGLE + MENU_MULTI + MENU_SETTINGS + MENU_ABOUT},
	{[0.025, 0.175, 0], [0.425, 0.06, 0], "Nacht Der Untoten", -1, menu_loadndu, MENU_SINGLE},
	//{[0.025, 0.575, 0], [0.250, 0.05, 0], "Warehouse", -1, menu_loadwh, MENU_SINGLE},
	{[0.475, 0.500, 0], [0.250, 0.05, 0], "Join", -1, game_join, MENU_JOIN},
	{[0.475, 0.575, 0], [0.250, 0.05, 0], "Spectate", -1, game_spec, MENU_JOIN},
	{[0.025, 0.500, 0], [0.250, 0.05, 0], "Resume", -1, menu_resume, MENU_PAUSE},
	{[0.025, 0.575, 0], [0.250, 0.05, 0], "Restart", -1, menu_restart, MENU_PAUSE},
	{[0.025, 0.650, 0], [0.250, 0.05, 0], "Settings", -1, menu_settings2, MENU_PAUSE},
	{[0.025, 0.725, 0], [0.250, 0.05, 0], "Main Menu", -1, menu_main, MENU_PAUSE},
	{[0.025, 0.925, 0], [0.250, 0.05, 0], "Back", -1, menu_back2, MENU_IGS},
	{[0.025, 0.500, 0], [0.250, 0.05, 0], "Yes", -1, menu_resy, MENU_RES},
	{[0.025, 0.575, 0], [0.250, 0.05, 0], "No", -1, menu_resn, MENU_RES},
};

//REMEMBER TO UPDATE THIS CONST IF YOU ADD BUTTONS
const float BUTTONS_COUNT = 17;

float mapdesc = 0;


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
	
	if(buttons[index].active > 0) //Add navigate.wav here when we figure out how to do a check to see if it was already executed.
	{
		alphafactor = 1;
		drawfill(pos, scale, [0.6,0.6,0.6] + [0.15,0.15,0.15]*buttons[index].active, 0.3 * alphafactor); //Solid Background
		drawline(1, pos, [pos_x + scale_x, pos_y, 0], [90,90,90], 1.5, 1); //top outline
		drawline(1, [pos_x, pos_y + scale_y, 0], [pos_x + scale_x, pos_y + scale_y, 0], [90,90,90], 1.5, 1); //bottom outline
	}
	else
		alphafactor = buttons[index].active + 1; //-1 invis, 0 normal
	
	if(cursor_pos_x > pos_x && cursor_pos_x < pos_x + scale_x && cursor_pos_y > pos_y && cursor_pos_y < pos_y + scale_y )
		buttons[index].active = 1;
	drawstring(pos + [scale_x*0.05, scale_y*0.25, 0], buttons[index].text, [scale_y*0.5, scale_y*0.5, 1], [0.8,0.8,0.8], 1 * alphafactor, 1);
	
	if(buttons[index].active > 0)
	{
		buttons[index].active -= frametime * 15;
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
	//moto - put loading of demo.bsp when it's time has come.
	if(serverkey("constate") == "disconnected")
	{
		if(g_width <= g_height * 1.77778)
			drawpic([0,0,0], "menu/bg", [g_height * 1.77778, g_height, 1], [1, 1, 1], 1);
		else
			drawpic([0,0,0], "menu/bg", [g_width, g_height, 1], [1, 1, 1], 1);
	}

		
	//Gradient on the background
	drawpic([0,0,0], "menu/gradient_l2r", [0.75*g_width, g_height, 1], [1, 1, 1], 1);
	

	//Menu titles & cinematic lines.
	local string title = "";
	switch(in_menu)
	{
		case MENU_MAIN:
			title = "MAIN MENU";
			//drawfill ([0.025*g_width, 0.253*g_height + g_height*0.025 + 3, 0], [0.22*g_width, 0.0025*g_height, 0], [0.4, 0.4, 0.4], 1); //Play | Settings
			//drawfill ([0.025*g_width, 0.323*g_height + g_height*0.025 + 3, 0], [0.22*g_width, 0.0025*g_height, 0], [0.4, 0.4, 0.4], 1); //Settings | Achievements
			//drawfill ([0.025*g_width, 0.393*g_height + g_height*0.025 + 3, 0], [0.22*g_width, 0.0025*g_height, 0], [0.4, 0.4, 0.4], 1); //Achievements | Credits
			//drawfill ([0.025*g_width, 0.463*g_height + g_height*0.025 + 3, 0], [0.22*g_width, 0.0025*g_height, 0], [0.4, 0.4, 0.4], 1); //Credits | Quit 
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
	switch(in_menu)
	{
		case MENU_ABOUT:
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