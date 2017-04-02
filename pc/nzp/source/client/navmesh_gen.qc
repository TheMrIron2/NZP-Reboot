
/*
#define NAV_MAX_SELECTED_VERTS 4
float selected_verts[NAV_MAX_SELECTED_VERTS];
float selected_vert_count;

navmesh_vertex cl_navmesh_verts[NAV_MAX_VERTS];
float cl_navmesh_vert_count;

navmesh_poly cl_navmesh_polies[NAV_MAX_POLIES];
float cl_navmesh_poly_count;


*/

//==========================================================================================
//			Temporary Structs Used for Navmesh Generation
//==========================================================================================

//For vertices, we're going to use a doubley linked list, with references to left / right vertices
//There's going to be a lot of insertion / deletion, linked list is ideal for this
struct navgen_vertex
{
	vector pos;
	//Pointer to prev navgen_vertex in global linked list
	navgen_vertex* prev;
	//Pointer to next navgen_vertex in global linked list
	navgen_vertex* next;
	
	//Vertex's left edge
	navgen_vertex* left;
	//Vertex's right edge
	navgen_vertex* right;
};

//Root node in linked list, where all insertions occur at
navgen_vertex* navgen_verts_root;

//Allocates a new vertex and inserts it into the linked list at root
navgen_vertex* cl_navgen_new_vert(vector pos)
{
	navgen_vertex* new_vert = memalloc(sizeof(navgen_vertex));
	
	new_vert->pos[0] = pos[0];
	new_vert->pos[1] = pos[1];
	new_vert->pos[2] = pos[2];
	
	new_vert->left = 0;
	new_vert->right = 0;
	new_vert->next = navgen_verts_root;
	if(navgen_verts_root)
	{
		navgen_verts_root->prev= new_vert;
	}
	new_vert->prev = 0;
	navgen_verts_root = new_vert;
	return new_vert;
}

//Removes and frees a vertex from the global vertex linked list
//This does not handle updating left/right vertex references, that depends on how / why we are deleting this vertex
void cl_navgen_free_vert(navgen_vertex* vert)
{
	if(!vert)
	{
		print("Warning: tried freeing a null vertex.\n");
		return;
	}
	
	if(vert->prev)
		(vert->prev)->next = vert->next;
	if(vert->next)
		(vert->next)->prev = vert->prev;
	
	//If this vert is root, update root
	if(navgen_verts_root == vert)
		navgen_verts_root = vert->next;
	
	memfree(vert);
}
//TODO: function for deleting a vertex from the list


void cl_navmesh_render_vert(navgen_vertex* vert)
{
	cl_navmesh_draw_vert(vert->pos,0);
}

void cl_navmesh_render_edge(navgen_vertex* from, navgen_vertex* to)
{
	cl_navmesh_draw_edge(from->pos, to->pos);
}

//A TEMP DEBUG METHOD THAT RENDERS INTERMEDIATE NAVMESH GENERATION RESULTS
void cl_navmesh_render_gen()
{
	navgen_vertex* vert = navgen_verts_root;
	
	while(vert)
	{
		cl_navmesh_render_vert(vert);
		if(vert->left)
			cl_navmesh_render_edge(vert,vert->left);
		if(vert->right)
			cl_navmesh_render_edge(vert,vert->right);
		
		//This will draw double edges, but this only really for debug, so it doesn't matter
		
		vert = vert->next;
	}
}

//Given starting position and edge tangent, walk along the edge until we hit some form of a corner
float cl_navgen_gen_walkalongedge(vector start, vector edge_tan)
{
	//FIXME: implement this
	return 0;
}

