extends Node2D
@export var sword_direction: int = 1;
@export var duck_attack: bool = false;
signal attack_finished

func _ready():
	hide();

func _on_sword_handler_horizontal_attack(facing, duck):
	if (self.sword_direction == facing && self.duck_attack == duck):
		attack_processing();
#	else:
#		error_handling(facing, duck, self.sword_direction, self.duck_attack, "horizontal");
		
func _on_sword_handler_vertical_attack(vertical, duck):
	if(self.sword_direction == vertical && self.duck_attack == duck):
		attack_processing();
#	else:
#		error_handling(vertical, duck, self.sword_direction, self.duck_attack, "vertical");		

func attack_processing():
	self.show();
	$Timer.start();
	
#func error_handling(face, is_duck, direction, duckattack, string):
#	print("ERROR: ", string, " attack in ", direction, " direction with ", duckattack, " duck state");
#	print("but actual state is ", face, " direction with ", is_duck, " duck state\n");
#	hide(); # just in case
#	attack_finished.emit(); # exit without attacking

func _on_timer_timeout():
	hide();
	attack_finished.emit();
