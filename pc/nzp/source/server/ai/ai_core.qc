void(float what) play_sound_z;


//Duplicate of ai_physics_movement, but does the move in x-axis first then y-axis (for sliding along walls, etc)

void() ai_component_wise_physics_movement = 
{
	float max_step_size = 18;//max stair step size pulled straight from engine defs
	float max_slope = 10.4;//18/tan(60) = 10.4, the length of the triangle formed by the max walkable slope of 60 degrees, and the max step height
	
	vector goal_org;
	
	vector org = [self.origin_x, self.origin_y, self.true_org_z];
	
	vector delta_org;
	
	//Iterate over x-axis then y-axis
	for(float i = 0; i < 2; i++)
	{
		delta_org = [0,0,0];
		
		delta_org[i] = self.velocity[i] * frametime;
		
		goal_org = org + delta_org;
	
		//Push down from a step above goal org to find result position
		
		vector above_goal = goal_org + [0,0,max_step_size];
		vector below_goal = goal_org - [0,0,max_step_size];
		
		tracebox(above_goal,self.mins,self.maxs,below_goal,MOVE_NOMONSTERS,self);
		
		if(trace_allsolid)
			continue;
			
		if(trace_startsolid)
		{
			tracebox(goal_org,self.mins,self.maxs,below_goal,MOVE_NOMONSTERS,self);
			if(trace_allsolid || trace_startsolid)
				continue;
		}
		
		if(trace_fraction >= 1)
		{
			//We walked off of a ledge
			self.true_org_z = goal_org_z;
			setorigin(self,goal_org);
			self.flags &= ~FL_ONGROUND;
			continue;
		}
		
		self.origin_x = trace_endpos_x;
		self.origin_y = trace_endpos_y;
		self.true_org_z = trace_endpos_z;
		self.origin_z += 0.05*(self.true_org_z - self.origin_z);
		setorigin(self, self.origin);
		self.flags |= FL_ONGROUND;
	}
}


