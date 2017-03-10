
//=================================================================================================================
//						Navmesh related functions
//=================================================================================================================

//Outlining what exactly I'm going to do
//List of all navmesh verts
//Lists of all polygons, who in turn have list of indices of all vertices that make up the polygons

//in editor:
//	we place vertices wherever we want
//	we select whatever vertices we want, and can make a polygon with them


//Things I want to handle:
//	placing two verts near a corner, and have them merge (sort of like find intersection between two edges and connect the edges at the intersection)


struct navmesh_vertex
{
	vector pos;
};



//Either a tri or a quad
struct navmesh_poly
{
	float verts[4];
	float vert_count;
	
	//The following two fields are for the pathfinding usage, they are useless for the editor itself
	float connected_polies[4];//What polygons we share an edge with (similar to links), more than 4 should be impossible
	float connected_polies_count;
	//FIXME: we can do directional polygons by in some way calculating this connected polies field in some other way
	vector center;//The center of the polygon in 3D space
};



//All vertices that ngons use in linked list
//navmesh_ngon_vert navmesh_all_verts[1024];
#define NAV_MAX_SELECTED_VERTS 4
float selected_verts[NAV_MAX_SELECTED_VERTS];
float selected_vert_count;

#define NAV_MAX_VERTS 1024
navmesh_vertex navmesh_verts[NAV_MAX_VERTS];
float navmesh_vert_count;

#define NAV_MAX_POLIES 512
navmesh_poly navmesh_polies[NAV_MAX_POLIES];
float navmesh_poly_count;


float navmesh_place_corner_state;
#define NAVMESH_PLACE_CORNER_PLACING 1
#define NAVMESH_PLACE_CORNER_CONFIRM 2


void navmesh_draw_vert(vector pos,float selected)
{
	//Assigning the shader as something else so that fte doesn't batch the calls (leading to colors not changing between draw calls)
	R_BeginPolygon("debug/wireframe",0);
	R_BeginPolygon("debug/solid_nocull",0);
	
	vector color;
	
	if(selected == 1)
		color = [1,1,0];
	else if(selected == 0)
		color = [0,0,1];
	else if(selected == 2)
		color = [0.5,0.5,1.0];
	else if(selected == 3)
		color = [0.5,1.0,0.5];
	else if(selected == 4)
		color = [1.0,0.0,0.0];
	else
		color = [0,0,0];
	
	float alpha = 0.4;
	
	//bottom face
	R_PolygonVertex(pos + [-5,5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,-5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [-5,-5,-5], [0,0,0], color,alpha);
	R_EndPolygon();
	//Top face
	R_PolygonVertex(pos + [-5,5,5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,5,5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,-5,5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [-5,-5,5], [0,0,0], color,alpha);
	R_EndPolygon();
	//Front face
	R_PolygonVertex(pos + [-5,-5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,-5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,-5,5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [-5,-5,5], [0,0,0], color,alpha);
	R_EndPolygon();
	//Back face
	R_PolygonVertex(pos + [-5,5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,5,5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [-5,5,5], [0,0,0], color,alpha);
	R_EndPolygon();
	//Left face
	R_PolygonVertex(pos + [-5,-5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [-5,5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [-5,5,5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [-5,-5,5], [0,0,0], color,alpha);
	R_EndPolygon();
	//Right face
	R_PolygonVertex(pos + [5,-5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,5,-5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,5,5], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [5,-5,5], [0,0,0], color,alpha);
	R_EndPolygon();
}


void navmesh_draw_poly(float poly_index)
{
	//Assigning the shader as something else so that fte doesn't batch the calls (leading to colors not changing between draw calls)
	R_BeginPolygon("debug/wireframe",0);
	R_BeginPolygon("debug/solid_nocull",0);
	
	vector color = [0.2,0.8,0.2];
	
	float face_alpha = 0.1;
	
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[0]].pos, [0,0,0], color, face_alpha);
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[1]].pos, [0,0,0], color, face_alpha);
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[2]].pos, [0,0,0], color, face_alpha);
	if(navmesh_polies[poly_index].vert_count > 3)
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[3]].pos, [0,0,0], color, face_alpha);
	R_EndPolygon();
	
	
	//Drawing polygon border
	//Assigning the shader as something else so that fte doesn't batch the calls (leading to colors not changing between draw calls)
	R_BeginPolygon("debug/wireframe",0);
	R_BeginPolygon("debug/solid_nocull",0);
	color = [0.5,0.5,0.5];
	float edge_width = 2;
	float edge_alpha = 0.2;
	//Vert 0->1
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[1]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[1]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[0]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[0]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
	R_EndPolygon();
	//Vert 1->2
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[2]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[2]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[1]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
	R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[1]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
	R_EndPolygon();
	
	if(navmesh_polies[poly_index].vert_count == 3)
	{
		//Vert 2->0
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[0]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[0]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[2]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[2]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
		R_EndPolygon();
	}
	else//Quad
	{
		//Vert 2->3
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[3]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[3]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[2]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[2]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
		R_EndPolygon();
		//Vert 3->0
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[0]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[0]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[3]].pos + [0,0,edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[navmesh_polies[poly_index].verts[3]].pos + [0,0,-edge_width], [0,0,0], color, edge_alpha);
		R_EndPolygon();
	}
}

float navmesh_is_vert_selected(float vert_index)
{
	for(float i = 0; i < selected_vert_count; i++)
	{
		if(selected_verts[i] == vert_index)
			return TRUE;
	}
	return FALSE;
}


