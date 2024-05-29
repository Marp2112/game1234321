extends Sprite2D
var blacksword
var normalsword
# Called when the node enters the scene tree for the first time.
func _ready():
	blacksword = preload("res://pixelplayerassets/swordentenblack.png")
	normalsword = preload("res://pixelplayerassets/swordenten.png")
func _physics_process(delta):
	var blackmode = get_parent().get_parent().get_parent().BLACKMODE
	if blackmode:
		texture = blacksword
	else:
		texture = normalsword
