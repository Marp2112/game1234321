extends CharacterBody2D

var SPEED = 1000
var dir : float
var spawnPos : Vector2
var spawnRot : float
var direction : float
var starttimer = false
@onready var sprite_2d = $Sprite2D
@onready var duration = $duration

func _ready():
	global_position.x = spawnPos.x - 7
	global_position.y = spawnPos.y - 30
	
func _physics_process(delta):
	rotation = rotation + 0.05
	print(starttimer)
	print(duration.time_left)
	if starttimer && duration.is_stopped():
		starttimer = false
		duration.start()
	if duration.is_stopped():
		destroy()
	move_and_slide()
	
func destroy():
	queue_free()