void() ai_physics_movement =
{
	if(self.think && self.nextthink < time)
	{
		self.think();
	}
	
	//Don't run movement on non-instantiated zombie ents
	if(strncmp(self.aistatus,"1"))
	{
		return;
	}
	
	if(self.health <= 0)
	{
		self.velocity.x = self.velocity.y = 0;
	}
	
	float max_step_size = 18;//max stair step size pulled straight from engine defs
	float max_slope = 10.4;//18/tan(60) = 10.4, the length of the triangle formed by the max walkable slope of 60 degrees, and the max step height
	
	vector goal_org;
	
	vector org = [self.origin_x, self.origin_y, self.true_org_z];
	
	
	if(!(self.flags & FL_ONGROUND))
	{
		self.velocity_z  -= self.gravity * sv_gravity * frametime;
		
		//Clamping to server terminal velocity (-sv_maxspeed -> sv_maxspeed)
		self.velocity_z = max(min(self.velocity_z, sv_maxspeed), -sv_maxspeed);
		
		goal_org = org + [0,0,self.velocity.z] * frametime;
		
		tracebox(org,self.mins,self.maxs,goal_org,MOVE_NOMONSTERS,self);
		
		//If falling and hit something
		if(self.velocity.z < 0 && trace_fraction < 1)
		{	
			self.flags |= FL_ONGROUND;
		}
		
		self.true_org_z = trace_endpos_z;
		setorigin(self, trace_endpos);
		return;
	}
	
	
	//=======================================================================================================================================
	//This code is a translated version of dquake's step movetype
	
	goal_org = org + self.velocity * frametime;
	
	//Push down from a step above goal org to find result position
	
	vector above_goal = goal_org + [0,0,max_step_size];
	vector below_goal = goal_org - [0,0,max_step_size];
	
	tracebox(above_goal,self.mins,self.maxs,below_goal,MOVE_NOMONSTERS,self);
	
	if(trace_allsolid)
	{
		//Try sliding along walls
		ai_component_wise_physics_movement();
		return;
	}
		
	if(trace_startsolid)
	{
		tracebox(goal_org,self.mins,self.maxs,below_goal,MOVE_NOMONSTERS,self);
		if(trace_allsolid || trace_startsolid)
		{
			//Try sliding along walls
			ai_component_wise_physics_movement();
			return;
		}
	}
	
	if(trace_fraction >= 1)
	{
		//We walked off of a ledge
		self.true_org_z = goal_org_z;
		setorigin(self,goal_org);
		self.flags &= ~FL_ONGROUND;
		return;
	}
	
	self.origin_x = trace_endpos_x;
	self.origin_y = trace_endpos_y;
	self.true_org_z = trace_endpos_z;
	self.origin_z += 0.05*(self.true_org_z - self.origin_z);
	
	setorigin(self, self.origin);
	
	//Lerping z-height:
	
	self.flags |= FL_ONGROUND;
	
	
	
	//=======================================================================================================================================
	
	
	/*float gravity_accel = self.gravity * 800;//800 is default server gravity TODO: use server gravity value

	//We assign only zombie velocity
	//use this velocity to move the zombie
	
	float prev_onground = self.flags & FL_ONGROUND;
	
	//Removing the onground flag
	self.flags &= ~FL_ONGROUND;
	
	vector org = self.origin;
	vector new_org;
	
	
	
//	setorigin(self,self.origin + self.velocity*frametime);
	
//	self.flags |= FL_ONGROUND;
	
//	return;
	
	
	//If we were previously on the ground
	if(prev_onground)
	{
		self.velocity.z = 0;
		new_org = org + (self.velocity * frametime);
		//Try a move to the current destination
		tracebox(org,self.mins,self.maxs,new_org,MOVE_NOMONSTERS,self);
		
		float non_step_fraction = trace_fraction;
		
		//If the move was successful
		if(non_step_fraction >= 1)
		{
			//Check if we walked off of a ledge
			tracebox(new_org,self.mins,self.maxs,new_org + [0,0,-2*max_step_size],MOVE_NOMONSTERS,self);
			//If we fell more than the max step height
			if(trace_fraction >= 0.5)
			{
				//add z-velocity
				self.velocity.z += -gravity_accel * frametime;
				setorigin(self,new_org + [0,0,-2*max_step_size*trace_fraction]);
			}
			else if(trace_fraction > 0)//We walked down the height of a step
			{
				//TODO: lerp vertical position to final pos
				setorigin(self,new_org + [0,0,-2*max_step_size*trace_fraction]);
				self.flags |= FL_ONGROUND;
			}
			else//We did not walk down
			{
				self.flags |= FL_ONGROUND;
				setorigin(self,new_org);
			}
		}
		else//Try the same move with a step up to see if we can complete the move
		{
			tracebox(org + [0,0,max_step_size],self.mins,self.maxs,new_org + [0,0,max_step_size],MOVE_NOMONSTERS,self);
			if(trace_fraction >= 1)
			{
				//FIXME: this can climb up any degree slope < 90
				//Tracebox down from this position to get our new ground height
				tracebox(new_org + [0,0,max_step_size],self.mins,self.maxs,new_org,MOVE_NOMONSTERS,self);
				
				//TODO: lerp vertical position to final pos
				setorigin(self,new_org + [0,0,max_step_size*(1 - trace_fraction)]);
				self.flags |= FL_ONGROUND;
			}
			else//If not, just move as much as we could in the tracebox without the step
			{
				setorigin(self,self.origin + non_step_fraction*(new_org-org));
				self.flags |= FL_ONGROUND;
			}
		}
		
	}
	else//if we were not previously on the ground
	{
		vector delta_org = self.velocity * frametime;
		//Applying x-axis velocity
		tracebox(org,self.mins,self.maxs,org + [delta_org.x,0,0],MOVE_NOMONSTERS,self);
		new_org = org + trace_fraction * [delta_org.x,0,0];
		//Applying y-axis velocity
		tracebox(new_org,self.mins,self.maxs,new_org + [0,delta_org.y,0],MOVE_NOMONSTERS,self);
		new_org = new_org + trace_fraction * [0,delta_org.y,0];
		//Applying z-axis velocity
		tracebox(new_org,self.mins,self.maxs,new_org + [0,0,delta_org.z],MOVE_NOMONSTERS,self);
		new_org = new_org + trace_fraction * [0,0,delta_org.z];
		
		setorigin(self,new_org);
		
		//Check if we hit something going down
		if(delta_org.z <= 0)
		{
			if(trace_fraction < 1)
			{
				//We are now on ground
				self.velocity.z = 0;
				self.flags |= FL_ONGROUND;
				return;
			}
		}

		//add z-velocity
		self.velocity.z += -gravity_accel * frametime;
		return;
	}*/
	
	//Outlining logic:
	//=====================================================================================
	//If we were not previously on the ground
		//apply x-axis velocity
		//apply y-axis velocity
		//apply z-axis velocity
			//Check if we are on ground (may be able to combine this with z-axis velocity)
			//i.e. if z-axis velocity > 0, we are obviously not on ground because we have just raised above it
			//if z-axis velocity < 0, and the attempt to move failed, we are now on ground
		//apply gravity to the velocity
	//else if we were previously on the ground
		//check if we are on the ground now (EDIT: is this necessary?)
		//try move
			//if success: 
				//check if we are on the ground after move
				//if we are not on the ground
					//if we went down less than a step height
						//lerp down to that height
					//if we went down more than a step height
						//we are no longer on the ground
			//if fail:
				//try the move again a step above
				//if success
					//cast down to get our final ground position
					//lerp to that height
	//=====================================================================================


	//Try move:
	//Check if we can fall here:
		//if so, add gravity to velocity & remove onground flag
	//Else try move:
		//if success, finish
	//Else try move with a step up:
		//if success, tracebox down from that position
		//LERP THE STEP UP FROM FINAL VERTICAL OFFSET
	//We don't want to repeatedly fall when going down a hill
		//Check our final position to see if we fell a slight amount, if so, lerp the step down
	
	//for smoothly transitioning up stairs, we can store a float showing goal and current
	//how can we smoothly and without jumps transition up entire staircases?
	
	//TODO: implement zombie walk physics
	//we have to account for smooth transitions up stairs
	//account for falling
	//account for not sliding down hills / slowing down up hills AT ALL (when going up hill, maintain horizontal velocity)
	//allow for zombies to walk through zombies
	
};


