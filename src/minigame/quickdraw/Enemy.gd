extends Timer
@export var min_ttf: float = 0.125; # shortest possible time enemy will wait
@export var max_ttf: float = 1.05; # longest possible time enemy will wait
var player_wins: int = 0;
signal player_wins_updated(no_of_wins);
	
func new_round_prep() -> void:
	recalculate_ttfs();
	
func recalculate_ttfs() -> void:
	# After about 14 wins, the enemy will reach their smallest minimum possible ttf. At 15, they reach their smallest maximum ttf.
	var low_ttf: float = clamp(((16 - float(self.player_wins)) / 16) * .95, self.min_ttf, self.max_ttf);
	var high_ttf: float = clamp(((16 - float(self.player_wins)) / 16) * 1.05, self.min_ttf, self.max_ttf);
	print(low_ttf, " ~ ", high_ttf); #DEBUG
	self.wait_time = randf_range(low_ttf, high_ttf);
	
func _on_quick_draw_new_round_started(score: int) -> void:
	player_wins = score;
	self.new_round_prep();
	#TODO: add code to reset animations

func _on_player_player_fired_first() -> void:
	self.stop();
	#TODO: add animations and shiet

func _on_player_player_fired_too_soon() -> void:
	self.stop();
	#TODO: add animations and shiet
