
/*
#define NAV_MAX_SELECTED_VERTS 4
float selected_verts[NAV_MAX_SELECTED_VERTS];
float selected_vert_count;

navmesh_vertex cl_navmesh_verts[NAV_MAX_VERTS];
float cl_navmesh_vert_count;

navmesh_poly cl_navmesh_polies[NAV_MAX_POLIES];
float cl_navmesh_poly_count;

*/

float debug_moreinfo;

//Vector assignment function, because fteqcc seems to have a broken vec1 = vec2; implementation (works only sometimes)
//Functionally equivalent to saying (*a)=b;
void vec_eq(vector* a, vector b)
{	
	a[0][0]=b[0];
	a[0][1]=b[1];
	a[0][2]=b[2];
}


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
	
	vec_eq(&(new_vert->pos),pos);
	
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

//FOR DEBUG
#define MAX_DEBUG_HULL_COUNT 200
vector debug_hulls[MAX_DEBUG_HULL_COUNT];
vector debug_hull_scales[MAX_DEBUG_HULL_COUNT];
vector debug_hull_colors[MAX_DEBUG_HULL_COUNT];
float debug_hull_alphas[MAX_DEBUG_HULL_COUNT];

float debug_hull_count;

void add_debug_hull(vector pos, vector scale, vector color, float alpha)
{
	//if(debug_hull_count >= MAX_DEBUG_HULL_COUNT)
	//	return;
	debug_hulls[debug_hull_count % MAX_DEBUG_HULL_COUNT] = pos;
	debug_hull_scales[debug_hull_count % MAX_DEBUG_HULL_COUNT] = scale;
	debug_hull_colors[debug_hull_count % MAX_DEBUG_HULL_COUNT] = color;
	debug_hull_alphas[debug_hull_count++ % MAX_DEBUG_HULL_COUNT] = alpha;
}

void clear_debug_hulls()
{
	debug_hull_count = 0;
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

void cl_navgen_free_all_verts()
{
	while(navgen_verts_root)
	{
		cl_navgen_free_vert(navgen_verts_root);
	}
	
	debug_hull_count = 0;
}


void cl_navmesh_render_vert(navgen_vertex* vert)
{
	cl_navmesh_draw_vert(vert->pos,[0,0,1],0.4);
}


void cl_navmesh_render_point(vector pos,vector color, float alpha)
{
	cl_navmesh_draw_vert(pos,color,alpha);
}

void cl_navmesh_render_edge(navgen_vertex* from, navgen_vertex* to)
{
	cl_navmesh_draw_edge(from->pos, to->pos);
}


//TEMP TEMP TEMP TEMP FIXME FIXME FIXME FIXME

//These defs are for testing the navmesh find min algorithm
navgen_vertex* vert1;
navgen_vertex* vert3;
navgen_vertex* vert2;
navgen_vertex* mid1;
navgen_vertex* mid3;


vector debug_lines_pos1[200];
vector debug_lines_pos2[200];
vector debug_lines_color[200];
float debug_lines_count;


void add_debug_line(vector p1, vector p2, vector color)
{
	if(debug_lines_count >= 200)
		return;
	
	debug_lines_pos1[debug_lines_count] = p1;
	debug_lines_pos2[debug_lines_count] = p2;
	debug_lines_color[debug_lines_count++] = color;
}
void clear_debug_lines()
{
	debug_lines_count = 0;
}

//Adds lines from corners of a regular hull
void add_debug_hull_line(vector p1, vector p2, vector color)
{
	//min
	vector ofs;
	vec_eq(&ofs,[VEC_HULL_MIN_x, VEC_HULL_MIN_y,0]);
	add_debug_line(p1 + ofs, p2 + ofs, color);
	
	//min max
	vec_eq(&ofs,[VEC_HULL_MIN_x, VEC_HULL_MAX_y,0]);
	add_debug_line(p1 + ofs, p2 + ofs, color);
	
	//max min
	vec_eq(&ofs,[VEC_HULL_MAX_x, VEC_HULL_MIN_y,0]);
	add_debug_line(p1 + ofs, p2 + ofs, color);
	
	//max max
	vec_eq(&ofs,[VEC_HULL_MAX_x, VEC_HULL_MAX_y,0]);
	add_debug_line(p1 + ofs, p2 + ofs, color);
}


//FIXME: remove these
float(vector start,vector ofs) cl_navgen_gen_walk;
float(vector start,vector ofs) cl_navgen_gen_direct_walk;
void(vector pos) cl_navgen_gen_drop_to_floor;

float debug_direct_walk;

//FIXME FIXME FIXME FIXME


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
	
	//Drawing debug collision hulls
	for(float i = 0; i < ((debug_hull_count < MAX_DEBUG_HULL_COUNT) ? debug_hull_count : MAX_DEBUG_HULL_COUNT); i++)
	{
		cl_navmesh_draw_test_ent(debug_hulls[i],debug_hull_scales[i],debug_hull_colors[i],debug_hull_alphas[i]);
	}
	
	//FIXME FIXME FIXME FIXME
	//For drawing the find min test algorithm
	if(vert1)
	{
		cl_navmesh_render_vert(vert1);
		if(vert1->left)
			cl_navmesh_render_edge(vert1,vert1->left);
		if(vert1->right)
			cl_navmesh_render_edge(vert1,vert1->right);
	}
	if(vert3)
	{
		cl_navmesh_render_vert(vert3);
		if(vert3->left)
			cl_navmesh_render_edge(vert3,vert3->left);
		if(vert3->right)
			cl_navmesh_render_edge(vert3,vert3->right);
	}
	if(vert2)
	{
		cl_navmesh_render_vert(vert2);
		if(vert2->left)
			cl_navmesh_render_edge(vert2,vert2->left);
		if(vert2->right)
			cl_navmesh_render_edge(vert2,vert2->right);
	}
	if(mid1)
		cl_navmesh_render_point(mid1->pos,[1,1,0],0.4);
	if(mid3)
		cl_navmesh_render_point(mid3->pos,[1,0,1],0.4);
		
	for(float j = 0; j < debug_lines_count; j++)
	{
		cl_navmesh_draw_line(debug_lines_pos1[j],debug_lines_pos2[j],2,debug_lines_color[j],0.2);
	}	
}

//Given starting position and edge tangent, walk along the edge until we hit some form of a corner
float cl_navgen_gen_walkalongedge(vector start, vector edge_tan)
{
	//FIXME: implement this
	return 0;
}



//For temporarily not continuing the recursion
float recursive_depth;
float disable_print;


//Assumes that the position given is very close to the floor, but might be too low or might be a bit too high
//(this is used for getting the player position, because player position from engine appears to be ofset by some tiny amount)
//Assigns trace_endpos as the position on the floor 
void cl_navgen_gen_drop_to_floor(vector pos)
{
	float max_step_height = 18;
	
	float iters = 0;
	
	float height = max_step_height;
	
	trace_startsolid = 1;
	
	while(trace_startsolid || trace_allsolid)
	{
		if(iters++ > 9998)
		{
			print("Warning: navgen drop to floor iters exceeded 9998\n");
			
			vec_eq(&trace_endpos, pos);
			return;
		}
		
		//If this is true, we are underneath a very low hanging ceiling (practically touching top of bbox), there is something wrong with this.
		if(height < 0.01)
		{
			vec_eq(&trace_endpos, pos);
			return;
		}
		
		//Try tracebox from +height to -max_step_height
		
		tracebox(pos + [0,0,height], VEC_HULL_MIN, VEC_HULL_MAX, pos - [0,0,max_step_height],MOVE_NOMONSTERS,self);
		
		if(trace_fraction > 0)
		{
			//trace_endpos is already the result
			return;
		}
		
		height = height * 0.5;
	}
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
	//tracebox(start - [0,0,1],VEC_HULL_MIN,VEC_HULL_MAX,start-[0,0,max_step_size],MOVE_NOMONSTERS,self);
	tracebox(start,VEC_HULL_MIN,VEC_HULL_MAX,start-[0,0,2*max_step_size],MOVE_NOMONSTERS,self);
	if((!trace_allsolid && !trace_startsolid) && trace_fraction > 0.5)
	{
		print("We are not on ground to begin, returning 0\n");
		print("\tTrace fraction: ",ftos(trace_fraction),"\n");
		print("\tstart solid: ",ftos(trace_startsolid)," all solid: ",ftos(trace_allsolid),"\n");
		
		add_debug_hull(start,[1,1,1],[1,0,1],0.05);
		
		vec_eq(&(trace_endpos),start);
		return 0;
	}
	
	//This is a problem for when we are checking left / right edges, because while walking the edge, we can never get to the vertex that
	//has been pushed off of a ledge
	//so, we must check for falling off of a ledge, but also 
	//========================================================================================
	
	//Assuming we are on the ground
	
	//float max_slope = 10.4;//18/tan(60) = 10.4, the length of the triangle formed by the max walkable slope of 60 degrees, and the max step height
	
	vector cur;
	vec_eq(&(cur),start);
	
	vector goal_org;
	
	vector delta_org;
	
	//0 means did not walk at all, 1 means we slid, 2 means we completed the move in x & y axis
	float success[2] = {0,0};
	
	//Iterate over x-axis then y-axis
	for(float i = 0; i < 2; i++)
	{
		
		delta_org = [0,0,0];
		
		delta_org[i] = ofs[i];
		
		vec_eq(&(goal_org),cur+delta_org);
	
		//Push down from a step above goal org to find result position
		
		vector above_goal;
		vec_eq(&above_goal,goal_org + [0,0,max_step_size]);
		vector below_goal;
		vec_eq(&below_goal, goal_org - [0,0,max_step_size]);
		
		tracebox(above_goal,VEC_HULL_MIN,VEC_HULL_MAX,below_goal,MOVE_NOMONSTERS,self);
		
		if(trace_allsolid || trace_startsolid)
		{
			tracebox(goal_org,VEC_HULL_MIN,VEC_HULL_MAX,below_goal,MOVE_NOMONSTERS,self);
			if(trace_allsolid || trace_startsolid)
			{
				//Hit a wall
				success[i] = 0;
				
				//Try straight tracebox to wall
				tracebox(cur,VEC_HULL_MIN,VEC_HULL_MAX,goal_org,MOVE_NOMONSTERS,self);
				
				if(trace_fraction > 0)
				{
					//We still moved on this move
					success[i] = 1;
					vec_eq(&(cur),trace_endpos);

				}
				
				continue;
			}
		}
		
		if(trace_fraction >= 1)
		{
			//We walked off of a ledge
			
			//Try straight tracebox back to the ledge from the lowered goal position
			tracebox(below_goal,VEC_HULL_MIN,VEC_HULL_MAX,below_goal-delta_org,MOVE_NOMONSTERS,self);
			
			vec_eq(&(cur),trace_endpos);
			cur_z += max_step_size;//don't lower the cur_z
			
			//cur should now be right up against the ledge, push back a tiny bit from the ledge so that we cannot fall
			vec_eq(&(cur),cur - 0.1*normalize(delta_org));

			
			//If we moved back to start, we were already on ledge, so we did not move on this axis
			if(vlen(cur - start) < 0.01)
				success[i] = 0;//treat this as hitting a dead end
			else
				success[i] = 2;

			//TODO: slide along the ledge until we hit a ledge corner
			
			//We are now just barely on a ledge
			
			continue;
		}
		
		success[i] = 2;
		
		//If this is a zero move and the other is not, our success depends entirely on the other move
		if(ofs[i] == 0 && ofs[(i+1)%2] != 0)
		{
			success[i] = -1;
		}
		
		vec_eq(&(cur),trace_endpos);

		//We are on the ground
	}

	//Assign trace end pos as where we ended up
	vec_eq(&(trace_endpos),cur);

	if(!disable_print)
		if(success[0] == 0 || success[0] == 0)
			print("Walk from: ",vtos(start), " to: ",vtos(start+ofs)," got to: ",vtos(cur),"\n");

	//If either move was a zero move, the success of the move depends on the other
	if(success[0] == -1)
		return success[1];
	if(success[1] == -1)
		return success[0];

	if(success[0] == success[1])
	{
		return success[0];
	}
	return 1;
}




