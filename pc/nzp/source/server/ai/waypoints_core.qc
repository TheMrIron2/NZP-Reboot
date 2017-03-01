
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
			setmodel(tempe, "progs/way/normal_way_door.spr");
		else
			setmodel(tempe, "progs/way/normal_way.spr");
		tempe = find (tempe, classname, "waypoint");
	}
	if (active_way)
	{
		if (active_way.targetname != "")
			setmodel(active_way, "progs/way/current_way_door.spr");
		else
			setmodel(active_way, "progs/way/current_way.spr");
		
		bprint (PRINT_HIGH, "Selected waypoint ");
		bprint (PRINT_HIGH, active_way.waynum);
		if(active_way.targetname != "")
		{
			bprint (PRINT_HIGH, ", special tag ");
			bprint (PRINT_HIGH, active_way.targetname);
		}
		bprint (PRINT_HIGH, "\n");
		
		int i;
		for	(i = 0; i < MAX_WAY_TARGETS; i++) {
			
		}
		if(active_way.target != "")
		{
			tempe = find (world, waynum, active_way.target);
			if (tempe)
			{
				if (tempe.targetname != "")
					setmodel(tempe, "progs/way/last_way_door.spr");
				else
					setmodel(tempe, "progs/way/last_way.spr");
				bprint(PRINT_HIGH, active_way.target);
				bprint(PRINT_HIGH, "\n");
			}
			else
			{
				active_way.target = "";
			}
		}
		if(active_way.target2 != "")
		{
			tempe = find (world, waynum, active_way.target2);
			if (tempe)
			{
				if (tempe.targetname != "")
					setmodel(tempe, "progs/way/last_way_door.spr");
				else
					setmodel(tempe, "progs/way/last_way.spr");
				bprint(PRINT_HIGH, active_way.target2);
				bprint(PRINT_HIGH, "\n");
			}
			else
			{
				active_way.target2 = "";
			}
		}
		if(active_way.target3 != "")
		{
			tempe = find (world, waynum, active_way.target3);
			if (tempe)
			{
				if (tempe.targetname != "")
					setmodel(tempe, "progs/way/last_way_door.spr");
				else
					setmodel(tempe, "progs/way/last_way.spr");
				bprint(PRINT_HIGH, tempe.target3);
				bprint(PRINT_HIGH, "\n");
			}
			else
			{
				active_way.target3 = "";
			}
		}
		if(active_way.target4 != "")
		{
			tempe = find (world, waynum, active_way.target4);
			if (tempe)
			{
				if (tempe.targetname != "")
					setmodel(tempe, "progs/way/last_way_door.spr");
				else
					setmodel(tempe, "progs/way/last_way.spr");
				bprint(PRINT_HIGH, active_way.target4);
				bprint(PRINT_HIGH, "\n");
			}
			else
			{
				active_way.target4 = "";
			}
		}
		if(active_way.target5 != "")
		{
			tempe = find (world, waynum, active_way.target5);
			if (tempe)
			{
				if (tempe.targetname != "")
					setmodel(tempe, "progs/way/last_way_door.spr");
				else
					setmodel(tempe, "progs/way/last_way.spr");
				bprint(PRINT_HIGH, active_way.target5);
				bprint(PRINT_HIGH, "\n");
			}
			else
			{
				active_way.target5 = "";
			}
		}
		if(active_way.target6 != "")
		{
			tempe = find (world, waynum, active_way.target6);
			if (tempe)
			{
				if (tempe.targetname != "")
					setmodel(tempe, "progs/way/last_way_door.spr");
				else
					setmodel(tempe, "progs/way/last_way.spr");
				bprint(PRINT_HIGH, "\n");
			}
			else
			{
				active_way.target6 = "";
			}
		}
		if(active_way.target7 != "")
		{
			tempe = find (world, waynum, active_way.target7);
			if (tempe)
			{
				if (tempe.targetname != "")
					setmodel(tempe, "progs/way/last_way_door.spr");
				else
					setmodel(tempe, "progs/way/last_way.spr");
				bprint(PRINT_HIGH, active_way.target7);
				bprint(PRINT_HIGH, "\n");
			}
			else
			{
				active_way.target7 = "";
			}
		}
		if(active_way.target8 != "")
		{
			tempe = find (world, waynum, active_way.target8);
			if (tempe)
			{
				if (tempe.targetname != "")
					setmodel(tempe, "progs/way/last_way_door.spr");
				else
					setmodel(tempe, "progs/way/last_way.spr");
				bprint(PRINT_HIGH, active_way.target8);
				bprint(PRINT_HIGH, "\n");
			}
			else
			{
				active_way.target8 = "";
			}
		}
	}
}

void () Waypoint_Functions =
{
	switch (self.impulse) {
		case 100:	
			Create_New_Waypoint();
			break;
		case 100:	
			Select_Waypoint();
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