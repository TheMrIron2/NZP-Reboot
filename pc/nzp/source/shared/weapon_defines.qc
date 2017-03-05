
string(float wep) GetWeaponName =
{
	switch (wep)
	{
		case W_COLT:
			return "Colt M1911";
		case W_KAR:
			return "Kar 98k";
		case W_THOMPSON:
			return "Thompson";
		case W_357:
			return ".357 Magnum";
		case W_BAR:
			return "BAR";
		case W_BK:
			return "Ballistic Knife";
		case W_BROWNING:
			return "Browning M1919";
		case W_DB:
			return "Double-Barreled Shotgun";
		case W_FG:
			return "FG42";
		case W_GEWEHR:
			return "Gewehr 43";
		case W_KAR_SCOPE:
			return "Scoped Kar 98k";
		case W_M1:
			return "M1 Garand";
		case W_M1A1:
			return "M1A1 Carbine";
		case W_M2:
			return "M2 Flamethrower";
		case W_MP40:
			return "MP40";
		case W_MG:
			return "MG42";
		case W_PANZER:
			return "Panzerschrek";
		case W_PPSH:
			return "PPSh-41";
		case W_PTRS:
			return "PTRS-41";
		case W_RAY:
			return "Ray Gun";
		case W_SAWNOFF:
			return "Sawnoff shotgun";
		case W_STG:
			return "STG-44";
		case W_TRENCH:
			return "M1897 Trench Gun";
		case W_TYPE:
			return "Type 100";
		case 25:
			return "Bowie Knife";
		case 26:
			return "Grenades";
		case 27:
			return "Bouncing Betty";
		case W_BIATCH:
      		return "Mustang & Sally";
    	case W_ARMAGEDDON:
			return "Armageddon";
		case W_GIBS:
			return "Gibs-O-Matic";
		case W_KILLU:
			return ".357 Plus 1 K1L-u";
		case W_WIDOW:
			return "The Widow Maker";
		case W_ACCELERATOR:
			return "B115 Accelerator";
		case W_BORE:
			return "24 Bore Long Range";
		case W_IMPELLER:
			return "420 Impeller";
		case W_COMPRESSOR:
			return "G115 Compressor";
		case W_HEADCRACKER:
			return "Headcracker";
		case W_M1000:
			return "M1000";
		case W_WIDDER:
			return "Widdershins RC-1";
		case W_FIW:
			return "F1W Nitrogen Cooled";
		case W_AFTERBURNER:
			return "The Afterburner";
		case W_BARRACUDA:
			return "Barracuda FU-A11";
		case W_LONGINUS:
			return "Longinus";
		case W_REAPER:
			return "The Reaper";
		case W_PENETRATOR:
			return "The Penetrator";
		case W_PORTER:
			return "Porter's X2 Ray Gun";
		case W_SNUFF:
			return "The Snuff Box";
		case W_SPATZ:
			return "Spatz-447 +";
		case W_GUT:
			return "Gut Shot";
		case W_SAMURAI:
			return "1001 Samurais";
		case W_NOWEP:
      		return " ";
    	case W_MP5:
      		return "MP5K";
    	case W_TESLA:
      		return "Wunderwaffe DG-2";
		default:
			return " ";
	}
}