//FIXME this is for debug
float debug_walk_to_point;


//Method that checks if pos + ofs is okay to walk
//returns 2 if walk is success
//returns 1 if walk was partial
//returns 0 if walk failed completely
//Assigns trace_endpos as the point along start -> start+ofs that we got to

//FIXME: direct walk steps down on some semi shallow ledges

float cl_navgen_gen_direct_walk(vector start,vector ofs)
{
	float max_step_size = 18;//max stair step pulled straight from engine defs
	float tan_60 = 1.73205080757;//tangent of 60 degrees (max walkable slope) (used to make sure we don't walk up a higher slope)
	
	//FIXME: fix this when we handle sliding along ledges
	//========================================================================================
	//for now, consider not on ground as a dead stop
	//tracebox(start - [0,0,1],VEC_HULL_MIN,VEC_HULL_MAX,start-[0,0,max_step_size],MOVE_NOMONSTERS,self);
	tracebox(start,VEC_HULL_MIN,VEC_HULL_MAX,start-[0,0,2*max_step_size],MOVE_NOMONSTERS,self);
	if((!trace_allsolid && !trace_startsolid) && trace_fraction > 0.5)
	{
		print("We are not on ground to begin, returning 0\n");
		print("\tTrace fraction: ",ftos(trace_fraction),"\n");
		print("\tstart solid: ",ftos(trace_startsolid)," all solid: ",ftos(trace_allsolid),"\n");
		
		add_debug_hull(start,[1,1,1],[1,0,1],0.05);
		
		if(debug_direct_walk)
			cl_navmesh_draw_test_ent(start,[1,1,1],[1,0,0],0.2);
		
		vec_eq(&(trace_endpos),start);
		return 0;
	}
	
	
	//This is a problem for when we are checking left / right edges, because while walking the edge, we can never get to the vertex that
	//has been pushed off of a ledge
	//so, we must check for falling off of a ledge, but also 
	//========================================================================================
	vector goal;
	vec_eq(&goal,start+ofs);
	
	float iters = 0;
	
	float step_up = 0;
	
	vector temp;
	vector cur;
	vector last_cur;
	vec_eq(&cur,start);
	vec_eq(&last_cur,start);
	
	vector last_ofs;
	
	float last_failed = 0;
	float cur_failed = 0;
	
	//Whether or not we moved at least a small amount (1 or 0)
	float moved_some_amount = 0;
	
	//for debugging
	float test_fraction = 0;
	
	//Alternate walking and stepping until we reach goal or hit a failure condition
	while(1)
	{
		if(iters == 9900)
		{
			//do nothing
			print("9900 iters\n");
		}
		if(iters++ > 9990)
		{
			print("Warning: runaway loop in navgen_direct_walk.\n");
			return 0;
		}
		
		
		if(!step_up)
		{
			//Try walking straight to goal
			tracebox(cur,VEC_HULL_MIN,VEC_HULL_MAX,goal,MOVE_NOMONSTERS,self);
	test_fraction = trace_fraction;
			vec_eq(&temp,trace_endpos);
			
			//Try a move with a step up next time
			step_up  = 1;
			
			//Get the vactor of the last move we did
			vec_eq(&last_ofs, trace_endpos - cur);
		}
		else
		{
			//Try walking to goal with a step up
			//tracebox up to see if we can move up
			tracebox(cur,VEC_HULL_MIN,VEC_HULL_MAX,cur+[0,0,max_step_size],MOVE_NOMONSTERS,self);
	test_fraction = trace_fraction;
			if(trace_fraction > 0.0001)
			{
				//Try a trace forward from that position
				
				//Copy the start tracebox position (will use it to get the vector of the move we did)
				vec_eq(&last_ofs, trace_endpos);
				
				tracebox(trace_endpos, VEC_HULL_MIN, VEC_HULL_MAX, [goal_x, goal_y, trace_endpos_z], MOVE_NOMONSTERS,self);
	test_fraction = trace_fraction;
				vec_eq(&temp,trace_endpos);
				
				//Get the vector of the last move we did
				vec_eq(&last_ofs, [goal_x, goal_y, trace_endpos_z] - last_ofs);
			}
			//Try a move without a step up next time
			step_up = 0;
		}
		
		//if we moved at least some amount:
		if(!trace_allsolid && !trace_startsolid && trace_fraction > 0.0001)
		{
			cur_failed = 0;
			vec_eq(&last_cur,cur);
			vec_eq(&cur,temp);
			moved_some_amount = 1;
			
			//Height before we consider having fallen
			float fall_height = vlen(last_ofs) * tan_60;
			
			//FIXME, this doesn't ensure that the step down is gradual, just that it's less than 60 derees
			
			//Don't let fall height be less than the max step size
			if(fall_height < max_step_size)
				fall_height = max_step_size;
			
			
			//Check if we fell at cur result position
			tracebox(cur,VEC_HULL_MIN,VEC_HULL_MAX,cur- [0,0,2*fall_height] ,MOVE_NOMONSTERS,self);
	test_fraction = trace_fraction;
			
			//If we moved at all
			if(!trace_allsolid && !trace_startsolid && trace_fraction > 0.0001)
			{		
				//Checking if we stepped down
				//If the angle between the move is greater than 60, we fell, otherwise we stepped down
				//if(vlen(trace_endpos - cur)/vlen(last_ofs) <= tan_60)
				if(trace_fraction <= 0.5)
				{
					//We stepped down
					vec_eq(&cur,trace_endpos);
				}
				//We fell down
				else
				{
					//getting back onto the ground
					//undo the last move from a lowered position
					tracebox(trace_endpos,VEC_HULL_MIN,VEC_HULL_MAX,[last_cur_x,last_cur_y,trace_endpos_z],MOVE_NOMONSTERS,self);
	test_fraction = trace_fraction;
					
					//FIXME: okay so we enter this block of code when on the stairs
					//add_debug_hull(trace_endpos,[1,1,1],[1,0,0],0.2);
					//then offset the position a tiny bit more and reset the z position back to normal
					vec_eq(&cur,trace_endpos - normalize(goal-start)*0.01);
					cur_z = last_cur_z;
					
					vec_eq(&trace_endpos, cur);
					
					//if we are now on ground, return 1, else return 0
					return 1;
				}
			}
		}
		
		//Check if we failed on this iteration and the last iteration
		if(last_failed && cur_failed)
		{
			return moved_some_amount;
		}
		
		//Check if we reached goal
		if(cur_x == goal_x && cur_y == goal_y)
		{
			if(debug_direct_walk)
				cl_navmesh_draw_test_ent(start,[1,1,1],[0,1,0],0.2);
		
			vec_eq(&trace_endpos, cur);
			return 2;
		}
		
		
		if(debug_direct_walk)
			cl_navmesh_draw_test_ent(cur,[1,1,1],[1,1,0],0.2);
		
		
		last_failed = cur_failed;
		cur_failed = 1;
	}
	
}



