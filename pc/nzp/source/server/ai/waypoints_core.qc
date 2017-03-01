
void() creator_way_touch =
{
	if (cvar("waypoint_mode")) {
		if (other.classname != "player") {
			return;
		}
		
		current_way = self;
	}
}

void () Create_New_Waypoint =
{
	float way_count;
	float tempf;
	entity tempe;
	entity new_way;
	string temps;
	new_way = spawn();

	setorigin(new_way, self.origin);
	
	
	//new_way.flags = FL_ITEM;
	new_way.solid = SOLID_TRIGGER;

	
	setmodel(new_way, "models/way/normal_way.spr");
	new_way.classname = "waypoint";

	way_count = 0;
	tempe = find (world, classname, "waypoint");
	while (tempe) {
		tempf = stof (tempe.waynum);
		if (tempf > way_count) {
			way_count = tempf;
		}
		tempe = find (tempe, classname, "waypoint");
	}
	
	temps = ftos(way_count + 1);
	new_way.waynum = temps;
	new_way.waynum = strzone(new_way.waynum);
	new_way.targetname = strzone(new_way.targetname);
	bprint (PRINT_HIGH, "Created waypoint  ");
	bprint (PRINT_HIGH, new_way.waynum);
	bprint (PRINT_HIGH, "\n");

	new_way.touch = creator_way_touch;
}


void () Make_Special_Waypoint =
{
	if (self.classname != "player" || !active_way) {
		return;
	}
	if (active_way.targetname != "") {//Toggling it back off
		setmodel(active_way, "models/way/current_way.spr");
		active_way.targetname = "";
		bprint (PRINT_HIGH, "Waypoint ");
		bprint (PRINT_HIGH, active_way.waynum);
		bprint (PRINT_HIGH, " is no longer a special waypoint\n");
		return;
	}

	if (active_way) {
		if(self.active_door == world) {
			bprint (PRINT_HIGH, "Error: no door selected!\n");
			return;
		}

		if(self.active_door.wayTarget == "") {
			bprint (PRINT_HIGH, "Error: Door has no wayTarget value!\n");
			return;
		}
		setmodel(active_way, "models/way/current_way_door.spr");
		active_way.targetname = self.active_door.wayTarget;

		bprint (PRINT_HIGH, "special waypoint ");
		bprint (PRINT_HIGH, active_way.waynum);
		bprint (PRINT_HIGH, " named ");
		bprint (PRINT_HIGH, active_way.targetname);
		bprint (PRINT_HIGH, "\n");
	}
}


void () Move_Waypoint =
{
	if (!active_way)
		return;

	setorigin (active_way, self.origin);
	bprint (PRINT_HIGH, "Moved waypoint ");
	bprint (PRINT_HIGH, active_way.waynum);
	bprint (PRINT_HIGH, "\n");
	
}

void () Select_Waypoint =
{
	if (self.classname != "player")
		return;
	if (!current_way)
		return;

	entity tempe;

	if (current_way == active_way)
		active_way = world;
	else
		active_way = current_way;

	tempe = find (world, classname, "waypoint");
	while (tempe)
	{
		if (tempe.targetname != "")
			setmodel(tempe, "models/way/normal_way_door.spr");
		else
			setmodel(tempe, "models/way/normal_way.spr");
		tempe = find (tempe, classname, "waypoint");
	}
	if (active_way)
	{
		if (active_way.targetname != "")
			setmodel(active_way, "models/way/current_way_door.spr");
		else
			setmodel(active_way, "models/way/current_way.spr");
		
		bprint (PRINT_HIGH, "Selected waypoint ");
		bprint (PRINT_HIGH, active_way.waynum);
		if(active_way.targetname != "")
		{
			bprint (PRINT_HIGH, ", special tag ");
			bprint (PRINT_HIGH, active_way.targetname);
		}
		bprint (PRINT_HIGH, "\n");
		
		float i;
		for	(i = 0; i < MAX_WAY_TARGETS; i++) {
			tempe = find (world, waynum, active_way.targets[i]);

			if (tempe) {
				if (tempe.targetname != "")
					setmodel(tempe, "models/way/last_way_door.spr");
				else
					setmodel(tempe, "models/way/last_way.spr");
				bprint(PRINT_HIGH, active_way.targets[i]);
				bprint(PRINT_HIGH, "\n");
			} else {
				active_way.targets[i] = "";
			}
		}
	}
}