void() path_corner_touch =
{
	self.origin_z = self.origin_z + 32;
	setorigin(self, self.origin);
	self.classname = "path_corner";
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.touch = SUB_Null;
	setsize(self, '0 0 0 ', '0 0 0');
	if(!self.target)
	{
		if (self.spawnflags & 1)
			return;
		bprint(PRINT_HIGH, "path_corner with name: ");
		bprint(PRINT_HIGH, self.targetname);
		bprint(PRINT_HIGH, " has no target!\n");
	}
};
//We want the path corner to drop to the ground and then we set it up 32 units so it's exact
void() path_corner =
{
	self.classname = "path_corner_set";
	self.movetype = MOVETYPE_BOUNCE;
	self.solid = SOLID_BBOX;
	self.touch = path_corner_touch;
	setsize(self, '0 0 0 ', '0 0 0');
};


void removeZombie();
void() Respawn = 
{
	Current_Zombies = Current_Zombies - 1;
	removeZombie();
};

entity(entity blarg) find_new_enemy =
{
	local entity player;
	local entity closest;
	local float bestdist;
	local float dist;
	bestdist = 10000;
	if(self.classname == "ai_zombie") {
		player = find(world,classname,"monkey");
		if(player) {
			return player;
		}
		
		player = find(world,classname,"player");
		///////////////////////////////
		if(!player) {
			return world;
		}
		//////////////////////////////
		while(player) {
      		if (player.downed == true) {
        		return world;
			  }
        
			dist = vlen(self.origin - player.origin);
			if (dist < bestdist) {
				closest = player;
				bestdist = dist;
				
			}
			player = find(player,classname,"player");
		}
		return closest;
		
	}
	bprint(PRINT_HIGH, "Error: Find_New_Enemy returns world! \n");
	return world;
};


