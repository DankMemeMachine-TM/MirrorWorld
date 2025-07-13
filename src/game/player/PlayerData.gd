extends Node
enum Weapon {MELEE, GUN};
var max_hp: int = 3;
var current_hp: int = 3;
var max_ammo: int = 99;
var current_ammo: int = 8;
var current_weapon: Weapon = Weapon.MELEE;

func swap_weapon():
	if(self.current_ammo <= 0 && self.current_weapon != Weapon.GUN): # when out of ammo, only swap if currently equipped w/ gun
		print("can't swap, out of ammo");
		return;
	if(current_weapon == Weapon.GUN):
		current_weapon = Weapon.MELEE;
	else:
		current_weapon = Weapon.GUN;

func change_hp(change_amount):
	self.current_hp = clamp(self.current_hp + change_amount, 0, self.max_hp);
	print(self.current_hp);