//Method that checks if pos + ofs is okay to walk
//returns 2 if walk is success
//returns 1 if walk was partial
//returns 0 if walk failed completely
float cl_old_navgen_gen_direct_walk(vector start,vector ofs)
{
	float max_step_size = 18;//max stair step size pulled straight from engine defs
	
	//FIXME: fix this when we handle sliding along ledges
	//========================================================================================
	//for now, consider not on ground as a dead stop
	//tracebox(start - [0,0,1],VEC_HULL_MIN,VEC_HULL_MAX,start-[0,0,max_step_size],MOVE_NOMONSTERS,self);
	tracebox(start,VEC_HULL_MIN,VEC_HULL_MAX,start-[0,0,2*max_step_size],MOVE_NOMONSTERS,self);
	if((!trace_allsolid && !trace_startsolid) && trace_fraction > 0.5)
	{
		print("We are not on ground to begin, returning 0\n");
		print("\tTrace fraction: ",ftos(trace_fraction),"\n");
		print("\tstart solid: ",ftos(trace_startsolid)," all solid: ",ftos(trace_allsolid),"\n");
		
		add_debug_hull(start,[1,1,1],[1,0,1],0.05);
		
		vec_eq(&(trace_endpos),start);
		return 0;
	}
	
	//This is a problem for when we are checking left / right edges, because while walking the edge, we can never get to the vertex that
	//has been pushed off of a ledge
	//so, we must check for falling off of a ledge, but also 
	//========================================================================================
	
	//Assuming we are on the ground
	
	//float max_slope = 10.4;//18/tan(60) = 10.4, the length of the triangle formed by the max walkable slope of 60 degrees, and the max step height
	
	vector cur;
	vec_eq(&(cur),start);
	
	vector goal_org;

	//Perform both x and y axis moves in one go
	vec_eq(&(goal_org),cur+ofs);
	
	//Push down from a step above goal org to find result position
		
	vector above_goal;
	vec_eq(&above_goal, goal_org + [0,0,max_step_size]);
	vector below_goal;
	vec_eq(&below_goal, goal_org - [0,0,max_step_size]);
	
	tracebox(above_goal,VEC_HULL_MIN,VEC_HULL_MAX,below_goal,MOVE_NOMONSTERS,self);
	
	if(!disable_print)
		print("direct walk ",vtos(start)," -> ",vtos(start+ofs),"\n");
	
	if(trace_allsolid || trace_startsolid)
	{
		if(!disable_print)
			print("\tfirst trace at ",vtos(above_goal)," -> ",vtos(below_goal)," was allsolid or startsolid\n");
		
		vec_eq(&trace_endpos,start);
		return 0;
		//Direct walk should not try traceboxing directly to the wall
		//We either walked to start + ofs, or we did not.
		
		/*tracebox(goal_org,VEC_HULL_MIN,VEC_HULL_MAX,below_goal,MOVE_NOMONSTERS,self);
		if(trace_allsolid || trace_startsolid)
		{
			if(!disable_print)
				print("\tsecond trace at ",vtos(goal_org)," -> ",vtos(below_goal)," was allsolid or startsolid\n");
			//Hit a wall
				
			//Try straight tracebox to wall
			tracebox(cur,VEC_HULL_MIN,VEC_HULL_MAX,goal_org,MOVE_NOMONSTERS,self);
			
			if(trace_fraction > 0)
			{
				if(!disable_print)
					print("\thit a wall, but we traced to wall. fraction: ",ftos(trace_fraction)," endpos ",vtos(trace_endpos),"\n");
				//We still moved on this move
				//trace_endpos already holds the result value
				if(debug_walk_to_point)
					print("  [hit but traced to wall]  \n");
				return 2;
			}
			
			if(!disable_print)
				print("failed tracebox straight to wall\n");
			
			vec_eq(&trace_endpos,start);
			return 0;
		}*/
	}
	if(trace_fraction >= 1)
	{
		//We walked off of a ledge
		
		//Try straight tracebox back to the ledge from the lowered goal position
		tracebox(below_goal,VEC_HULL_MIN,VEC_HULL_MAX,below_goal-ofs,MOVE_NOMONSTERS,self);
		
		
		trace_endpos_z += max_step_size;//don't lower the cur_z
		
		//cur should now be right up against the ledge, push back a tiny bit from the ledge so that we cannot fall
		vec_eq(&(trace_endpos),trace_endpos - 0.1*normalize(ofs));
		
		if(!disable_print)
			print("\twalked off a ledge at ",vtos(above_goal)," -> ",vtos(below_goal),"\n");

		//If we moved back to start, we were already on ledge, so we did not move
		if(vlen(cur - start) < 0.01)
		{
			if(!disable_print)
				print("\ttracebox back to onledge pos was small\n");
			return 0;//treat this as hitting a dead end
		}
		
		if(!disable_print)
			print("\twalked back onto ledge at ",vtos(trace_endpos),"\n");
		
		return 2;			

		//TODO: slide along the ledge until we hit a ledge corner		
		//We are now just barely on a ledge
	}
	
	if(debug_walk_to_point)
		print("  [walked straight to point]  \n");
	
	//trace_endpos already holds result position
	return 2;
}



//Returns the length of the x & y components of this vector
float xy_vlen(vector v)
{
	return vlen([v_x,v_y,0]);
}


string walk_percent(vector start, vector cur, vector goal)
{
	return ftos(xy_vlen(cur-start) / xy_vlen(goal-start));
}
//FIXME: remove the stuff above

//Walks to x & y coordinate of point
//We walk in dist increments, and assume we are unobstructed
//Returns 1 if successful, 0 otherwise
//Assigns the trace_endpos as the actual point we got to (as z-coordinate may be different)
float cl_navgen_gen_walk_to_point(vector start, vector point)
{
	float dist = 1;
	
	//dilemma, if dist is too small, we can introduce errors
	//I need a new form of calculating things.
	//maybe my old method of walking horizontally, 
		//then traceboxing down from there to check for descent.
	//else try the move with a step up
	
	//because this method might skip over very small corners, but I don't want to make this algorithm take forever to execute
	
	vector cur;
	vec_eq(&(cur),start);
	
	//vector dir;
	//vec_eq(&(dir),normalize([point_x,point_y,0] - [start_x,start_y,0]));
	
	vector cur_ofs;
	vec_eq(&cur_ofs, dist * normalize([point_x,point_y,0] - [start_x,start_y,0]));
	//vec_eq(&(cur_ofs), dir * dist);
	
	float move;
	
	
	float iters = 0;
	vector last_pos;
	vec_eq(&(last_pos),cur);	
//	float updated_x = 0;
	float updated = 0;
	
	if(debug_walk_to_point)
	{
		print("dist: ", ftos(dist),"\n");
		print("Start: ",vtos(start),"\n");
		print("End: ",vtos(point),"\n");
		print("Walk to point started: ",walk_percent(start,cur,point),",\t,",vtos(cur),"\n");
		
		add_debug_hull(start,[1,1,1],[0,0,1],0.05);
		add_debug_hull(start,[0.1,0.1,1],[0,0,1],0.05);
		add_debug_hull(point,[1,1,1],[0,0,1],0.05);
		add_debug_hull(point,[0.1,0.1,1],[0,0,1],0.05);
	}
	
	while(1)
	{
		if(iters++ >= 9997)
		{
			print("\n\nWarning: iterations exceeded 9998\n");
			print("Trying to walk from ",vtos(start)," to ",vtos(point),"\n");
			
			print("Info: cur_ofs:",vtos(cur_ofs)," cur:", vtos(cur)," last pos:",vtos(last_pos),"\n");
			
			add_debug_hull(start,[1,1,1],[0,1,0],0.05);
			add_debug_hull(start,[0.01,0.01,0.01],[0,1,0],0.2);
			
			add_debug_hull(point,[1,1,1],[1,0,0],0.05);
			add_debug_hull(point,[0.01,0.01,0.01],[0,1,0],0.2);
			
			add_debug_hull(cur,[1,1,1],[1,1,1],0.05);
			add_debug_hull(cur,[0.01,0.01,0.01],[1,1,1],0.2);
			
			add_debug_hull(last_pos,[1,1,1],[0.5,0.5,0.5],0.05);
			add_debug_hull(last_pos,[0.01,0.01,0.01],[0.5,0.5,0.5],0.2);
			
			
			print("cur ofs x: ",ftos(cur_ofs_x),", delta x: ",ftos(point_x-cur_x),"\n");
			print("cur ofs y: ",ftos(cur_ofs_y),", delta y: ",ftos(point_y-cur_y),"\n");
			
			
			//Stop recursion so we can follow the printed debug traces
			recursive_depth = 100;
			
			vec_eq(&trace_endpos,start);
			return 0;
		}
		//Don't walk past endpoint
		
		updated = 0;
		
		
		
		if(xy_vlen(cur_ofs) > xy_vlen(point - cur))
		{
			
			if(!disable_print)
			{
				print("\n cur_ofs is too large\n");
				print("cur_ofs: ",vtos(cur_ofs)," -> needed: ",vtos(point - cur),"\n");
			}
				
			vec_eq(&cur_ofs, point - cur);
			
			if(!disable_print)
			{
				print("\n cur_ofs is set to: ",vtos(point-cur),"\n");
				print("\n cur+cur_ofs: ",vtos(cur+cur_ofs),"  point: ",vtos(point),"\n");
			}
			
			updated = 1;
		}
		
//		if((cur_ofs_x > 0 && cur_ofs_x > (point_x - cur_x)) || (cur_ofs_x < 0 && cur_ofs_x < (point_x - cur_x)))
//		{
			//print("x walk dist exceeds actual dist, decreasing walk dist.\n");
			
			//print("cur_ofs_x ",ftos(cur_ofs_x)," -> ",ftos(point_x - cur_x),"\n");
//			if(!disable_print)
//				print("\n cur_ofs_x is set to ",ftos(point_x-cur_x),"\n");
//			cur_ofs_x = point_x - cur_x;
//			
//			if(!disable_print)
//				print("\n cur_x+cur_ofs_x: ",ftos(cur_x+cur_ofs_x),"  point_x: ",ftos(point_x),"\n");
//			updated_x = 1;
//		}
//		else
//			updated_x = 0;
			
//		if((cur_ofs_y > 0 && cur_ofs_y > (point_y - cur_y)) || (cur_ofs_y < 0 && cur_ofs_y < (point_y - cur_y)))
//		{
			//print("y walk dist exceeds actual dist, decreasing walk dist.\n");
			
			//print("cur_ofs_y ",ftos(cur_ofs_y)," -> ",ftos(point_y - cur_y),"\n");
			
//			cur_ofs_y = point_y - cur_y;
//		}
		
		//If we are at the endpoint
		if(cur_ofs_x == 0 && cur_ofs_y == 0)
		{
			if(!disable_print)
				print("ofs is 0, walk_to_point succeeded, point = ",vtos(point),"\n");
				
			vec_eq(&(trace_endpos),cur);
			return 1;
		}
		
		
		move = cl_navgen_gen_direct_walk(cur,cur_ofs);
		
		
		if(updated == 1)
			if(!disable_print)
				print(" walked: ",vtos(cur),"  ->  ",vtos(trace_endpos),"\n");
		
		//Check if we made it
		if(trace_endpos_x == point_x && trace_endpos_y == point_y)
		{
			//trace_endpos already holds result pos
			return 1;
		}
		
		if(move == 0 || move == 1)//We do not allow sliding or partial moves in this algorithm
		{
			//debug_hulls[debug_hull_count++] = cur;
			//debug_hulls[debug_hull_count++] = cur + cur_ofs;
			if(!disable_print)
				print("hit something along the way, walk_to_point failed\n");
			//print("cur: ",vtos(cur)," cur_ofs: ",vtos(cur_ofs),"\n");
			vec_eq(&trace_endpos,start);
			return 0;
		}
		
		vec_eq(&(last_pos),cur);
		vec_eq(&(cur),trace_endpos);
		
		if(debug_walk_to_point)
		{
			print("Walk to point: ",walk_percent(start,cur,point),",\t,",vtos(cur),"\n");
			add_debug_hull(cur,[1,1,1],[0,0,1],0.05);
			add_debug_hull(cur,[0.1,0.1,1],[0,0,1],0.05);
		}
	}
}



