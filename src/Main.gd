extends Node
var current_scene: Node;
var TestScene = preload("res://src/TestScene.tscn");
var TitleScene = preload("res://src/title/Title.tscn");
var QuickDrawScene = preload("res://src/minigame/quickdraw/QuickDraw.tscn");
#var NightFlightScene = preload("res://src/minigame/nightflight/NightFlight.tscn");

# Use strings when transitions are called to get the needed scene
var scene_dic = {
	"TestScene" = TestScene,
	"TitleScene" = TitleScene,
	"QuickDrawScene" = QuickDrawScene,
	#"NightFlightScene" = NightFlightScene
}

func _ready():
	Save.startup_load_save_data();
	add_new_scene(TitleScene);

# remove the "from" scene, and add the "to" scene (use a func for this to connect signals)
func _on_scene_transition(to):
	current_scene.queue_free();
	add_new_scene(scene_dic[to]);
	
# add the new scene and connect the scene transition signal to the new scene
func add_new_scene(to):
	var new_scene: Node = to.instantiate();
	current_scene = new_scene;
	self.add_child(new_scene);
	new_scene.main_scene_transition.connect(_on_scene_transition);
