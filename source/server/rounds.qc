void() Spawn_Enemy = 
{
	if (roundtype == 1)
	{
		if (spawn_a_zombieA())
		{
			Current_Zombies = Current_Zombies + 1;
		}
	}
	else if (roundtype == 2)
	{
		if (spawn_a_dogA())
		{
			Current_Zombies = Current_Zombies + 1;
		}
	}
}

void(string s) playSoundAtPlayers =
{
	local entity p;
	p = find(world,classname,"player");
	while(p)
	{
		sound(p,CHAN_AUTO,s,1,ATTN_NONE);
		p = find(p,classname,"player");
	}
}

void() EndRound =
{
	rounds_change = 4;
	SetUpdate(self, UT_ROUNDS_CHANGE, rounds_change, 0, 0);
	playSoundAtPlayers("sounds/rounds/eround.wav");
	round_changetime = time + 5;
}

void() PlayerSpawn;

void() NewRound =
{		
	entity who = find(world,classname,"spectator");
	while(who != world)
	{
		if(who.isspec)
		{
			self = who;
			PlayerSpawn();
			break;
		}
		
	}

	entity tempe;
	round_changetime = 0;
	spawn_time = time + 5;
	sounds_playing = 0;//just in case it ever somehow glitches
	if (delay_at_round > 0.08)
	{
		delay_at_round = delay_at_round*0.95;
		if (delay_at_round < 0.08)
			delay_at_round = 0.08;
	}
	if (rounds != 0)
	{
		playSoundAtPlayers("sounds/rounds/nround.wav");
		rounds_change = 6;
		SetUpdate(self, UT_ROUNDS_CHANGE, rounds_change, 0, 0);
		blink_return = time + 2;
	}
	rounds = rounds + 1;

	NotifyNewRound(rounds);
	tempe = find(world, classname, "player");
	while (tempe)
	{
		if(tempe.grenades & 1)
		{
			tempe.primary_grenades = tempe.primary_grenades + 2;
			if (tempe.primary_grenades > 4)
				tempe.primary_grenades = 4;
		}
		tempe = find(tempe, classname, "player");
	}
	set_z_health();
	if(rounds < 10)
	{
		if (rounds == 1)
			Remaining_Zombies = Total_Zombies = 6;//6 jukkihere 1
		else if (rounds == 2)
			Remaining_Zombies = Total_Zombies = 8;//8 jukkihere 42
		else if (rounds == 3)
			Remaining_Zombies = Total_Zombies = 13;//13 jukkihere 42
		else if (rounds == 4)
			Remaining_Zombies = Total_Zombies = 18;//18 jukkihere 42
		else if (rounds == 5 && !gotdog)
			Remaining_Zombies = Total_Zombies = 24;
		else if (rounds == 5 && gotdog)
			Remaining_Zombies = Total_Zombies = 10; // naievil -- if we have dogs then we should have the true value
		else if (rounds == 6)
			Remaining_Zombies = Total_Zombies = 27;
		else if (rounds == 7)
			Remaining_Zombies = Total_Zombies = 28;
		else if (rounds == 8)
			Remaining_Zombies = Total_Zombies = 28;
		else if (rounds == 9)
			Remaining_Zombies = Total_Zombies = 29;
	}
	else
	{
		if ((rounds == 10 || rounds == 15) && gotdog)
			Remaining_Zombies = Total_Zombies = 15;
		else
			Remaining_Zombies = Total_Zombies = rint((0.0842 * rounds * rounds) + (0.1954 * rounds)+22.05);
	}
	maxreward = 50 * rounds;
	if (maxreward > 500)
			maxreward = 500;
	totalreward = 0;
	Current_Zombies = 0;
	spawn_delay = 0;
	totalpowerups = 0;
	powerup_activate = powerup_activate*1.14;
	
	if ((rounds == 5 || rounds == 10 || rounds == 15) && gotdog) {
		roundtype = 2;
		localcmd("fog 0.25\n"); 
	} else {
		roundtype = 1;
		localcmd(strcat("fog ", world.fog));
	}
}
void() Round_Core =
{
	if (game_over)
		return;
	
	if (round_changetime <= (time + 2) && !rounds && round_changetime) {
		rounds_change = 2;
	}

	if (round_changetime <= (time + 2) && rounds && round_changetime) {
		rounds_change = 5;
	}

	if (blink_return && blink_return < time && rounds_change == 6)
	{
		blink_return = time + 3;
		rounds_change = 7;
	}
	if (blink_return && blink_return < time && rounds_change == 7)
	{
		blink_return = 0;
		rounds_change = 0;
	}
	if (round_changetime >= time)
		return;
	if (round_changetime)
	{
		roundtype = 1;
			
		NewRound();
		return;
	}
	if (Total_Zombies > Current_Zombies && spawn_time < time)
	{
		Spawn_Enemy();
	}
	if (!Remaining_Zombies && !Delay_Time)
	{
		Delay_Time = time + 2;
		rounds_change = 3;
	}
	else if (Delay_Time && Delay_Time < time)
	{
		Delay_Time = 0;
		EndRound();
	}
	
	SetUpdate(self, UT_ROUNDS_CHANGE, rounds_change, 0, 0);
}

void() InitRounds =
{
	roundtype = 1;
	delay_at_round = 2/0.95;
	totalpowerups = 0;
	powerup_activate = 2000/1.14;
	spawnAllZombEnts();
	round_changetime = time + 2;
	rounds_change = 1;
	roundinit = 1;
	SetUpdate(self, UT_ROUNDS_CHANGE, rounds_change, 0, 0);
}