//Walks to x & y coordinate of about halfway between start and point
//We walk in dist increments, and assume we are unobstructed
//Returns 1 if successful, 0 otherwise
//Assigns the trace_endpos as the actual point we got to (as z-coordinate may be different)
float cl_navgen_gen_walk_to_midpoint(vector start, vector point)
{
	//If start and point are at the same position, we technically succeeded, but is an error case
	if(xy_vlen(point - start) == 0)
	{
		print("Warning: tried to calculate midpoint of two superimposed points\n");
		vec_eq(&trace_endpos, start);
		return 1;
	}
	
	
	//Walk in increments of 3.0 or 1/10th of distance between point and start, whichever is smaller
	float dist;
	dist = xy_vlen(point - start) * 0.1;
	if(dist > 3.0)
		dist = 3.0;
	
	vector cur;
	vec_eq(&(cur),start);
	vector cur_ofs;
	vec_eq(&cur_ofs, dist * normalize([point_x,point_y,0] - [start_x,start_y,0]));
		
	
	float move;
	
	float iters = 0;
	vector last_pos;
	vec_eq(&(last_pos),cur);	

	float updated = 0;
	
	
	vector xy_midpoint = ([point_x,point_y,0] + [start_x,start_y,0])/2;
	
	if(!disable_print)
		print("\t [ ",vtos(start)," -> ",vtos(point)," ]tentative midpoint: ",vtos(xy_midpoint),"\n");
	
	if(debug_walk_to_point)
	{
		print("dist: ", ftos(dist),"\n");
		print("Start: ",vtos(start),"\n");
		print("End: ",vtos(point),"\n");
		print("\ttentative midpoint: ",vtos(xy_midpoint),"\n");
		print("Walk to midpoint started: ",walk_percent(start,cur,point),",\t,",vtos(cur),"\n");
	}
		
	
	//We're going to walk to point as normal, but exit when we've walked over halfway there.
	while(1)
	{
		if(iters++ >= 9998)
		{
			print("\n\nWarning: walk to midpoint iterations exceeded 9998\n");
			print("Trying to walk from ",vtos(start)," to ",vtos(point),"\n");
			
			print("Info: cur_ofs:",vtos(cur_ofs)," delta:", vtos(point - cur)," last pos:",vtos(last_pos),"\n");
			
			add_debug_hull(start,[1,1,1],[0,1,0],0.05);
			add_debug_hull(start,[0.01,0.01,0.01],[0,1,0],0.2);
			
			add_debug_hull(point,[1,1,1],[1,0,0],0.05);
			add_debug_hull(point,[0.01,0.01,0.01],[0,1,0],0.2);
			
			add_debug_hull(cur,[1,1,1],[1,1,1],0.05);
			add_debug_hull(cur,[0.01,0.01,0.01],[1,1,1],0.2);
			
			add_debug_hull(last_pos,[1,1,1],[0.5,0.5,0.5],0.05);
			add_debug_hull(last_pos,[0.01,0.01,0.01],[0.5,0.5,0.5],0.2);
			
			//Stop recursion so we can follow the printed debug traces
			recursive_depth = 100;
			
			vec_eq(&trace_endpos,start);
			return 0;
		}
		
		updated = 0;
		
		
		//Don't walk past midpoint
		if(xy_vlen(cur_ofs) > xy_vlen(xy_midpoint - cur))
		{
			
			if(!disable_print)
			{
				print("\n cur_ofs is too large\n");
				print("cur_ofs: ",vtos(cur_ofs)," -> needed: ",vtos(point - cur),"\n");
			}
				
			vec_eq(&cur_ofs, xy_midpoint - [cur_x,cur_y,0]);
			
			if(!disable_print)
			{
				print("\n cur_ofs is set to: ",vtos(point-cur),"\n");
				print("\n cur+cur_ofs: ",vtos(cur+cur_ofs),"  point: ",vtos(point),"\n");
			}
			
			updated = 1;
		}
		
		//If we are at the endpoint
		if(cur_ofs_x == 0 && cur_ofs_y == 0)
		{
			if(!disable_print)
				print("ofs is 0, walk_to_point succeeded, point = ",vtos(point),"\n");
				
			vec_eq(&(trace_endpos),cur);
			return 1;
		}
		
		
		move = cl_navgen_gen_direct_walk(cur,cur_ofs);
		
		if(updated == 1)
			if(!disable_print)
				print(" walked: ",vtos(cur),"  ->  ",vtos(trace_endpos),"\n");
				
		//Check if we have reached the midpoint
		if(trace_endpos_x == xy_midpoint_x && trace_endpos_y == xy_midpoint_y)
		{
			return 1;
		}
			
		
		//Check if we hit a wall or obstruction along the way
		if(move == 0 || move == 1)//We do not allow sliding or partial moves in this algorithm
		{
			if(debug_walk_to_point)
			{
				add_debug_hull(cur,[1,1,1],[1,0,0],0.05);
				add_debug_hull(cur,[0.1,0.1,1],[1,0,0],0.05);
				add_debug_hull([xy_midpoint_x,xy_midpoint_y,cur_z],[1,1,1],[0,1,0],0.05);
				add_debug_hull([xy_midpoint_x,xy_midpoint_y,cur_z],[0.1,0.1,1],[0,1,0],0.05);
				
				add_debug_hull(cur+cur_ofs,[0.1,0.1,1],[1,1,0],0.05);
				add_debug_hull(cur+cur_ofs,[1,1,1],[1,1,0],0.05);
				
				add_debug_hull(start,[0.1,0.1,1],[0,0,1],0.1);
				add_debug_hull(point,[0.1,0.1,1],[0,0,0.5],0.1);
				print("Walk to midpoint hit something along the way.\n");
			}
			if(!disable_print)
				print("hit something along the way, walk_to_point failed\n");
			//print("cur: ",vtos(cur)," cur_ofs: ",vtos(cur_ofs),"\n");
			vec_eq(&trace_endpos,start);
			return 0;
		}
		
		vec_eq(&(last_pos),cur);
		vec_eq(&(cur),trace_endpos);
		
		if(debug_walk_to_point)
		{
			print("Walk to midpoint: ",walk_percent(start,cur,point),",\t,",vtos(cur),"\n");
		}
	}
}



//Walks to x & y coordinate of about halfway between start and point
//We walk in dist increments, and assume we are unobstructed
//Returns 1 if successful, 0 otherwise
//Assigns the trace_endpos as the actual point we got to (as z-coordinate may be different)
float cl_backup_navgen_gen_walk_to_midpoint(vector start, vector point)
{
	float dist = 3.0;
	
	//Walk in increments of 3.0 or 1/10th of distance between point and start, whichever is smaller
	dist = xy_vlen(point - start) / 10;
	if(dist > 3.0)
		dist = 3.0;
	
	vector cur;
	vec_eq(&(cur),start);
	
	//vector dir;
	//vec_eq(&(dir),normalize([point_x,point_y,0] - [start_x,start_y,0]));
	
	vector cur_ofs;
	//vec_eq(&(cur_ofs), dir * dist);
	
	float move;
	
	
	float iters = 0;
	vector last_pos;
	vec_eq(&(last_pos),cur);	
//	float updated_x = 0;
	float updated = 0;
	
	
	vector xy_midpoint = ([point_x,point_y,0] + [start_x,start_y,0])/2;
	
	print("\t [ ",vtos(start)," -> ",vtos(point)," ]tentative midpoint: ",vtos(xy_midpoint),"\n");
	
	//float dist_to_walk = xy_vlen(point-start) * 0.5;
	//float dist_walked = 0;
	
	
	
	//We're going to walk to point as normal, but exit when we've walked over halfway there.
	while(1)
	{
		if(iters++ >= 9998)
		{
			print("\n\nWarning: iterations exceeded 9998\n");
			print("Trying to walk from ",vtos(start)," to ",vtos(point),"\n");
			
			print("Info: cur_ofs:",vtos(cur_ofs)," cur:", vtos(cur)," last pos:",vtos(last_pos),"\n");
			
			
			add_debug_hull(start,[1,1,1],[0,1,0],0.05);
			add_debug_hull(start,[0.01,0.01,0.01],[0,1,0],0.2);
			
			add_debug_hull(point,[1,1,1],[1,0,0],0.05);
			add_debug_hull(point,[0.01,0.01,0.01],[0,1,0],0.2);
			
			add_debug_hull(cur,[1,1,1],[1,1,1],0.05);
			add_debug_hull(cur,[0.01,0.01,0.01],[1,1,1],0.2);
			
			add_debug_hull(last_pos,[1,1,1],[0.5,0.5,0.5],0.05);
			add_debug_hull(last_pos,[0.01,0.01,0.01],[0.5,0.5,0.5],0.2);
			
			
			print("cur ofs x: ",ftos(cur_ofs_x),", delta x: ",ftos(point_x-cur_x),"\n");
			print("cur ofs y: ",ftos(cur_ofs_y),", delta y: ",ftos(point_y-cur_y),"\n");
			
			
			//Stop recursion so we can follow the printed debug traces
			recursive_depth = 100;
			
			vec_eq(&trace_endpos,start);
			return 0;
		}
		//Don't walk past endpoint
		
		updated = 0;
		
		vec_eq(&cur_ofs, dist * normalize([point_x,point_y,0] - [cur_x,cur_y,0]));
		
		
		if(xy_vlen(cur_ofs) > xy_vlen(point - cur))
		{
			
			if(!disable_print)
			{
				print("\n cur_ofs is too large\n");
				print("cur_ofs: ",vtos(cur_ofs)," -> needed: ",vtos(point - cur),"\n");
			}
				
			vec_eq(&cur_ofs, point - cur);
			
			if(!disable_print)
			{
				print("\n cur_ofs is set to: ",vtos(point-cur),"\n");
				print("\n cur+cur_ofs: ",vtos(cur+cur_ofs),"  point: ",vtos(point),"\n");
			}
			
			updated = 1;
		}
		
		//If we are at the endpoint
		if(cur_ofs_x == 0 && cur_ofs_y == 0)
		{
			if(!disable_print)
				print("ofs is 0, walk_to_point succeeded, point = ",vtos(point),"\n");
				
			vec_eq(&(trace_endpos),cur);
			return 1;
		}
		
		
		move = cl_navgen_gen_direct_walk(cur,cur_ofs);
		
		if(updated == 1)
			if(!disable_print)
				print(" walked: ",vtos(cur),"  ->  ",vtos(trace_endpos),"\n");
		
		if(move == 0 || move == 1)//We do not allow sliding or partial moves in this algorithm
		{
			//We may have made it to the point anyways, so check
			if(trace_endpos_x == point_x && trace_endpos_y == point_y)
			{
				return 1;
			}
			
			//debug_hulls[debug_hull_count++] = cur;
			//debug_hulls[debug_hull_count++] = cur + cur_ofs;
			if(!disable_print)
				print("hit something along the way, walk_to_point failed\n");
			//print("cur: ",vtos(cur)," cur_ofs: ",vtos(cur_ofs),"\n");
			vec_eq(&trace_endpos,start);
			return 0;
		}
		
		//dist_walked += xy_vlen(trace_endpos - cur);
		
		//if(dist_walked > dist_to_walk)
		if(xy_vlen(trace_endpos-start) / xy_vlen(point-start) >= 0.45)
		{
			//trace_endpos already holds midpoint
			return 1;
		}
		
		vec_eq(&(last_pos),cur);
		vec_eq(&(cur),trace_endpos);
		
		
	}
}



