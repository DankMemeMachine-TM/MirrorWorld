extends CanvasLayer
signal main_scene_transition(to, from);

func _on_test_scene_button_button_up():
	main_scene_transition.emit("TestScene");

func _on_quick_draw_button_button_up():
	main_scene_transition.emit("QuickDrawScene");
