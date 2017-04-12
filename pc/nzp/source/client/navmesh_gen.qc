
/*
#define NAV_MAX_SELECTED_VERTS 4
float selected_verts[NAV_MAX_SELECTED_VERTS];
float selected_vert_count;

navmesh_vertex cl_navmesh_verts[NAV_MAX_VERTS];
float cl_navmesh_vert_count;

navmesh_poly cl_navmesh_polies[NAV_MAX_POLIES];
float cl_navmesh_poly_count;


*/

//Vector assignment function, because fteqcc seems to have a broken vec1 = vec2; implementation (works only sometimes)
//Functionally equivalent to saying (*a)=b;
void vec_eq(vector* a, vector b)
{
	(*a) = b;
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
vector debug_hulls[200];
vector debug_hull_scales[200];
vector debug_hull_colors[200];
float debug_hull_alphas[200];

float debug_hull_count;

void add_debug_hull(vector pos, vector scale, vector color, float alpha)
{
	debug_hulls[debug_hull_count] = pos;
	debug_hull_scales[debug_hull_count] = scale;
	debug_hull_colors[debug_hull_count] = color;
	debug_hull_alphas[debug_hull_count++] = alpha;
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
	
	//Drawing debug collision hulls
	for(float i = 0; i < debug_hull_count; i++)
	{
		cl_navmesh_draw_test_ent(debug_hulls[i],debug_hull_scales[i],debug_hull_colors[i],debug_hull_alphas[i]);
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
	//tracebox(start - [0,0,1],VEC_HULL_MIN,VEC_HULL_MAX,start-[0,0,max_step_size],MOVE_NOMONSTERS,self);
	tracebox(start,VEC_HULL_MIN,VEC_HULL_MAX,start-[0,0,2*max_step_size],MOVE_NOMONSTERS,self);
	if((!trace_allsolid && !trace_startsolid) && trace_fraction > 0.5)
	{
		print("Trace fraction: ",ftos(trace_fraction),"\n");
		print("start solid: ",ftos(trace_startsolid)," all solid: ",ftos(trace_allsolid),"\n");
		print("We are not on ground to begin, returning 0\n");
		
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
					success[i] = 2;
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

//Walks to x & y coordinate of point, returns vector of how far we got
//We walk in dist increments, and assume we are unobstructed
vector cl_navgen_gen_walk_to_point(vector start, vector point)
{
	float dist = 3;
	
	vector cur;
	vec_eq(&(cur),start);
	
	vector dir;
	vec_eq(&(dir),normalize([point_x,point_y,0] - [start_x,start_y,0]));
	
	vector cur_ofs;
	vec_eq(&(cur_ofs), dir * dist);
	
	float move;
	
	
	float iters = 0;
	vector last_pos;
	vec_eq(&(last_pos),cur);	
	float updated_x = 0;
	
	while(1)
	{	
		if(iters++ >= 9999)
		{
			print("\n\nWarning: iterations exceeded 9998\n");
			print("Trying to walk from ",vtos(start)," to ",vtos(point),"\n");
			
			print("Info: cur_ofs:",vtos(cur_ofs)," cur:", vtos(cur)," last pos:",vtos(last_pos),"\n");
			
			
			
			add_debug_hull(start,[1,1,1],[0,1,0],0.1);
			add_debug_hull(start,[0.01,0.01,0.01],[0,1,0],0.2);
			
			add_debug_hull(point,[1,1,1],[1,0,0],0.1);
			add_debug_hull(point,[0.01,0.01,0.01],[0,1,0],0.2);
			
			add_debug_hull(cur,[1,1,1],[1,1,1],0.1);
			add_debug_hull(cur,[0.01,0.01,0.01],[1,1,1],0.2);
			
			add_debug_hull(last_pos,[1,1,1],[0.5,0.5,0.5],0.1);
			add_debug_hull(last_pos,[0.01,0.01,0.01],[0.5,0.5,0.5],0.2);
			
			
			debug_hulls[debug_hull_count++] = start;
			debug_hulls[debug_hull_count++] = point;
			debug_hulls[debug_hull_count++] = cur;
			debug_hulls[debug_hull_count++] = last_pos;
			
			
			print("cur ofs x: ",ftos(cur_ofs_x),", delta x: ",ftos(point_x-cur_x),"\n");
			print("cur ofs y: ",ftos(cur_ofs_y),", delta y: ",ftos(point_y-cur_y),"\n");
			
			return start;
		}
		//Don't walk past endpoint
		if((cur_ofs_x > 0 && cur_ofs_x > (point_x - cur_x)) || (cur_ofs_x < 0 && cur_ofs_x < (point_x - cur_x)))
		{
			//print("x walk dist exceeds actual dist, decreasing walk dist.\n");
			
			//print("cur_ofs_x ",ftos(cur_ofs_x)," -> ",ftos(point_x - cur_x),"\n");
			print("\n cur_ofs_x is set to ",ftos(point_x-cur_x),"\n");
			cur_ofs_x = point_x - cur_x;
			
			print("\n cur_x+cur_ofs_x: ",ftos(cur_x+cur_ofs_x),"  point_x: ",ftos(point_x),"\n");
			updated_x = 1;
		}
		else
			updated_x = 0;
			
		if((cur_ofs_y > 0 && cur_ofs_y > (point_y - cur_y)) || (cur_ofs_y < 0 && cur_ofs_y < (point_y - cur_y)))
		{
			//print("y walk dist exceeds actual dist, decreasing walk dist.\n");
			
			//print("cur_ofs_y ",ftos(cur_ofs_y)," -> ",ftos(point_y - cur_y),"\n");
			
			cur_ofs_y = point_y - cur_y;
			
		}
		
		//If we are at the endpoint
		if(cur_ofs_x == 0 && cur_ofs_y == 0)
		{
			print("ofs is 0, walk_to_point succeeded, point = ",vtos(point),"\n");
			vec_eq(&(trace_endpos),cur);
			return point;
		}
		
		
		move = cl_navgen_gen_walk(cur,cur_ofs);
		
		if(move == 0 || move == 1)//We do not allow sliding or partial moves in this algorithm
		{
			//debug_hulls[debug_hull_count++] = cur;
			//debug_hulls[debug_hull_count++] = cur + cur_ofs;
			print("hit something along the way, walk_to_point failed\n");
			//print("cur: ",vtos(cur)," cur_ofs: ",vtos(cur_ofs),"\n");
			return start;
		}
		
		vec_eq(&(last_pos),cur);
		vec_eq(&(cur),trace_endpos);
		
		if(updated_x == 1)
			print(" got to pos x: ",ftos(cur_x),"\n");
	}
	return start;
}



//Returns 0 if edge is unobstructed
//Returns 1 if walking directly from pos1 to pos2 fails
//Returns 1 if walking directly from pos2 to pos1 fails
//TODO: handle ledges and hitting the navmesh
float cl_navgen_obstructed(vector pos1, vector pos2)
{
	//Try walk from pos1 to pos2
	
	if(cl_navgen_gen_walk_to_point(pos1,pos2) != pos2)
	{
		//print("could not walk from pos1 to pos2 (Result was not: ",vtos(pos2),")\n");
		return 1;
	}
	//Try walk from pos2 to pos1
	if(cl_navgen_gen_walk_to_point(pos2,pos1) != pos1)
	{
		//print("could not walk from pos2 to pos1\n");
		return 1;
	}
		
	return 0;
}


//Given pos1 that can walk to other, and pos2 that cannot walk to other
//Returns furthest point from pos1 (on line from pos1 to pos2) that can still walk to other
vector cl_navgen_find_min(vector pos1, vector pos2, vector other)
{
	vector min;
	vec_eq(&(min),pos1);
	vector max;
	vec_eq(&(max),pos2);
	vector mid;
	
	
	float delta = 0.01;//how close does the min and max have to be for us to accept min as the desired point?
	
	//debug_hulls[debug_hull_count++] = pos1;
	//debug_hulls[debug_hull_count++] = pos2;
	
	//====== temp =======
	
//	print("Find min: ",vtos(pos1),"->",vtos(pos2)," : ",vtos(other),", [");
	
	vector pos2xy = [pos2_x,pos2_y,0];
	vector pos1xy = [pos1_x,pos1_y,0];
	
	float xylen = vlen([pos2_x - pos1_x,pos2_y - pos1_y,0]);
	float iters = 0;
	//===================
		
	while(1)
	{
		//This should not happen
		if(iters++ > 1000)
		{
			print("\n\nWarning: iterations > 1000 encountered.\n");
			
			//debug_hulls[debug_hull_count++] = pos1;
			//debug_hulls[debug_hull_count++] = pos2;
			//debug_hulls[debug_hull_count++] = mid;
			print("Find min: ",vtos(pos1),"->",vtos(pos2)," : ",vtos(other),", \n");
			print("Fraction: (",ftos(vlen([min_x,min_y,0]-pos1xy)/xylen),",",ftos(vlen([max_x,max_y,0]-pos1xy)/xylen),")\n");
			
			return min;
		}
		//===temp===
//		print(" (",ftos(vlen([min_x,min_y,0]-pos1xy)/xylen),",",ftos(vlen([max_x,max_y,0]-pos1xy)/xylen),"),");
		//==========

		if(vlen([max_x,max_y,0]-[min_x,min_y,0]) < delta)
		{
//			print("]\n");
			return min;
		}
			
		vec_eq(&(mid),(min+max)/2);
		
		if(cl_navgen_gen_walk_to_point(min,mid) == mid)
		{
			//This should always run
			vec_eq(&(mid),trace_endpos);
			//debug_hulls[debug_hull_count++] = mid;
		}
		else
		{
			print("!!!!!!!!!!!!!!!! Warning: could not walk to mid from min.\n");
			//FIXME: this sometimes executes
			//I guess we can't just rely on jumping back and forth across large gaps
			
			//debug_hulls[debug_hull_count++] = min;
			//debug_hulls[debug_hull_count++] = mid;
		}
		
		//debug_hulls[debug_hull_count++] = min;
		//debug_hulls[debug_hull_count++] = max;
		
		if(cl_navgen_obstructed(mid,other))
			vec_eq(&(max),mid);
		else
			vec_eq(&(min),mid);
	}
}

//TODO: method that resolves a corner on a bsp hull, we essentially walk back and forth with one vert until:
//	moving back and forth a tiny tiny amount is the difference between an obstructed edge and an unobstructed edge

//For temporarily not continuing the recursion
float recursive_depth;

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
	
	//walk the vertex in the direction a small amount
	while(1)
	{
		//Try walking a small amount forward
		vec_eq(&(last_vert_pos),vert->pos);
		
		move = cl_navgen_gen_walk(vert->pos,walk_dir);
		
		vec_eq(&(vert->pos),trace_endpos);
		
		print("Move result: ",ftos(move),"\n");
		if(!move && !did_move)
		{
			break;
		}
		did_move = 1;
		
		
		
		//check if left edge was obstructed
		print("Checking left to vert edge\n");
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
			
			
			//Get new_vert as close as possible to our vert such that we can still walk to our left vert
//			print("Before: ",vtos(new_vert->pos));
			
			vec_eq(&(new_vert->pos), cl_navgen_find_min(new_vert->pos,vert->pos,(new_vert->left)->pos));
//			print("After: ",vtos(new_vert->pos));
			
			
			//Get new_vert as close as possible to our left vert such that we can still walk to our vert
			vec_eq(&(new_vert->pos), cl_navgen_find_min(new_vert->pos,(new_vert->left)->pos,vert->pos));
			
			vec_eq(&(vert->pos), last_vert_pos);
			
			
			//Check if the new vertex didn't move
			if(vert->pos == new_vert->pos)
			{
				print("Subdivided vertex did not move, subdivision undone\n");
				//Undo the subdivision
				vert->left = new_vert->left;
				(new_vert->left)->right = vert;
				
				cl_navgen_free_vert(new_vert);
			}
			else
			{
				recursive_depth++;
				cl_navgen_gen_floodfill(vert);
				recursive_depth--;
			}
			
			return;
		}
	
		//check if right edge was obstructed
		print("Checking vert to right edge\n");
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
			
			//Get new_vert as close as possible to our vert such that we can still walk to our right vert
			vec_eq(&(new_vert->pos), cl_navgen_find_min(new_vert->pos,vert->pos,(new_vert->right)->pos) );
			//Get new_vert as close as possible to our right vert such that we can still walk to our vert
			vec_eq(&(new_vert->pos), cl_navgen_find_min(new_vert->pos,(new_vert->right)->pos,vert->pos) );
			
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
				recursive_depth++;
				cl_navgen_gen_floodfill(vert);
				recursive_depth--;
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
			
			if(cl_navgen_gen_walk_to_point(vert->pos,edge_center) == edge_center)
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
			
			if(cl_navgen_gen_walk_to_point(vert->pos,edge_center) == edge_center)
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



void cl_navmesh_gen_navmesh()
{
	//TODO: create 3 vertices in a triangle at player position, call floodfill on all 3
	
	//navgen_verts_root = 0;
	
	//vector player_pos = getentity(player_localentnum, GE_ORIGIN);
	vector player_pos;
	
	vec_eq(&player_pos,getentity(player_localentnum, GE_ORIGIN));
	
	//Find floor at pos
	cl_navgen_gen_walk(player_pos,[0,0,0]);
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
