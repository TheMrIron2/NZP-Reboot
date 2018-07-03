/* ================================
    Achievement code by MotoLegacy
   ================================ */

void() Achievement_Init = {
    //define all of the achivements
    activeachievement = -1; //-1 = no achievement to display
    achievementname[0] = "Ready..";
    achievementdesc[0] = "Reach Round 5.";
    achievementimg[0] = strcat(achievementdir, "ready.tga");
    achievementname[1] = "Steady..";
    achievementdesc[1] = "Reach Round 10.";
    achievementimg[1] = strcat(achievementdir, "steady.tga");
    achievementname[2] = "Go? Hell No...";
    achievementdesc[2] = "Reach Round 15.";
    achievementimg[2] = strcat(achievementdir, "go.tga");

    //unlock the achievements that we already have
    local float file;
    local string val;
    file = fopen("ach.dat", FILE_READ);
    val = fgets(file);
    achievementunlocked[0] = stof(val);
    val = fgets(file);
    achievementunlocked[1] = stof(val);
    val = fgets(file);
    achievementunlocked[2] = stof(val);
    fclose(file);
}

void(float ach) Unlock_Achievement = {
    local float file;

    achievementunlocked[ach] = 1;

    file = fopen("ach.dat", FILE_WRITE);

    if (achievementunlocked[0])
        fputs(file, "1\n");
    else
        fputs(file, "0\n");
    if (achievementunlocked[1])
        fputs(file, "1\n");
    else
        fputs(file, "0\n");
    if (achievementunlocked[2])
        fputs(file, "1\n");
    else
        fputs(file, "0\n");
    fclose(file);

    activeachievement = ach;
}