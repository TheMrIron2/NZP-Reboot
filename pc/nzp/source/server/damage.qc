void(entity attacker, float d_style) DieHandler =
{
    float t;

    t = random();

    if (self.classname == "ai_zombie") {
        self.th_die();
    }

    if (attacker.classname == "player") {
        if (d_style == S_NORMAL) {
            addmoney(attacker, 60, true);
            total_powerup_points = total_powerup_points + 60;
        }
    }
}

void(entity victim,entity attacker, float damage, float d_style) DamageHandler = {
	entity old_self;
	if (victim.classname == "ai_zombie") {
		if (attacker.classname == "player" && (victim.health - damage)> 0) {
			addmoney(attacker, 10, 1);
        }

		victim.health = victim.health - damage;

		if (victim.health <= 0 || instakill_finished) {
			old_self = self;
			self = victim;
			DieHandler(attacker, d_style);
			self = old_self;
		}
	}
}