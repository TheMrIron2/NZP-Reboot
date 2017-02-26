float(float wep) GetFiretype =
{

	switch (wep)
	{
		case W_COLT:
			return 1;
		case W_KAR:
			return 1;
		case W_THOMPSON:
			return 0;
		case W_357:
			return 1;
		case W_BAR:
			return 0;
		case W_BROWNING:
			return 0;
    }

    return 0;
}

float(float wep) getWeaponMag =
{

	switch (wep)
	{
		case W_COLT:
			return 8;
		case W_KAR:
			return 5;
		case W_THOMPSON:
			return 20;
		case W_357:
			return 6;
		case W_BAR:
			return 20;
		case W_BROWNING:
			return 125;
	}
	return 0;
}

float(float wep) getWeaponAmmo =
{

	switch (wep)
	{
		case W_COLT:
			return 80;
		case W_KAR:
			return 50;
		case W_THOMPSON:
			return 200;
		case W_357:
			return 80;
		case W_BAR:
			return 140;
		case W_BROWNING:
			return 500;
	}
	return 0;
}


float(float wep) getWeaponDamage =
{

	switch (wep)
	{
		case W_COLT:
			return 20;
		case W_KAR:
			return 100;
		case W_THOMPSON:
			return 120;
		case W_357:
			return 1000;
		case W_BAR:
			return 100;
		case W_BROWNING:
			return 130;
    }

    return 0;
}

float(float wep) GetWeaponShotcount =
{

    return 1;
}

float(float wep, float penetration_times) getWeaponPenetration =
{
	if (!penetration_times)
		return 2;
	switch (wep)
	{
		case W_COLT:
			if (penetration_times >= 2)
				return 0;
			return 0.75;
		case W_KAR:
			if (penetration_times >= 3)
				return 0;
			return 1;
		case W_THOMPSON:
			if (penetration_times >= 2)
				return 0;
			return 0.8;
		case W_357:
			if (penetration_times >= 3)
				return 0;
		case W_BAR:
			if (penetration_times >= 3)
				return 0;
			return 1;
		case W_BROWNING:
			if (penetration_times >= 3)
				return 0;
			return 1;
    }
    
	return 0;
}

float(float wep) GetWeaponSpread =
{
	
	return 0;
}

float(float wep, float delaytype) getWeaponDelay =
{

	switch (wep)
	{
		case W_COLT:
			if (delaytype == RELOAD)
				return 2.5;
			else if (delaytype == FIRE)
				return 0.075;
		case W_KAR:
			if (delaytype == RELOAD)
				return 1.6;
			else if (delaytype == FIRE)
				return 0.3;
		case W_THOMPSON:
			if (delaytype == RELOAD)
				return 2.4;
			else if (delaytype == FIRE)
				return 0.08;
		case W_357:
			if (delaytype == RELOAD)
				return 2.2;
			else if (delaytype == FIRE)
				return 0.32;
		case W_BAR:
			if (delaytype == RELOAD)
				return 3.5;
			else if (delaytype == FIRE)
				return 0.16;
		case W_BROWNING:
			if (delaytype == RELOAD)
				return 3.3;
			else if (delaytype == FIRE)
				return 0.096;
    }

    return 0;
}

