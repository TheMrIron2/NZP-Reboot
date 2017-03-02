
float Distance (vector from, vector to) {
	return vlen(from - to);
}

float HeuristicCostEstimate (float start_way, float end_way)
{
	//for now we will just look the distance between.
	return Distance(waypoints[start_way].org, waypoints[end_way].org);
}

float IsEmpty(float *set, float max) {
	float i;

	for (i = 0; i < max; i++) {
		if (set[i] > 0) {
			return true;
		}
	}

	return false;
}
float Add(float *set, float max, float val) {
	float i;

	for (i = 0; i < max; i++) {
		if (set[i] <= 0) {
			set[i] = val;
			return true;
		}
	}

	return false;
}
float Remove(float *set, float max, float val) {
	float i;

	for (i = 0; i < max; i++) {
		if (set[i] == val) {
			set[i] = 0;
			return true;
		}
	}

	return false;
}
float In(float *set, float max, float val) {
	float i;

	for (i = 0; i < max; i++) {
		if (set[i] == val) {
			return i;
		}
	}

	return -1;
}

void ReconstructPath(entity z, float start_way, float end_way) {
	float current = end_way;
	float pathSet[MAX_WAYPOINTS];
	float pathsize = 1;

	pathSet[0] = current;

	while(current != start_way) {
		print("current ", ftos(current), " came_from: ", ftos(waypoints[current].came_from), "\n");
		current = waypoints[current].came_from;
		Add(pathSet, MAX_WAYPOINTS, current);
		pathsize++;
	}
		Add(pathSet, MAX_WAYPOINTS, start_way);



	float i;
	for (i = 0; i < pathsize; i++) {
		float inv = pathsize - i;
		z.way_path[i] = waypoints[pathSet[inv]].id;
		print("p: ", ftos(waypoints[pathSet[inv]].id), " i: ", ftos(i), " way: ", ftos(z.way_path[inv]), "\n");
	} 

	//while(current != star_way)
}

float Pathfind (entity z, float start_way, float end_way) {
	float openSet[MAX_WAYPOINTS];
	float closedSet[MAX_WAYPOINTS];
	float cost;
	openSet[0] = start_way;

	float i;
	for (i = 0; i < MAX_WAYPOINTS;i++)// clear all the waypoints
	{
		waypoints[i].came_from = 0;
		waypoints[i].f_score = -1;
		waypoints[i].g_score = -1;
	}

	waypoints[start_way].g_score = 0;
	waypoints[start_way].f_score = HeuristicCostEstimate(start_way, end_way);

	while (IsEmpty(openSet, MAX_WAYPOINTS)) {
		float current, best;
		best = 0;

		for (i = 0; i < MAX_WAYPOINTS; i++) {
			if (openSet[i] > 0) { //if openset has a waypoint
				if (openSet[best] == 0) {
					best = i;
				} else if (waypoints[openSet[i]].f_score < waypoints[openSet[best]].f_score) { //Is that waypoints fscore lower than current
					best = i;
				}
			}
		}

		current = openSet[best];

		if (current == end_way) {
			ReconstructPath(z, start_way, end_way);

			return 1;
		}

		openSet[best] = 0;
		Add(closedSet, MAX_WAYPOINTS, current);

		for (i = 0; i < MAX_WAY_TARGETS; i++) {
			float neighbor = waypoints[current].target_id[i];
			
			if (In(closedSet, MAX_WAYPOINTS, neighbor) != -1) {
				continue;
			}

			cost = waypoints[current].g_score + Distance(waypoints[current].org, waypoints[neighbor].org);
			
			float inClosed, inOpen;

			inOpen = In(openSet, MAX_WAYPOINTS, neighbor);
			inClosed = In(closedSet, MAX_WAYPOINTS, neighbor);
			if (inOpen != -1) {
				if (cost < waypoints[neighbor].g_score) {
					Remove(openSet, MAX_WAYPOINTS, neighbor);
				}
			}
			
			if (inClosed != -1) {
				if (cost < waypoints[neighbor].g_score) {
					Remove(closedSet, MAX_WAYPOINTS, neighbor);
				}
			}

			if (inOpen == -1 && inClosed == -1) {
				waypoints[neighbor].g_score = cost;
				Add(openSet, MAX_WAYPOINTS, neighbor);
				waypoints[neighbor].f_score = waypoints[neighbor].g_score + HeuristicCostEstimate(neighbor, end_way);
				waypoints[neighbor].came_from = current;
			}
		}

	}
	return -1;
}


