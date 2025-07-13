extends CanvasLayer

func _ready():
	$AmmoLabel.init();
	$QuitButton.show();

func _on_player_bullet_fired(ammo):
	$AmmoLabel/RemainingBullets.text = str(ammo);
