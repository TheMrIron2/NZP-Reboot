//
// nzdparser.qc - parses NZData files for map variety.. yeah, that's a good way to put it.
//

/*
    For what ever reason, this has no affect on PSP.
    The function is called, yet absolotely NOTHING
    in the game changes. FIXME.
*/

//custom weapon search
void(entity who) nzd_defineweapon = {
	float f, p, l, fnum, wepnum, framenum, fsnd;
	string line;

	line = strcat(mappath, ".cw");
	f = fopen(line, FILE_READ);

	if (f == -1) { //no custom weapons
		return;
	}
	wepnum = -1;
	p = 0;
	l = 1;

	while(l) {
		string li;
		li = fgets(f);

		if not (li) {
			l = 0;
			break;
		}

		line = strtrim(li);

		if (line == "")
			continue;

		switch(p) {
			case 0:
				wepnum += 1;
				if (line == "weapon")
					p = 1;
				break;
			case 1:
				if (line == "{")
					p = 2;
				else
					bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(line, " expected {\n")));
				break;
			case 2:
				tokenize(line);

				string v, vari;
				vari = strtrim(argv(0));
				v = strtrim(argv(2));

				switch (vari) {
					case "name":
						W_CUSTOMNAME[wepnum] = v;
						break;
					case "mag":
						W_CMAG[wepnum] = stof(v);
						break;
					case "reserve":
						W_CRESERVE[wepnum] = stof(v);
						break;
					case "vmodel":
						W_CVMODEL[wepnum] = v;
						break;
					case "vmodel2":
						W_CVMODEL2[wepnum] = v;
						break;
					case "gmodel":
						W_CGMODEL[wepnum] = v;
						break;
					case "isdual":
						W_CDUAL[wepnum] = stof(v);
						break;
					case "firetype":
						W_CFIRETYPE[wepnum] = stof(v);
						break;
					case "dmg":
						W_CDMG[wepnum] = stof(v);
						break;
					case "shotcount":
						W_CSHOTCOUNT[wepnum] = stof(v);
						break;
					case "bodypen":
						W_CBODYPEN[wepnum] = stof(v);
						break;
					case "penetration":
						W_CPENETRATION[wepnum] = stof(v);
						break;
					case "spread":
						W_CSPREAD[wepnum] = stof(v);
						break;
					case "fdelay":
						W_CFDELAY[wepnum] = stof(v);
						break;
					case "rdelay":
						W_CRDELAY[wepnum] = stof(v);
						break;
					case "walkspeed":
						W_CWALKSPD[wepnum] = stof(v);
						break;
					case "firesound":
						W_CFIRESOUND[wepnum] = v;
						break;
					case "skin":
						W_CSKIN[wepnum] = stof(v);
						break;
					case "recoil":
						W_CRECOIL[wepnum] = stof(v);
						break;
					case "crossmin":
						W_CCROSSMIN[wepnum] = stof(v);
						break;
					case "crossmax":
						W_CCROSSMAX[wepnum] = stof(v);
						break;
					case "lowmag":
						W_CLOWMAG[wepnum] = stof(v);
						break;
					case "lowreserve":
						W_CLOWRES[wepnum] = stof(v);
						break;
					case "flash":
						W_CFLASH[wepnum] = stov(v);
					case "flashsize":
						W_CFLASHSIZE[wepnum] = stof(v);
						break;
					case "pap":
						W_CPAPWEP[wepnum] = stof(v);
						break;
					case "ads":
						W_CADS[wepnum] = stov(v);
						break;
					case "frames":
						p = 3;
						break;
					case "framesnd":
						p = 5;
						break;
					case "snd":
						p = 7;
						break;
                    case "}":
						#ifndef PSP
						#ifndef NX
						sendCustomWeapon(wepnum, W_CUSTOMNAME[wepnum], W_CVMODEL[wepnum], W_CMAG[wepnum], W_CRESERVE[wepnum], vtos(W_CADS[wepnum]), W_CCROSSMIN[wepnum], W_CCROSSMAX[wepnum], vtos(W_CFLASH[wepnum]), W_CFLASHSIZE[wepnum], W_CVMODEL2[wepnum], W_CDUAL[wepnum], who);
						#endif
						#endif
						if (wepnum == MAX_CWEAPONS - 1) {
							l = 0;
							break;
						} else {
							p = 0;
							fnum = 0;
							framenum = 0;
							fsnd = 0;
						}
                        break;
					default:
						bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(line, " expected }\n")));
						break;
				}
				break;
			case 3:
                if (line == "[") {
                    p = 4;
                } else {
                    bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(line, " expected [\n")));
                }
                break;
            case 4:
                if (line == "]") {
                    p = 2;
                } else {
					switch(wepnum) {
						case 0: W_C1FRAMES[fnum] = stof(line); break;
						case 1: W_C2FRAMES[fnum] = stof(line); break;
						case 2: W_C3FRAMES[fnum] = stof(line); break;
						case 3: W_C4FRAMES[fnum] = stof(line); break;
					}
					fnum++;
                }
				break;
			case 5:
                if (line == "[") {
                    p = 6;
                } else {
                    bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(line, " expected [\n")));
                }
                break;
            case 6:
                if (line == "]") {
                    p = 2;
                } else {
					switch(wepnum) {
						case 0: W_C1XSNDFRAME[framenum] = stof(line); break;
						case 1: W_C2XSNDFRAME[framenum] = stof(line); break;
						case 2: W_C3XSNDFRAME[framenum] = stof(line); break;
						case 3: W_C4XSNDFRAME[framenum] = stof(line); break;
					}
					framenum++;
                }
				break;
			case 7:
                if (line == "[") {
                    p = 8;
                } else {
                    bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(line, " expected [\n")));
                }
                break;
            case 8:
                if (line == "]") {
                    p = 2;
                } else {
					switch(wepnum) {
						case 0: W_C1XTRASND[fsnd] = line; break;
						case 1: W_C2XTRASND[fsnd] = line; break;
						case 2: W_C3XTRASND[fsnd] = line; break;
						case 3: W_C4XTRASND[fsnd] = line; break;
					}
					fsnd++;
                }
				break;
		}
	}
	fclose(f);
}