//Method that checks if pos + ofs is okay to walk
//returns 2 if walk is success
//returns 1 if walk was partial
//returns 0 if walk failed completely
float cl_navgen_gen_walk(vector start,vector ofs)
{
	float max_step_size = 18;//max stair step size pulled straight from engine defs
	
	//FIXME: fix this when we handle sliding along ledges
	//========================================================================================
	//for now, consider not on ground as a dead stop
	tracebox(start - [0,0,1],VEC_HULL_MIN,VEC_HULL_MAX,start-[0,0,max_step_size],MOVE_NOMONSTERS,self);
	if(!trace_allsolid && !trace_startsolid)
	{
		trace_endpos = start;
		return 0;
	}
	//========================================================================================
	
	//Assuming we are on the ground
	
	//float max_slope = 10.4;//18/tan(60) = 10.4, the length of the triangle formed by the max walkable slope of 60 degrees, and the max step height
	
	vector goal_org;
	
	vector delta_org;
	
	//0 means did not walk at all, 1 means we slid, 2 means we completed the move in x/y axis
	float success[2] = {0,0};
	
	//Iterate over x-axis then y-axis
	for(float i = 0; i < 2; i++)
	{
		
		delta_org = [0,0,0];
		delta_org[i] = ofs[i];
		
		goal_org = start + delta_org;
	
		//Push down from a step above goal org to find result position
		
		vector above_goal = goal_org + [0,0,max_step_size];
		vector below_goal = goal_org - [0,0,max_step_size];
		
		tracebox(above_goal,VEC_HULL_MIN,VEC_HULL_MAX,below_goal,MOVE_NOMONSTERS,self);
		
		if(trace_allsolid || trace_startsolid)
		{
			tracebox(goal_org,VEC_HULL_MIN,VEC_HULL_MAX,below_goal,MOVE_NOMONSTERS,self);
			if(trace_allsolid || trace_startsolid)
			{
				//Hit a wall
				success[i] = 0;
				
				//Try straight tracebox to wall
				tracebox(start,VEC_HULL_MIN,VEC_HULL_MAX,goal_org,MOVE_NOMONSTERS,self);
				
				if(trace_fraction > 0)
				{
					//We still moved on this move
					success[i] = 1;
					start = trace_endpos;
				}
				
				continue;
			}
		}
		
		if(trace_fraction >= 1)
		{
			//We walked off of a ledge
			
			//Try straight tracebox back to the ledge from the lowered goal polsition
			tracebox(below_goal,VEC_HULL_MIN,VEC_HULL_MAX,below_goal-delta_org,MOVE_NOMONSTERS,self);
			
			start_x = trace_endpos_x;
			start_y = trace_endpos_y;
			start_z = trace_endpos_z + max_step_size;//don't lower the start_z
			
			//TODO: slide along the ledge until we hit a ledge corner
			
			success[i] = 1;
			
			//We are no longer on the gorund
			continue;
		}
		
		if(delta_org[i] != 0)
			success[i] = 1;
		start_x = trace_endpos_x;
		start_y = trace_endpos_y;
		start_z = trace_endpos_z;
		//We are on the ground
	}

	//Assign trace end pos as where we ended up
	trace_endpos_x = start_x;
	trace_endpos_y = start_y;
	trace_endpos_z = start_z;


	if(success[0] == success[1])
	{
		return success[0];
	}
	return 1;
}

//Walks to x & y coordinate of point, returns vector of how far we got
//We walk in dist increments
vector cl_navgen_gen_walk_to_point(vector start, vector point)
{
	/*float dist = 3;
	
	vector cur = start;
	vector cur_ofs = normalize(point - cur) * dist;
	float move;
	while(1)
	{
		move = cl_navgen_gen_walk(cur,cur_ofs);
		if(move == 0)
			return start;
			
		start = trace_endpos;
		
		if(
		
		start
	}
	return start;*/
	//TODO: implement method that walks from start to a point until the x & y coordinates match
	//use this to get midpoint of an edge (where the midpoint)
}


