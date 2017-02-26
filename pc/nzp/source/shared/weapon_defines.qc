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
	}
}