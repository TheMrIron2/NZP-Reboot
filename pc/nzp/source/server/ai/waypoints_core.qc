
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

void () Waypoint_Functions =
{
	switch (self.impulse) {
		case 100:	
			Create_New_Waypoint();
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