string(float perk) GetPerkName =
{
	switch (perk)
	{
		case 1:
			return "Quick Revive";
		case 2:
			return "Juggernog";
		case 3:
			return "Speed Cola";
		case 4:
			return "Double Tap";
		case 5:
			return "Stamin-Up";
		case 6:
			return "PhD Flopper";
		default:
			return "NULL";
	}
}

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
		case W_DB:
			return 1;
		case W_FG:
			return 0;
		case W_GEWEHR:
			return 1;
		case W_KAR_SCOPE:
			return 1;
		case W_M1:
			return 1;
		case W_M1A1:
			return 1;
		case W_M2:
			return 6;
		case W_MP40:
			return 0;
		case W_MG:
			return 0;
		case W_PANZER:
			return 3;
		case W_PPSH:
			return 0;
		case W_PTRS:
			return 0;
		case W_RAY:
			return 4;
		case W_SAWNOFF:
			return 1;
		case W_STG:
			return 0;
		case W_TRENCH:
			return 1;
		case W_TYPE:
			return 0;
		case W_BIATCH:
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
		case W_BAR:
			return 20;
		case W_BROWNING:
			return 125;
		case W_DB:
			return 2;
		case W_FG:
			return 32;
		case W_GEWEHR:
			return 10;
		case W_KAR_SCOPE:
			return 5;
		case W_M1:
			return 8;
		case W_M1A1:
			return 15;
		case W_M2:
			return 200;
		case W_MP40:
			return 32;
		case W_MG:
			return 125;
		case W_PANZER:
			return 1;
		case W_PPSH:
			return 71;
		case W_PTRS:
			return 5;
		case W_RAY:
			return 20;
		case W_SAWNOFF:
			return 2;
		case W_STG:
			return 30;
		case W_TRENCH:
			return 6;
		case W_TYPE:
			return 30;
		case W_BIATCH:
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
		case W_BAR:
			return 140;
		case W_BROWNING:
			return 500;
		case W_DB:
			return 60;
		case W_DB:
			return 200;
		case W_GEWEHR:
			return 120;
		case W_KAR_SCOPE:
			return 50;
		case W_M1:
			return 128;
		case W_M1A1:
			return 120;
		case W_M2:
      		return 200;
		case W_MP40:
			return 192;
		case W_MG:
			return 500;
		case W_PANZER:
			return 20;
		case W_PPSH:
			return 355;
		case W_PTRS:
			return 60;
		case W_RAY:
			return 160;
		case W_SAWNOFF:
			return 60;
		case W_STG:
			return 180;
		case W_TRENCH:
			return 60;
		case W_TYPE:
			return 160;
		case W_BIATCH:
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
		case W_BAR:
			return 100;
		case W_BROWNING:
			return 130;
		case W_FG:
			return 100;
		case W_GEWEHR:
			return 90;
		case W_KAR_SCOPE:
			return 800;
		case W_M1:
			return 200;
		case W_M1A1:
			return 120;
		case W_MP40:
			return 100;
		case W_MG:
			return 130;
		case W_PANZER:
			return 600;
		case W_PPSH:
			return 100;
		case W_PTRS:
			return 1000;
		case W_RAY:
			return 1000;
		case W_SAWNOFF:
			return 240;
		case W_STG:
			return 180;
		case W_TRENCH:
			return 120;
		case W_TYPE:
			return 100;
		case W_BIATCH:
			return 1000;
    }

    return 0;
}