float(float wep, float frametype) GetFrame =
{
	switch (wep)
	{
		case W_COLT:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 2;
				case RELOAD_START:
					return 3;
				case RELOAD_END:
					return 26;
				case SPRINT_IN_START:
					return 33;
				case SPRINT_IN_END:
					return 34;
				case SPRINT_START:
					return 35;
				case SPRINT_END:
					return 40;
				case SPRINT_OUT_START:
					return 41;
				case SPRINT_OUT_END:
					return 42;
				case TAKE_OUT_START:
					return 29;
				case TAKE_OUT_END:
					return 32;
				case PUT_OUT_START:
					return 26;
				case PUT_OUT_END:
					return 29;
				case RELOAD_CANCEL:
					return 13;
			}
			break;
		case W_KAR:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 3;
				case RELOAD_START:
					return 14;
				case RELOAD_END:
					return 28;
				case SPRINT_IN_START:
					return 29;
				case SPRINT_IN_END:
					return 30;
				case SPRINT_OUT_START:
					return 30;
				case SPRINT_OUT_END:
					return 29;
				case TAKE_OUT_START:
					return 33;
				case TAKE_OUT_END:
					return 35;
				case PUT_OUT_START:
					return 32;
				case PUT_OUT_END:
					return 33;
				case RELOAD_CANCEL:
					return 21;
			}	
			break;
		case W_THOMPSON:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 2;
				case RELOAD_START:
					return 3;
				case RELOAD_END:
					return 25;
				case SPRINT_IN_START:
					return 26;
				case SPRINT_IN_END:
					return 27;
				case SPRINT_OUT_START:
					return 28;
				case SPRINT_OUT_END:
					return 29;
				case TAKE_OUT_START:
					return 32;
				case TAKE_OUT_END:
					return 35;
				case PUT_OUT_START:
					return 29;
				case PUT_OUT_END:
					return 32;
				case RELOAD_CANCEL:
					return 15;
			}
			break;
		case W_357:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 3;
				case RELOAD_START:
					return 4;
				case RELOAD_END:
					return 25;
				case SPRINT_IN_START:
					return 32;
				case SPRINT_IN_END:
					return 33;
				case SPRINT_START:
					return 35;
				case SPRINT_END:
					return 40;
				case SPRINT_OUT_START:
					return 41;
				case SPRINT_OUT_END:
					return 42;
				case TAKE_OUT_START:
					return 29;
				case TAKE_OUT_END:
					return 31;
				case PUT_OUT_START:
					return 26;
				case PUT_OUT_END:
					return 28;
				case RELOAD_CANCEL:
					return 14;
			}
			break;
		case W_BAR:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 2;
				case RELOAD_START:
					return 3;
				case RELOAD_END:
					return 36;
				case SPRINT_IN_START:
					return 37;
				case SPRINT_IN_END:
					return 38;
				case SPRINT_OUT_START:
					return 38;
				case SPRINT_OUT_END:
					return 37;
				case TAKE_OUT_START:
					return 41;
				case TAKE_OUT_END:
					return 39;
				case PUT_OUT_START:
					return 39;
				case PUT_OUT_END:
					return 41;
				case RELOAD_CANCEL:
					return 21;
			}
			break;
		case W_BROWNING:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 3;
				case RELOAD_START:
					return 4;
				case RELOAD_END:
					return 37;
				case SPRINT_IN_START:
					return 92;
				case SPRINT_IN_END:
					return 93;
				case SPRINT_OUT_START:
					return 95;
				case SPRINT_OUT_END:
					return 96;
				case TAKE_OUT_START:
					return 100;
				case TAKE_OUT_END:
					return 103;
				case PUT_OUT_START:
					return 97;
				case PUT_OUT_END:
					return 100;
				case RELOAD_CANCEL:
					return 16;
			}
			break;
		
	}

    return 0;
}

string(float wep, float gorvmodel) GetWeaponModel =
{

	switch (wep)
	{
		case W_COLT:
			if (gorvmodel)
				return ("models/weapons/m1911/g_colt.mdl");
			else
				return ("models/weapons/m1911/v_colt.mdl");
		case W_KAR:
			if (gorvmodel)
				return ("models/weapons/kar/g_kar.mdl");
			else
				return ("models/weapons/kar/v_kar.mdl");
		case W_THOMPSON:
			if (gorvmodel)
				return ("models/weapons/thomp/g_thomp.mdl");
			else
				return ("models/weapons/thomp/v_thomp.mdl");
		case W_357:
			if (gorvmodel)
				return ("models/weapons/357/g_357.mdl");
			else
				return ("models/weapons/357/v_357.mdl");
		case W_BAR:
			if (gorvmodel)
				return ("models/weapons/bar/g_bar.mdl");
			else
				return ("models/weapons/bar/v_bar.mdl");
		case W_BROWNING:
			if (gorvmodel)
				return ("models/weapons/browning/g_browning.mdl");
			else
				return ("models/weapons/browning/v_browning.mdl");
    }

    return "";
}

string(float wep) GetWeaponSound =

{
	switch (wep)
	{
		case W_COLT:
			return "sounds/weapons/colt/shoot.wav";
		case W_KAR:
			return "sounds/weapons/kar/shoot.wav";
		case W_THOMPSON:
			return "sounds/weapons/thomp/shoot.wav";
		case W_357:
			return "sounds/weapons/357/shoot.wav";
		case W_BAR:
			return "sounds/weapons/bar/shoot.wav";
		case W_BROWNING:
			return "sounds/weapons/browning/shoot.wav";
    }

    return "";
}