//Returns 0 if edge is unobstructed
//Returns 1 if walking directly from pos1 to pos2 fails
//Returns 1 if walking directly from pos2 to pos1 fails
//TODO: handle ledges and hitting the navmesh
//FIXME: this doesn't handle low hanging brushes overhead (it fails)
float cl_navgen_obstructed(vector pos1, vector pos2)
{
	//Try walk from pos1 to pos2
	
	if(!cl_navgen_gen_walk_to_point(pos1,pos2))
	{
		//print("could not walk from pos1 to pos2 (Result was not: ",vtos(pos2),")\n");
		return 1;
	}
	//Try walk from pos2 to pos1
	if(!cl_navgen_gen_walk_to_point(pos2,pos1))
	{
		//print("could not walk from pos2 to pos1\n");
		return 1;
	}
		
	return 0;
}


//Returns 1 if successful, 0 otherwise
//Assigns the midpoint to trace_endpos
float cl_navgen_calc_midpoint(vector a, vector b)
{
	vector mid;
	vector backup_trace_endpos;
	if(cl_navgen_gen_walk_to_midpoint(a,b))
	{
		print("\tmidpoint Success: ",vtos(trace_endpos),"\n");
		vec_eq(&backup_trace_endpos,trace_endpos);
		
		//TEMP DEBUG STUFF
		//==================
		//If we found midpoint, check to verify that we can walk from a to midpoint and b to midpoint
		//The assumption for this function is that we can from a to b, and from b to a
		
		if(cl_navgen_obstructed(a,b))
			print("Warning: a <-> b obstructed\n"); 
		if(cl_navgen_obstructed(trace_endpos,a))
			print("Warning: found midpoint <-> a obstructed\n");
		if(cl_navgen_obstructed(trace_endpos,b))
			print("Warning: found midpoint <-> b obstructed\n"); 
		
		
		//==================
		
		//trace_endpos is already midpoint
		vec_eq(&trace_endpos,backup_trace_endpos);
		return 1;
	}
	else
	{
		vec_eq(&backup_trace_endpos,trace_endpos);
		
		
		for(float i = 0; i < 40; i++)print("=");print("\n");
		print("Warning: could not walk to mid from min.\n");
		for(float i = 0; i < 40; i++)print("=");print("\n");
		
		if(cl_navgen_gen_walk_to_point(a,b))
		{
			print("\tCan walk from a to b\n");
		}
		else
			print("\tCannot walk from a to b\n");
		
		//Calling cl_navgen_gen_walk_to_midpoint again with debug turned on
		for(float i = 0; i < 40; i++)print("=");print("\n");
		for(float i = 0; i < 40; i++)print("=");print("\n");
		print("start debug call \n\n");
		//float temp = disable_print;
		
		//disable_print = 0;
		debug_walk_to_point = 1;
		cl_navgen_gen_walk_to_point(a,b);
		print("\n");
		cl_navgen_gen_walk_to_midpoint(a,b);
		debug_walk_to_point = 0;
		//disable_print = 1;
		print("\n end debug call \n");
		for(float i = 0; i < 40; i++)print("=");print("\n");
		for(float i = 0; i < 40; i++)print("=");print("\n");
		print("\n");
		
		//FIXME: sometimes walk to midpoint fails even though we can walk from a to b
		vec_eq(&trace_endpos,backup_trace_endpos);
		return 0;
	}
	/*
	vec_eq(&(mid),(a+b)/2);
	if(cl_navgen_gen_walk_to_point(a,mid))
	{
		//Copy trace endpos to mid
		vec_eq(&mid,trace_endpos);
		//This should always run
	
		//DEBUG remove this, make sure mid can walk to a and b
		if(cl_navgen_obstructed(mid,a))
		{
			print(" Warning, cannot walk from mid to a\n");
		}
		//If min and mid3 are obstructed, print an error
		if(cl_navgen_obstructed(mid,b))
		{
			print(" Warning, cannot walk from mid to b\n");
		}
		
		
		if(debug_moreinfo == 1)
			print("\tmidpoint Success: ",vtos(mid),"\n");
		
		vec_eq(&trace_endpos,mid);
		return 1;
	}
	else
	{
		if(debug_moreinfo == 1)
			print("\tmidpoint failure\n");
			
		for(float i = 0; i < 40; i++)print("=");print("\n");
		print("Warning: could not walk to mid from min.\n");
		for(float i = 0; i < 40; i++)print("=");print("\n\n");
		
		//Print some more debug info
		//if(debug_moreinfo)
		{
		//	debug_moreinfo = 0;
			//Can we even walk from a to b?
			//if(cl_navgen_obstructed(a,b))
			if(!cl_navgen_gen_walk_to_point(a,b))
			{
				print("\tCannot walk from a to b\n");
			}
			else
				print("\tCan walk from a to b\n");
			//DEBUG remove this, make sure mid can walk to a and b
			if(cl_navgen_obstructed(mid,a))
			{
				print(" Warning, cannot walk from mid to a\n");
			}
			else
				print("Can walk from mid to a\n");
			//If min and mid3 are obstructed, print an error
			if(cl_navgen_obstructed(mid,b))
			{
				print(" Warning, cannot walk from mid to b\n");
			}
			else
				print("Can walk from mid to b\n");
			
			if(cl_navgen_gen_walk_to_point(a,mid))
			{
				print("\tCan actually walk from a to mid\n");
			}
			else
				print("\tCannot walk from a to mid\n");
		//	debug_moreinfo = 1;
			
			
			
		}
		
		//Run this method once so we can follow the prints
		float temp_noprint = disable_print;
		disable_print = 0;
		cl_navgen_gen_walk_to_point(a,mid);
		disable_print = temp_noprint;
		
		print("\nEnd debug call\n");
		
		
		add_debug_hull(a,[1,1,1],[0,1,0],0.05);
		add_debug_hull(b,[1,1,1],[1,0,0],0.05);
		
		vec_eq(&trace_endpos,a);
		return 0;
	}*/
}

//Restructuring find_min algorithm:
//Given pos1 pos2 and pos3, alternates moving pos2 towards pos1 and pos3 a tiny amount until we cannot walk to the one we are not moving towards
//Assigns trace_endpos as resulting minimum
//Returns 0 if we encountered an error / issue, 1 if we successfully found the minimum (I'm not yet sure if this error handling is useful in any way)
float cl_navgen_find_min(vector pos1, vector pos2, vector pos3)
{
	float pos1_minimized = 0;
	float pos3_minimized = 0;
	
	vector min;
	vec_eq(&min,pos2);
	
	vector mid1;
	vector mid3;
	
	float delta = 0.01;//how close does the min and max have to be for us to accept min as the desired point?
	
	float iters = 0;
	
	print("\nFind min Start\n\n");
	print("pos1: ",vtos(pos1),"\nmin: ",vtos(min),"\n pos3:",vtos(pos3),"\n");
	
	while(1)
	{
		if(iters++ >= 9999)
		{
			print("Warning: iters exceeded 9998\n");
			vec_eq(&trace_endpos,min);
			return 0;
		}
				
		iters2 = 0;
		
		
		pos1_minimized = 0;
		
		//Subdivide min to pos1 until we can walk to pos3 from mid1
		while(1)
		{
			if(iters2++ >= 9999)
			{
				print("Warning iters2 exceeded 9998 on 1\n");
				return 0;
			}
		}
		
		//TODO: use the code below to finish implementing the fixed version of find_min
		
		if(pos1_minimized && pos3_minimized)
		{
			vec_eq(&trace_endpos,min);
			return 1;
		}
	}
}


/*	
	float delta = 0.01;
	//subdivide from min to 1 once
	//once we find a min to 1 subdivision that can walk to 3, state = 2;
	if(find_min_state == 1)
	{
		//Just for breaking out of the loop
		do
		{
			//Check if mid1 and min are so close that we have minimized this edge
			if(xy_vlen(mid1->pos - vert2->pos) < delta)
			{
				mid1_minimized = 1;
				find_min_state = 2;
				vec_eq(&(mid3->pos),vert3->pos);
				print("Minimized edge 1:(",ftos(xy_vlen(mid1->pos - vert2->pos)),")\n");
				break;
			}
			
			//if we can walk from mid1 to vert3, stop and anounce that.
			if(!cl_navgen_obstructed(mid1->pos,vert3->pos))
			{
				print("Can walk from mid1 to pos3\n");
				find_min_state = 2;
				vec_eq(&(mid3->pos),vert3->pos);
				vec_eq(&(vert2->pos),mid1->pos);
				
				add_debug_hull_line(mid1->pos,vert3->pos,[0,1,0]);
				
				break;
			}
					
			add_debug_hull_line(mid1->pos,vert3->pos,[1,0,0]);
			
			//Subdivide
			print("Cannot walk from mid1 to pos3, subdividing mid1.\n");
				
			cl_navgen_calc_midpoint(vert2->pos,mid1->pos);
			
			vec_eq(&(mid1->pos),trace_endpos);
				
		}
		while(0);
	}
	
	//subdivide from min to 3 once
	//once we find a min to 3 subdivision that can walk to 3, state = 2;
	else if(find_min_state == 2)
	{
		//Just for breaking out of the loop
		do
		{
			//Check if mid3 and min are so close that we have minimized this edge
			if(xy_vlen(mid3->pos - vert2->pos) < delta)
			{
				mid3_minimized = 1;
				find_min_state = 1;
				vec_eq(&(mid1->pos),vert1->pos);
				print("Minimized edge 3:(",ftos(xy_vlen(mid3->pos - vert2->pos)),")\n");
				break;
			}
			
			//if we can walk from mid3 to vert1, stop and anounce that.
			if(!cl_navgen_obstructed(mid3->pos,vert1->pos))
			{
				print("Can walk from mid3 to pos1\n");
				find_min_state = 1;
				vec_eq(&(vert2->pos),mid3->pos);
				vec_eq(&(mid1->pos),vert1->pos);
				add_debug_hull_line(mid3->pos,vert1->pos,[0,1,0]);
				
				break;
			}
					
			add_debug_hull_line(mid3->pos,vert1->pos,[1,0,0]);
			
			//Subdivide
			print("Cannot walk from mid3 to pos1, subdividing mid3.\n");
				
			cl_navgen_calc_midpoint(vert2->pos,mid3->pos);
			
			vec_eq(&(mid3->pos),trace_endpos);
				
		}
		while(0);
	}
	
	//Check if the algorithm is finished.
	if(mid1_minimized == 1 && mid3_minimized == 1)
	{
		print("Both edges minimized, algorithm finished.\n");
		find_min_state = 3;
	}
}
*/
//=======================================================================================================================
//=======================================================================================================================
//=======================================================================================================================
//=======================================================================================================================
//=======================================================================================================================
//=======================================================================================================================