float(float wep) GetWeaponShotcount =
{
	switch(wep)
	{
		case W_DB:
			return 8;
		case W_SAWNOFF:
			return 8;
		case W_TRENCH:
			return 8;
	}

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
		case W_DB:
			if (penetration_times >= 1)
				return 0;
			return 0.5;
		case W_FG:
			if (penetration_times >= 2)
				return 0;
			return 0.9;
		case W_GEWEHR:
			if (penetration_times >= 2)
				return 0;
			return 0.9;
		case W_KAR_SCOPE:
			if (penetration_times >= 3)
				return 0;
			return 1;
		case W_M1:
			if (penetration_times >= 2)
				return 0;
			return 0.9;
		case W_M1A1:
			if (penetration_times >= 2)
				return 0;
			return 0.9;
		case W_MP40:
			if (penetration_times >= 2)
				return 0;
			return 0.8;
		case W_MG:
			if (penetration_times >= 3)
				return 0;
			return 1;
		case W_PPSH:
			if (penetration_times >= 2)
				return 0;
			return 0.75;
		case W_PTRS:
			if (penetration_times >= 5)
				return 0;
			return 1;
		case W_SAWNOFF:
			if (penetration_times >= 1)
				return 0;
			return 0.4;
		case W_STG:
			if (penetration_times >= 2)
				return 0;
			return 0.8;
		case W_TRENCH:
			if (penetration_times >= 1)
				return 0;
			return 0.7;
		case W_TYPE:
			if (penetration_times >= 2)
				return 0;
			return 0.8;
		case W_BIATCH:
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
		case W_DB:
			if (delaytype == RELOAD)
				return 2.8;
			else if (delaytype == FIRE)
				return 0.283;
		case W_FG:
			if (delaytype == RELOAD)
			  	return 4.5;
			else if (delaytype == FIRE)
				return 0.064;
		case W_GEWEHR:
			if (delaytype == RELOAD)
				return 3.5;
			else if (delaytype == FIRE)
				return 0.125;
		case W_M1:
			if (delaytype == RELOAD)
				return 3.8;
			else if (delaytype == FIRE)
				return 0.135;
		case W_M1A1:
			if (delaytype == RELOAD)
				return 2.9;
			else if (delaytype == FIRE)
				return 0.135;
		case W_M2:
			if (delaytype == RELOAD)
				return 2.7;
			else if (delaytype == FIRE)
				return 0.02;
		case W_MP40:
			if (delaytype == RELOAD)
				return 2.2;
			else if (delaytype == FIRE)
				return 0.112;
		case W_MG:
			if (delaytype == RELOAD)
				return 3.6;
			else if (delaytype == FIRE)
				return 0.01;
		case W_PANZER:
			if (delaytype == RELOAD)
				return 1.55;
			else if (delaytype == FIRE)
				return 0.331;
		case W_PPSH:
			if (delaytype == RELOAD)
				return 3.3;
			else if (delaytype == FIRE)
				return 0.048;
		case W_PTRS:
			if (delaytype == RELOAD)
				return 2.8;
			else if (delaytype == FIRE)
				return 0.8;
		case W_RAY:
			if (delaytype == RELOAD)
				return 3.1;
			else if (delaytype == FIRE)
				return 0.331;
		case W_SAWNOFF:
			if (delaytype == RELOAD)
				return 2.8;
			else if (delaytype == FIRE)
				return 0.283;
		case W_STG:
			if (delaytype == RELOAD)
				return 2.5;
			else if (delaytype == FIRE)
				return 0.102;
		case W_TRENCH:
			if (delaytype == RELOAD)
				return 2.2;
			else if (delaytype == FIRE)
				return 0.283;
		case W_TYPE:
			if (delaytype == RELOAD)
				return 2.3;
			else if (delaytype == FIRE)
				return 0.08;
		case W_BIATCH:
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
		case W_DB:
				switch (frametype)
				{
					case FIRE_START:
						return 1;
					case FIRE_END:
						return 4;
					case RELOAD_START:
						return 5;
					case RELOAD_END:
						return 31;
					case SPRINT_IN_START:
						return 32;
					case SPRINT_IN_END:
						return 33;
					case SPRINT_OUT_START:
						return 33;
					case SPRINT_OUT_END:
						return 31;
					case TAKE_OUT_START:
						return 38;
					case TAKE_OUT_END:
						return 41;
					case PUT_OUT_START:
						return 35;
					case PUT_OUT_END:
						return 37;
					case RELOAD_CANCEL:
						return 22;
				}
				break;
		case W_FG:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 3;
				case RELOAD_START:
					return 41;
				case RELOAD_END:
					return 88;
				case SPRINT_IN_START:
					return 29;
				case SPRINT_IN_END:
					return 33;
				case SPRINT_OUT_START:
					return 34;
				case SPRINT_OUT_END:
					return 37;
				case TAKE_OUT_START:
					return 8;
				case TAKE_OUT_END:
					return 15;
				case PUT_OUT_START:
					return 3;
				case PUT_OUT_END:
					return 7;
				case RELOAD_CANCEL:
					return 64;
			}
			break;
		case W_GEWEHR:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 2;
				case RELOAD_START:
					return 3;
				case RELOAD_END:
					return 38;
				case SPRINT_IN_START:
					return 49;
				case SPRINT_IN_END:
					return 49;
				case SPRINT_OUT_START:
					return 51;
				case SPRINT_OUT_END:
					return 52;
				case TAKE_OUT_START:
					return 55;
				case TAKE_OUT_END:
					return 59;
				case PUT_OUT_START:
					return 53;
				case PUT_OUT_END:
					return 56;
				case RELOAD_CANCEL:
					return 16;
			}
			break;
		case W_KAR_SCOPE:
				switch (frametype)
				{
					case FIRE_START:
						return 1;
					case FIRE_END:
						return 3;
					case SPRINT_IN_START:
						return 36;
					case SPRINT_IN_END:
						return 37;
					case SPRINT_OUT_START:
						return 37;
					case SPRINT_OUT_END:
						return 36;
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
		
		case W_M1:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 3;
				case RELOAD_START:
					return 8;
				case RELOAD_END:
					return 44;
				case SPRINT_IN_START:
					return 58;
				case SPRINT_IN_END:
					return 59;
				case SPRINT_OUT_START:
					return 60;
				case SPRINT_OUT_END:
					return 61;
				case TAKE_OUT_START:
					return 59;
				case TAKE_OUT_END:
					return 63;
				case PUT_OUT_START:
					return 56;
				case PUT_OUT_END:
					return 59;
				case RELOAD_CANCEL:
					return 16;
			}
			break;
	
		case W_M1A1:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 2;
				case RELOAD_START:
					return 3;
				case RELOAD_END:
					return 29;
				case SPRINT_IN_START:
					return 37;
				case SPRINT_IN_END:
					return 38;
				case SPRINT_OUT_START:
					return 38;
				case SPRINT_OUT_END:
					return 37;
				case TAKE_OUT_START:
					return 33;
				case TAKE_OUT_END:
					return 36;
				case PUT_OUT_START:
					return 30;
				case PUT_OUT_END:
					return 33;
				case RELOAD_CANCEL:
					return 17;
			}
			break;
		case W_M2:
			switch (frametype)
			{
				case FIRE_START:
					return 0;
				case FIRE_END:
					return 0;
				case SPRINT_IN_START:
					return 0;
				case SPRINT_IN_END:
					return 0;
				case SPRINT_OUT_START:
					return 8;
				case SPRINT_OUT_END:
					return 0;
				case TAKE_OUT_START:
					return 0;
				case TAKE_OUT_END:
					return 0;
				case PUT_OUT_START:
					return 0;
				case PUT_OUT_END:
					return 0;
				case RELOAD_CANCEL:
					return 0;
			}
			break;
		case W_MP40:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 2;
				case RELOAD_START:
					return 3;
				case RELOAD_END:
					return 21;
				case SPRINT_IN_START:
					return 37;
				case SPRINT_IN_END:
					return 38;
				case SPRINT_OUT_START:
					return 39;
				case SPRINT_OUT_END:
					return 40;
				case TAKE_OUT_START:
					return 32;
				case TAKE_OUT_END:
					return 35;
				case PUT_OUT_START:
					return 30;
				case PUT_OUT_END:
					return 32;
				case RELOAD_CANCEL:
					return 16;
			}
			break;
		case W_MG:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 2;
				case RELOAD_START:
					return 3;
				case RELOAD_END:
					return 38;
				case SPRINT_IN_START:
					return 39;
				case SPRINT_IN_END:
					return 40;
				case SPRINT_OUT_START:
					return 40;
				case SPRINT_OUT_END:
					return 38;
				case TAKE_OUT_START:
					return 43;
				case TAKE_OUT_END:
					return 47;
				case PUT_OUT_START:
					return 42;
				case PUT_OUT_END:
					return 43;
				case RELOAD_CANCEL:
					return 21;
			}
			break;
		case W_PANZER:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 6;
				case RELOAD_START:
					return 7;
				case RELOAD_END:
					return 28;
				case SPRINT_IN_START:
					return 37;
				case SPRINT_IN_END:
					return 38;
				case SPRINT_OUT_START:
					return 45;
				case SPRINT_OUT_END:
					return 45;
				case TAKE_OUT_START:
					return 44;
				case TAKE_OUT_END:
					return 45;
				case PUT_OUT_START:
					return 39;
				case PUT_OUT_END:
					return 42;
				case RELOAD_CANCEL:
					return 16;
				case AIM_IN_END:
					return 33;
			}
			break;
		case W_PPSH:
			switch (frametype)
			{
				case FIRE_START:
					return 0;
				case FIRE_END:
					return 0;
				case RELOAD_START:
					return 4;
				case RELOAD_END:
					return 34;
				case SPRINT_IN_START:
					return 44;
				case SPRINT_IN_END:
					return 45;
				case SPRINT_OUT_START:
					return 47;
				case SPRINT_OUT_END:
					return 49;
				case TAKE_OUT_START:
					return 46;
				case TAKE_OUT_END:
					return 49;
				case PUT_OUT_START:
					return 43;
				case PUT_OUT_END:
					return 46;
				case RELOAD_CANCEL:
					return 16;
			}
			break;
		case W_PTRS:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 4;
				case RELOAD_START:
					return 5;
				case RELOAD_END:
					return 32;
				case SPRINT_IN_START:
					return 48;
				case SPRINT_IN_END:
					return 50;
				case SPRINT_OUT_START:
					return 51;
				case SPRINT_OUT_END:
					return 54;
				case TAKE_OUT_START:
					return 44;
				case TAKE_OUT_END:
					return 47;
				case PUT_OUT_START:
					return 41;
				case PUT_OUT_END:
					return 44;
				case RELOAD_CANCEL:
					return 16;
			}
			break;
    	case W_RAY:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 3;
				case RELOAD_START:
					return 4;
				case RELOAD_END:
					return 30;
				case SPRINT_IN_START:
					return 42;
				case SPRINT_IN_END:
					return 42;
				case SPRINT_OUT_START:
					return 42;
				case SPRINT_OUT_END:
					return 42;
				case TAKE_OUT_START:
					return 42;
				case TAKE_OUT_END:
					return 42;
				case PUT_OUT_START:
					return 42;
				case PUT_OUT_END:
					return 42;
				case RELOAD_CANCEL:
					return 16;
				case AIM_IN_START:
					return 30;
				case AIM_IN_END:
					return 34;
				case AIM_LOOP:
					return 35;
				case AIM_OUT_START:
					return 36;
				case AIM_OUT_END:
					return 40;
				case AIM_FIRE_START:
					return 34;
				case AIM_FIRE_END:
					return 35;
			}
			break;
		case W_SAWNOFF:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 4;
				case RELOAD_START:
					return 5;
				case RELOAD_END:
					return 31;
				case SPRINT_IN_START:
					return 32;
				case SPRINT_IN_END:
					return 33;
				case SPRINT_OUT_START:
					return 33;
				case SPRINT_OUT_END:
					return 31;
				case TAKE_OUT_START:
					return 38;
				case TAKE_OUT_END:
					return 41;
				case PUT_OUT_START:
					return 35;
				case PUT_OUT_END:
					return 37;
				case RELOAD_CANCEL:
					return 22;
			}
			break;
		case W_STG:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 2;
				case RELOAD_START:
					return 3;
				case RELOAD_END:
					return 24;
				case SPRINT_IN_START:
					return 40;
				case SPRINT_IN_END:
					return 42;
				case SPRINT_OUT_START:
					return 43;
				case SPRINT_OUT_END:
					return 45;
				case TAKE_OUT_START:
					return 42;
				case TAKE_OUT_END:
					return 46;
				case PUT_OUT_START:
					return 39;
				case PUT_OUT_END:
					return 42;
				case RELOAD_CANCEL:
					return 16;
			}
			break;
		case W_TRENCH:
			switch (frametype)
			{
				case FIRE_START:
					return 1;
				case FIRE_END:
					return 3;
				case SPRINT_IN_START:
					return 27;
				case SPRINT_IN_END:
					return 28;
				case SPRINT_OUT_START:
					return 27;
				case SPRINT_OUT_END:
					return 26;
				case TAKE_OUT_START:
					return 32;
				case TAKE_OUT_END:
					return 36;
				case PUT_OUT_START:
					return 30;
				case PUT_OUT_END:
					return 32;
				case RELOAD_CANCEL:
					return 20;
			}
			break;
		case W_TYPE:
			switch (frametype)
			{
				case FIRE_START:
					return 0;
				case FIRE_END:
					return 1;
				case RELOAD_START:
					return 2;
				case RELOAD_END:
					return 24;
				case SPRINT_IN_START:
					return 35;
				case SPRINT_IN_END:
					return 37;
				case SPRINT_OUT_START:
					return 38;
				case SPRINT_OUT_END:
					return 40;
				case TAKE_OUT_START:
					return 38;
				case TAKE_OUT_END:
					return 41;
				case PUT_OUT_START:
					return 35;
				case PUT_OUT_END:
					return 38;
				case RELOAD_CANCEL:
					return 16;
				case AIM_IN_END:
					return 28;
				case AIM_IN_START:
					return 27;
			}
			break;
		case W_BIATCH:
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
					return 33;
				case SPRINT_IN_END:
					return 34;
				case SPRINT_START:
					return 44;
				case SPRINT_END:
					return 43;
				case SPRINT_OUT_START:
					return 50;
				case SPRINT_OUT_END:
					return 42;
				case TAKE_OUT_START:
					return 39;
				case TAKE_OUT_END:
					return 42;
				case PUT_OUT_START:
					return 36;
				case PUT_OUT_END:
					return 39;
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
		case W_DB:
			if (gorvmodel)
				return ("models/weapons/db/g_db.mdl");
			else
				return ("models/weapons/db/v_db.mdl");
		case W_FG:
			if (gorvmodel)
				return ("models/weapons/fg42/g_fg.mdl");
			else
				return ("models/weapons/fg42/v_fg.mdl");
		case W_GEWEHR:
			if (gorvmodel)
				return ("models/weapons/gewehr/g_gewehr.mdl");
			else
				return ("models/weapons/gewehr/v_gewehr.mdl");
		case W_KAR_SCOPE:
			if (gorvmodel)
				return ("models/weapons/kar/g_kars.mdl");
			else
				return ("models/weapons/kar/v_kar.mdl");
		case W_M1:
			if (gorvmodel)
				return ("models/weapons/garand/g_m1.mdl");
			else
				return ("models/weapons/garand/v_m1.mdl");
		case W_M1A1:
			if (gorvmodel)
				return ("models/weapons/m1carbine/g_m1a1.mdl");
			else
				return ("models/weapons/m1carbine/v_m1a1.mdl");
		case W_M2:
			if (gorvmodel)
				return ("models/weapons/m2flame/g_m2flame.mdl");
			else
				return ("models/weapons/m2flame/v_m2flame.mdl");
		case W_MP40:
			if (gorvmodel)
				return ("models/weapons/mp40/g_mp40.mdl");
			else
				return ("models/weapons/mp40/v_mp40.mdl");
		case W_MG:
			if (gorvmodel)
				return ("models/weapons/mg/g_mg.mdl");
			else
				return ("models/weapons/mg/v_mg.mdl");
		case W_PANZER:
			if (gorvmodel)
				return ("models/weapons/panzer/g_panzer.mdl");
			else
				return ("models/weapons/panzer/v_panzer.mdl");
		case W_PPSH:
			if (gorvmodel)
				return ("models/weapons/ppsh/g_ppsh.mdl");
			else
				return ("models/weapons/ppsh/v_ppsh.mdl");
		case W_PTRS:
			if (gorvmodel)
				return ("models/weapons/ptrs/g_ptrs.mdl");
			else
				return ("models/weapons/ptrs/v_ptrs.mdl");
		case W_RAY:
			if (gorvmodel)
				return ("models/weapons/ray/g_ray.mdl");
			else
				return ("models/weapons/ray/v_ray.mdl");
		case W_SAWNOFF:
			if (gorvmodel)
				return ("models/weapons/sawnoff/g_sawnoff.mdl");
			else
				return ("models/weapons/sawnoff/v_sawnoff.mdl");
		case W_STG:
			if (gorvmodel)
				return ("models/weapons/stg/g_stg.mdl");
			else
				return ("models/weapons/stg/v_stg.mdl");
		case W_TRENCH:
			if (gorvmodel)
				return ("models/weapons/trench/g_trench.mdl");
			else
				return ("models/weapons/trench/v_trench.mdl");
		case W_TYPE:
			if (gorvmodel)
				return ("models/weapons/type/g_type.mdl");
			else
				return ("models/weapons/type/v_type.mdl");
		case W_BIATCH:
			if (gorvmodel)
				return ("models/weapons/m1911/g_colt.mdl");
			else
				return ("models/weapons/m1911/v_biatch_right.mdl");
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
		case W_DB:
			return "sounds/weapons/shotgun/shoot.wav";
		case W_FG:
			return "sounds/weapons/fg42/shoot.wav";
		case W_GEWEHR:
			return "sounds/weapons/gewehr/shoot.wav";
		case W_KAR_SCOPE:
			return "sounds/weapons/kar/shoot.wav";
		case W_M1:
			return "sounds/weapons/garand/shoot.wav";
		case W_M1A1:
			return "sounds/weapons/m1carbine/shoot.wav";
		case W_M2:
			return "sounds/weapons/m2flame/flamethrower.wav";
		case W_MP40:
			return "sounds/weapons/mp40/shoot.wav";
		case W_MG:
			return "sounds/weapons/mg42/shoot.wav";
		case W_PANZER:
			return "sounds/weapons/panzer/shoot.wav";
		case W_PPSH:
			return "sounds/weapons/ppsh/shoot.wav";
		case W_PTRS:
			return "sounds/weapons/ptrs/shoot.wav";
		case W_RAY:
			return "sounds/weapons/raygun/shoot.wav";
		case W_SAWNOFF:
			return "sounds/weapons/shotgun/shoot.wav";
		case W_STG:
			return "sounds/weapons/stg/shoot.wav";
		case W_TRENCH:
			return "sounds/weapons/shotgun/shoot.wav";
		case W_TYPE:
			return "sounds/weapons/type100/shoot.wav";
		case W_BIATCH:
			return "sounds/weapons/colt/shoot.wav";
    }

    return "";
}

