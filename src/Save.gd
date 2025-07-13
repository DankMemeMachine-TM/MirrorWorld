extends Node
var save_disabled: bool = false; #if save cannot be created/loaded for whatever reason, turn this on so game doesn't try to save
var save_dic = {
	"main" : "user://save/001.res",
	"mini" : "user://save/002.res",
	"suspend": "user://save/003.res",
}

func save_disabled_check():
	if(save_disabled):
		print("saving is disabled for this session");
	return save_disabled;

func check_if_save_folder_exists(): # check mid-game; if false, disable saving
	if(DirAccess.open("user://save")):
		print("save data found!")
		return true;
	return false;
	
func startup_load_save_data():
	if(!check_if_save_folder_exists()):
		self.initialize_save_data();

func initialize_save_data():
	print("creating save data...");
	self.create_save_folder();
	self.create_maingame_save_data();
	self.create_minigame_save_data();
	self.create_suspend_save_data();
	print("save data created!");

func create_save_folder():
	if(!check_if_save_folder_exists()):
		DirAccess.open("user://").make_dir("save");
	else:
		print("save folder exists");
		
func create_maingame_save_data():
	var maingame_save_data = {
		"game_started" : 0,
		"times_died" : 0,
		"game_overs": 0,
		"continues_used": 0,
		"enemies_killed": 0,
		"game_completed": 0,
		"expert_mode_completed": 0,
	};
	var packed = PackedDataContainer.new();
	packed.pack(maingame_save_data);
	ResourceSaver.save(packed, save_dic["main"]);

func create_minigame_save_data():
	var minigame_save_data = {
		"quickdraw_high_score" : 0,
		"nightflight_high_score" : 0
	};
	var packed = PackedDataContainer.new();
	packed.pack(minigame_save_data);
	ResourceSaver.save(packed, save_dic["mini"]);
	
func create_suspend_save_data():
	var suspend_save_data = {
		"current_level" : 0,
		"lives" : 0,
		"continues" : 0,
		"bullets" : 0,
	}
	var packed = PackedDataContainer.new();
	packed.pack(suspend_save_data);
	ResourceSaver.save(packed, save_dic["suspend"]);

func load_minigame_data():
	if(save_disabled_check()):
		return null;
	var container = load(save_dic["mini"]);
	if(container == null):
		print("minigame data not found");
		self.create_minigame_save_data();
		container = load(save_dic["mini"]);
		print(container);
	return container;
	
func save_minigame_data(data, input, to_save):
	if(save_disabled_check()):
		return null;
	var minigame_save_data = {
		"quickdraw_high_score" : input if to_save == "quickdraw_high_score" else data["quickdraw_high_score"] if data else 0,
		"nightflight_high_score" : input if to_save == "nightflight_high_score" else data["nightflight_high_score"] if data else 0,
	};
	var packed = PackedDataContainer.new();
	packed.pack(minigame_save_data);
	ResourceSaver.save(packed, save_dic["mini"]);
	return packed;
