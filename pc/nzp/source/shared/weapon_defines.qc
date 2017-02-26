float(float wep) GetFiretype =
{

	switch (wep)
	{
		case W_COLT:
			return 1;
			break;
    }

    return 0;
}

float(float wep) getWeaponMag =
{

	switch (wep)
	{
		case W_COLT:
			return 8;
	}
	return 0;
}

float(float wep) getWeaponAmmo =
{

	switch (wep)
	{
		case W_COLT:
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
    }

    return "";
}

string(float wep) GetWeaponSound =

{
	switch (wep)
	{
		case W_COLT:
			return "sounds/weapons/colt/shoot.wav";
    }

    return "";
}

void (float wep, float anim_style, float dualwep, float curweaponframe)	PlayWeaponSound =
{
	switch (wep) {
		case W_COLT:
			if (curweaponframe == 5) {
				sound (self ,5, "sounds/weapons/colt/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 12) {
				sound (self ,5, "sounds/weapons/colt/magin.wav", 1, ATTN_NORM);
			} else if(curweaponframe == 18)
				sound (self ,5, "sounds/weapons/colt/slide.wav", 1, ATTN_NORM);
		break;
	}
}