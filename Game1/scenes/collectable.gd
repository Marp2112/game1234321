extends Area2D

@onready var player_hitbox = $PlayerHitbox




func _on_body_entered(body):
	if (body.name == "player_hitbox"):
		queue_free()