void navmesh_editor_draw()
{
	for(float i = 0; i < navmesh_vert_count; i++)
	{
		navmesh_draw_vert(navmesh_verts[i].pos, navmesh_is_vert_selected(i) );
	}
	
	for(float i = 0; i < navmesh_poly_count; i++)
	{
		navmesh_draw_poly(i);
	}
	
	navmesh_draw_test_ent(0);
	navmesh_draw_test_ent(1);
	
	pathfind_draw_result_node_path();
	pathfind_draw_result_portals();
	pathfind_draw_result_path();
	
	if(navmesh_place_corner_state == NAVMESH_PLACE_CORNER_PLACING || navmesh_place_corner_state == NAVMESH_PLACE_CORNER_CONFIRM)
	{
		
		//vector vorg = getviewprop(VF_ORIGIN);
		//vector vorg = getentity(player_localentnum, GE_ORIGIN);
		//vector vorg = getviewprop(VF_ORIGIN) - VEC_VIEW_OFS;
		vector vorg = getviewprop(VF_ORIGIN);
		vector vang = getviewprop(VF_ANGLES);
	
		vector vang_left1 = vang + [0,6,0];//Two degrees to the left
		vector vang_left2 = vang + [0,5,0];//Three degrees to the left
		vector vang_right1 = vang + [0,-6,0];//Two degrees to the right
		vector vang_right2 = vang + [0,-5,0];//Three degrees to the right
		
		makevectors(vang);
		vector vang_fwd = v_forward;
		
		makevectors(vang_left1);
		vector vang_left1_fwd = v_forward;
		//Trace out to wall
		tracebox(vorg,VEC_HULL_MIN,VEC_HULL_MAX,vorg+(vang_left1_fwd * 2000),1,self);
		vector wall_hit_left1 = vorg+(vang_left1_fwd * 2000)*trace_fraction;
		//Trace down to ground
		tracebox(wall_hit_left1,VEC_HULL_MIN,VEC_HULL_MAX,wall_hit_left1+([0,0,-1] * 2000),1,self);
		
		vector hit_left1 = wall_hit_left1 + (([0,0,-1] * 2000) * trace_fraction);
		
		makevectors(vang_left2);
		vector vang_left2_fwd = v_forward;
		//Trace out to wall
		tracebox(vorg,VEC_HULL_MIN,VEC_HULL_MAX,vorg+(vang_left2_fwd * 2000),1,self);
		vector wall_hit_left2 = vorg+(vang_left2_fwd * 2000)*trace_fraction;
		//Trace down to ground
		tracebox(wall_hit_left2,VEC_HULL_MIN,VEC_HULL_MAX,wall_hit_left2+([0,0,-1] * 2000),1,self);
		
		vector hit_left2 = wall_hit_left2 + (([0,0,-1] * 2000) * trace_fraction);
		
		
		makevectors(vang_right1);
		vector vang_right1_fwd = v_forward;
		//Trace out to wall
		tracebox(vorg,VEC_HULL_MIN,VEC_HULL_MAX,vorg+(vang_right1_fwd * 2000),1,self);
		vector wall_hit_right1 = vorg+(vang_right1_fwd * 2000)*trace_fraction;
		//Trace down to ground
		tracebox(wall_hit_right1,VEC_HULL_MIN,VEC_HULL_MAX,wall_hit_right1+([0,0,-1] * 2000),1,self);
		
		vector hit_right1 = wall_hit_right1 + (([0,0,-1] * 2000) * trace_fraction);
		
		
		makevectors(vang_right2);
		vector vang_right2_fwd = v_forward;
		//Trace out to wall
		tracebox(vorg,VEC_HULL_MIN,VEC_HULL_MAX,vorg+(vang_right2_fwd * 2000),1,self);
		vector wall_hit_right2 = vorg+(vang_right2_fwd * 2000)*trace_fraction;
		//Trace down to ground
		tracebox(wall_hit_right2,VEC_HULL_MIN,VEC_HULL_MAX,wall_hit_right2+([0,0,-1] * 2000),1,self);
		
		vector hit_right2 = wall_hit_right2 + (([0,0,-1] * 2000) * trace_fraction);
		
		navmesh_draw_vert(hit_left1, 0 );
		navmesh_draw_vert(hit_left2, 0 );
		navmesh_draw_vert(hit_right1, 0 );
		navmesh_draw_vert(hit_right2, 0 );
		
		//TODO: draw walls that we have hit (2 flat planes on the walls we hit)
		
		//===================== Calculate the resolved vertex pos =======================
		//This solution only works for 90 degree corners
		
		//Line 1 extends from l1a in direction l1_dir
		/*vector l1a;
		l1a = hit_left2;
		vector l1_dir = normalize(hit_left1 - l1a);
		//The third point
		vector p2 = hit_right1;
		
		//Considering only l1_dir in the 2d plane of z=0
		
		vector vert_loc;
		vert_loc.z = l1a.z;
		
		//Is the line vertical?
		if(l1_dir.x == 0)//Is the line vertical?
		{
			vert_loc.x = l1a.x;
			vert_loc.y = p2.y;
			//FIXME
		}
		else if(l1_dir.y == 0)//Is the line horizontal?
		{
			vert_loc.x = p2.x;
			vert_loc.y = l1a.y;
			//FIXME
		}
		else
		{
			//Getting slope of line 1
			float m = (hit_left1.y - hit_left2.y) / (hit_left1.x - hit_left2.x);
			
			float x1 = p2.x - l1a.x;
			float y1 = p2.y - l1a.y;
			
			vert_loc.x = (x1 + m*y1)/(m*m + 1);
			vert_loc.y = (-1/m) * (vert_loc.x-x1) + y1;
		}
		
		vert_loc.x += l1a.x;
		vert_loc.y += l1a.y;*/
		
		
		//===============================================================================
		//This solution should work with any corner
		//===============================================================================
		
		//Line 1: hit_left1 -> hit_left2
		//Line 2: hit_right1 -> hit_right2
		vector vert_loc;
		
		float skew = 0;
		float horizontal = 1;
		float vertical = 2;
		
		float line_1_orient = skew;
		float line_2_orient = skew;
		
		//Check left wall is horizontal
		if(hit_left1.y == hit_left2.y)
		{
			line_1_orient = horizontal;
		}
		//Check if the left wall is vertical
		else if(hit_left1.x == hit_left2.x)
		{
			line_1_orient = vertical;
		}
		
		//Check if the right wall is horizontal
		if(hit_right1.y == hit_right2.y)
		{
			line_2_orient = horizontal;
		}
		//Check if the right wall is vertical
		else if(hit_right1.x == hit_right2.x)
		{
			line_2_orient = vertical;
		}
		
		//Checking if the lines are parallel and not skew
		if(line_1_orient == line_2_orient && line_1_orient != skew)
		{
			if(navmesh_place_corner_state == NAVMESH_PLACE_CORNER_CONFIRM)
			{
				print("Cannot place corner for parallel walls (there is no corner).\n");
				navmesh_place_corner_state = NAVMESH_PLACE_CORNER_PLACING;
			}
			return;
		}
		
		//Checking other special cases
		else if(line_1_orient == horizontal && line_2_orient == vertical)
		{
			vert_loc.x = hit_right1.x;
			vert_loc.y = hit_left1.y;
		}
		else if(line_1_orient == vertical && line_2_orient == horizontal)
		{
			vert_loc.x = hit_left1.x;
			vert_loc.y = hit_right1.y;
		}
		else if(line_1_orient == vertical)//line 2 is skew
		{
			vert_loc.x = hit_left1.x;
			//Plugging in vert_loc.x into equation of line 2 to get vert_loc.y
			//Slope of line 2
			float m2_a = (hit_right2.y - hit_right1.y)/(hit_right2.x - hit_right1.x);
			vert_loc.y = m2_a*(vert_loc.x - hit_right1.x) + hit_right1.y;
		}

		else if(line_2_orient == vertical)//line 1 is skew
		{
			vert_loc.x = hit_right1.x;
			//P;ugging in vert_loc.x into equation of line 1 to get vert_loc.y
			//Slope of line 1
			float m1_a = (hit_left2.y - hit_left1.y)/(hit_left2.x - hit_left1.x);
			vert_loc.y = m1_a*(vert_loc.x - hit_left1.x) + hit_left1.y;
		}
		else//Both lines are skew or horizontal
		{
			//Slope of line 1
			float m1 = (hit_left2.y - hit_left1.y)/(hit_left2.x - hit_left1.x);
			//Slope of line 2
			float m2 = (hit_right2.y - hit_right1.y)/(hit_right2.x - hit_right1.x);
			
			//Checking if the walls are parallel
			if(m1 == m2)
			{
				if(navmesh_place_corner_state == NAVMESH_PLACE_CORNER_CONFIRM)
				{
					print("Cannot place corner for skew parallel walls (there is no corner).\n");
					navmesh_place_corner_state = NAVMESH_PLACE_CORNER_PLACING;
				}
				return;
			}
			
			//Resolving the corner vertex location (this is derived from the solution of the two lines)
			vert_loc.x = ((m1 * hit_left1.x) - (m2 * hit_right1.x) + hit_right1.y - hit_left1.y) / (m1 - m2);
			//Plugging in vert_loc.x to the equation of the first line to get vert_loc.y
			vert_loc.y = m1*(vert_loc.x - hit_left1.x) + hit_left1.y;
		}
		
		//Placing the vert as the highest z-value
		float highest_z = hit_left1.z;
		
		if(hit_left2.z > highest_z)
			highest_z = hit_left2.z;
		if(hit_right1.z > highest_z)
			highest_z = hit_right1.z;
		if(hit_right2.z > highest_z)
			highest_z = hit_right2.z;
		vert_loc.z = highest_z;
		
		//Traceboxing down from that vert position to get actual height
		tracebox(vert_loc,VEC_HULL_MIN,VEC_HULL_MAX,vert_loc+([0,0,-1] * 2000),1,self);
		vert_loc.z = vert_loc.z + (-2000 * trace_fraction);
		
		
		//================================================================================
		
		//Render the resolved vertex pos
		navmesh_draw_vert(vert_loc, 1 );
			
		if(navmesh_place_corner_state == NAVMESH_PLACE_CORNER_CONFIRM)
		{	
			navmesh_verts[navmesh_vert_count].pos.x = vert_loc.x;
			navmesh_verts[navmesh_vert_count].pos.y = vert_loc.y;
			navmesh_verts[navmesh_vert_count].pos.z = vert_loc.z;
			
			navmesh_vert_count++;
			
			navmesh_place_corner_state = 0;
		}
		
	}
	
	//For using tracebox to place vertices
	/*vector vorg = getviewprop(VF_ORIGIN);
	vector vang = getviewprop(VF_ANGLES);
	
	makevectors(vang);
	
	//v_forward, v_right, v_up
	getviewprop(VF_ACTIVESEAT);
	
	//Tracebox out from there
	//Zombie dimensions
	tracebox(vorg,[-8,-8,-32],[8,8,30],vorg+(v_forward * 2000),1,self);
	
	
	//Tracebox down from there
	vector vpos1 = vorg+(v_forward*2000)*trace_fraction;
	navmesh_draw_vert(vpos1, 0 );
	
	tracebox(vpos1,[-8,-8,-32],[8,8,30],vpos1+([0,0,-1] * 2000),1,self);
	vector vpos2 = vpos1+(([0,0,-1] * 2000) * trace_fraction);
	
	navmesh_draw_vert(vpos2, 1 );*/
	
	//Tracebox down from there	
}

//Places a vertex at player position
void navmesh_place_vert()
{
	if(navmesh_vert_count >= navmesh_verts.length)
	{
		print("Can't add vertex, max vert count has been reached.\n");
		return;
	}
	
	//Placing the vert at player origin
	vector vert_pos = getentity(player_localentnum, GE_ORIGIN);
	
	navmesh_verts[navmesh_vert_count].pos.x = vert_pos.x;
	navmesh_verts[navmesh_vert_count].pos.y = vert_pos.y;
	navmesh_verts[navmesh_vert_count].pos.z = vert_pos.z;

	print("Vertex ");
	print(ftos(navmesh_vert_count));
	print(" created.\n");
	
	navmesh_vert_count++;
}