float() avoid_zombies =
{
	local entity ent;
	ent = findradius(self.origin,23);//22.67
	makevectors(self.angles);
	float left_amount, right_amount;
	left_amount = right_amount = 0;
	while(ent)
	{
		if(ent.classname == "ai_zombie" && ent != self)
		{
			local vector vec_b;
			local float dot;
			//vec_b = normalize(self.origin - ent.origin);
			//dot = v_right * vec_b;
			//dot = self.angles_y - (dot > 0.5) ? 90 :  270;
			
			vec_b = (self.origin - ent.origin);
			dot = (v_right_x * vec_b_x) + (v_right_y * vec_b_y);//dot product
			if(dot > 0)// on right
				right_amount++;
			else// on left
				left_amount++;
		}
		ent = ent.chain;
	}
	if(left_amount + right_amount == 0)
		return 0;
	
	return (left_amount > right_amount) ? 15 : -15;
};

float() push_away_zombies =
{
	local entity ent;
	ent = findradius(self.origin,11);
	float return_value;
	return_value = 0;
	while(ent)
	{
		if(ent.classname == "ai_zombie" && ent != self)
		{
			vector push;
			push = ent.origin - self.origin;
			push_z = 0;
			push = normalize(push) * 10;
			
			ent.velocity += push;
			return_value = 1;
		}
		ent = ent.chain;
	}
	return return_value;
}


void(float dist, vector vec) do_walk_to_vec =
{
	if(dist == 0)
		return;
	
	self.ideal_yaw = vectoyaw(vec - self.origin);
	if(self.outside == false)
	{
		push_away_zombies();
		//self.ideal_yaw += avoid_zombies(); //no longer relevant since our direction doesn't care about our yaw any more
	}
	ChangeYaw();
	vector new_velocity;
	
	//Don't consider z-component
	vector goal = [vec.x, vec.y, self.origin.z];
	
	float len;
	len = vlen(self.origin - goal);
	
	if(dist > len)//if we're moving past our goal position
	{
		//FIXME: this may fix a glitch with a navmesh's innacuracy
		//	setorigin(self,goal);
		//	self.velocity = [0,0,0];
		dist = len;
	}
	//This movement method is moving directly towards the goal, regardless of where our yaw is facing (fixes several issues)
	new_velocity = normalize(goal - self.origin) * dist * 10;//10 comes from logic ticks per second
	
	new_velocity_z = self.velocity_z;
	self.velocity = new_velocity;
};

void(float dist) do_walk =
{
	do_walk_to_vec(dist,self.goalentity.origin);
};


void(float dist) walk_to_window =
{
	do_walk_to_vec(dist,self.goalorigin);
};


float(vector where) nearby = 
{
	if(self.classname == "ai_zombie")
	{
		float xdist;
		float ydist;
		float zdist;
		xdist = fabs(self.origin_x - where_x);
		ydist = fabs(self.origin_y - where_y);
		zdist = fabs(self.origin_z - where_z);
		
		if(xdist < 4 && ydist < 4)//horizontal distance is fairly close
		{
			if(zdist < 50)//vertical distance just has to be arbitrarily close
			{
				return 1;
			}
		}
		return 0;
	}
	/*else if(self.classname == "ai_hellhound")
	{
		if(vlen(self.origin - what.origin) < 35)
		{
			if(vlen(self.origin - what.origin) < 6)
			{
				return 1;
			}
			else
			{
				interpolateToVector(what.origin,0.25);
			}
		}
	}*/
	return 0;
};