void() Remove_Waypoint =
{
	entity tempe;
	float i;
	if (!active_way)
		return;
		
	tempe = find (world, classname, "waypoint");
	while (tempe) {
	
		for	(i = 0; i < MAX_WAY_TARGETS; i++) {
			if (tempe.targets[i] == active_way.waynum) {
				tempe.targets[i] = "";
			}
		}

		tempe = find (tempe, classname, "waypoint");
	}
		
	bprint(PRINT_HIGH, "Removed waypoint ");
	bprint(PRINT_HIGH, active_way.waynum);
	bprint(PRINT_HIGH, "\n");
	remove (active_way);
}

float Waypoint_Linked_To(entity from, entity to) {
	float i;
	for	(i = 0; i < MAX_WAY_TARGETS; i++) {
		if (from.waynum == to.targets[i]) {
			bprint(PRINT_HIGH, "These waypoints are already linked!\n");
			return 1;
		}
	}

	return 0;
}

float Link (entity from, entity to) {
	float i;
	entity tempe;
	for	(i = 0; i < MAX_WAY_TARGETS; i++) {
		tempe = find (world, waynum, from.targets[i]);

		if (tempe == world || tempe == to) {
			from.targets[i] = to.waynum;
			bprint(PRINT_HIGH, "Linked waypoint ");
			bprint(PRINT_HIGH, to.waynum);
			bprint(PRINT_HIGH, " to ");
			bprint(PRINT_HIGH, from.waynum);
			bprint(PRINT_HIGH, "\n");

			if (to.targetname != "") {
				setmodel(to, "models/way/last_way_door.spr");
			} else {
				setmodel(to, "models/way/last_way.spr");
			}
			
			return 1;
		}
	}

	return 0;
}

void () Link_Waypoints =
{
	if (self.classname != "player")
		return;
	if (!current_way)
		return;
	if (!active_way)
		return;
	if (current_way == active_way)
		return;
	
	if (Waypoint_Linked_To(current_way, active_way)) {
		bprint(PRINT_HIGH, "These waypoints are already linked!\n");
		return;
	}
	
	float i;
	entity tempe;
	for	(i = 0; i < MAX_WAY_TARGETS; i++) {
		tempe = find (world, waynum, active_way.targets[i]);

		if (tempe == world) {
			if (Link(active_way, current_way)) {
				return;
			}
		}
	}

	
	bprint(PRINT_HIGH, "no targets remaining!\n");
}



void() Dual_Link_Waypoints =
{
	if (self.classname != "player" || !current_way || !active_way || current_way == active_way) {
		return;
	}
	
	float result1,result2;
	result1 = Waypoint_Linked_To(current_way,active_way);
	result2 = Waypoint_Linked_To(active_way,current_way);
	
	if(result1 && result2) {
		bprint(PRINT_HIGH, "Both waypoints already linked!\n");
		return;
	}
	
	if(!result1)
	{
		if (Link(current_way,active_way)) {
			bprint(PRINT_HIGH, "Linked waypoint ", current_way.waynum, " to ", active_way.waynum, "\n");
		} else {
			bprint(PRINT_HIGH, "ERROR: Could not link waypoint ", current_way.waynum, " to ", active_way.waynum, "\n");
		}
	}
	if(!result2)
	{
		if (Link(active_way,current_way)) {
			bprint(PRINT_HIGH, "Linked waypoint ", active_way.waynum, " to ", current_way.waynum, "\n");
		} else {
			bprint(PRINT_HIGH, "ERROR: Could not link waypoint ", active_way.waynum, " to ", current_way.waynum, "\n");
		}
	}
}


string tempstest;
void() Save_Waypoints
{
	float file;
	string h;
	float i;
	entity tempe;

	h = strcat(mappath, ".way");
	file = fopen (h, FILE_WRITE);
	dprint ("Saving waypoints ", h, "\n");
	
	local entity dway;
	//fputs(file, "begin\n");
	dway = find(world, classname, "waypoint");
	while (dway)
	{
		fputs(file,"waypoint\n");
		fputs(file,"{\n");
		fputs(file, " id: ", dway.waynum, "\n");
		if (dway.targetname != "") {
			fputs(file, " door: ", dway.targetname, "\n");
		}

		fputs(file, " targets:\n");
		fputs(file, " [\n");
		for (i = 0; i < MAX_WAY_TARGETS; i++) {
			tempe = find (world, waynum, dway.targets[i]);

			if (tempe != world) {
				fputs(file, "  ", dway.targets[i], "\n");
			}
		}
		fputs(file, " ]\n");
		fputs(file,"}\n");
		
		
		dway = find(dway, classname, "waypoint");
		if (dway)
			fputs(file,"\n");
	}
	fclose(file);
}