void cl_navgen_gen_floodfill(navgen_vertex* vert)
{	
	//Incrementally move vertex away from it's edges until stop or our edges are obstructed
	//calculate direction from edges
	
	vector walk_dir = [0,0,0]; //take line tangent to line normalize(vert->right->pos - vert->left->pos)
	
	float walk_dist = 3;//how many qu to walk at each step
	
	//Calculating walk_dir
	//===========================
	vector tangent = ((vert->right)->pos - (vert->left)->pos);
	//Don't care about z-difference
	tangent_z = 0;
	tangent = normalize(tangent);
	
	//Getting edge normal
	walk_dir[0] = -tangent[1];
	walk_dir[1] = tangent[0];
	walk_dir *= walk_dist;
	
	//if walk_dir is zero vector, something is horribly wrong
	if(walk_dir == [0,0,0])
	{
		print("Navmesh generation Error: walk_dir is zero vector for vert at pos: ",vtos(vert->pos)," with edges ");
		if(vert->left) 
			print("L: ",vtos((vert->left)->pos));
		else
			print("L: null");
		if(vert->right)
			print(" R: ",vtos((vert->right)->pos));
		else
			print(" R: null");
		print("\n");
		return;
	}
	//===========================
	
	float did_move = 0;
	
	float move;
	
	print("Walk dir: ",vtos(walk_dir),"\n");
	
	//walk the vertex in the direction a small amount
	while(1)
	{
		//Try walking a small amount forward
		move = cl_navgen_gen_walk(vert->pos,walk_dir);
		
		vert->pos = trace_endpos;
		
		print("Move result: ",ftos(move),"\n");
		if(!move && !did_move)
		{
			
			break;
		}
		did_move = 1;
		
		
		//check if left edge is obstructed
		//if(left edge is obstructed)
		//	break;
		
		//check if right edge is obstructed
		//if(right edge is obstructed)
		//	break;
		
		//check if we intersected with any other vertex edge
			//walk along the edge and see if we hit one of the verts
		//check if we hit any other vertex
		
		//Check if we moved but hit a dead end without obstruction
		if(!move)
		{
			//=========================
			//Subdivide left edge
			//=========================
			vector edge_center = (vert->pos + (vert->left)->pos)/2;
			//FIXME: THIS CAN GO HORRIBLY WRONG
			//TODO: walk along edge until we get to the center point
			//Drop to floor
			//FIXME: for now, just drop to floor (assuming edge midpoint is a step height above the floor (and head is not in ceiling)
			cl_navgen_gen_walk(edge_center,[0,0,0]);
			edge_center = trace_endpos;
			
			navgen_vertex* new_vert = cl_navgen_new_vert(edge_center);
			new_vert->left = vert->left;
			(vert->left)->right = new_vert;
			new_vert->right = vert;
			vert->left = new_vert;
			cl_navgen_gen_floodfill(new_vert);
			
			//=========================
			//Subdivide right edge
			//=========================
			edge_center = (vert->pos + (vert->right)->pos)/2;
			//FIXME: THIS CAN GO HORRIBLY WRONG
			//TODO: walk along edge until we get to the center point
			//Drop to floor
			//FIXME: for now, just drop to floor (assuming edge midpoint is a step height above the floor (and head is not in ceiling)
			cl_navgen_gen_walk(edge_center,[0,0,0]);
			edge_center = trace_endpos;
			
			new_vert = cl_navgen_new_vert(edge_center);
			new_vert->right = vert->right;
			(vert->right)->left = new_vert;
			new_vert->left = vert;
			vert->right = new_vert;
			cl_navgen_gen_floodfill(new_vert);
			
			break;
		}
	}
	
	if(!did_move)
		return;
		
	//Call cl_navgen_gen_floodfill on left and right verts
	
	//if left / right edge was obstructed
		//regress to last unobstructed position
		//hone in on corner position,
		//etc...
}



void cl_navmesh_gen_navmesh()
{
	//TODO: create 3 vertices in a triangle at player position, call floodfill on all 3
	
	//navgen_verts_root = 0;
	
	vector player_pos = getentity(player_localentnum, GE_ORIGIN);
	
	//Find floor at pos
	cl_navgen_gen_walk(player_pos,[0,0,0]);
	player_pos = trace_endpos;
	
	float initial_tri_size = 10;
	
	//TODO: tracebox down from above player pos to get actual floor position
	navgen_vertex* v1 = cl_navgen_new_vert(player_pos + [0,initial_tri_size,0]);
	navgen_vertex* v2 = cl_navgen_new_vert(player_pos + [-initial_tri_size,-initial_tri_size,0]);
	navgen_vertex* v3 = cl_navgen_new_vert(player_pos + [initial_tri_size,-initial_tri_size,0]);
	
	v1->left = v2;
	v1->right = v3;
	
	v2->right = v1;
	v2->left = v3;
	
	v3->left = v1;
	v3->right = v2;
	
	
	cl_navgen_gen_floodfill(v1);
	

	
}
/*	
	//vector vorg = getviewprop(VF_ORIGIN);
	//vector vorg = getentity(player_localentnum, GE_ORIGIN);
	
	//recursive_flood_fill(vorg + [0,0,10],32);
	
		
		
		/*vector vorg = getviewprop(VF_ORIGIN);
		vector vang = getviewprop(VF_ANGLES);
	
		vector vang_left1 = vang + [0,6,0];//Two degrees to the left
		vector vang_left2 = vang + [0,5,0];//Three degrees to the left
		vector vang_right1 = vang + [0,-6,0];//Two degrees to the right
		vector vang_right2 = vang + [0,-5,0];//Three degrees to the right
		
		makevectors(vang);
		vector vang_fwd = v_forward;
		
		
		
		tracebox(vert_loc,VEC_HULL_MIN,VEC_HULL_MAX,vert_loc+([0,0,-1] * 2000),1,self);
		vert_loc.z = vert_loc.z + (-2000 * trace_fraction);
		
		
		//================================================================================
		
		//Render the resolved vertex pos
		cl_navmesh_draw_vert(vert_loc, 1 );
			
		if(cl_navmesh_place_corner_state == NAVMESH_PLACE_CORNER_CONFIRM)
		{	
			cl_navmesh_verts[cl_navmesh_vert_count].pos.x = vert_loc.x;
			cl_navmesh_verts[cl_navmesh_vert_count].pos.y = vert_loc.y;
			cl_navmesh_verts[cl_navmesh_vert_count].pos.z = vert_loc.z;
			
			cl_navmesh_vert_count++;
			
			cl_navmesh_place_corner_state = 0;
		}
		*/
		//======================================================================*/

