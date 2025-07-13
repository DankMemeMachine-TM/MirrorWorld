extends Node
var draw_declared: bool = false;
var ready_to_input: bool = false;
signal player_fired_first;
signal player_fired_too_soon;

func _process(_delta):
	if(ready_to_input):
		if(Input.is_action_just_pressed("confirm") || Input.is_action_just_pressed("confirm")):
			if(draw_declared):
				one_fired();
				player_fired_first.emit();
			else:
				one_fired();
				player_fired_too_soon.emit();

func declare_draw():
	draw_declared = true;

func _on_ready_timer_timeout():
	ready_to_input = true;

func _on_enemy_timeout():
	one_fired();

func one_fired():
	draw_declared = false;
	ready_to_input = false;
