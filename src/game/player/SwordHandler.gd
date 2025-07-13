extends Node
signal horizontal_attack
signal vertical_attack

func _on_player_attack_input(facing, duck, vertical):
	if(!vertical):
		horizontal_attack.emit(facing, duck);
	else:
		vertical_attack.emit(vertical, duck);
