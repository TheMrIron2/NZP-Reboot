//
// nzdparser.qc - parses NZData files for map variety.. yeah, that's a good way to put it.
//

/*
    For what ever reason, this has no affect on PSP.
    The function is called, yet absolotely NOTHING
    in the game changes. FIXME.
*/

//basically copying the waypoint code.. yikes
void() load_nzd = {
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
                    case "wep":
                        point = 3;
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
		}
	}

	fclose(file);
}