float cl_old_old_navgen_find_min(vector pos1, vector pos2, vector pos3)
{
	float pos1_minimized = 0;
	float pos3_minimized = 0;
	
	vector min;
	vec_eq(&min,pos2);
	
	vector mid1;
	vector mid3;
	
	float delta = 0.1;//how close does the min and max have to be for us to accept min as the desired point?
	
	float iters = 0;
	
	print("\nFind min Start\n\n");
	print("pos1: ",vtos(pos1),"\nmin: ",vtos(min),"\n pos3:",vtos(pos3),"\n");
	
	while(1)
	{
		if(iters++ >= 9999)
		{
			print("Warning: iters exceeded 9998\n");
			vec_eq(&trace_endpos,min);
			return 0;
		}
		pos1_minimized = 0;
		pos3_minimized = 0;
				
		//These are for debug
		//===================
		vector temp_mid1;
		vector temp_mid3;
		//===================
		
		//================================================================================================
		//Make sure min can walk to pos1 and pos3
		print(" ========== Checking to make sure edges aren't obstructed before iter ========= \n");
		print("====== Calculating midpoints ======\n");
		print("  min to pos1: ");
		cl_navgen_calc_midpoint(min,pos1);
		vec_eq(&temp_mid1,trace_endpos);
		
		print("  min to pos3: ");
		cl_navgen_calc_midpoint(min,pos3);
		vec_eq(&temp_mid3,trace_endpos);
		print("===================================\n");
		print("\n  pos1: ",vtos(pos1),"\n");
		print("  mid1: ",vtos(temp_mid1),"\n");
		print("  min: ",vtos(min),"\n");
		print("  mid3: ",vtos(temp_mid3),"\n");
		print("  pos3: ",vtos(pos3),"\n\n");
		
		
		if(cl_navgen_obstructed(min,pos1))
			print("  min<->pos1 FAIL\n");
		else
			print("  min<->pos1 okay\n");
		if(cl_navgen_obstructed(min,pos3))
			print("  min<->pos3 FAIL\n");
		else
			print("  min<->pos3 okay\n");
		
		if(cl_navgen_obstructed(temp_mid1,pos1))
			print("  mid1<->pos1 FAIL\n");
		else
			print("  mid1<->pos1 okay\n");
			
		if(cl_navgen_obstructed(temp_mid1,min))
			print("  mid1<->min FAIL\n");
		else
			print("  mid1<->min okay\n");
		
		if(cl_navgen_obstructed(temp_mid3,pos3))
			print("  mid3<->pos3 FAIL\n");
		else
			print("  mid3<->pos3 okay\n");
			
		if(cl_navgen_obstructed(temp_mid3,min))
			print("  mid3<->min FAIL\n");
		else
			print("  mid3<->min okay\n");
		print(" =============================== End before iter ============================ \n");
		//================================================================================================
		
		
		//Walk towards pos1
		//Calculate mid1 from min to pos1
		debug_moreinfo = 1;
		cl_navgen_calc_midpoint(min,pos1);
		vec_eq(&mid1,trace_endpos);
		debug_moreinfo = 0;
		float iters2 = 0;

		
		//Subdivide min to pos1 until we can walk to pos3 from mid1
		while(1)
		{
			//FIXME: we're getting into this with min and mid1 being equal... what?
			if(iters2++ >= 9999)
			{
				print(" Warning: iters2 exceeded 9998 on first loop\n");
				vec_eq(&trace_endpos,min);
				return 0;
			}
			
			
			
			if(xy_vlen(mid1 - min) < delta)
			{
				pos1_minimized = 1;
				print("1:",ftos(iters2),"-> minimized(",ftos(xy_vlen(mid1-min)),")\n");
				print("mid1: ",vtos(mid1),", min: ",vtos(min),"\n");
				break;
			}
				
			
			//If we can walk from mid1 to pos3
			if(!cl_navgen_obstructed(mid1,pos3))
			{
				vec_eq(&min,mid1);
				print("1:",ftos(iters2)," ");
				break;
			}
			else
			{
				//recalculate mid1 from min to mid1
				if(!cl_navgen_calc_midpoint(min,mid1))
				{
					print("\n\nWarning: failed to calc midpoint from min to mid1.\n");
					vec_eq(&trace_endpos,min);
					return 0;
				}
				vec_eq(&(mid1), trace_endpos);
				if(mid1 == min)//FIXME THIS SHOULD NOT HAPPEN
				{
					print("\n\nmid1 is now min, something went horribly wrong somewhere.\n");
					vec_eq(&trace_endpos,min);
					return 0;
				}
			}
		}
		
		
		
		//================================================================================================
		//Make sure min can walk to pos1 and pos3
		print(" ========== Checking to make sure edges aren't obstructed between iter ========= \n");
		print("====== Calculating midpoints ======\n");
		print("  min to pos1: ");
		cl_navgen_calc_midpoint(min,pos1);
		vec_eq(&temp_mid1,trace_endpos);
		
		print("  min to pos3: ");
		cl_navgen_calc_midpoint(min,pos3);
		vec_eq(&temp_mid3,trace_endpos);
		print("===================================\n");
		print("\n  pos1: ",vtos(pos1),"\n");
		print("  mid1: ",vtos(temp_mid1),"\n");
		print("  min: ",vtos(min),"\n");
		print("  mid3: ",vtos(temp_mid3),"\n");
		print("  pos3: ",vtos(pos3),"\n\n");
		if(cl_navgen_obstructed(min,pos1))
			print("  min<->pos1 FAIL\n");
		else
			print("  min<->pos1 okay\n");
		if(cl_navgen_obstructed(min,pos3))
			print("  min<->pos3 FAIL\n");
		else
			print("  min<->pos3 okay\n");
		
		if(cl_navgen_obstructed(temp_mid1,pos1))
			print("  mid1<->pos1 FAIL\n");
		else
			print("  mid1<->pos1 okay\n");
			
		if(cl_navgen_obstructed(temp_mid1,min))
			print("  mid1<->min FAIL\n");
		else
			print("  mid1<->min okay\n");
		
		if(cl_navgen_obstructed(temp_mid3,pos3))
			print("  mid3<->pos3 FAIL\n");
		else
			print("  mid3<->pos3 okay\n");
			
		if(cl_navgen_obstructed(temp_mid3,min))
			print("  mid3<->min FAIL\n");
		else
			print("  mid3<->min okay\n");

		print(" =============================== End between iter ============================ \n");
		//================================================================================================
		
		
		
		iters2 = 0;
		
		//Walk towards pos3
		//Calculate mid3 from min to pos3
		cl_navgen_calc_midpoint(min,pos3);
		vec_eq(&(mid3), trace_endpos);
		
		//Subdivide min to pos3 until we can walk to pos1 from mid3
		while(1)
		{
			if(iters2++ >= 9999)
			{
				print(" Warning: iters2 exceeded 9998 on second loop\n");
				vec_eq(&trace_endpos,min);
				return 0;
			}
			
			
			if(xy_vlen(mid3 - min) < delta)
			{
				pos3_minimized = 1;
				print("3:",ftos(iters2),"-> minimized(",ftos(xy_vlen(mid3-min)),")\n");
				print("mid3: ",vtos(mid3),", min: ",vtos(min),"\n");
				break;
			}
			
			//If we can walk from mid3 to pos1
			if(!cl_navgen_obstructed(mid3,pos1))
			{
				vec_eq(&min,mid3);
				print("3:",ftos(iters2)," ");
				break;
			}
			else
			{
				
				//FIXME: something is wrong with the following logic that I am using.
				//I use the following logic:
				//If I can walk from a to b, and I walk from a to (a+b)/2, I should still be able to walk to b
				//now either my implementation is incorrect, OR floating point errors are screwing me up big time.
				//I checked and it appears that we are walking on the same line (i.e. walk direction is exactly the same)
				
				//recalculate mid3 from min to mid3
				if(!cl_navgen_calc_midpoint(min,mid3))
				{
					print("\n\nWarning: failed to calc midpoint from min to mid3.\n");
					vec_eq(&trace_endpos,min);
					return 0;
				}
				vec_eq(&(mid3), trace_endpos );
				if(mid3 == min)//FIXME THIS SHOULD NOT HAPPEN
				{
					print("\n\nmid3 is now min, something went horribly wrong somewhere.\n");
					vec_eq(&trace_endpos,min);
					return 0;
				}
			}
		}
		
		//FOR DEBUG
		//If we cannot walk to pos1 or pos3 from min, there is a problem
		
		//================================================================================================
		//Make sure min can walk to pos1 and pos3
		
		//FIXME: this is when things break (after a few iterations)
		
		print(" ========== Checking to make sure edges aren't obstructed after iter ========= \n");
		print("====== Calculating midpoints ======\n");
		print("  min to pos1: ");
		debug_moreinfo = 1;
		cl_navgen_calc_midpoint(min,pos1);
		vec_eq(&temp_mid1,trace_endpos);
		debug_moreinfo = 0;
		
		//FIXME: we encountered an issue: below checks mid1->min FAIL, but that's impossible, because
		//we calculate mid1 from min right here... so what...?
		
		print("  min to pos3: ");
		cl_navgen_calc_midpoint(min,pos3);
		vec_eq(&temp_mid3,trace_endpos);
		print("===================================\n");
		print("\n  pos1: ",vtos(pos1),"\n");
		print("  mid1: ",vtos(temp_mid1),"\n");
		print("  min: ",vtos(min),"\n");
		print("  mid3: ",vtos(temp_mid3),"\n");
		print("  pos3: ",vtos(pos3),"\n\n");
		if(cl_navgen_obstructed(min,pos1))
			print("  min<->pos1 FAIL\n");
		else
			print("  min<->pos1 okay\n");
		if(cl_navgen_obstructed(min,pos3))
			print("  min<->pos3 FAIL\n");
		else
			print("  min<->pos3 okay\n");
		
		if(cl_navgen_obstructed(temp_mid1,pos1))
			print("  mid1<->pos1 FAIL\n");
		else
			print("  mid1<->pos1 okay\n");
			
		if(cl_navgen_obstructed(temp_mid1,min))//FIXME: this fails, for some odd reason
			print("  mid1<->min FAIL\n");
		else
			print("  mid1<->min okay\n");
		
		if(cl_navgen_obstructed(temp_mid3,pos3))
			print("  mid3<->pos3 FAIL\n");
		else
			print("  mid3<->pos3 okay\n");
			
		if(cl_navgen_obstructed(temp_mid3,min))
			print("  mid3<->min FAIL\n");
		else
			print("  mid3<->min okay\n");

		print(" =============================== End after iter ============================ \n");
		//================================================================================================
		
		if(pos1_minimized && pos3_minimized)
		{
			vec_eq(&trace_endpos,min);
			return 1;
		}
	}
}

