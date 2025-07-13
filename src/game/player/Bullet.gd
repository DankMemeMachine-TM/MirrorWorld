extends Area2D
@export var speed = 5000;
var vertical_bullet: bool = false;

func _ready():
	hide();
	
func _physics_process(delta):
	if(vertical_bullet):
		self.position += -transform.y * speed * delta;
	else:
		self.position += transform.x * speed * delta;
	
func init(bullet_pos, facing, vertical):
	self.position = bullet_pos;
	if(vertical == 0):
		self.speed *= facing;
	if(vertical != 0):
		self.vertical_bullet = true;
		self.speed *= vertical;
	show();

func _on_duration_timeout():
	self.queue_free();
