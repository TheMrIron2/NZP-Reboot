/*
+------+
|Client|
+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Handle's "clients" (eg, Players) connecting, disconnecting, etc.           |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/
void() ClientKill = {};

void() ClientConnect = {bprint("Client connected\n");};
void() ClientDisconnect = {bprint("Client disconnected\n");};

void() PlayerPreThink = 
{
};

void() PlayerPostThink = 
{	
};
void() PutClientInServer =
{
	local entity spawn_spot;             		// This holds where we want to spawn
	spawn_spot = find (world, classname, "info_player_start"); // Find it :)

	self.classname = "player";           		// I'm a player!
	self.health = self.max_health = 100; 		// My health (and my max) is 100
	self.takedamage = DAMAGE_AIM;        		// I can be fired at
	self.solid = SOLID_SLIDEBOX;         		// Things sort of 'slide' past me
	self.movetype = MOVETYPE_WALK;       		// Yep, I want to walk.
	self.flags = FL_CLIENT;              		// Yes, I'm a client.

	self.origin = spawn_spot.origin + '0 0 1'; 	// Move to the spawnspot location
	self.angles = spawn_spot.angles;     		// Face the angle the spawnspot indicates
	self.fixangle = TRUE;                		// Turn this way immediately

	setmodel (self, "progs/player.mdl"); 		// Set my player to the player model
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX); // Set my size

	//self.view_ofs = '0 0 22';            			// Center my view
	self.view_ofs = VEC_VIEW_OFS;            			// Center my view
	self.velocity = '0 0 0';           			// Stop any old movement
	
	self.currentammo = 32;						// Give reserve ammo
	self.currentmag = 8;						// Give magazine ammo
	self.weapon = W_COLT;						// Define weapon	
	
	self.grenades = self.grenades | 1; //add frag grenades to player inventory
	self.primary_grenades = 0; //add frag grenades to player inventory
};