void (vector here, float which, string special, string trg, string trg2, string trg3, string trg4, string trg5, string trg6, string trg7, string trg8) Create_Waypoint =
{
	entity new_way;
	new_way = spawn();

	setorigin(new_way, here);
	
	
	//new_way.flags = FL_ITEM;
	new_way.solid = SOLID_TRIGGER;

	if (cvar("waypoint_mode"))
		setmodel(new_way, "models/way/normal_way.spr");
	new_way.classname = "waypoint";
	new_way.classname = strzone(new_way.classname);

	new_way.waynum = ftos(which);
	new_way.waynum = strzone(new_way.waynum);
	dprint ("Created waypoint  ");
	dprint (new_way.waynum);
	dprint ("\n");
	
	if (special != "")
	{
		if (!cvar("waypoint_mode"))
			new_way.classname = "waypoint_s";
		if (cvar("waypoint_mode"))
			setmodel(new_way, "models/way/normal_way_door.spr");
		new_way.targetname = special;
		new_way.targetname = strzone(new_way.targetname);
		dprint ("Special waypoint  ");
		dprint (new_way.targetname);
		dprint ("\n");
		//current_special++;
	}

	new_way.targets[0] = trg;
	new_way.targets[1] = trg2;
	new_way.targets[2] = trg3;
	new_way.targets[3] = trg4;
	new_way.targets[4] = trg5;
	new_way.targets[5] = trg6;
	new_way.targets[6] = trg7;
	new_way.targets[7] = trg8;

	new_way.touch = creator_way_touch;
}

void() Load_Waypoints_Legacy
{
	float file, which;
	string h, special, trg, trg2, trg3, trg4, trg5, trg6, trg7, trg8;
	local vector where;

	h = strcat(mappath, ".way");
	file = fopen (h, FILE_READ);

	if (file == -1)
	{
		dprint("Error: file not found \n");
		return;
	}

	while (1)
	{
		dprint("Loading waypoint\n");
		// the first line is just a comment, ignore it
		h = fgets(file);	
		if (h != "Waypoint")
		{
			bprint(PRINT_HIGH, "Last waypoint\n");
			fclose(file);
			return;
		}
		h = fgets(file);
		h = fgets(file);
		h = substring(h, 9, 20);
		where = stov(h);
		
		h = (fgets(file));
		h = substring(h, 5, 20);
		which = stof(h);
	
		h = (fgets(file));
		special = substring(h, 10, 20);
	
		h = (fgets(file));
		trg = substring(h, 9, 20);

		h = (fgets(file));
		trg2 = substring(h, 10, 20);

		h = (fgets(file));
		trg3 = substring(h, 10, 20);

		h = (fgets(file));
		trg4 = substring(h, 10, 20);

		h = (fgets(file));
		trg5 = substring(h, 10, 20);

		h = (fgets(file));
		trg6 = substring(h, 10, 20);

		h = (fgets(file));
		trg7 = substring(h, 10, 20);

		h = (fgets(file));
		trg8 = substring(h, 10, 20);
		
		Create_Waypoint(where, which, special, trg, trg2, trg3, trg4, trg5, trg6, trg7, trg8);

		h = (fgets(file));
		h = (fgets(file));
	}
}

//Waypoint logic functions
void () Waypoint_Functions =
{
	switch (self.impulse) {
		case 100:	
			Create_New_Waypoint();
			break;
		case 101:	
			Make_Special_Waypoint();
			break;
		case 102:	
			Select_Waypoint();
			break;
		case 103:
			Move_Waypoint();
			break;
		case 104:
			Link_Waypoints ();
			break;
		case 105:
			Dual_Link_Waypoints();
			break;
		case 106:
			Save_Waypoints();
			break;
		case 107:
			Load_Waypoints_Legacy();
			break;
		case 108:
			Load_Waypoints_Legacy();
			break;
		case 109:
			Remove_Waypoint();
			break;
	}
	
	self.impulse = 0;
};

void () Waypoint_Logic =
{
	if (!waypoint_mode) {
		waypoint_mode = 1;
		entity zent;
	
		zent = find (world, classname, "ai_zombie");
		while (zent)
		{
			remove (zent);
			zent = find (zent, classname, "ai_zombie");
		}

		zent = find (world, classname, "door_nzp_cost");
		while (zent)
		{
			zent.solid = SOLID_NOT;
			zent.touch = SUB_Null;
			zent = find (zent, classname, "door_nzp_cost");
		}
		zent = find (world, classname, "door_nzp");
		while (zent)
		{
			zent.solid = SOLID_NOT;
			zent.touch = SUB_Null;
			zent.solid = SOLID_NOT;
			zent = find (zent, classname, "door_nzp");
		}
		zent = find (world, classname, "window");
		while (zent)
		{
			zent.solid = SOLID_NOT;
			zent.touch = SUB_Null;
			zent = find (zent, classname, "window");
		}
		
	}
	Waypoint_Functions();
};