extends Area2D


func _on_body_entered(body):
	if (body.name == "CharacterBody2D"):
		print("nigger")
		queue_free()
