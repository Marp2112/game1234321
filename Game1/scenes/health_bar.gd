extends ProgressBar

@onready var damage_bar = $DamageBar
@onready var timer = $Timer

var health = 0 : set = _set_health

var MoveDamageBar = false

func _physics_process(_delta):
	if MoveDamageBar:
		damage_bar.value = move_toward(damage_bar.value, health, 1.5)
	
	if !timer.is_stopped():
		MoveDamageBar = false

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		get_parent().queue_free()
		
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health
	

func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health


func _on_timer_timeout():
	MoveDamageBar = true