//basically copying the waypoint code.. yikes
void() load_nzd = {

	#ifndef NX
    float file, point;
    string h;
    float loop;
    float wepdata = 0;

    h = strcat(mappath, ".nzd");
	file = fopen (h, FILE_READ);
	
	if (file == -1)
	{
		dprint(".NZD file not found, using default settings..\n");
		return;
	}

    point = 0;
    loop = 1;

    while(loop) {
        string line;
		line = fgets(file);
		if not (line) {
			bprint(PRINT_HIGH, "End of file\n");
			loop = 0;
			break;
		}
		h = strtrim(line);

		//print(h, "\n");
		if (h == "") {
			continue;
		}

		switch (point) {
			case 0:
                //switch-ception!
                switch(h) {
                    case "mech": point = 1; break;
                    default: bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(h, "\n")));
                }
				break;
			case 1:
				if (h == "{") {
					point = 2;
				} else {
					bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(h, " expected {\n")));
				}
				break;
			case 2:
				tokenize(h);

				string value, variable;
				variable = strtrim(argv(0));
				value = strtrim(argv(2));
				switch (variable) {
					case "proneperkpoints":
						G_PRONEPOINTS = stof(value);
						break;
					case "spawnpoints":
						G_STARTPOINTS = stof(value);
						break;
                    case "round":
                        G_STARTROUND = stof(value);
                        break;
                    case "worldtext":
                        G_WORLDTEXT = stof(value);
                        break;
					case "perkpower":
						G_PERKPOWER = stof(value);
						break;
					case "hud":
						G_HUD = value;
						break;
					case "hudhor":
						G_HUDHOR = stof(value);
						break;
                    case "wep":
                        point = 3;
                        break;
					case "perk":
						point = 5;
						break;
                    case "}":
                        loop = 0;
                        break;
					default:
						bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(h, " expected }\n")));
						break;
				}
				break;
            case 3:
                if (h == "[") {
                    point = 4;
                } else {
                    bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(h, " expected [\n")));
                }
                break;
            case 4:
                if (h == "]") {
                    point = 2;
                } else {
                    G_STARTWEAPON[wepdata] = stof(h);
                    wepdata++;
                }
                break;
			case 5:
				if (h == "[") {
					point = 6;
				} else {
					bprint(PRINT_HIGH, strcat("Error: unknown variable ", strcat(h, " expected [\n")));
				}
				break;
			case 6:
				if (h == "]") {
					point = 2;
				} else {
					G_PERKS = G_PERKS | stof(h);
				}
				break;
		}
	}

	fclose(file);
	#endif
}