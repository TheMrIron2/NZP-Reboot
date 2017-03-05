
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
	
	if(selected)
		color = [1,1,0];
	else
		color = [0,0,1];
	
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
	
	
	if(navmesh_place_corner_state == NAVMESH_PLACE_CORNER_PLACING || navmesh_place_corner_state == NAVMESH_PLACE_CORNER_CONFIRM)
	{
		
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
		
		//FIXME: check if line 1 is horizontal or vertical
		//FIXME: check if line 2 is horizontal or vertical
		
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
	
	vector player_pos = getviewprop(VF_ORIGIN);
	//Placing the vert at ent level
	
	
	tracebox(player_pos,VEC_HULL_MIN,VEC_HULL_MAX,player_pos+([0,0,-1] * 2000),1,self);
	
	vector vert_pos = player_pos+([0,0,-1] * 2000)*trace_fraction;
	

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
	
	vector player_pos = getviewprop(VF_ORIGIN);
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