float(float wep) IsDualWeapon = {
	switch(wep) {
		case W_BIATCH:
			return 1;
		default:
			return 0;
	}
}

float(float wep) IsPapWeapon = {
	switch(wep) {
		case W_BIATCH:
			return 1;
		default:
			return 0;
	}
}

void (float wep, float anim_style, float dualwep, float curweaponframe)	PlayWeaponSound =
{
	if (anim_style == FIRE)
	{
		if (wep == W_KAR || wep == W_KAR_SCOPE)
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
		else if (wep == W_TRENCH || wep == W_GUT)
		{
			if (curweaponframe == 7)
				sound (self ,5, "sounds/weapons/shotgun/pump.wav", 1, ATTN_NORM);
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
		case W_DB:
		case W_SAWNOFF:
			if (curweaponframe == 6) {
				sound (self ,5, "sounds/weapons/shotgun/open.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 12) {
				sound (self ,5, "sounds/weapons/shotgun/out.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 20) {
				sound (self ,5, "sounds/weapons/shotgun/in.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 26) {
				sound (self ,5, "sounds/weapons/shotgun/close.wav", 1, ATTN_NORM);
			}
			break;
		case W_FG:
			if (curweaponframe == 43) {
				sound (self ,5, "sounds/weapons/fg42/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 60) {
				sound (self ,5, "sounds/weapons/fg42/magin.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 72) {
				sound (self ,5, "sounds/weapons/fg42/boltback.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 77) {
				sound (self ,5, "sounds/weapons/fg42/boltforward.wav", 1, ATTN_NORM);
			}
			break;
		case W_GEWEHR:
			if (curweaponframe == 10) {
				sound (self ,5, "sounds/weapons/gewehr/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 24) {
				sound (self ,5, "sounds/weapons/gewehr/magin.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 27) {
				sound (self ,5, "sounds/weapons/gewehr/maghit.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 33) {
				sound (self ,5, "sounds/weapons/gewehr/boltrelease.wav", 1, ATTN_NORM);
			}
			break;
		case W_KAR_SCOPE:
			if (curweaponframe == 15) {
				sound (self ,5, "sounds/weapons/kar/boltup.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 16) {
				sound (self ,5, "sounds/weapons/kar/boltback.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 20) {
				sound (self ,5, "sounds/weapons/kar/insert.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 25) {
				sound (self ,5, "sounds/weapons/kar/boltforward.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 27) {
				sound (self ,5, "sounds/weapons/kar/boltdown.wav", 1, ATTN_NORM);
			}
			break;
		case W_M1:
			if (curweaponframe == 6) {
				sound (self ,5, "sounds/weapons/garand/clipout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 20) {
				sound (self ,5, "sounds/weapons/garand/clipin.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 26) {
				sound (self ,5, "sounds/weapons/garand/clippush.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 37) {
				sound (self ,5, "sounds/weapons/garand/boltrelease.wav", 1, ATTN_NORM);
			}
			break;
		case W_M1A1:
			if (curweaponframe == 6) {
				sound (self ,5, "sounds/weapons/m1carbine/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 14) {
				sound (self ,5, "sounds/weapons/m1carbine/magin.wav", 1, ATTN_NORM);
			} else if(curweaponframe == 16) {
				sound (self ,5, "sounds/weapons/m1carbine/maghit.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 24) {
				sound (self ,5, "sounds/weapons/m1carbine/bolt.wav", 1, ATTN_NORM);
			}
			break;
		case W_MG:
			if (curweaponframe == 8) {
				sound (self ,5, "sounds/weapons/mg42/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 19) {
				sound (self ,5, "sounds/weapons/mg42/magin.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 29) {
				sound (self ,5, "sounds/weapons/mg42/charge.wav", 1, ATTN_NORM);
			}
			break;
		case W_MP40:
			if (curweaponframe == 10) {
				sound (self ,5, "sounds/weapons/mp40/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 17) {
				sound (self ,5, "sounds/weapons/mp40/magin.wav", 1, ATTN_NORM);
			}
			break;
		case W_PANZER:
			if (curweaponframe == 12) {
				sound (self ,5, "sounds/weapons/panzer/move.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 16) {
				sound (self ,5, "sounds/weapons/panzer/insert.wav", 1, ATTN_NORM);
			}
			break;
		case W_PPSH:
				if (curweaponframe == 7) {
				sound (self ,5, "sounds/weapons/ppsh/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 15) {
				sound (self ,5, "sounds/weapons/ppsh/magin.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 19) {
				sound (self ,5, "sounds/weapons/ppsh/maghit.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 26) {
				sound (self ,5, "sounds/weapons/ppsh/boltback.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 28) {
				sound (self ,5, "sounds/weapons/ppsh/boltrelease.wav", 1, ATTN_NORM);
			}
			break;
		case W_PTRS:
			if (curweaponframe == 6) {
				sound (self ,5, "sounds/weapons/ptrs/open.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 18) {
				sound (self ,5, "sounds/weapons/ptrs/magin.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 21) {
				sound (self ,5, "sounds/weapons/ptrs/maghit.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 27) {
				sound (self ,5, "sounds/weapons/ptrs/close.wav", 1, ATTN_NORM);
			}
			break;
		case W_RAY:
			if (curweaponframe == 7) {
				sound (self ,5, "sounds/weapons/raygun/open.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 12) {
				sound (self ,5, "sounds/weapons/raygun/out.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 21) {
				sound (self ,5, "sounds/weapons/raygun/in.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 26) {
				sound (self ,5, "sounds/weapons/raygun/close.wav", 1, ATTN_NORM);
			}
			break;
		case W_STG:
			if (curweaponframe == 11) {
				sound (self ,5, "sounds/weapons/stg/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 21) {
				sound (self ,5, "sounds/weapons/stg/magin.wav", 1, ATTN_NORM);
			}
			break;
		case W_TRENCH:
			if (curweaponframe == 19) {
				sound (self ,5, "sounds/weapons/shotgun/insert.wav", 1, ATTN_NORM);
			}
		case W_TYPE:
			if (curweaponframe == 6) {
				sound (self ,5, "sounds/weapons/type100/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 15) {
				sound (self ,5, "sounds/weapons/type100/magin.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 20) {
				sound (self ,5, "sounds/weapons/type100/boltpull.wav", 1, ATTN_NORM);
			}
			break;
		case W_BIATCH:
			if (curweaponframe == 10) {
				sound (self ,5, "sounds/weapons/colt/magout.wav", 1, ATTN_NORM);
			} else if (curweaponframe == 19) {
				sound (self ,5, "sounds/weapons/colt/magin.wav", 1, ATTN_NORM);
			} else if(curweaponframe == 26) {
				sound (self ,5, "sounds/weapons/colt/slide.wav", 1, ATTN_NORM);
			}
			break;
	}
}


void(float weptype) precache_extra =
{
	switch (weptype) {
		case W_COLT:
		case W_BIATCH:
			precache_sound("sounds/weapons/colt/shoot.wav");
			precache_sound("sounds/weapons/colt/magout.wav");
			precache_sound("sounds/weapons/colt/magin.wav");
			precache_sound("sounds/weapons/colt/slide.wav");
			precache_model ("models/weapons/m1911/v_biatch_right.mdl");	// sprite explosion
			break;
		case W_KAR_SCOPE:
		case W_KAR:
			precache_sound ("sounds/weapons/kar/boltup.wav");
			precache_sound ("sounds/weapons/kar/boltback.wav");
			precache_sound ("sounds/weapons/kar/boltforward.wav");
			precache_sound ("sounds/weapons/kar/boltdown.wav");
			precache_sound ("sounds/weapons/kar/clipin.wav");
			precache_sound ("sounds/weapons/kar/clipoff.wav");
			precache_sound ("sounds/weapons/kar/shoot.wav");
			precache_sound ("sounds/weapons/kar/insert.wav");
			precache_model ("models/weapons/kar/v_karscope.mdl");
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
		case W_SAWNOFF:
		case W_DB:
			precache_sound("sounds/weapons/shotgun/open.wav");
			precache_sound("sounds/weapons/shotgun/out.wav");
			precache_sound("sounds/weapons/shotgun/in.wav");
			precache_sound("sounds/weapons/shotgun/close.wav");
			precache_sound("sounds/weapons/shotgun/shoot.wav");
			break;
		case W_FG:
			precache_sound("sounds/weapons/fg42/magout.wav");
			precache_sound("sounds/weapons/fg42/magin.wav");
			precache_sound("sounds/weapons/fg42/boltback.wav");
			precache_sound("sounds/weapons/fg42/boltforward.wav");
			precache_sound("sounds/weapons/fg42/shoot.wav");
			break;
		case W_GEWEHR:
			precache_sound("sounds/weapons/gewehr/magout.wav");
			precache_sound("sounds/weapons/gewehr/magin.wav");
			precache_sound("sounds/weapons/gewehr/maghit.wav");
			precache_sound("sounds/weapons/gewehr/boltrelease.wav");
			precache_sound("sounds/weapons/gewehr/shoot.wav");
			break;
		case W_M1:
			precache_sound ("sounds/weapons/garand/clipout.wav");
			precache_sound ("sounds/weapons/garand/clipin.wav");
			precache_sound ("sounds/weapons/garand/clippush.wav");
			precache_sound ("sounds/weapons/garand/boltrelease.wav");
			precache_sound ("sounds/weapons/garand/shoot.wav");
			break;
		case W_M1A1:
			precache_sound("sounds/weapons/m1carbine/shoot.wav");
			precache_sound("sounds/weapons/m1carbine/magout.wav");
			precache_sound("sounds/weapons/m1carbine/magin.wav");
			precache_sound("sounds/weapons/m1carbine/maghit.wav");
			precache_sound("sounds/weapons/m1carbine/bolt.wav");
			break;
		case W_M2:
			precache_sound("sounds/weapons/m2flame/flamethrower.wav");
			//precache_model ("progs/flame_main2.spr");	// sprite explosion
			break;
		case W_MP40:
			precache_sound ("sounds/weapons/mp40/shoot.wav");
			precache_sound ("sounds/weapons/mp40/magout.wav");
			precache_sound ("sounds/weapons/mp40/magin.wav");
			break;
		case W_MG:
			precache_sound("sounds/weapons/mg42/magout.wav");
			precache_sound("sounds/weapons/mg42/magin.wav");
			precache_sound("sounds/weapons/mg42/charge.wav");
			precache_sound("sounds/weapons/mg42/shoot.wav");
			break;
		case W_PANZER:
			precache_sound ("sounds/weapons/panzer/move.wav");
			precache_sound ("sounds/weapons/panzer/insert.wav");
			precache_sound ("sounds/weapons/panzer/shoot.wav");
			//precache_model ("progs/shark.mdl");
			break;
		case W_PPSH:
			precache_sound("sounds/weapons/ppsh/magout.wav");
			precache_sound("sounds/weapons/ppsh/magin.wav");
			precache_sound("sounds/weapons/ppsh/maghit.wav");
			precache_sound("sounds/weapons/ppsh/boltback.wav");
			precache_sound("sounds/weapons/ppsh/boltrelease.wav");
			precache_sound("sounds/weapons/ppsh/shoot.wav");
			break;
		case W_PTRS:
			precache_sound ("sounds/weapons/ptrs/open.wav");
			precache_sound ("sounds/weapons/ptrs/maghit.wav");
			precache_sound ("sounds/weapons/ptrs/magin.wav");
			precache_sound ("sounds/weapons/ptrs/close.wav");
			precache_sound ("sounds/weapons/ptrs/shoot.wav");
			break;
		case W_RAY:
			precache_sound("sounds/weapons/raygun/open.wav");
			precache_sound("sounds/weapons/raygun/out.wav");
			precache_sound("sounds/weapons/raygun/in.wav");
			precache_sound("sounds/weapons/raygun/close.wav");
			precache_sound("sounds/weapons/raygun/shoot.wav");
			//precache_model ("progs/raybeam.mdl");
			break;
		case W_STG:
			precache_sound ("sounds/weapons/stg/magout.wav");
			precache_sound ("sounds/weapons/stg/magin.wav");
			precache_sound ("sounds/weapons/stg/shoot.wav");
			break;
		case W_TRENCH:
			precache_sound ("sounds/weapons/shotgun/pump.wav");
			precache_sound ("sounds/weapons/shotgun/insert.wav");
			precache_sound ("sounds/weapons/shotgun/shoot.wav");
			break;
		case W_TYPE:
			precache_sound("sounds/weapons/type100/magout.wav");
			precache_sound("sounds/weapons/type100/magin.wav");
			precache_sound("sounds/weapons/type100/boltpull.wav");
			precache_sound("sounds/weapons/type100/shoot.wav");
			break;
	}
}