//Deletes all selected vertices
void navmesh_delete_verts()
{
	if(selected_vert_count <= 0)
	{
		print("No vertices selected.\n");
		return;
	}
	
	for(float i = 0; i < selected_vert_count; i++)
	{
		float vert = selected_verts[i];
		print("Deleting vert: ");
		print(ftos(vert));
		print(".\n");
		//Check if vertex is in any polygons, if so delete that polygon
		for(float j = 0; j < navmesh_poly_count; j++)
		{
			for(float k = 0; k < navmesh_polies[j].vert_count; k++)
			{
				if(navmesh_polies[j].verts[k] == vert)
					navmesh_delete_poly_at_index(j);	
			}
		}
		
		
		//Bringing all vertices down to not leave any holes in the array
		//Moving down every index to the right of what we deselected to not leave any holes
		for(float j = vert; j < navmesh_vert_count - 1; j++)
		{
			navmesh_verts[j].pos.x = navmesh_verts[j+1].pos.x;
			navmesh_verts[j].pos.y = navmesh_verts[j+1].pos.y;
			navmesh_verts[j].pos.z = navmesh_verts[j+1].pos.z;
		}
		//Clearing the last one
		navmesh_verts[navmesh_vert_count-1].pos = [0,0,0];
		navmesh_vert_count--;
		
		
		//Fixing references to verts in all polygons
		for(float j = 0; j < navmesh_poly_count; j++)
		{
			for(float k = 0; k < navmesh_polies[j].vert_count; k++)
			{
				if(navmesh_polies[j].verts[k] >= vert)
					navmesh_polies[j].verts[k]--;
			}
		}
		//Fixing references of selected verts
		for(float j = i; j < selected_vert_count; j++)
		{
			if(selected_verts[j] >= vert)
				selected_verts[j]--;
		}
	}
	selected_vert_count = 0;
	for(float i = 0; i < selected_verts.length; i++)
	{
		selected_verts[i] = -1;
	}
}


//=================================== Navmesh vertex selection functions ===================================
//Returns index of the vertex that is nearest to the player
float navmesh_get_nearest_vert()
{
	if(navmesh_vert_count <= 0)
	{
		return -1;
	}
	
	vector player_pos = getentity(player_localentnum, GE_ORIGIN);
	float closest_dist = vlen(player_pos - navmesh_verts[0].pos);
	float closest_index = 0;
	
	float temp_dist;
	
	for(float i = 1; i < navmesh_vert_count; i++)
	{
		temp_dist = vlen(player_pos - navmesh_verts[i].pos);
		
		if(temp_dist < closest_dist)
		{
			closest_dist = temp_dist;
			closest_index = i;
		}
	}
	return closest_index;
}

//Selects the nearest vertex
void navmesh_select_vert()
{
	if(selected_vert_count >= selected_verts.length)
	{
		print("Can't select another vertex, max vertices selected.\n");
		return;
	}
	
	float vert = navmesh_get_nearest_vert();
	if(vert == -1)
	{
		print("No vertices to select");
		return;
	}
	if(navmesh_is_vert_selected(vert))
	{
		print("Vert is already selected.\n");
		return;
	}
	
	print("Vertex ");
	print(ftos(vert));
	print(" selected.\n");
	selected_verts[selected_vert_count++] = vert;
}


//Deselects the nearest vertex
void navmesh_deselect_vert()
{
	float vert = navmesh_get_nearest_vert();
	
	if(vert == -1)
	{
		print("No vertices to select.\n");
		return;
	}
	
	for(float i = 0; i < selected_vert_count; i++)
	{
		if(selected_verts[i] == vert)
		{
			selected_verts[i] = -1;
			
			//Moving down every index to the right of what we deselected to not leave any holes
			for(float j = i; j < selected_vert_count - 1; j++)
			{
				selected_verts[j] = selected_verts[j+1];
			}
			selected_verts[selected_vert_count - 1] = -1;
			selected_vert_count--;
			
			print("Vertex ");
			print(ftos(i));
			print(" deselected.\n");
			return;
		}
	}
	print("Vertex is not selected.\n");
}

//Deselects all vertices
void navmesh_deselect_all()
{
	for(float i = 0; i < selected_verts.length; i++)
	{
		selected_verts[i] = -1;
	}
	selected_vert_count = 0;
	
	
	print("All vertices deselected.\n");
}

//=============================================================================================================

float navmesh_is_poly_selected()
{
	//Check if this polygon already exists
	float verts_selected[4];
	
	for(float i = 0; i < navmesh_poly_count; i++)
	{
		verts_selected[0] = FALSE;
		verts_selected[1] = FALSE;
		verts_selected[2] = FALSE;
		verts_selected[3] = FALSE;
		
		//Check each of the poly's verts
		for(float j = 0; j < navmesh_polies[i].vert_count; j++)
		{
			//Check each of our selected verts to see if they are in this polygon
			for(float k = 0; k < selected_vert_count; k++)
			{
				if(navmesh_polies[i].verts[j] == selected_verts[k])
				{
					verts_selected[j] = TRUE;
				}
			}
			
			//This poly vert was not selected
			if(verts_selected[j] == FALSE)
			{
				break;
			}
		}
		
		if(navmesh_polies[i].vert_count == 3)
		{
			if(verts_selected[0] == TRUE && verts_selected[1] == TRUE && verts_selected[2] == TRUE)
			{
				return TRUE;
			}
		}
		else if(navmesh_polies[i].vert_count == 4)
		{
			if(verts_selected[0] == TRUE && verts_selected[1] == TRUE && verts_selected[2] == TRUE && verts_selected[3] == TRUE)
			{
				return TRUE;
			}
		}
	}
	return FALSE;
}


void navmesh_make_poly()
{
	if(selected_vert_count < 3)
	{
		print("Not enough selected vertices to make a polygon (need 3).\n");
		return;
	}
	
	if(navmesh_poly_count >= navmesh_polies.length)
	{
		print("Max polygon count reached.\n");
		return;
	}
	
	if(navmesh_is_poly_selected())
	{
		print("This polygon already exists.\n");
		return;
	}
	
	
	//Sorting the verts so the polygon is build consecutively (i.e. vert 0 -> vert 1 is an edge, 1->2, 2->3, and 3->0 are all edges)
	//Furthermore, this sorting will ensure the verts are sorted in a clockwise order, so we also apply it to tris
	
	//Calculating center of the polygon
	local vector center = [0,0,0];
	for(float j = 0; j < selected_vert_count; j++)
	{
		center += navmesh_verts[selected_verts[j]].pos;
	}
	center /= selected_vert_count;
	
	float vert_angle[NAV_MAX_SELECTED_VERTS] = {};
	
	//Calculating angle of verts
	for(float j = 0; j < selected_vert_count; j++)
	{
		vert_angle[j] = atan2(navmesh_verts[selected_verts[j]].pos.y - center.y,navmesh_verts[selected_verts[j]].pos.x - center.x);
	}
	
	//Sorting from least to greatest
	for(float j = 0; j < selected_vert_count; j++)
	{
		//Finding lowest value from j to selected_vert_count
		float lowest_value = vert_angle[j];
		float lowest_index = j;
		for(float k = j; k < selected_vert_count; k++)
		{
			if(vert_angle[k] < lowest_value)
			{
				lowest_value = vert_angle[k];
				lowest_index = k;
			}
		}
		//Swapping the lowest value with index j
		float temp_angle = vert_angle[j];
		vert_angle[j] = vert_angle[lowest_index];
		vert_angle[lowest_index] = temp_angle;
		
		float temp_vert = selected_verts[j];
		selected_verts[j] = selected_verts[lowest_index];
		selected_verts[lowest_index] = temp_vert;
	}
	
	

	for(float i = 0; i < selected_vert_count; i++)
	{
		navmesh_polies[navmesh_poly_count].verts[i] = selected_verts[i];
	}
	navmesh_polies[navmesh_poly_count].vert_count = selected_vert_count;
	navmesh_poly_count++;
}

void navmesh_delete_poly_at_index(float poly_index)
{
	//Starting at this polygon, move every polygon after in the array down one (leave no holes in the array)
	//Moving down every index to the right of what we deselected to not leave any holes
	for(float i = poly_index; i < navmesh_poly_count - 1; i++)
	{
		navmesh_polies[i].vert_count = navmesh_polies[i+1].vert_count;
		for(float j = 0; j < navmesh_polies[i].verts.length; j++)
		{
			navmesh_polies[i].verts[j] = navmesh_polies[i+1].verts[j];
		}
	}
	//Clearing the last one
	navmesh_polies[navmesh_poly_count-1].vert_count = 0;
	for(float j = 0; j < navmesh_polies[navmesh_poly_count-1].verts.length; j++)
	{
		navmesh_polies[navmesh_poly_count-1].verts[j] = -1;
	}
	navmesh_poly_count--;
}

