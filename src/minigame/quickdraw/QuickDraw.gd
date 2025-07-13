extends Node
signal main_scene_transition(to);
signal new_round_started(score);
signal ready_to_draw;
var current_score: int = 0;
var high_score: int = 0;
var save_file;

func _ready():
	# will probably add a set of instructions pre-game
	self.save_file = Save.load_minigame_data();
	self.high_score = self.save_file["quickdraw_high_score"] if self.save_file else 0; #TODO: make function in case save is corrupt
	self.initialize_game();
	
func initialize_game():
	$Hud/CurrentScoreText/CurrentScoreValue.text = str(0);
	$Hud/HighScoreText/HighScoreValue.text = str(high_score);
	self.new_round();

func new_round():
	$Hud/CurrentScoreText/CurrentScoreValue.text = str(current_score);
	new_round_started.emit(self.current_score);
	$Hud/ReadyText.show();
	$Hud/DrawText.hide();
	$Hud/VictoryText.hide();
	$Hud/DefeatText.hide();
	$Hud/TooSoonText.hide();
	$Hud/ReplayText.hide();
	$Hud/ReadyText/ReadyTimer.start();
	
func restart_game():
	self.current_score = 0;
	$Hud/CurrentScoreText/CurrentScoreValue.text = str(current_score);
	
func quit_game():
	main_scene_transition.emit("TitleScene");

func _on_quit_button_button_up(): #debug function
	self.quit_game();

func _on_ready_timer_timeout():
	$Hud/ReadyText.hide();
	$DrawTimer.start();
	
func _on_draw_timer_timeout():
	$Hud/DrawText.show();
	$Enemy.start();
	$Player.call("declare_draw");

func _on_player_player_fired_first(): # PLAYER WINS
	self.current_score += 1;
	$Hud/CurrentScoreText/CurrentScoreValue.text = str(self.current_score);
	# Should this be run every time a new high score is set, or should the user manually save their new score?
	if(self.current_score > self.high_score):
		self.high_score = self.current_score;
		$Hud/HighScoreText/HighScoreValue.text = str(self.high_score);
		if(self.save_file):
			self.save_file = Save.save_minigame_data(self.save_file, self.high_score, "quickdraw_high_score");
		else:
			print("no save file detected: high score not saved");
	$Hud/DrawText.hide();
	$Hud/VictoryText.show();
	$PostGameTimer.start();

func _on_enemy_timeout(): # PLAYER LOSES
	self.current_score = 0;
	$Hud/DrawText.hide();
	$Hud/DefeatText.show();
	#$Enemy.player_wins = 0;
	$PostGameTimer.start();
	
func _on_player_player_fired_too_soon(): # PLAYER LOSES
	self.current_score = 0;
	$Hud/TooSoonText.show();
	$DrawTimer.stop();
	$PostGameTimer.start();

func _on_post_game_timer_timeout(): # PROMPT PLAYER TO CONTINUE/PLAY AGAIN
	$Hud/VictoryText.hide();
	$Hud/DefeatText.hide();
	$Hud/TooSoonText.hide();
	$Hud/ReplayText.show();

func _on_yes_button_button_up():
	self.new_round();

func _on_no_button_button_up():
	self.quit_game();
