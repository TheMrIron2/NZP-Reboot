// 
//		Clientfuncs -- used to communicate between server and client
//

void SetUpdate(entity client, float type, float val1, float val2, float val3)
{
	#ifndef PSP
	if (type != 2)
	{
		msg_entity = client;
		WriteByte(MSG_ONE, SVC_CGAMEPACKET);
		WriteByte(MSG_ONE, EVENT_UPDATE);
		WriteByte(MSG_ONE, type); // UT_HUD, UT_ROUNDS_CHANGE
		WriteByte(MSG_ONE, val1); 
		WriteByte(MSG_ONE, val2);
		WriteByte(MSG_ONE, val3); // misc flags/vars for later if needed
	}
	else
	{
		WriteByte(MSG_ALL, SVC_CGAMEPACKET);
		WriteByte(MSG_ALL, EVENT_UPDATE);
		WriteByte(MSG_ALL, type); // UT_HUD, UT_ROUNDS_CHANGE
		WriteByte(MSG_ALL, val1); 
		WriteByte(MSG_ALL, val2);
		WriteByte(MSG_ALL, val3); // misc flags/vars for later if needed
	}
	#endif
}

#ifndef PSP
void(entity to, float type, float cost, float weapon) useprint = {
	
    msg_entity = to;
	WriteByte(MSG_ONE, SVC_CGAMEPACKET);
	WriteByte(MSG_ONE, EVENT_USEPRINT);
	WriteByte(MSG_ONE, type);
	WriteShort(MSG_ONE, cost);
	WriteByte(MSG_ONE, weapon);
	
}
#endif

void NotifyNewRound(float to) {
	#ifndef PSP
	
	WriteByte(MSG_ALL, SVC_CGAMEPACKET);
	WriteByte(MSG_ALL, EVENT_NEWROUND);
	WriteByte(MSG_ALL, to);
	
	#endif
}

void SetRound(entity client, float to) {
	#ifndef PSP
	
    msg_entity = client;
	WriteByte(MSG_ONE, SVC_CGAMEPACKET);
	WriteByte(MSG_ONE, EVENT_SETROUND);
	WriteByte(MSG_ONE, to);
	
	#endif
}

void SetPerk(entity client, float to) 
{
	#ifndef PSP
	
    msg_entity = client;
	WriteByte(MSG_ONE, SVC_CGAMEPACKET);
	WriteByte(MSG_ONE, EVENT_PERK);
	WriteLong(MSG_ONE, to);
	
	#endif
}

void(float to) SwitchWeapon =
{
	#ifndef PSP
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_WEAPONCHANGE);
	WriteByte(MSG_MULTICAST, to);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
	
	#endif
}

void(string to, float skin) UpdateVmodel =
{
	#ifndef PSP
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_UPDATEVMODEL);
	WriteString(MSG_MULTICAST, to);
	WriteByte(MSG_MULTICAST, skin);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
	
	#endif
}

void(string to, float skin) UpdateV2model =
{
	#ifndef PSP
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_UPDATEV2MODEL);
	WriteString(MSG_MULTICAST, to);
	WriteByte(MSG_MULTICAST, skin);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
	#endif	
}

void(float broadcast_time, float type) BroadcastMessage =
{
	#ifndef PSP
	
	WriteByte(MSG_ALL, SVC_CGAMEPACKET);
	WriteByte(MSG_ALL, EVENT_BROADCAST);
	WriteByte(MSG_ALL, broadcast_time);
	WriteByte(MSG_ALL, type);
	
	#endif
}

void(float playernum, float points, float am, float kills, string name, entity person) UpdatePlayerPoints =
{
	#ifndef PSP
	
	if (player_count == 0) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EVENT_POINTUPDATE);
		WriteByte(MSG_MULTICAST, playernum);
		WriteLong(MSG_MULTICAST, points);
		WriteLong(MSG_MULTICAST, am);
		WriteLong(MSG_MULTICAST, kills);
		WriteString(MSG_MULTICAST, name);
		msg_entity = person;
		multicast('0 0 0', MULTICAST_ONE);
	}
	else {
		WriteByte(MSG_ALL, SVC_CGAMEPACKET);
		WriteByte(MSG_ALL, EVENT_POINTUPDATE);
		WriteByte(MSG_ALL, playernum);
		WriteLong(MSG_ALL, points);
		WriteLong(MSG_ALL, am);
		WriteLong(MSG_ALL, kills);
		WriteString(MSG_ALL, name);
	}
	
	#endif
}

void(float newtime, float newtype, entity change) PromptLevelChange = 
{
	#ifndef PSP
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_BLACKOUT);
	WriteByte(MSG_MULTICAST, newtime);
	WriteByte(MSG_MULTICAST, newtype);
	msg_entity = change;
	multicast('0 0 0', MULTICAST_ONE);
	
	#endif
}