//==========================================================================================================================
//returns 0 if a vertex exists within dist of pos
float vert_exists(vector pos,float dist)
{
	for(float i = 0; i < cl_navmesh_vert_count; i++)
	{
		for(float j = 0; j < 3; j++)
		{
			if(fabs(cl_navmesh_verts[i].pos[j] - pos[j]) >= dist)
			{
				break;
			}
			
			if(j >= 2)
				return 1;
		}
	}
	return 0;
}

//====================================================================================================================================
//============================================ Testing navmesh generation ============================================================
//====================================================================================================================================


//Duplicate of ai_physics_movement, but does the move in x-axis first then y-axis (for sliding along walls, etc)
/*
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

//TODO: change these methods to not actually move an entity, but to just check whether a move is possible (following these rules)
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
	//Lerping z-height:
	self.origin_z += 0.05*(self.true_org_z - self.origin_z);
	
	setorigin(self, self.origin);
	

	self.flags |= FL_ONGROUND;
	//=======================================================================================================================================
};

//====================================================================================================================================
//============================================== End navmesh generation test =========================================================
//====================================================================================================================================

float trace_move(vector start, vector mins, vector maxs, vector end)
{
	
}

void recursive_flood_fill(vector where, float dist)
{
	if(cl_navmesh_vert_count >= 512)
	{
		print("Warning: ran out of vertices");
		return;
	}
	cl_navmesh_verts[cl_navmesh_vert_count++].pos = where;
	//dist is how far in the 4 directions we flood fill (sort of like resolution)
	
	//Try forward
	vector delta = [0,dist,0];
	
	tracebox(where,VEC_HULL_MIN,VEC_HULL_MAX,where + delta,MOVE_NOMONSTERS,self);
	if(trace_fraction >= 1 && !trace_allsolid && !trace_startsolid)
	{
		if(vert_exists(where + delta, dist) == 0)
		{
			recursive_flood_fill(where+delta,dist);
		}
	}
	
	//Try back
	delta = [0,-dist,0];
	
	tracebox(where,VEC_HULL_MIN,VEC_HULL_MAX,where + delta,MOVE_NOMONSTERS,self);
	if(trace_fraction >= 1 && !trace_allsolid && !trace_startsolid)
	{
		if(vert_exists(where + delta, dist) == 0)
		{
			
			recursive_flood_fill(where+delta,dist);
		}
	}
	
	//Try left
	delta = [-dist,0,0];
	
	tracebox(where,VEC_HULL_MIN,VEC_HULL_MAX,where + delta,MOVE_NOMONSTERS,self);
	if(trace_fraction >= 1 && !trace_allsolid && !trace_startsolid)
	{
		if(vert_exists(where + delta, dist) == 0)
		{
			
			recursive_flood_fill(where+delta,dist);
		}
	}
	
	//Try right
	delta = [dist,0,0];
	
	tracebox(where,VEC_HULL_MIN,VEC_HULL_MAX,where + delta,MOVE_NOMONSTERS,self);
	if(trace_fraction >= 1 && !trace_allsolid && !trace_startsolid)
	{
		if(vert_exists(where + delta, dist) == 0)
		{
			
			recursive_flood_fill(where+delta,dist);
		}
	}
}*/