void(float dist) Window_Walk =
{
	if(self.reload_delay < time)
		Respawn();
	
	if(self.hop_step == 0)//following path corners
	{		
		if(self.goalentity == world)
		{
			if((!self.target) && (self.outside == TRUE))
			{
				bprint(PRINT_HIGH, "Error: Outside zombie spawn point has no target.\n");
				Respawn();
			}
			self.goalentity = find(world,targetname, self.target);
			if(!self.goalentity)
			{
				bprint(PRINT_HIGH, "Error: Outside zombie spawn point target does not exist.\n");
				Respawn();
			}
		}
		
		if(self.goalentity.classname == "path_corner" && nearby(self.goalentity.origin))
		{
			if (self.goalentity.spawnflags & 1) //this path corner sets zombie on inside.
			{
				self.outside = FALSE;
				self.goalentity = world;
				self.enemy = find_new_enemy(self);
				self.th_walk();
				return;
			}
			self.reload_delay = time + 30;
			self.goalentity = find(world,targetname,self.goalentity.target);
			
			//Assumption is that when the zombie is outside, we can always walk from one path_corner to the next in a straight line, any devation should be corrected by the mapper
		}
		
		do_walk(dist);
		
		if(self.goalentity.classname == "window")
		{
			if(!self.goalentity.box1owner)
			{
				//self.used = WBOX1;
				self.goalentity.box1owner = self;
				self.goalorigin = self.goalentity.box1;
				self.hop_step = 3;
				self.reload_delay = time + 30;
			}
			else 	if(!self.goalentity.box2owner)
			{
				//self.used = WBOX2;
				self.goalentity.box2owner = self;
				self.goalorigin = self.goalentity.box2;
				self.hop_step = 3;
				self.reload_delay = time + 30;
			}
			else 	if(!self.goalentity.box3owner)
			{
				//self.used = WBOX3;
				self.goalentity.box3owner = self;
				self.goalorigin = self.goalentity.box3;
				self.hop_step = 3;
				self.reload_delay = time + 30;
			}
			else if(vlen(self.origin - self.goalentity.origin) < 150)
			{	
				//we don't claim the idlebox
				//self.used = WIDLEBOX;
				self.goalorigin = self.goalentity.idlebox;
				self.hop_step = 1;
				self.reload_delay = time + 30;
			}
			//else we continue walking to window until we either find one that's good, or we are close enough to chase idle_spot
		}
	}
	else if(self.hop_step == 1)//walking to the window's idle location
	{
		if(nearby(self.goalorigin))
		{
			self.hop_step = 2;
			self.reload_delay = time + 30;
			self.th_idle();
		}
		else
		{
			walk_to_window(dist);
		}
	}
	else if(self.hop_step == 2)//we're at idle box, waiting for a window attack box to be free...
	{
		if(!self.goalentity.box1owner)
		{
			//self.used = WBOX1;
			self.goalentity.box1owner = self;
			self.goalorigin = self.goalentity.box1;
			self.hop_step = 3;
			self.reload_delay = time + 30;
			self.th_walk();
		}
		else if(!self.goalentity.box2owner)
		{
			//self.used = WBOX2;
			self.goalentity.box2owner = self;
			self.goalorigin = self.goalentity.box2;
			self.hop_step = 3;
			self.reload_delay = time + 30;
			self.th_walk();
		}
		else if(!self.goalentity.box3owner)
		{
			//self.used = WBOX3;
			self.goalentity.box3owner = self;
			self.goalorigin = self.goalentity.box3;
			self.hop_step = 3;
			self.reload_delay = time + 30;
			self.th_walk();
		}
	}
	else if(self.hop_step == 3)//walking to window attack box
	{
		if(nearby(self.goalorigin))
		{
			self.hop_step = 4;
			self.reload_delay = time + 30;
			self.th_idle();
		}
		else
		{
			walk_to_window(dist);
		}
	}
	else if(self.hop_step == 4)//attacking box
	{
		if(self.chase_time < time)
		{
			if(self.angles_z != self.goalentity.angles_z)
			{
				self.ideal_yaw = self.goalentity.angles_z;
				ChangeYaw();
				return;
			}
			if(self.goalentity.health > 0)
			{
				self.reload_delay = time + 30;
				self.th_melee();				
				if(rounds <= 5)
					self.chase_time = time + 1.5;
				else
					self.chase_time = time + 0.75;
				return;
			}
		}
		if(self.goalentity.health <= 0)
		{
			self.outside = 2;
			self.chase_time = 0;
			self.hop_step = 0;
		}
		else return;
	}
};


