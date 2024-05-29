extends CharacterBody2D

var SPEED = 1000
var dir : float
var spawnPos : Vector2
var spawnRot : float
var direction : float
@onready var sprite_2d = $Sprite2D

func _ready():
	global_position = spawnPos
	
func _physics_process(_delta):
	if direction < 0:
		sprite_2d.flip_h = true
	else: 
		sprite_2d.flip_h = false
	velocity.x = SPEED * direction
	move_and_slide()

func _on_area_2d_body_entered(_body):
	queue_free()


func _on_area_2d_area_entered(area):
	if area.is_in_group("enemiehitbox"):
		area.get_parent().take_damage(global_position, 80)
