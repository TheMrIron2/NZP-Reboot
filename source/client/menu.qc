//
//	Menu stuff.. very uglp :p
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
	if (in_menu == MENU_PAUSE)
		in_menu = MENU_IGS;
	else
		in_menu = MENU_SETTINGS;
};

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
	if (in_menu == MENU_IGS)
		in_menu = MENU_PAUSE;
	else
		in_menu = MENU_MAIN;
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
	if (player_count == 0)
		localcmd("pause");
	in_menu = MENU_NONE;
	setcursormode(FALSE);
};

void() menu_main =
{
	in_menu = MENU_MAIN;
	localcmd("disconnect\n");
};

//settings adjustments

void() settings_fps = {
	local float fps = cvar("show_fps");

	if (fps == 0)
		fps = 1;
	else
		fps = 0;

	cvar_set("show_fps", ftos(fps));
}

/*

	MENU GUIDELINES (to perserve consistency)
	
	* Buttons that belong to the same category should have a spacing
	difference of 0.05.

	* Buttons that do not belong to the same category should have
	a spacing difference of 0.075.

*/

//struct for all buttons, note scale is going to be multiplied with width/height in draw step, so keep them between 0 and 1
var struct
{
	vector pos;
	string text;
	float active; //used for mouseover hilight (positive values) and alpha (negative values)
	void() action; //function that is called when the button is pressed
	float group; //a bit field, button will be usable/visible when these bits are active
} buttons[] =
{
	{[0.025, 0.175, 0], "Solo", -1, menu_single, MENU_MAIN},
	{[0.025, 0.225, 0], "Cooperative", -1, menu_multi, MENU_MAIN},
	{[0.025, 0.300, 0], "Settings", -1, menu_settings, MENU_MAIN},
	{[0.025, 0.375, 0], "Achievements", -1, menu_main, MENU_MAIN},
	{[0.025, 0.450, 0], "Credits", -1, menu_about, MENU_MAIN},
	{[0.025, 0.525, 0], "Quit", -1, menu_quit, MENU_MAIN},
	{[0.025, 0.900, 0], "Back", -1, menu_back, MENU_SINGLE + MENU_MULTI + MENU_SETTINGS + MENU_ABOUT + MENU_IGS},
	{[0.025, 0.175, 0], "Nacht der Untoten", -1, menu_loadndu, MENU_SINGLE},
	{[0.025, 0.500, 0], "Resume", -1, menu_resume, MENU_PAUSE},
	{[0.025, 0.550, 0], "Restart", -1, menu_restart, MENU_PAUSE},
	{[0.025, 0.600, 0], "Settings", -1, menu_settings, MENU_PAUSE},
	{[0.025, 0.650, 0], "Main Menu", -1, menu_main, MENU_PAUSE},

	{[0.025, 0.500, 0], "Yes", -1, menu_resy, MENU_RES},
	{[0.025, 0.550, 0], "No", -1, menu_resn, MENU_RES},

	{[0.025, 0.175, 0], "Show FPS", -1, settings_fps, MENU_SETTINGS + MENU_IGS},
};

//REMEMBER TO UPDATE THIS CONST IF YOU ADD BUTTONS
const float BUTTONS_COUNT = 15; //17
float lastActive;


//this function handles drawing the buttons and checking if they should be active/hilighted
void(float index) Update_Button = 
{
	float btnscale = 0.030*g_height;

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

	
	if(buttons[index].active > 0) {
		drawstring(pos, buttons[index].text, [g_height * 0.030, g_height * 0.030, 1], [1,0,0], 1, 1);
	} else {
		drawstring(pos, buttons[index].text, [g_height * 0.030, g_height * 0.030, 1], [0.8,0.8,0.8], 1, 1);
	}

	if (cursor_pos_x > pos_x && cursor_pos_x < pos_x + (g_height * 0.6) && cursor_pos_y > pos_y && cursor_pos_y < pos_y + btnscale) {
		if (index != lastActive)
			sound(self, 0, "sounds/menu/navigate.wav", 1, ATTN_NONE);
		
		buttons[index].active = 1;
		lastActive = index;
	}

	if (lastActive == -1) {
		buttons[index].active = 0;
	} else {
		buttons[lastActive].active = 1;
	}
		

	if(buttons[index].active > 0)
	{
		buttons[index].active -= frametime * 15;
		if(buttons[index].active < 0)
			buttons[index].active = 0;
	}
};


void(float index) Button_Click = 
{
	float btnscale = 0.030*g_height;

	//don't click if not active
	if(buttons[index].active == -1)
		return;
		
	local vector pos = buttons[index].pos;
	pos_x *= g_width;
	pos_y *= g_height;
	//local vector scale = buttons[index].scale;
	//scale_x *= g_width;
	//scale_y *= g_height;
	
	if (cursor_pos_x > pos_x && cursor_pos_x < pos_x + (g_height * 0.6) && cursor_pos_y > pos_y && cursor_pos_y < pos_y + btnscale) {
		buttons[index].action(); //do whatever this button is supposed to do
		lastActive = -1;
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


//FIXME -- credits look ugly, font scaling & such
void() Draw_Extra_Credits = 
{
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
}

void() Draw_Extra_Restart =
{
	drawstring([0.025*g_width, 0.375*g_height, 0], "Are you sure you want to restart?", [g_height * 0.020, g_height * 0.020, 1], [0.8,0.8,0.8], 1, 1);
	drawstring([0.02*g_width, 0.425*g_height, 0], "Your current progress will be lost!", [g_height * 0.020, g_height * 0.020, 1], [0.8,0.8,0.8], 1, 1);
}

void() Draw_Extra_Settings =
{
	local string fpsval;

	if (cvar("show_fps") == 0)
		fpsval = S_DISABLED;
	else
		fpsval = S_ENABLED;

	drawstring([0.325*g_width, 0.175*g_height, 0], fpsval, [g_height * 0.030, g_height * 0.030, 1], [0.8,0.8,0.8], 1, 1);
}

void() Draw_Menu =
{
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

	//menu title
	local string title = "";
	switch(in_menu)
	{
		case MENU_MAIN:
			title = "MAIN MENU";
			break;
		case MENU_SINGLE:
			title = "SOLO";
			break;
		case MENU_MULTI:
			title = "COOP";
			break;
		case MENU_ABOUT:
			title = "CREDITS";
			Draw_Extra_Credits();
			break;
		case MENU_PAUSE:
			title = "PAUSED";
			break;
		case MENU_IGS:
		case MENU_SETTINGS:
			title = "SETTINGS";
			Draw_Extra_Settings();
			break;
		case MENU_RES:
			title = "RESTART";
			Draw_Extra_Restart();
			break;
		default:
			title = "Nazi Zombies: Portable";
	}
	
	drawstring([0.025*g_width, 0.025*g_width, 0], title, [g_height * 0.045, g_height * 0.045, 1], [0.8, 0.8, 0.8], 1, 1);

	//Update buttons
	local float i;

	for(i = 0; i < BUTTONS_COUNT; i++)
	{
		Update_Button(i);
	}
};