void (float wep, float anim_style, float dualwep, float curweaponframe)	PlayWeaponSound =
{
	if (anim_style == FIRE)
	{
		if (wep == W_KAR)
		{
			if (curweaponframe == 6)
				sound (self ,5, "sounds/weapons/kar/boltup.wav", 1, ATTN_NORM);
			else if (curweaponframe == 7)
				sound (self ,5, "sounds/weapons/kar/boltback.wav", 1, ATTN_NORM);
			else if (curweaponframe == 9)
				sound (self ,5, "sounds/weapons/kar/boltforward.wav", 1, ATTN_NORM);
			else if (curweaponframe == 10)
				sound (self ,5, "sounds/weapons/kar/boltdown.wav", 1, ATTN_NORM);
		}
	} else if (anim_style != RELOAD) {
		return;
	}


	switch (wep) {
		case W_COLT:
			if (curweaponframe == 5) {
				sound (self ,5, "sounds/weapons/colt/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 12) {
				sound (self ,5, "sounds/weapons/colt/magin.wav", 1, ATTN_NORM);
			} else if(curweaponframe == 18) {
				sound (self ,5, "sounds/weapons/colt/slide.wav", 1, ATTN_NORM);
			}
			break;
		case W_KAR:
			if (curweaponframe == 15) {
				sound (self ,5, "sounds/weapons/kar/boltup.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 16) {
				sound (self ,5, "sounds/weapons/kar/boltback.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 20) {
				sound (self ,5, "sounds/weapons/kar/clipin.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 25) {
				sound (self ,5, "sounds/weapons/kar/boltforward.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 26) {
				sound (self ,5, "sounds/weapons/kar/clipoff.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 27) {
				sound (self ,5, "sounds/weapons/kar/boltdown.wav", 1, ATTN_NORM);
			}
			break;
		case W_THOMPSON:
			if (curweaponframe == 6) {
				sound (self ,5, "sounds/weapons/thomp/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 12) {
				sound (self ,5, "sounds/weapons/thomp/magin.wav", 1, ATTN_NORM);}
			else if (curweaponframe == 19) {
				sound (self ,5, "sounds/weapons/thomp/boltback.wav", 1, ATTN_NORM);
			}
			break;
		case W_357:
			if (curweaponframe == 5) {
				sound (self ,5, "sounds/weapons/357/open.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 9) {
				sound (self ,5, "sounds/weapons/357/out.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 15) {
				sound (self ,5, "sounds/weapons/357/in.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 20) {
				sound (self ,5, "sounds/weapons/357/close.wav", 1, ATTN_NORM);
			}
			break;
		case W_BAR:
			if (curweaponframe == 6  || curweaponframe == 31) {
				sound (self ,5, "sounds/weapons/bar/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 19 || curweaponframe == 29) {
				sound (self ,5, "sounds/weapons/bar/magin.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 23) {
				sound (self ,5, "sounds/weapons/bar/maghit.wav", 1, ATTN_NORM);
			}
			break;
		case W_BROWNING:
			if (curweaponframe == 9) {
				sound (self ,5, "sounds/weapons/browning/boltback.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 16) {
				sound (self ,5, "sounds/weapons/browning/topopen.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 22) {
				sound (self ,5, "sounds/weapons/browning/chainoff.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 32) {
				sound (self ,5, "sounds/weapons/browning/boltback.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 39) {
				sound (self ,5, "sounds/weapons/browning/topopen.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 49) {
				sound (self ,5, "sounds/weapons/browning/chainon.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 53) {
				sound (self ,5, "sounds/weapons/browning/chainplace.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 58) {
				sound (self ,5, "sounds/weapons/browning/topclose.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 61) {
				sound (self ,5, "sounds/weapons/browning/tophit.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 70) {
				sound (self ,5, "sounds/weapons/browning/boltforward.wav", 1, ATTN_NORM);
			}
			break;
	}
}


void(float weptype) precache_extra =
{
	switch (weptype) {
		case W_COLT:
			precache_sound("sounds/weapons/colt/shoot.wav");
			precache_sound("sounds/weapons/colt/magout.wav");
			precache_sound("sounds/weapons/colt/magin.wav");
			break;
		case W_KAR:
			precache_sound ("sounds/weapons/kar/boltup.wav");
			precache_sound ("sounds/weapons/kar/boltback.wav");
			precache_sound ("sounds/weapons/kar/boltforward.wav");
			precache_sound ("sounds/weapons/kar/boltdown.wav");
			precache_sound ("sounds/weapons/kar/clipin.wav");
			precache_sound ("sounds/weapons/kar/clipoff.wav");
			precache_sound ("sounds/weapons/kar/shoot.wav");
			break;
		case W_THOMPSON:
			precache_sound("sounds/weapons/thomp/magout.wav");
			precache_sound("sounds/weapons/thomp/magin.wav");
			precache_sound("sounds/weapons/thomp/boltback.wav");
			precache_sound("sounds/weapons/thomp/shoot.wav");
			break;
		case W_357:
			precache_sound("sounds/weapons/357/open.wav");
			precache_sound("sounds/weapons/357/out.wav");
			precache_sound("sounds/weapons/357/in.wav");
			precache_sound("sounds/weapons/357/close.wav");
			precache_sound("sounds/weapons/357/shoot.wav");
			break;
		case W_BAR:
			precache_sound("sounds/weapons/bar/shoot.wav");
			precache_sound("sounds/weapons/bar/magout.wav");
			precache_sound("sounds/weapons/bar/magin.wav");
			precache_sound("sounds/weapons/bar/maghit.wav");
			break;
		case W_BROWNING:
			precache_sound ("sounds/weapons/browning/boltback.wav");
			precache_sound ("sounds/weapons/browning/topopen.wav");
			precache_sound ("sounds/weapons/browning/chainoff.wav");
			precache_sound ("sounds/weapons/browning/boltback.wav");
			precache_sound ("sounds/weapons/browning/topopen.wav");
			precache_sound ("sounds/weapons/browning/chainon.wav");
			precache_sound ("sounds/weapons/browning/chainplace.wav");
			precache_sound ("sounds/weapons/browning/topclose.wav");
			precache_sound ("sounds/weapons/browning/tophit.wav");
			precache_sound ("sounds/weapons/browning/boltforward.wav");
			precache_sound ("sounds/weapons/browning/shoot.wav");
			break;
	}
}