void(float dist) Window_Hop =
{
	if(self.hop_step == 0) {
		if(self.goalentity.box1owner == self) {//we're at center box.
			self.hop_step = 4;
		} else {
			self.hop_step = 1;//wait for box1 to be free so we can claim it and walk to it.
			self.th_idle();
		}
	}
	if(self.hop_step == 1) {//waiting idly for box1 to be free, when free, we will claim it.
		if(!self.goalentity.box1owner || self.goalentity.box1owner == self) {
			self.goalentity.box1owner = self;
			
			if(self.goalentity.box2owner == self)
				self.goalentity.box2owner = world;
			if(self.goalentity.box3owner == self)
				self.goalentity.box3owner = world;
				
			//self.used = WBOX1;
			
			self.goalorigin = self.goalentity.box1;
			self.hop_step = 2;
			self.th_walk();
		}
	}
	if(self.hop_step == 2) {//we've claimed it, walk to box1
		if(nearby(self.goalorigin)) {
			self.hop_step = 4;
			self.angles = self.goalentity.angles;
		} else {
			walk_to_window(dist);
		}
	}
	
	if(self.hop_step == 4 && self.chase_time < time) {//we're at this step because we already own box1, so don't even check if window is busy...
		if(!self.goalentity.usedent) {
			self.hop_step = 5;
			self.angles = self.goalentity.angles;
			self.goalentity.box1owner = world;//free box1
			self.goalentity.usedent = self;//we own the window
			//don't need to set goalorigin here
			//self.used = WWINDOW;
			self.chase_time = 0;
			self.th_windowhop();
			return;
		} else {
			self.tries++;
			self.chase_time = time + 0.2;
			if(self.tries > 10) {
				self.goalentity.usedent = world;//free up the window if we've been waiting to hop
			}
		}
	}
	
	if(self.hop_step == 6) {
		self.outside = FALSE;
		self.goalentity.usedent = world;//free up the window, we're done hopping it
		//self.used = 0;
		self.goalentity = world;
		self.enemy = find_new_enemy(self);
		//self.th_die();
		self.th_walk();
	}
}

void() PathfindToEnemy =
{
	//Navmesh usage
	float result = sv_navmesh_pathfind(self,self.enemy);
	
	if(result == 1)
	{
		self.chase_time = time + 7;
		setorigin(self.goaldummy,sv_zombie_pathfind_result[self.index].result_path[0]);
		self.goalentity = self.goaldummy;
		
		//Check if we are extremely close to goaldummy already
		//if so, move goaldummy to the next point in the path
		//FIXME: need to verify that this solves the problem
		if(vlen(self.origin - self.goaldummy.origin) < 2 && sv_zombie_pathfind_result[self.index].result_length > 1)
		{
			print("Already at goal 1 after pathfinding, advancing to goal 2\n");
			//setorigin(self.goaldummy,sv_zombie_pathfind_result[self.index].result_path[1]);
		}
		
	}
	//else
	//{
		//bprint(PRINT_HIGH, "Pathfind failure.\n");
	//}
	
	
	//Waypoint usage
	/*
	float pathresult;
	pathresult = Do_Pathfind(self,self.enemy);
	self.way_cur = 0;
	if(pathresult != -1)
	{
		//self.goaldummy.origin = Get_First_Waypoint(self,self.origin,VEC_HULL_MIN,VEC_HULL_MAX);
		self.goalway = pathresult;
		setorigin(self.goaldummy,waypoints[self.goalway].org);
		self.goalentity = self.goaldummy;
		self.chase_time = time + 7;
	}
	else if(self.goalway == -1)
	{
		self.goalentity = self.enemy;
		self.chase_time = time + 6;
	}
	else
	{
		bprint(PRINT_HIGH, "FirstPathfind Failure\n");
	}*/
	
	
}

void() NextPathfindToEnemy {
	self.way_cur++;

	if (self.way_cur < 40 && self.way_path[self.way_cur] != -1) {
		self.goalway = self.way_path[self.way_cur];
		setorigin(self.goaldummy,waypoints[self.goalway-1].org);
	} else {
		self.way_cur = 0;
	}
}

//
float(vector start, vector min, vector max, vector end, float nomonsters, entity forent) tracemove
{
	//was tracebox
	traceline(start,end,nomonsters,forent);
	
	if(trace_ent == forent || trace_endpos == end) {
		return 1;
	} else {	
		return 0;	
	}		
}

float() TryWalkToEnemy =
{
	//was tracebox
	float TraceResult;
	TraceResult = tracemove(self.origin,VEC_HULL_MIN,VEC_HULL_MAX,self.enemy.origin,TRUE,self);
	if(TraceResult == 1) {
		self.goalentity = self.enemy;
		self.chase_time = time + 7;
		return 1;
	} else {	
		return 0;	
	}		
};


