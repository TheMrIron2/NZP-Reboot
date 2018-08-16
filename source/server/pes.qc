/*
    Moon's PES System
     ~ MotoLegacy ~
*/

.float haspes;
.float pesactive;

void() changegrav = {
    if (other.gravity == 1)
        other.gravity = 0.2;
    else
        other.gravity = 1;
}

void() func_gravchange =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);
    setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
    self.touch = changegrav;
};

void() touch_pes = {
    if (other.classname != "player" || other.haspes)
        return;

    useprint(other, 14, 0, 0);
    if (other.button7) {
        other.haspes = true;
        local entity tempe;
        tempe = self;
        self = other;
        Set_W_Frame (0, 39, 0, 0, 0, W_TakeOut, "models/machines/v_pap.mdl", true, S_BOTH);
        self = tempe;

        other.pesactive = true;
    }
}

void() item_pes = {
    self.solid = SOLID_TRIGGER;
	precache_model ("models/machines/quick_revive.mdl");
	precache_model ("models/machines/v_perk.mdl");
	precache_sound ("sounds/machines/perk_drink.wav");
  	precache_sound ("sounds/weapons/papfire.wav");
	setorigin (self, self.origin);
	setmodel (self, "models/machines/quick_revive.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.classname = "item_pes";
	self.touch = touch_pes;
}