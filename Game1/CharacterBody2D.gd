extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
var player = preload("res://scenes/player.gd").new()
@onready var hit_collision_shape_2d = $Hit/CollisionShape2D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if velocity.x != 0:
		animated_sprite_2d.animation = "Run"
	
	
	velocity.x = -SPEED
	
	if velocity.x != 0:
		var isRight = velocity.x > 0
		animated_sprite_2d.flip_h = isRight

	move_and_slide()


func _on_hit_body_entered(body):
	if (body.name == "CharacterBody2D"):
		if body.position.x > position.x:
			print("left of enemy")
			player.hitfromright = true
		if body.position.x < position.x:
			print("right of enemy")
		player.knockback = true