void(float dist) Inside_Walk = 
{
	if(self.enemy_timeout < time || self.enemy == world) {
		self.enemy_timeout = time + 5;
		local entity oldEnemy;
		oldEnemy = self.enemy;
		self.enemy = find_new_enemy(self);
	}
	//================Check for proximity to player ===========
	if(vlen(self.enemy.origin - self.origin) < 60) {
		if(self.enemy.classname == "monkey") {
			self.th_idle();
		}
		
		if(self.attack_delay < time) {
			self.attack_delay = time + 1 + (1 * random());
			self.th_melee();  
			self.goalentity = self.enemy;
			self.chase_time = time + 5;
		}
		return;
	}
	
	
	PathfindToEnemy();
	/*
	if(vlen(self.enemy.origin - self.origin) < 600) {//50 feet
		if(self.goalentity == self.enemy && self.chase_enemy_time > time) {
			return;
		}
		if(TryWalkToEnemy())
		{
			self.chase_enemy_time = time + 0.5;
			return;
		}
	}

	if(self.goalentity == self.enemy) {
		self.goalentity = self.goaldummy;
		self.chase_time = 0;
	}
	//============= No Target ====================
	if(self.goalentity == world) {//not sure when this would ever occur... but whatever.
		self.goalentity = self.goaldummy;
	}
	//============ GoalDummy is Target ============
	if(self.goalentity == self.goaldummy) {
		if(nearby(self.goaldummy.origin)) {
			PathfindToEnemy();
		}

		if(self.chase_time < time) {
			if(self.goaldummy.origin != world.origin && tracemove(self.origin,VEC_HULL_MIN,VEC_HULL_MAX,self.goalentity.origin,TRUE,self) == 1) {
				self.chase_time = time + 7;
			} else {
				PathfindToEnemy();
			}
		}
	}*/
}

.float droptime;
void(float dist) Zombie_Walk =  
{
	//Resetting velocity from last frame (except for vertical)
	self.velocity_x = 0;
	self.velocity_y = 0;
	//self.flags = self.flags | FL_PARTIALGROUND;

	//check_onfire();
	if (!(self.flags & FL_ONGROUND)) 
	{

		if (!self.droptime) 
		{
			self.droptime = time + 1;
		} 
		else if (self.droptime < time) 
		{
			self.droptime = 0;
			//bprint(PRINT_HIGH, "not on ground\n");
			self.th_fall();
			return;
		}
	}
	
	if(self.outside == TRUE) 
	{
		//handle special walk case for walking to org
		Window_Walk(dist);
		return;
	}
	
	if(self.outside == 2) 
	{
		//play_sound_z(2);
		Window_Hop(dist);
		//handle special walk case for walking to org
		return;
	}
	if(self.outside == FALSE) 
	{
		if(self.goalentity == self.enemy) 
		{
			if(vlen(self.origin - self.enemy.origin) < 60) 
			{
				return;
			}
		}
	}
	do_walk(dist);
}


void() Zombie_AI = 
{	
	//dist = 0;
	float dist = 0;
	self.flags = self.flags | FL_PARTIALGROUND;
	//check_onfire();
	
	if(self.outside == TRUE) 
	{
		play_sound_z(2);
		//self.calc_time = time + (0.3 * random());
		//Window_Walk(dist);
		return;
	} else if(self.outside == 2)
	{
		play_sound_z(2);
		//Window_Hop(0);
		return;
	} else if(self.outside == FALSE) 
	{
		play_sound_z(2);
		//self.calc_time = time + (0.25 + (0.15 * random()));
		Inside_Walk(dist);
	}
}

//This function ensures that only one zombie's ai is done at a time, brings down lag significantly
void() Do_Zombie_AI = 
{
	local entity z;
	
	z = find(lastzombie,aistatus,"1");
	if(z == world) 
	{
		z = find(world,aistatus,"1");
		if(z == world) 
		{
			return;//no zombies alive.
		}
	}
	local entity oself;	
	oself = self;
	self = z;
	//if(z.classname == "ai_zombie")//removed because only zombies atm
	Zombie_AI();
	self = oself;
	lastzombie = z;
}