extends Timer
@export var min_ttf: float = 0.125; # shortest possible time enemy will wait
@export var max_ttf: float = 1.05; # longest possible time enemy will wait
var player_wins: int = 0;
signal player_wins_updated(no_of_wins);
	
func new_round_prep():
	recalculate_ttfs();
	
func recalculate_ttfs():
	var low_ttf: float = clamp(((16 - float(self.player_wins)) / 16) * .95, self.min_ttf, self.max_ttf);
	var high_ttf: float = clamp(((16 - float(self.player_wins)) / 16) * 1.05, self.min_ttf, self.max_ttf);
	print(low_ttf, " ~ ", high_ttf);
	self.wait_time = randf_range(low_ttf, high_ttf); #temporary

func _on_player_player_fired_first():
	self.stop();
	self.player_wins += 1;
	player_wins_updated.emit(self.player_wins);

func _on_player_player_fired_too_soon():
	self.stop();
	self.player_wins = 0;
	player_wins_updated.emit(self.player_wins);