void(entity who) UpdatePunchangle =	
{		

	// naievil -- shit logic lol...but result looks clean as fuck...
	#ifndef PSP
	WriteByte(MSG_ONE, SVC_CGAMEPACKET);
	WriteByte(MSG_ONE, EVENT_PUNCHANGLE);
	WriteCoord(MSG_ONE, who.punchangle_x);
	WriteCoord(MSG_ONE, who.punchangle_y);
	WriteCoord(MSG_ONE, who.punchangle_z);
	
	vector tempv = who.punchangle;
		
	if (fabs(who.punchangle_x) > 0.01) {
		if (who.punchangle_x >= 0.05*tempv_x)
			who.punchangle_x -= 0.05*tempv_x;
		else if (who.punchangle_x <= -0.05*tempv_x)
			who.punchangle_x -= 0.05*tempv_x;
		else
			who.punchangle_x = 0;
	} else 
		who.punchangle_x = 0;
		
	if (fabs(who.punchangle_y) > 0.01) {
		if (who.punchangle_y >= 0.05*tempv_y)
			who.punchangle_y -= 0.05*tempv_y;
		else if (who.punchangle_y <= -0.05*tempv_y)
			who.punchangle_y -= 0.05*tempv_y;
		else 
			who.punchangle_y = 0;
	} else 
		who.punchangle_y = 0;
		
	if (fabs(who.punchangle_z) > 0.01) {
		if (who.punchangle_z >= 0.05*tempv_z)
			who.punchangle_z -= 0.05*tempv_z;
		else if (who.punchangle_z <= -0.05*tempv_z)
			who.punchangle_z -= 0.05*tempv_z;
		else 
			who.punchangle_z = 0;
	} else 
		who.punchangle_z = 0;
		
	#endif
}

#ifndef PSP
void(string msg, entity who) ScrollText = {
	if (player_count == 0) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EVENT_SCROLLTEXT);
		WriteString(MSG_MULTICAST, msg);
		msg_entity = who;
		multicast('0 0 0', MULTICAST_ONE);
	} else {
		WriteByte(MSG_ALL, SVC_CGAMEPACKET);
		WriteByte(MSG_ALL, EVENT_SCROLLTEXT);
		WriteString(MSG_ALL, msg);
	}
}

void(string chaptertitle, string location, string date, string person, entity who) WorldText = {
	if (player_count == 0) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EVENT_WORLDDATA);
		WriteString(MSG_MULTICAST, chaptertitle);
		WriteString(MSG_MULTICAST, location);
		WriteString(MSG_MULTICAST, date);
		WriteString(MSG_MULTICAST, person);
		msg_entity = who;
		multicast('0 0 0', MULTICAST_ONE);
	} else {
		WriteByte(MSG_ALL, SVC_CGAMEPACKET);
		WriteByte(MSG_ALL, EVENT_WORLDDATA);
		WriteString(MSG_ALL, chaptertitle);
		WriteString(MSG_ALL, location);
		WriteString(MSG_ALL, date);
		WriteString(MSG_ALL, person);
	}
}

void(float ach, entity who) GiveAchievement= {
	if (player_count == 0) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EVENT_ACHIEVEMENT);
		WriteByte(MSG_MULTICAST, ach);
		msg_entity = who;
		multicast('0 0 0', MULTICAST_ONE);
	} else {
		WriteByte(MSG_ALL, SVC_CGAMEPACKET);
		WriteByte(MSG_ALL, EVENT_ACHIEVEMENT);
		WriteByte(MSG_ALL, ach);
	}
}
#endif

// *****************************************
// Unrelated to engine, but custom functions
// *****************************************

float() crandom =
{
	return 2*(random() - 0.5);
}

void WeaponSwitch(entity player) {
	float wep, cmag, cmag2, cammo;

	wep = other.weapon;
	other.weapon = other.secondaryweapon;
	other.secondaryweapon = wep;

	cmag = other.currentmag;
	other.currentmag = other.secondarymag;
	other.secondarymag = cmag;

	cmag2 = other.currentmag2;
	other.currentmag2 = other.secondarymag2;
	other.secondarymag2 = cmag2;

	cammo = other.currentammo;
	other.currentammo = other.secondaryammo;
	other.secondaryammo = cammo;

	entity tempe = self;
	self = player;
	SwitchWeapon(other.weapon);
	self = tempe;
}

void(entity person, float expamt, float doublepoint) addmoney =
{
	if (person.classname != "player")
		return;

	if (expamt > 0 && doublepoint == TRUE && x2_finished> time) {
		person.points = person.points + expamt*2;
		person.score += expamt*2;
	} else {
		if (expamt > 0)
			person.score += expamt;
		person.points = person.points + expamt;
	}
		
	UpdatePlayerPoints(person.playernum, person.points, expamt, person.kills, person.netname, person);
};