void navmesh_delete_poly()
{
	float verts_selected[4];
	float poly_index = -1;
	//Find index of the polygon whose vertices are all selected
	for(float i = 0; i < navmesh_poly_count; i++)
	{
		verts_selected[0] = FALSE;
		verts_selected[1] = FALSE;
		verts_selected[2] = FALSE;
		verts_selected[3] = FALSE;
		
		//Check each of the poly's verts
		for(float j = 0; j < navmesh_polies[i].vert_count; j++)
		{
			//Check each of our selected verts to see if they are in this polygon
			for(float k = 0; k < selected_vert_count; k++)
			{
				if(navmesh_polies[i].verts[j] == selected_verts[k])
				{
					verts_selected[j] = TRUE;
				}
			}
			
			//This poly vert was not selected
			if(verts_selected[j] == FALSE)
			{
				break;
			}
		}
		
		if(navmesh_polies[i].vert_count == 3)
		{
			if(verts_selected[0] == TRUE && verts_selected[1] == TRUE && verts_selected[2] == TRUE)
			{
				poly_index = i;
				break;
			}
		}
		else if(navmesh_polies[i].vert_count == 4)
		{
			if(verts_selected[0] == TRUE && verts_selected[1] == TRUE && verts_selected[2] == TRUE && verts_selected[3] == TRUE)
			{
				poly_index = i;
				break;
			}
		}
	}
	if(poly_index == -1)
	{
		print("A polygon is not selected.\n");
		return;
	}
	
	//Starting at this polygon, move every polygon after in the array down one (leave no holes in the array)
	//Moving down every index to the right of what we deselected to not leave any holes
	for(float i = poly_index; i < navmesh_poly_count - 1; i++)
	{
		navmesh_polies[i].vert_count = navmesh_polies[i+1].vert_count;
		for(float j = 0; j < navmesh_polies[i].verts.length; j++)
		{
			navmesh_polies[i].verts[j] = navmesh_polies[i+1].verts[j];
		}
	}
	//Clearing the last one
	navmesh_polies[navmesh_poly_count-1].vert_count = 0;
	for(float j = 0; j < navmesh_polies[navmesh_poly_count-1].verts.length; j++)
	{
		navmesh_polies[navmesh_poly_count-1].verts[j] = -1;
	}
	navmesh_poly_count--;			
	print("Deleted polygon.\n");
}

//Treats 1st and 2nd selected verts as line 1, 3rd and 4th verts as line 2, places a new vertex at the intersection of these lines
void navmesh_resolve_corner()
{
	if(selected_vert_count < 3)
	{
		print("You need to select at least 3 vertices to resolve a corner.\n");
		return;
	}
	
	//Line 1 extends from l1a in direction l1_dir
	vector l1a;
	l1a = navmesh_verts[selected_verts[0]].pos;
	vector l1_dir = normalize(navmesh_verts[selected_verts[1]].pos - l1a);
	//The third point
	vector p2 = navmesh_verts[selected_verts[2]].pos;
	
	
	//Considering only l1_dir in the 2d plane of z=0
	
	vector vert_loc;
	vert_loc.z = l1a.z;
	
	//Is the line vertical?
	if(l1_dir.x == 0)//Is the line vertical?
	{
		vert_loc.x = l1a.x;
		vert_loc.y = p2.y;
	}
	else if(l1_dir.y == 0)//Is the line horizontal?
	{
		vert_loc.x = p2.x;
		vert_loc.y = l1a.y;
	}
	else
	{
		//Getting slope of line 1
		float m = l1_dir.y / l1_dir.x;
		
		float x1 = p2.x - l1a.x;
		float y1 = p2.y - l1a.y;
		
		vert_loc.x = (x1 + m*y1)/(m*m + 1);
		vert_loc.y = (-1/m) * (vert_loc.x-x1) + y1;
	}
	
	vert_loc.x += l1a.x;
	vert_loc.y += l1a.y;
	
	
	//Place a new vert at the location
	navmesh_verts[navmesh_vert_count].pos.x = vert_loc.x;
	navmesh_verts[navmesh_vert_count].pos.y = vert_loc.y;
	navmesh_verts[navmesh_vert_count].pos.z = vert_loc.z;
	
	print("Resolved corner with vertex ");
	print(ftos(navmesh_vert_count));
	print(" at (");
	print(ftos(vert_loc.x));
	print(" , ");
	print(ftos(vert_loc.y));
	print(" , ");
	print(ftos(vert_loc.z));
	print(").\n");
	
	
	navmesh_vert_count++;
}

void navmesh_place_corner()
{
	navmesh_place_corner_state = NAVMESH_PLACE_CORNER_PLACING;
}
void navmesh_cancel_corner()
{
	navmesh_place_corner_state = 0;
}
void navmesh_confirm_corner()
{
	if(navmesh_place_corner_state == NAVMESH_PLACE_CORNER_PLACING)
		navmesh_place_corner_state = NAVMESH_PLACE_CORNER_CONFIRM;
}

void toggle_navmesh_editor()
{
	
	if(navmesh_mode == TRUE)
	{
		print("navmesh editor: 0\n");
		navmesh_mode = FALSE;
	}
	else
	{
		print("navmesh editor: 1\n");
		navmesh_mode = TRUE;
		navmesh_deselect_all();
	}
}


void navmesh_calc_connected_polies()
{
	for(float i = 0; i < navmesh_poly_count; i++)
	{
		for(float j = i + 1; j < navmesh_poly_count; j++)
		{
			//Check if poly j shares an edge with poly i
			
			//Edge case: where two opposite corners (two corners not on the same edge) of a quad are shared with another poly
			//but this edge case is a result of terrible topology, so I will not consider it
			
			//Check if poly j shares at least 2 vertices with poly i
			//I'm not sure what sharing more than 2 verts means... but it's a result of bad topology, so I will not consider it
			//		if two quads share 4: they are the same 			-> bad topology
			//		if two quads share 3: one of them is convex, one is concave 	-> bad topology
			//		if a quad shares 3 with a tri: the tri is within the quad 	-> bad topology
			//		if two tris share 3: they are the same 				-> bad topology
			float shared_verts = 0;
			
			//Iterate over ith poly's verts
			for(float k = 0; k < navmesh_polies[i].vert_count; k++)
			{
				//Iterate over jth poly's verts
				for(float l = 0; l < navmesh_polies[j].vert_count; l++)
				{
					if(navmesh_polies[i].verts[k] == navmesh_polies[j].verts[l])
					{
						shared_verts++;
					}
				}
			}
			
			//Print a warning if more than 2, should be impossible
			if(shared_verts > 2)
			{
				print("Warning: polygon ");
				print(ftos(i));
				print(" shares ");
				print(ftos(shared_verts));
				print(" vertices with polygon ");
				print(ftos(j));
				print(". There is an issue somewhere.\n");
			}
			//Should I print a warning if they share 3 or 4? (it's a result of bad topology)
			if(shared_verts >= 2)
			{
				//Setting the polygons as connected to each other
				if(navmesh_polies[i].connected_polies_count >= 4)
				{
					print("Warning: polygon ");
					print(ftos(i));
					print(" shares an edge with more than 4 other polygons.\n");
					break;
				}
				if(navmesh_polies[j].connected_polies_count >= 4)
				{
					print("Warning: polygon ");
					print(ftos(j));
					print(" shares an edge with more than 4 other polygons.\n");
					break;
				}
				navmesh_polies[i].connected_polies[navmesh_polies[i].connected_polies_count++] = j;
				navmesh_polies[j].connected_polies[navmesh_polies[j].connected_polies_count++] = i;
				print("Poly ");
				print(ftos(i));
				print(" is connected to ");
				print(ftos(j));
				print(" and poly ");
				print(ftos(j));
				print(" is connected to ");
				print(ftos(i));
				print(".\n");
			}	
		}
	}
	print("Connected polygons calculated.\n");
}

//We calculate this outside of polygon creation / editing because the polygon centers are not important to creation, only to actually using in pathfinding
void navmesh_calc_polies_centers()
{
	for(float i = 0; i < navmesh_poly_count; i++)
	{
		local vector cen = [0,0,0];
		for(float j = 0; j < navmesh_polies[i].vert_count; j++)
		{
			cen += navmesh_verts[navmesh_polies[i].verts[j]].pos;
		}
		cen /= navmesh_polies[i].vert_count;
		navmesh_polies[i].center.x = cen.x;
		navmesh_polies[i].center.y = cen.y;
		navmesh_polies[i].center.z = cen.z;
	}
	print("Centers calculated.\n");
}


//==================================================================
//TEMP TEMP TEMP for testing
float pathfinding_specific_navmesh_data_calculated;
//This float is set to TRUE once we have calculated the polygon centers and connected polygons
//We don't precalculate them because we don't care about this data in editor
//This data should be calculated by navmesh exporter, and loaded in by navmesh importer
//So this data should exist by the time pathfinding functions are executed, hence why I calculate it just before calling pathfind.
//==================================================================