float Do_Pathfind(entity from, entity to) {

	float i;
	float TraceResult;

	float dist, best_dist, best, best_target;

	dist = 0;
	best_dist = 100000000;

	for (i = 0; i < MAX_WAYPOINTS; i++) {
		TraceResult = tracemove (from.origin, VEC_HULL_MIN, VEC_HULL_MAX, waypoints[i].org, TRUE ,from);
		if (TraceResult) {
			dist = Distance(waypoints[i].org, from.origin);

			if(dist < best_dist) {
				best_dist = dist;
				best = i;
			}
		}
	}
	dist = 0;
	best_dist = 100000000;

	for (i = 0; i < MAX_WAYPOINTS; i++) {
		TraceResult = tracemove (to.origin, VEC_HULL_MIN, VEC_HULL_MAX, waypoints[i].org, TRUE ,to);
		if (TraceResult) {
			dist = Distance(waypoints[i].org, to.origin);

			if(dist < best_dist) {
				best_dist = dist;
				best_target = i;
			}
		}
	}

	print("Starting waypoint: ", ftos(best)," Ending waypoint: ", ftos(best_target), "\n");




	return Pathfind(from, best, best_target);
}

void CalcDistances() {
	float i, s;

	for (i = 0; i < MAX_WAYPOINTS; i++) {
		if (waypoints[i].id > 0) {
			for (s = 0; s < MAX_WAY_TARGETS; s++) {
				float targ;
				targ = waypoints[i].target_id[s];
				if (targ > 0) {
					waypoints[i].dist[s] = Distance(waypoints[i].org, waypoints[targ].org);
				}
			}
		}
	}
}

void creator_way_touch();
void LoadWaypointData() {
    float file, which, point;
	string h;
	local vector where;
	float targetcount, loop, waycount;
	entity new_way;

	waypoint_ai waypoint;

	h = strcat(mappath, ".way");
	file = fopen (h, FILE_READ);

	if (file == -1)
	{
		dprint("Error: file not found \n");
		return;
	}

    float i, s;

    for (i = 0; i < MAX_WAYPOINTS; i++) {
        waypoints[i].org = '0 0 0';
        waypoints[i].id = 0;
        waypoints[i].g_score = 0;
        waypoints[i].f_score = 0;
        waypoints[i].targetdoor = "";

        for (s = 0; s < MAX_WAY_TARGETS; s++) {
            waypoints[i].target_id[s] = 0;
            waypoints[i].dist[s] = 0;
        }
    }

	point = 0;
	waycount = 0;
	targetcount = 0;
	loop = 1;
	while (loop)
	{
		string line;
		line = fgets(file);
		if not (line) {
			bprint(PRINT_HIGH, "End of file\n");
			loop = 0;
			break;
		}
		h = strtrim(line);

		//print(h, "\n");
		if (h == "") {
			continue;
		}

		switch (point) {
			case 0:
				if (h == "waypoint") {
					new_way = spawn();
					new_way.solid = SOLID_TRIGGER;

					setmodel(new_way, "models/way/normal_way.spr");
					new_way.classname = "waypoint";

					new_way.touch = creator_way_touch;
					point = 1;
					targetcount = 0;
				} else {
					bprint(PRINT_HIGH, "Error: unknown point ", h, "\n");
				}
				break;
			case 1:
				if (h == "{") {
					point = 2;
				} else {
					bprint(PRINT_HIGH, "Error: unknown variable ", h, " expected {\n");
				}
				break;
			case 2:
				tokenize(h);

				string value, variable;
				variable = strtrim(argv(0));
				value = strtrim(argv(2));

				switch (variable) {
					case "origin":
						waypoint.org = stov(value);
						setorigin(new_way, stov(value));
						break;
					case "id":
						new_way.waynum = value;
						waypoint.id = stof(value);
						break;
					case "door":
						new_way.targetname = value;
						waypoint.targetdoor = value;
						break;
					case "targets":
						point = 3;
						break;
					case "}":
						float id = waypoint.id;

						waypoints[id] = waypoint;

						point = 0;
						break;
					default:
						bprint(PRINT_HIGH, "Error: unknown variable ", variable, "\n");
						break;
				}
				break;
			case 3:
				if (h == "[") {
					point = 4;
				} else {
					bprint(PRINT_HIGH, "Error: unknown variable ", h, " expected [\n");
				}
				break;
			case 4:
				if (targetcount >= MAX_WAY_TARGETS) {
					bprint(PRINT_HIGH, "Error: Target count too high for waypoint\n");
				} else if (h == "]") {
					point = 2;
				} else  {
					waypoint.target_id[targetcount] = stof(h);
					new_way.targets[targetcount] = h;
				}
				break;
		}
	}

	fclose(file);


	CalcDistances();
}