//Given pos1 that can walk to other, and pos2 that cannot walk to other
//Returns furthest point from pos1 (on line from pos1 to pos2) that can still walk to other
//Assigns value of min to trace_endpos
float cl_old_navgen_find_min(vector pos1, vector pos2, vector other)
{
	vector min;
	vec_eq(&(min),pos1);
	vector max;
	vec_eq(&(max),pos2);
	vector mid;
	
	
	float delta = 0.001;//how close does the min and max have to be for us to accept min as the desired point?
	
	//debug_hulls[debug_hull_count++] = pos1;
	//debug_hulls[debug_hull_count++] = pos2;
	
	//====== temp =======
	
//	print("Find min: ",vtos(pos1),"->",vtos(pos2)," : ",vtos(other),", [");
	
	vector pos2xy = [pos2_x,pos2_y,0];
	vector pos1xy = [pos1_x,pos1_y,0];
	
	float xylen = vlen([pos2_x - pos1_x,pos2_y - pos1_y,0]);
	float iters = 0;
	//===================
	
	print("=======================================================\n");
	print("=======================================================\n");
	print("=======================================================\n");
	print("=======================================================\n");
	print("=======================================================\n");
	print("=======================================================\n");
	print("Find min: ");
		
	while(1)
	{
		//This should not happen
		if(iters++ > 1000)
		{
			print("\n\nWarning: iterations > 1000 encountered.\n");
			add_debug_hull(pos1,[1,1,1],[0,1,0],0.05);
			add_debug_hull(pos2,[1,1,1],[1,0,0],0.05);
			add_debug_hull(other,[1,1,1],[0,0,1],0.05);
			
			add_debug_hull(min,[1,1,1],[0,0,0],0.05);
			add_debug_hull(max,[1,1,1],[0.2,0.2,0.2],0.05);
			
			//debug_hulls[debug_hull_count++] = pos1;
			//debug_hulls[debug_hull_count++] = pos2;
			//debug_hulls[debug_hull_count++] = mid;
			print("Find min: ",vtos(pos1),"->",vtos(pos2)," : ",vtos(other),", \n");
			print("Fraction: (",ftos(vlen([min_x,min_y,0]-pos1xy)/xylen),",",ftos(vlen([max_x,max_y,0]-pos1xy)/xylen),")\n");
			
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			
			vec_eq(&trace_endpos,min);
			return 0;
		}
		//===temp===
//		print(" (",ftos(vlen([min_x,min_y,0]-pos1xy)/xylen),",",ftos(vlen([max_x,max_y,0]-pos1xy)/xylen),"),");
		//==========

		if(vlen([max_x,max_y,0]-[min_x,min_y,0]) < delta)
		{
//			print("]\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");	

			vec_eq(&trace_endpos,min);
			return 0;
		}
			
		vec_eq(&(mid),(min+max)/2);
		
		if(cl_navgen_gen_walk_to_point(min,mid))
		{
			print("1:");
			//This should always run
			vec_eq(&(mid),trace_endpos);
			//debug_hulls[debug_hull_count++] = mid;
		}
		else
		{
			print("!!!!!!!!!!!!!!!! Warning: could not walk to mid from min.\n");
			
			add_debug_hull(pos1,[1,1,1],[0,1,0],0.05);
			add_debug_hull(pos2,[1,1,1],[1,0,0],0.05);
			add_debug_hull(other,[1,1,1],[0,0,1],0.05);
			
			add_debug_hull(min,[1,1,1],[0,0,0],0.05);
			add_debug_hull(max,[1,1,1],[0.2,0.2,0.2],0.05);
			
			
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			print("=======================================================\n");
			
			vec_eq(&trace_endpos,min);
			return 0;
			//FIXME: this sometimes executes
			//I guess we can't just rely on jumping back and forth across large gaps
			
			//debug_hulls[debug_hull_count++] = min;
			//debug_hulls[debug_hull_count++] = mid;
		}
		
		//debug_hulls[debug_hull_count++] = min;
		//debug_hulls[debug_hull_count++] = max;
		
		if(cl_navgen_obstructed(mid,other))
		{
			print("mn ");
			vec_eq(&(max),mid);
		}
		else
		{
			print("mx ");
			vec_eq(&(min),mid);
		}
	}
}

//TODO: method that resolves a corner on a bsp hull, we essentially walk back and forth with one vert until:
//	moving back and forth a tiny tiny amount is the difference between an obstructed edge and an unobstructed edge


void cl_navgen_gen_floodfill(navgen_vertex* vert)
{	
	if(recursive_depth > 3)
		return;
	//Incrementally move vertex away from it's edges until stop or our edges are obstructed
	//calculate direction from edges
	
	vector walk_dir = [0,0,0]; //take line tangent to line normalize(vert->right->pos - vert->left->pos)
	
	float walk_dist = 3;//how many qu to walk at each step
	
	//Calculating walk_dir
	//===========================
	vector tangent;
	vec_eq(&(tangent),((vert->right)->pos - (vert->left)->pos));
	
	//Don't care about z-difference
	tangent_z = 0;
	vec_eq(&(tangent),normalize(tangent));
	
	
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
	
	vector last_vert_pos;
	
	navgen_vertex* new_vert;
	
	
	float iters = 0;
	
	//walk the vertex in the direction a small amount
	while(1)
	{
		if(iters++ > 9998)
		{
			print("Warning: floodfill algorithm runaway loop\n");
			return;
		}
		//Try walking a small amount forward
		vec_eq(&(last_vert_pos),vert->pos);
		
		move = cl_navgen_gen_walk(vert->pos,walk_dir);
		
		vec_eq(&(vert->pos),trace_endpos);
		if(!disable_print)
			print("Move result: ",ftos(move),"\n");
		if(!move && !did_move)
		{
			break;
		}
		did_move = 1;
		
		
		
		//check if left edge was obstructed
		//print("Checking left to vert edge\n");
		if(cl_navgen_obstructed((vert->left)->pos,vert->pos))
		{
			print("Left edge obstructed.\n");
			
			//Subdivide the left edge
			//Insert the new vertex at our last vertex position
			new_vert = cl_navgen_new_vert(last_vert_pos);
			
			new_vert->left = vert->left;
			(vert->left)->right = new_vert;
			new_vert->right = vert;
			vert->left = new_vert;
			
			
			//Getting the vertex as close to the corner as possible
			cl_navgen_find_min(vert->pos,new_vert->pos,(new_vert->left)->pos);
			vec_eq(&(new_vert->pos), trace_endpos);
			
			
			
			//Get new_vert as close as possible to our vert such that we can still walk to our left vert
//			print("Before: ",vtos(new_vert->pos));
			
			
			
			//vec_eq(&(new_vert->pos), cl_navgen_find_min(new_vert->pos,vert->pos,(new_vert->left)->pos));
			//cl_navgen_find_min(new_vert->pos,vert->pos,(new_vert->left)->pos);
			//vec_eq(&(new_vert->pos), trace_endpos);
//			print("After: ",vtos(new_vert->pos));
			
			
			//Get new_vert as close as possible to our left vert such that we can still walk to our vert
			//vec_eq(&(new_vert->pos), cl_navgen_find_min(new_vert->pos,(new_vert->left)->pos,vert->pos));
			//cl_navgen_find_min(new_vert->pos,(new_vert->left)->pos,vert->pos);
			//vec_eq(&(new_vert->pos), trace_endpos);
			
			vec_eq(&(vert->pos), last_vert_pos);
			
			
			//Check if the new vertex didn't move
			//if(vert->pos == new_vert->pos)
			/*{
				print("Subdivided vertex did not move, subdivision undone\n");
				//Undo the subdivision
				vert->left = new_vert->left;
				(new_vert->left)->right = vert;
				
				cl_navgen_free_vert(new_vert);
			}
			else*/
			{
				//recursive_depth++;
				//cl_navgen_gen_floodfill(vert);
				//recursive_depth--;
			}
			
			return;
		}
	
		//check if right edge was obstructed
		//print("Checking vert to right edge\n");
		if(cl_navgen_obstructed(vert->pos,(vert->right)->pos))
		{
			print("Right edge obstructed.\n");
			
			//Subdivide the right edge
			//Insert the new vertex at our last vertex position
			new_vert = cl_navgen_new_vert(last_vert_pos);
			
			new_vert->right = vert->right;
			(vert->right)->left = new_vert;
			new_vert->left = vert;
			vert->right = new_vert;
			
			//Getting the vertex as close to the corner as possible
			cl_navgen_find_min(new_vert->pos,vert->pos,(new_vert->right)->pos);
			vec_eq(&(new_vert->pos), trace_endpos );
			
			vec_eq(&(vert->pos), last_vert_pos);
			
			//Check if the new vertex didn't move
			if(vert->pos == new_vert->pos)
			{
				print("Subdivided vertex did not move, subdivision undone\n");
				//Undo the subdivision
				vert->right = new_vert->right;
				(new_vert->right)->left = vert;
				
				cl_navgen_free_vert(new_vert);
			}
			else
			{
				//recursive_depth++;
				//cl_navgen_gen_floodfill(vert);
				//recursive_depth--;
			}
			
			return;
		}
		
		
		//check if we intersected with any other vertex edge
			//walk along the edge and see if we hit one of the verts
		//check if we hit any other vertex
		
		//Check if we moved but hit a dead end without obstruction
		if(!move)
		{
			//=========================
			//Subdivide left edge
			//=========================
			vector edge_center;
			vec_eq(&(edge_center), (vert->pos + (vert->left)->pos)/2 );
			
			if(cl_navgen_gen_walk_to_point(vert->pos,edge_center))
			{
				//This should always run
				vec_eq(&(edge_center), trace_endpos);
				
			}
			else
			{
				print("Warning: could not walk to vertex midpoint.\n");
			}
			
			new_vert = cl_navgen_new_vert(edge_center);
			new_vert->left = vert->left;
			(vert->left)->right = new_vert;
			new_vert->right = vert;
			vert->left = new_vert;
			
			//=========================
			//Subdivide right edge
			//=========================
			vec_eq(&(edge_center), (vert->pos + (vert->right)->pos)/2 );
			
			if(cl_navgen_gen_walk_to_point(vert->pos,edge_center))
			{
				//This should always run
				vec_eq(&(edge_center), trace_endpos );
			}
			else
			{
				print("Warning: could not walk to vertex midpoint.\n");
			}
			
			new_vert = cl_navgen_new_vert(edge_center);
			new_vert->right = vert->right;
			(vert->right)->left = new_vert;
			new_vert->left = vert;
			vert->right = new_vert;
			
			break;
		}
	}
	
	if(!did_move)
		return;
		
	//FIXME: it should be safe to call these because of the temp recursive_depth safety net
	//however, we cannot call these without recursive_depth until we handle navmesh intersecting itself
	//Call cl_navgen_gen_floodfill on left and right verts
	/*recursive_depth++;
	cl_navgen_gen_floodfill(vert->left);
	recursive_depth--;
	recursive_depth++;
	cl_navgen_gen_floodfill(vert->right);
	recursive_depth--;*/
	
	
	//if left / right edge was obstructed
		//regress to last unobstructed position
		//hone in on corner position,
		//etc...
}