//==========================================================================================================================
//============================ The following methods are methods required in the pathfinding code ==========================
//==========================================================================================================================
//This is for placing a temp entity to test the pathfinding
vector goalent_pos;
float goalent_set;
vector startent_pos;
float startent_set;

void navmesh_draw_test_ent(float is_goal)
{
	//Assigning the shader as something else so that fte doesn't batch the calls (leading to colors not changing between draw calls)
	R_BeginPolygon("debug/wireframe",0);
	R_BeginPolygon("debug/solid_nocull",0);
	
	//vector	VEC_HULL_MIN = '-16 -16 -32';
	//vector	VEC_HULL_MAX = '16 16 40';
	float min_x = -16;
	float min_y = -16;
	float min_z = -32;
	float max_x = 16;
	float max_y = 16;
	float max_z = 40;
	
	vector color;
	
	vector pos;
	
	if(is_goal)
	{
		pos = goalent_pos;
		color = [1,0,0];
	}
	else
	{
		pos = startent_pos;
		color = [0,1,0];
	}
	
	float alpha = 0.4;
	
	//bottom face
	R_PolygonVertex(pos + [min_x,max_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,max_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,min_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [min_x,min_y,min_z], [0,0,0], color,alpha);
	R_EndPolygon();
	//Top face
	R_PolygonVertex(pos + [min_x,max_y,max_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,max_y,max_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,min_y,max_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [min_x,min_y,max_z], [0,0,0], color,alpha);
	R_EndPolygon();
	//Front face
	R_PolygonVertex(pos + [min_x,min_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,min_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,min_y,max_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [min_x,min_y,max_z], [0,0,0], color,alpha);
	R_EndPolygon();
	//Back face
	R_PolygonVertex(pos + [min_x,max_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,max_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,max_y,max_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [min_x,max_y,max_z], [0,0,0], color,alpha);
	R_EndPolygon();
	//Left face
	R_PolygonVertex(pos + [min_x,min_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [min_x,max_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [min_x,max_y,max_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [min_x,min_y,max_z], [0,0,0], color,alpha);
	R_EndPolygon();
	//Right face
	R_PolygonVertex(pos + [max_x,min_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,max_y,min_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,max_y,max_z], [0,0,0], color,alpha);
	R_PolygonVertex(pos + [max_x,min_y,max_z], [0,0,0], color,alpha);
	R_EndPolygon();
}

void navmesh_place_test_goalent()
{
	goalent_pos = getentity(player_localentnum, GE_ORIGIN);
	
	goalent_set = TRUE;
	
	
	//Calculate data that the navmesh exporer will calculate, but only do it once.
	if(pathfinding_specific_navmesh_data_calculated == FALSE)
	{
		pathfinding_specific_navmesh_data_calculated = TRUE;
		navmesh_calc_polies_centers();
		navmesh_calc_connected_polies();
	}
	
	if(goalent_set == TRUE && startent_set == TRUE)
	{
		float start = navmesh_get_containing_poly(startent_pos);
		float goal = navmesh_get_containing_poly(goalent_pos);
		pathfind_start(start,goal,startent_pos,goalent_pos);
	}
	

}
void navmesh_place_test_startent()
{
	startent_pos = getentity(player_localentnum, GE_ORIGIN);
	
	startent_set = TRUE;
	
	//Calculate data that the navmesh exporer will calculate, but only do it once.
	if(pathfinding_specific_navmesh_data_calculated == FALSE)
	{
		pathfinding_specific_navmesh_data_calculated = TRUE;
		navmesh_calc_polies_centers();
		navmesh_calc_connected_polies();
	}
	
	if(goalent_set == TRUE && startent_set == TRUE)
	{
		float start = navmesh_get_containing_poly(startent_pos);
		float goal = navmesh_get_containing_poly(goalent_pos);
		pathfind_start(start,goal,startent_pos,goalent_pos);
	}
}

//Returns 1 if pos is inside poly at index poly_index, 0 otherwise
float navmesh_is_inside_poly(vector pos, float poly_index)
{
	
	//TODO: check if z coord is close enough to poly
	
	local vector vert_to_pos;//points from vert to pos
	local vector vert_to_next;//points from vert to the next vertex
	local vector vert;
	local vector next_vert;
	float vert_count = navmesh_polies[poly_index].vert_count;
	//We are considered to be in the polygon, if pos is on the left of all edges of the polygon (if verts are ordered in CW order)
	for(float i = 0; i < vert_count; i++)
	{
		vert = navmesh_verts[navmesh_polies[poly_index].verts[i]].pos;
		next_vert = navmesh_verts[navmesh_polies[poly_index].verts[(i + 1) % vert_count]].pos;
		
		vert_to_pos = pos - vert;
		vert_to_next = next_vert - vert;
		
		//Check if vert_to_pos is to the left of vert_to_next
		if(vert_to_next.x * vert_to_pos.y - vert_to_next.y * vert_to_pos.x < 0)
			return 0;
	}
	
	
	//FOR DEBUG: select that polygon if succesfull
	navmesh_deselect_all();
	selected_vert_count = navmesh_polies[poly_index].vert_count;
	for(float i = 0; i < selected_vert_count; i++)
	{
		selected_verts[i] = navmesh_polies[poly_index].verts[i];
	}	
	//============================================
	
	
	return 1;
}

//Returns the distance between the 2d line l1->l2 and pos
float navmesh_2D_line_point_dist(vector l1, vector l2, vector pos)
{
	float dot = (l2 - l1) * (pos - l2);
	if(dot > 0)
		return vlen(l2 - pos);
		
	dot = (l1 - l2) * (pos - l1);
	if(dot > 0)
		return vlen(l1 - pos);
	
	//2D cross product between (next_vert-vert) and (pos-vert)
	//float dist = (l2.x - l1.x) * (pos.y - l1.y) - (l2.y - l1.y) * (pos.y - l1.y);
	//dist = dist / vlen(l1 - l2);
	
	float dist = vlen(crossproduct(l2-l1,l1-pos))/vlen(l1-l2);
	
	return fabs(dist);
}

//Returns distance from pos to an edge of the poly if pos is very close to an edge of the poly at index poly_index, -1 otherwise
float navmesh_is_close_to_poly(vector pos, float poly_index)
{
	float leeway = 30;//Must be within 30 qu of edge to be considered close
	
	//TODO: check if close enough on z-axis
	
	local vector vert_to_pos;//points from vert to pos
	local vector vert_to_next;//points from vert to the next vertex
	
	
	local vector vert;
	local vector next_vert;
	float vert_count = navmesh_polies[poly_index].vert_count;
	
	float shortest_dist = 100000;
	
	//Only considering 2D
	//pos.z = 0;
	
	//We are considered to be in the polygon, if pos is on the left of all edges of the polygon (if verts are ordered in CW order)
	for(float i = 0; i < vert_count; i++)
	{
		vert = navmesh_verts[navmesh_polies[poly_index].verts[i]].pos;
		next_vert = navmesh_verts[navmesh_polies[poly_index].verts[(i + 1) % vert_count]].pos;
		
		//Calculating in 2D:
		//vert.z = 0;
		//next_vert.z = 0;
		
		float temp_dist = navmesh_2D_line_point_dist(vert, next_vert, pos);
		
		if(temp_dist < shortest_dist)
		{
			print("shorter dist: ");
			print(ftos(temp_dist));
			print(".\n");
			shortest_dist = temp_dist;
		}	
	}
	
	if(shortest_dist < leeway)
		return shortest_dist;
	
	return -1;
}

//Returns polygon that pos is inside of. 
//If we are in no polygon, returns a polygon whose edge we are sufficiently close to (might be in but are not due to a small error)
//Otherwise, returns -1
float navmesh_get_containing_poly(vector pos)
{
	//Get nearest polygon, and check if pos is in that polygon
	
	float poly_tried[NAV_MAX_POLIES] = {};
	
	float closest_poly = -1;
	float closest_poly_dist = 1000000;
	
	//In reality, there's no need to try ALL polygons, the one we are in should be within the nearest 10 or so, but checking all to be safe
	for(float i = 0; i < navmesh_poly_count; i++)
	{
		
		//Find the first poly we haven't tried.
	
		float lowest_dist = 100000;//Would initialize to first one, but we would have to find the first unused poly, which is a waste of calculations
		float lowest_index = -1;
		
		for(float j = 0; j < navmesh_poly_count; j++)
		{
			float temp_dist = vlen(navmesh_polies[0].center - pos);
			
			if(temp_dist < lowest_dist)
			{
				lowest_dist = temp_dist;
				lowest_index = j;
			}
		}
		
		
		//Check if we are in polygon i
		if(navmesh_is_inside_poly(pos,i))
		{
			print("Ent pos is inside poly: ");
			print(ftos(i));
			print(".\n");
			return i;
		}
		
		//If we are not in polygon i, check if we are very close to one of its edges
		float dist = navmesh_is_close_to_poly(pos,i);
		
		if(dist >= 0)
		{
			if(dist < closest_poly_dist)
			{
				closest_poly = i;
			}
		}

	}
	
	
	//FOR DEBUG: select that polygon if succesfull
	if(closest_poly != -1)
	{
		navmesh_deselect_all();
		selected_vert_count = navmesh_polies[closest_poly].vert_count;
		for(float i = 0; i < selected_vert_count; i++)
		{
			selected_verts[i] = navmesh_polies[closest_poly].verts[i];
		}
	}
	//============================================
	
	if(closest_poly == -1)
	{
		print("Ent pos is not in or near any polygons.\n");
	}
	else
	{
		print("Ent pos is near but not in poly: closest_poly.\n");
	}
	
	return closest_poly;
}




//================================================================================================================
//=============================================== Actual A* functions ============================================
//================================================================================================================


#define PATHFIND_POLY_SET_NONE 0
#define PATHFIND_POLY_SET_OPEN 1
#define PATHFIND_POLY_SET_CLOSED 2
//Contains what set the ith polygon is in
float pathfind_poly_set[NAV_MAX_POLIES];
//Contains the index of the last polygon that we used to get to the ith polygon
float pathfind_poly_prev[NAV_MAX_POLIES];
//Contains the g-score of the ith polygon (distance from start node to ith node along the node path)
float pathfind_poly_g_score[NAV_MAX_POLIES];

//Calculates the heuristic h score value (Our best guess for how far this node is from the goal node)
float pathfind_calc_h_score(float current, float goal)
{
	//FIXME: we could just as easily return vlen()^2 for comparisons... (saves a sqrt operation)
	return vlen(navmesh_polies[goal].center - navmesh_polies[current].center);
}

//f score = g score + h score
float pathfind_poly_f_score[NAV_MAX_POLIES];


//TEMP ARRAY THAT HOLDS THE RESULTS OF THE PATHFIND (contains index of polygon in order from start to goal)
float pathfind_result_node_path[NAV_MAX_POLIES];
//How many polies are in the path
float pathfind_result_node_length;

//Contains a list of points that makes up the path
vector pathfind_result_path[NAV_MAX_POLIES];
//How many points are in the path
float pathfind_result_length;

//Together, these two arrays hold the list of portals (edges) we cross on the path
float pathfind_portals_left_vert[NAV_MAX_POLIES];
float pathfind_portals_right_vert[NAV_MAX_POLIES];
//pathfind_portals_length is the same as (pathfind_result_node_length - 1)
//How many portals are in the pathfind_portals_left_vert
float pathfind_portals_length;


//TODO: when I add funnel algorithm, keep a list of vectors instead of a list of polygon indices


//Returns the polygon with the lowest f score from polygons the open set
float pathfind_get_lowest_f_score()
{
	//TODO: implement a better algorithm for finding the lowest score
	
	float best_score = 100000;
	float best_score_index = -1;
	
	for(float i = 0; i < navmesh_poly_count; i++)
	{
		if(pathfind_poly_set[i] == PATHFIND_POLY_SET_OPEN)
		{
			if(pathfind_poly_f_score[i] < best_score)
			{
				best_score = pathfind_poly_f_score[i];
				best_score_index = i;
			}
		}
	}
	
	return best_score_index;
}

void pathfind_clear_temp_data()
{
	//Technically we only need to iterate over navmesh_poly_count...
	for(float i = 0; i < NAV_MAX_POLIES; i++)
	{
		pathfind_poly_set[i] = PATHFIND_POLY_SET_NONE;
		pathfind_poly_prev[i] = -1;
		pathfind_poly_g_score[i] = 0;
		pathfind_poly_f_score[i] = 0;
		pathfind_result_node_path[i] = -1;
		
		pathfind_result_path[i].x = 0;
		pathfind_result_path[i].y = 0;
		pathfind_result_path[i].z = 0;
		
		pathfind_portals_right_vert[i] = -1;
		pathfind_portals_left_vert[i] = -1;
	}
	pathfind_result_node_length = 0;
	pathfind_result_length = 0;
	pathfind_portals_length = 0;
}

//Returns some number > 0 if point p is to the left of line a->b
//Returns some number < 0 if point is to the right of line a->b
//Returns 0 if point is on the line
//(Left / Right is defined in the xy plane, z=0)
float pathfind_point_is_to_left(vector a, vector b, vector p)
{
	return (b.x - a.x)*(p.y - a.y) - (b.y - a.y)*(p.x - a.x);
}

//Returns the signed cos^2(theta) where theta is the smaller angle between the vectors (left-apex) and (right-apex)
float pathfind_signed_cos_squared(vector apex, vector left, vector right)
{
	//v1 is the left edge of the funnel
	vector v1 = left - apex;
	//v2 is the right edge of the funnel
	vector v2 = right - apex;
	
	float dot = v1*v2;
	//Getting the sign of the dot product (because we lose it when squaring it)
	float sign = dot / fabs(dot);
	return sign * (dot*dot) / ((v1*v1)*(v2*v2));
}

//Applies a funnel algorithm to the path defined by the array pathfind_result_node_path 
// and populates pathfind result path
void pathfind_smooth_path(vector start_point, vector goal_point)
{
	//Evaluate portals and identify left / right portal vertices
	for(float i = 1; i < pathfind_result_node_length; i++)
	{
		float prev_poly = pathfind_result_node_path[i-1];
		float poly = pathfind_result_node_path[i];
		/*vector prev_poly_pos;
		prev_poly_pos.x = navmesh_polies[prev_poly].center.x;
		prev_poly_pos.y = navmesh_polies[prev_poly].center.y;
		prev_poly_pos.z = navmesh_polies[prev_poly].center.z;
		vector poly_pos;
		poly_pos.x = navmesh_polies[poly].center.x;
		poly_pos.y = navmesh_polies[poly].center.y;
		poly_pos.z = navmesh_polies[poly].center.z;*/
		//Was going to use 
		
		//Find the two vertices that these polygons share
		//Because polygons must share two consecutive verts:
		//the CCW winding of the triangle dictates that the next shared vertex is to the left of, and in the index after the first shared vertex
		//i.e. of the two consecutive verts shard, the former is to the right
		
		float shared_verts[2];
		shared_verts[0] = -1;
		shared_verts[1] = -1;
		float shared_verts_index[2];//The index of the vert in previous poly's vert list
		shared_verts_index[0] = -1;
		shared_verts_index[1] = -1;
		float verts_found = 0;
		
		//TODO: consider precalculating the shared edge in the links
		for(float j = 0; j < navmesh_polies[prev_poly].vert_count; j++)
		{
			for(float k = 0; k < navmesh_polies[poly].vert_count; k++)
			{
				if(navmesh_polies[prev_poly].verts[j] == navmesh_polies[poly].verts[k])
				{
					shared_verts[verts_found] = navmesh_polies[prev_poly].verts[j];
					shared_verts_index[verts_found++] = j;
				}
				if(verts_found > 1)
					break;
			}
			if(verts_found > 1)
				break;
		}
		
		//if first one is a quad: shared edge must be, where the first index is right and second index is left
		//3-0, 0-1, 1-2, 2-3
		//if first one is a tri: shared edge must be, where the first index is right and second index is left
		//2-0, 0-1, 1-2
		
		//Two distinct cases:
		//If index of first is 0, and index of second is 2 or 3
		if(shared_verts_index[0] == 0 && shared_verts_index[1] >= 2)
		{
			//then left is 0, right is 3 or 4
			pathfind_portals_left_vert[pathfind_portals_length] = shared_verts[0];
			pathfind_portals_right_vert[pathfind_portals_length++] = shared_verts[1];
			
		}
		else
		{
			//Else, one with the lower index is right, higher index is left
			pathfind_portals_right_vert[pathfind_portals_length] = shared_verts[0];
			pathfind_portals_left_vert[pathfind_portals_length++] = shared_verts[1];
		}
	}
	
	print("Portals: ");
	for(float i = 0; i < pathfind_portals_length; i++)
	{
		print("[");
		print(ftos(i));
		print("] = (");
		print(ftos(pathfind_portals_left_vert[i]));
		print(" , ");
		print(ftos(pathfind_portals_right_vert[i]));
		print(") , ");
	}
	
	//starting at start_pos (not at start center point)
	//get vectors that point to first left edge and first right edge
	
	vector funnel_apex = start_point;
	float funnel_left_index = 0;
	//Index of the funnel's left vertex in the portal list
	vector funnel_left = navmesh_verts[pathfind_portals_left_vert[0]].pos;
	//Index of the funnel's right vertex in the portal list
	float funnel_right_index = 0;
	vector funnel_right = navmesh_verts[pathfind_portals_right_vert[0]].pos;
	
	float last_cos_squared = -1;
	
	while(1)
	{
		print("=============Funnel iteration.==========\n");
		//Check if we have reached the end of the portals, consider the goal position as the last portal
		//If we are not at the last index of the left portal
		
		//Keeping track of whether or not advancing the left edge or right edge narrows the funnel
		float advanced_left = FALSE;
		float advanced_right = FALSE;
		
		float cos_squared = 0;
		
		
		//Consider the end goal point as the last portal
		//================ Checking left funnel edge =================
		if(funnel_left_index < pathfind_portals_length)
		{
			print("Trying to advance left edge.\n");
			//Calculate the angle of advancing the left portal
			vector next_funnel_left;
			
			if(funnel_left_index < pathfind_portals_length - 1)
			{
				next_funnel_left = navmesh_verts[pathfind_portals_left_vert[funnel_left_index+1]].pos;
				print("Next left edge is vert: ");
				print(ftos(pathfind_portals_left_vert[funnel_left_index+1]));
				print(".\n");
			}
			else
			{
				print("Trying next left edge as goal point.\n");
				//If funnel_left is pointing to the last portal in the array, consider the goal_point the last portal
				next_funnel_left = goal_point;
			}
			//Get cos^2 of angle between vectors
			cos_squared = pathfind_signed_cos_squared(funnel_apex, next_funnel_left, funnel_right);
			
			//If the next left edge crosses the current right edge
			if(pathfind_point_is_to_left(funnel_apex,funnel_right,next_funnel_left) < 0)
			{
				print("next left edge crosses current right edge.\n");
				//Add funnel right point to path
				pathfind_result_path[pathfind_result_length++] = funnel_right;
				
				//Check if we are at the end of our portal list
				if(funnel_right_index >= pathfind_portals_length - 1)
				{
					pathfind_result_path[pathfind_result_length++] = goal_point;
					return;
				}
				
				
				//Restart algorithm with the portal after the right point
				funnel_apex = funnel_right;
				
				funnel_left_index = funnel_right_index + 1;
				funnel_left = navmesh_verts[pathfind_portals_left_vert[funnel_left_index]].pos;
				funnel_right_index = funnel_right_index + 1;
				funnel_right = navmesh_verts[pathfind_portals_right_vert[funnel_right_index]].pos;
				last_cos_squared = pathfind_signed_cos_squared(funnel_apex, funnel_left, funnel_right);
				continue;
			}
			
			//If the next left edge narrows the funnel
			if(cos_squared >= last_cos_squared)
			{
				printf("next left edge narrows the funnel, %f >= %f.\n",cos_squared,last_cos_squared);
				//Advance the left edge
				funnel_left = next_funnel_left;
				funnel_left_index++;
				
				advanced_left = TRUE;
				last_cos_squared = cos_squared;
				
				//Check if the portal we just added was the goal point (will be after the list)
				if(funnel_left_index >= pathfind_portals_length)
				{
					pathfind_result_path[pathfind_result_length++] = goal_point;
					return;
				}
			}
		}
		//================ Checking right funnel edge =================
		if(funnel_right_index < pathfind_portals_length)
		{
			print("Trying to advance right edge:.\n");
			//Calculate the angle of advancing the left portal
			vector next_funnel_right;
			
			if(funnel_right_index < pathfind_portals_length - 1)
			{
				next_funnel_right = navmesh_verts[pathfind_portals_right_vert[funnel_right_index+1]].pos;
				print("Next right edge is vert: ");
				print(ftos(pathfind_portals_right_vert[funnel_right_index+1]));
				print(".\n");
			}
			else
			{
				print("Trying next right edge as goal point.\n");
				//If funnel_right is pointing to the last portal in the array, consider the goal_point the last portal
				next_funnel_right = goal_point;
			}
			//Get cos^2 of angle between vectors
			cos_squared = pathfind_signed_cos_squared(funnel_apex, funnel_left, next_funnel_right);
			
			//If the next right edge crosses the current left edge
			if(pathfind_point_is_to_left(funnel_apex,funnel_left,next_funnel_right) > 0)
			{
				print("next right edge crosses current left edge.\n");
				//Add funnel left point to path
				pathfind_result_path[pathfind_result_length++] = funnel_left;
				
				//Check if we are at the end of our portal list
				if(funnel_left_index >= pathfind_portals_length - 1)
				{
					pathfind_result_path[pathfind_result_length++] = goal_point;
					return;
				}
				
				
				//Restart algorithm with the portal after the right point
				funnel_apex = funnel_left;
				
				funnel_right_index = funnel_left_index + 1;
				funnel_right = navmesh_verts[pathfind_portals_right_vert[funnel_right_index]].pos;
				funnel_left_index = funnel_left_index + 1;
				funnel_left = navmesh_verts[pathfind_portals_left_vert[funnel_left_index]].pos;
				last_cos_squared = pathfind_signed_cos_squared(funnel_apex, funnel_left, funnel_right);
				continue;
			}
			
			//If the next right edge narrows the funnel
			if(cos_squared >= last_cos_squared)
			{
				printf("next right edge narrows the funnel, %f >= %f.\n",cos_squared,last_cos_squared);
				//Advance the left edge
				funnel_right = next_funnel_right;
				funnel_right_index++;
				
				advanced_right = TRUE;
				last_cos_squared = cos_squared;
				
				//Check if the portal we just added was the goal point (will be after the list)
				if(funnel_right_index >= pathfind_portals_length)
				{
					pathfind_result_path[pathfind_result_length++] = goal_point;
					return;
				}
			}
		}
		if(advanced_left == FALSE && advanced_right == FALSE)
		{
			print("Hit funnel freeze condition.\n");
			return;
			//If neither the right nor the left vertex was advanced:
			//find the closest vert in the portal left verts that either crosses or is in the funnel
			//find the closest vert in the portal right verts that either crosses or is in the funnel
			//if any of the vertices cross, pick the one with the lower portal index:
			//	place a path corner at the opposite vertex of the current funnel
			//	resume the algorithm
			//if one or both of the found vertices are in the funnel:
			//	update the corresponding funnel edge points with the new corners
			//	resume the algorithm
			
			//TODO: when finding min verts, if the next one is the same as the current vertex, skip it (not sure if vertex equality is defined)
			//TODO: replace pathfind_portals array with vectors, and set the last one as the goal position
			
		}
	print("==========================\n");
	}
	//if advancing the left edge narrows the cone:
		//advance left edge
	//if advancing the left edge crosses the right edge:
		//set apex as the right edge
	//if advancing the right edge narrows the cone:
		//advance the right edge
	//if advancing the right edge crosses the left edge:
		//set apex as the left edge
	//if advancing the left edge widens and advancing the right edge widens
		//skip this portal
		
	//the last left edge / right edge is the goal position
}

//Evaluates the path that is found in the pathfinding algorithm and populates an array with the nodes in the path from start to goal
void pathfind_trace_path(float start, float goal)
{
	float current = start;
	//Count the length of the path (how many polygons the path traverses)
	current = goal;
	pathfind_result_node_length = 1;
	do
	{
		print("Poly ");
		print(ftos(current));
		print(" came from  ");
		print(ftos(pathfind_poly_prev[current]));
		print(".\n");
		current = pathfind_poly_prev[current];
		pathfind_result_node_length++;
	} while(current != start);
	
	
	//Starting at goal waypoint, add the traversed waypoints to the result path in reverse order
	current = goal;
	for(float i = 0; i < pathfind_result_node_length; i++)
	{
		pathfind_result_node_path[pathfind_result_node_length - 1 - i] = current;
		current = pathfind_poly_prev[current];
	}
	
	print("Pathfind success, path length: ");
	print(ftos(pathfind_result_node_length));
	print(".\n");
	
	print("Path: ");
	for(float i = 0; i < pathfind_result_node_length; i++)
	{
		if(i > 0)
			print(" , ");
		print(ftos(pathfind_result_node_path[i]));
	}
	print(" .\n");
}

//Accepts start polygon and goal polygon
//Returns 1 on success.
//Returns 0 on fail.
float pathfind_start(float start, float goal, vector start_pos, vector end_pos)
{
	if(start == -1)
	{
		print("Error: pathfind start node invalid.\n");
		return 0;
	}
	if(goal == -1)
	{
		print("Error: pathfind goal node invalid.\n");
		return 0;
	}
	if(start == goal)
	{
		//Calculating node path
		pathfind_result_node_path[0] = start;
		pathfind_result_node_length = 1;
		print("Pathind success: trivial case (start = goal).\n");
		
		//Calculating vector based path (go directly to goal)
		pathfind_result_path[0].x = end_pos.x;
		pathfind_result_path[0].y = end_pos.y;
		pathfind_result_path[0].z = end_pos.z;
		pathfind_result_length = 1;
		return 1;
	}
	
	//Clearing previous data
	pathfind_clear_temp_data();
	
	//Adding start polygon to the open set
	pathfind_poly_set[start] = PATHFIND_POLY_SET_OPEN;
	pathfind_poly_g_score[start] = 0;
	pathfind_poly_f_score[start] = 0 + pathfind_calc_h_score(start , goal);
	
	//Fields that need to be set:
	//pathfind_poly_set[NAV_MAX_POLIES];
	//pathfind_prev_poly[NAV_MAX_POLIES];
	//pathfind_poly_g_score[NAV_MAX_POLIES];
	//pathfind_poly_f_score[NAV_MAX_POLIES];
	
	print("Pathfind init. Start: ");
	print(ftos(start));
	print(" , Goal: ");
	print(ftos(goal));
	print(".\n");
	
	float current = start;
	
	float pathfind_success = FALSE;
	
	while(current != -1)
	{
		if(current == goal)
		{
			print("Current is now goal. Breaking.\n");
			pathfind_success = TRUE;
			break;
		}
		//Add current node to the closed set
		pathfind_poly_set[current] = PATHFIND_POLY_SET_CLOSED;
		//Add connected nodes to the open set
		for(float i = 0; i < navmesh_polies[current].connected_polies_count; i++)
		{
			float neighbor = navmesh_polies[current].connected_polies[i];
			
			print("Checking poly ");
			print(ftos(current));
			print("'s neighbor ");
			print(ftos(neighbor));
			print(".\n");
			
			if(pathfind_poly_set[neighbor] != PATHFIND_POLY_SET_CLOSED)
			{
				print("Neighbor is not in closed list.\n");
				//Calculate tentative f score
				//Calculate tentative g score (distance from start to current + distance from current to neighbor)
				float tentative_g_score = pathfind_poly_g_score[current] + vlen(navmesh_polies[neighbor].center - navmesh_polies[current].center);
				
				if(pathfind_poly_set[neighbor] != PATHFIND_POLY_SET_OPEN || tentative_g_score < pathfind_poly_g_score[neighbor])
				{
					print("Neighbor is not in open list, or a better g score has been found.\n");
					//Adding neighbor to open set
					pathfind_poly_set[neighbor] = PATHFIND_POLY_SET_OPEN;
					
					//Updating scores for neighbor node
					float tentative_f_score = tentative_g_score + pathfind_calc_h_score(neighbor , goal);
					pathfind_poly_g_score[neighbor] = tentative_g_score;
					pathfind_poly_f_score[neighbor] = tentative_f_score;
					
					//Linking neighbor node to current node (for tracing path)
					pathfind_poly_prev[neighbor] = current;
					
					print("Assigning Poly ");
					print(ftos(neighbor));
					print(" came from  ");
					print(ftos(current));
					print(".\n");
				}
				
			}
		}		
		
		current = pathfind_get_lowest_f_score();
	}
	
	
	//Tracing the pathfind results
	if(pathfind_success == TRUE)
	{
		pathfind_trace_path(start,goal);
		
		pathfind_smooth_path(start_pos,end_pos);
		
		return 1;
	}
	print("Pathfind fail");
	return 0;
}


//This renders the raw pathfind results (polygon center to polygon center)
void pathfind_draw_result_node_path()
{
	//FIXME: don't call if length is 0
	if(pathfind_result_node_length < 1)
		return;
	//================= Drawing Polygon Center ======================
	//=======================================
	//Assigning the shader as something else so that fte doesn't batch the calls (leading to colors not changing between draw calls)
	R_BeginPolygon("debug/wireframe",0);
	R_BeginPolygon("debug/solid_nocull",0);
	
	vector color;
	color = [1,0.1,0.5];
	float alpha = 0.2;//0.3
	float edge_width = 2;
	float edge_alpha = 0.2;//0.3
	
	for(float i = 0; i < pathfind_result_node_length; i++)
	{
		vector pos = navmesh_polies[pathfind_result_node_path[i]].center + [0,0,-5];
		//bottom face
		R_PolygonVertex(pos + [-5,5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,-5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [-5,-5,-5], [0,0,0], color,alpha);
		R_EndPolygon();
		//Top face
		R_PolygonVertex(pos + [-5,5,5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,5,5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,-5,5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [-5,-5,5], [0,0,0], color,alpha);
		R_EndPolygon();
		//Front face
		R_PolygonVertex(pos + [-5,-5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,-5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,-5,5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [-5,-5,5], [0,0,0], color,alpha);
		R_EndPolygon();
		//Back face
		R_PolygonVertex(pos + [-5,5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,5,5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [-5,5,5], [0,0,0], color,alpha);
		R_EndPolygon();
		//Left face
		R_PolygonVertex(pos + [-5,-5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [-5,5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [-5,5,5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [-5,-5,5], [0,0,0], color,alpha);
		R_EndPolygon();
		//Right face
		R_PolygonVertex(pos + [5,-5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,5,-5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,5,5], [0,0,0], color,alpha);
		R_PolygonVertex(pos + [5,-5,5], [0,0,0], color,alpha);
		R_EndPolygon();
		
		if(i > 0)
		{
			//Draw an edge connecting ith node to previous node
			R_PolygonVertex(navmesh_polies[pathfind_result_node_path[i]].center + [0,0,-5] + [0,0,-edge_width], [0,0,0], color, edge_alpha);
			R_PolygonVertex(navmesh_polies[pathfind_result_node_path[i]].center + [0,0,-5] + [0,0,edge_width], [0,0,0], color, edge_alpha);
			R_PolygonVertex(navmesh_polies[pathfind_result_node_path[i-1]].center + [0,0,-5] + [0,0,edge_width], [0,0,0], color, edge_alpha);
			R_PolygonVertex(navmesh_polies[pathfind_result_node_path[i-1]].center + [0,0,-5] + [0,0,-edge_width], [0,0,0], color, edge_alpha);
			R_EndPolygon();
		}
	}
	
	
}


void pathfind_draw_result_portals()
{
	if(pathfind_portals_length < 1)
		return;
	vector color;
	color = [0.5,0.5,1.0];
	float edge_width = 4;
	float edge_alpha = 0.2;//0.3
	
	for(float i = 0; i < pathfind_portals_length; i++)
	{
		navmesh_draw_vert(navmesh_verts[pathfind_portals_left_vert[i]].pos + [0,0,-10],2);
		navmesh_draw_vert(navmesh_verts[pathfind_portals_right_vert[i]].pos + [0,0,-8],3);
		
		R_BeginPolygon("debug/wireframe",0);
		R_BeginPolygon("debug/solid_nocull",0);
		
		//Draw an edge connecting portals
		R_PolygonVertex(navmesh_verts[pathfind_portals_left_vert[i]].pos + [0,0,-10] + [0,0,-edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[pathfind_portals_left_vert[i]].pos + [0,0,-10] + [0,0,edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[pathfind_portals_right_vert[i]].pos + [0,0,-8] + [0,0,edge_width], [0,0,0], color, edge_alpha);
		R_PolygonVertex(navmesh_verts[pathfind_portals_right_vert[i]].pos + [0,0,-8] + [0,0,-edge_width], [0,0,0], color, edge_alpha);
		R_EndPolygon();
	}
}

void pathfind_draw_result_path()
{		
	if(pathfind_result_length < 1)
		return;
		
	vector color;
	color = [1.0,0.0,0.0];
	float edge_width = 4;
	float edge_alpha = 0.2;//0.3
	
	//Drawing the a line connecting the start and first path node
	navmesh_draw_vert(startent_pos + [0,0,10],4);
	R_BeginPolygon("debug/wireframe",0);
	R_BeginPolygon("debug/solid_nocull",0);
	
	//Draw an edge connecting portals
	R_PolygonVertex(pathfind_result_path[0] + [0,0,10] + [0,0,-edge_width], [0,0,0], color, edge_alpha);
	R_PolygonVertex(pathfind_result_path[0] + [0,0,10] + [0,0,edge_width], [0,0,0], color, edge_alpha);
	R_PolygonVertex(startent_pos + [0,0,10] + [0,0,edge_width], [0,0,0], color, edge_alpha);
	R_PolygonVertex(startent_pos + [0,0,10] + [0,0,-edge_width], [0,0,0], color, edge_alpha);
	R_EndPolygon();
	
	
	for(float i = 0; i < pathfind_result_length; i++)
	{
		navmesh_draw_vert(pathfind_result_path[i] + [0,0,10],4);
		
		if(i > 0)
		{
			R_BeginPolygon("debug/wireframe",0);
			R_BeginPolygon("debug/solid_nocull",0);
			
			//Draw an edge connecting portals
			R_PolygonVertex(pathfind_result_path[i] + [0,0,10] + [0,0,-edge_width], [0,0,0], color, edge_alpha);
			R_PolygonVertex(pathfind_result_path[i] + [0,0,10] + [0,0,edge_width], [0,0,0], color, edge_alpha);
			R_PolygonVertex(pathfind_result_path[i-1] + [0,0,10] + [0,0,edge_width], [0,0,0], color, edge_alpha);
			R_PolygonVertex(pathfind_result_path[i-1] + [0,0,10] + [0,0,-edge_width], [0,0,0], color, edge_alpha);
			R_EndPolygon();
		}
	}
	
	
	
}

//==========================================================================================================================