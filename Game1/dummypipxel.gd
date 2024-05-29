extends AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
var taking_damage = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !taking_damage:
		animation_player.play("idle")


func take_damage(_damage_source_position: Vector2, received_damage: int):
	taking_damage = true
	animation_player.play("hurt")
	
func reset():
	taking_damage = false