//===============================================================================================================================
//===============================================================================================================================
//========================================== Test section for debugging find_min algorithm ======================================
//===============================================================================================================================
//===============================================================================================================================

//vert defs are above (so render can use them)
//navgen_vertex* vert1;
//navgen_vertex* vert3;
//navgen_vertex* vert2;


float find_min_state;

float mid1_minimized;
float mid3_minimized;

void temp_continue_find_min()
{
	if(find_min_state == 3)
	{
		print("Algorithm already finished.\n");
		return;
	}
	
	float delta = 0.01;
	//subdivide from min to 1 once
	//once we find a min to 1 subdivision that can walk to 3, state = 2;
	if(find_min_state == 1)
	{
		//Just for breaking out of the loop
		do
		{
			clear_debug_hulls();
			clear_debug_lines();
		
			mid1_minimized = 0;
			
			//Check if mid1 and min are so close that we have minimized this edge
			if(xy_vlen(mid1->pos - vert2->pos) < delta)
			{
				mid1_minimized = 1;
				find_min_state = 2;
				vec_eq(&(mid3->pos),vert3->pos);
				print("Minimized edge 1:(",ftos(xy_vlen(mid1->pos - vert2->pos)),")\n");
				break;
			}
			
			//if we can walk from mid1 to vert3, stop and anounce that.
			if(!cl_navgen_obstructed(mid1->pos,vert3->pos))
			{
				print("Can walk from mid1 to pos3\n");
				find_min_state = 2;
				vec_eq(&(mid3->pos),vert3->pos);
				vec_eq(&(vert2->pos),mid1->pos);
				
				add_debug_hull_line(mid1->pos,vert3->pos,[0,1,0]);
				
				break;
			}
					
			add_debug_hull_line(mid1->pos,vert3->pos,[1,0,0]);
			
			//Subdivide
			print("Cannot walk from mid1 to pos3, subdividing mid1.\n");
				
			cl_navgen_calc_midpoint(vert2->pos,mid1->pos);
			
			vec_eq(&(mid1->pos),trace_endpos);
				
		}
		while(0);
	}
	
	//subdivide from min to 3 once
	//once we find a min to 3 subdivision that can walk to 3, state = 2;
	else if(find_min_state == 2)
	{
		//Just for breaking out of the loop
		do
		{
			clear_debug_hulls();
			clear_debug_lines();
		
			mid3_minimized = 0;
			
			//Check if mid3 and min are so close that we have minimized this edge
			if(xy_vlen(mid3->pos - vert2->pos) < delta)
			{
				mid3_minimized = 1;
				find_min_state = 1;
				vec_eq(&(mid1->pos),vert1->pos);
				print("Minimized edge 3:(",ftos(xy_vlen(mid3->pos - vert2->pos)),")\n");
				break;
			}
			
			//if we can walk from mid3 to vert1, stop and anounce that.
			if(!cl_navgen_obstructed(mid3->pos,vert1->pos))
			{
				print("Can walk from mid3 to pos1\n");
				find_min_state = 1;
				vec_eq(&(vert2->pos),mid3->pos);
				vec_eq(&(mid1->pos),vert1->pos);
				add_debug_hull_line(mid3->pos,vert1->pos,[0,1,0]);
				
				break;
			}
					
			add_debug_hull_line(mid3->pos,vert1->pos,[1,0,0]);
			
			//Subdivide
			print("Cannot walk from mid3 to pos1, subdividing mid3.\n");
				
			cl_navgen_calc_midpoint(vert2->pos,mid3->pos);
			
			vec_eq(&(mid3->pos),trace_endpos);
				
		}
		while(0);
	}
	
	//Check if the algorithm is finished.
	if(mid1_minimized == 1 && mid3_minimized == 1)
	{
		print("Both edges minimized, algorithm finished.\n");
		find_min_state = 3;
	}
}


void temp_call_find_min()
{
	//Restarts the algorithm and begins it
	clear_debug_hulls();
	clear_debug_lines();
	
	find_min_state = 0;
	//clear the navmesh verts
	if(vert1)
		memfree(vert1);
	if(vert2)
		memfree(vert2);
	if(vert3)
		memfree(vert3);
	if(mid1)
		memfree(mid1);
	if(mid3)
		memfree(mid3);
	vert1 = 0;
	vert2 = 0;
	vert3 = 0;
	mid1 = 0;
	mid3 = 0;
	
	
	//If we haven't started the algorithm
	//Set everything up and start it
	if(find_min_state == 0)
	{
		vert1 = memalloc(sizeof(navgen_vertex));
		vert3 = memalloc(sizeof(navgen_vertex));
		vert2 = memalloc(sizeof(navgen_vertex));
		
		vector player_pos;
	
		vec_eq(&player_pos,getentity(player_localentnum, GE_ORIGIN));
		
		//Find floor at pos
		cl_navgen_gen_drop_to_floor(player_pos);
		//player_pos = trace_endpos;
		vec_eq(&player_pos,trace_endpos);
		
		float initial_tri_size = 100;//10
		
		//Rotate the triangle
		
		float angle = time;
		
		//TODO: tracebox down from above player pos to get actual floor position
		vec_eq(&(vert2->pos),player_pos);
		
		cl_navgen_gen_direct_walk(player_pos, [cos(angle + 3.14),sin(angle + 3.14),0]*initial_tri_size);
		vec_eq(&(vert1->pos),trace_endpos);
		cl_navgen_gen_direct_walk(player_pos, [cos(angle + 1.57),sin(angle + 1.57),0]*initial_tri_size);
		vec_eq(&(vert3->pos),trace_endpos);
		
		

		vert1->left = 0;
		vert1->right = vert2;
		vert2->left = vert1;
		vert2->right = vert3;
		vert3->left = vert2;
		vert3->right = 0;
		
		//Check if corners are not obstructed
		if(!cl_navgen_obstructed(vert1->pos,vert3->pos))
		{
			print("findmin: forward and left are not obstructed, nothing to do.\n");
			find_min_state = 3;//finished state
			add_debug_hull_line(vert1->pos,vert3->pos,[0,1,0]);
			return;
		}
		
		//Make sure we can walk from 1 to min and min to 3
		if(cl_navgen_obstructed(vert1->pos,vert2->pos))
		{
			print("Warning: findmin: cannot walk from v1 to min.\n");
			find_min_state = 3;
			return;
		}
		if(cl_navgen_obstructed(vert2->pos,vert3->pos))
		{
			print("Warning: findmin: cannot walk from v3 to min.\n");
			find_min_state = 3;
			return;
		}
		
		mid1 = memalloc(sizeof(navgen_vertex));
		vec_eq(&(mid1->pos),vert1->pos);
		mid3 = memalloc(sizeof(navgen_vertex));
		vec_eq(&(mid3->pos),vert3->pos);
		
		add_debug_hull_line(vert1->pos,vert3->pos,[1,0,0]);
		
		
		find_min_state = 1;
		return;
	}
}


//===============================================================================================================================
//===============================================================================================================================
//========================================== End Test section for debugging find_min algorithm ======================================
//===============================================================================================================================
//===============================================================================================================================


void cl_navmesh_gen_navmesh()
{
	disable_print = 1;
	//temp_call_find_min();
	
	//navgen_verts_root = 0;
	
	//vector player_pos = getentity(player_localentnum, GE_ORIGIN);
	vector player_pos;
	
	if(disable_print)
		disable_print = 0;
	else
		disable_print = 1;
	
	vec_eq(&player_pos,getentity(player_localentnum, GE_ORIGIN));
	
	//Find floor at pos
	cl_navgen_gen_drop_to_floor(player_pos);
	//player_pos = trace_endpos;
	vec_eq(&player_pos,trace_endpos);
	
	float initial_tri_size = 40;//10
	
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
	
	recursive_depth = 0;
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
