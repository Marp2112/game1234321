extends ProgressBar

@onready var damage_bar = $DamageBar
@onready var timer = $Timer

var spirit_energy = 0 : set = _set_spirit_energy

var MoveDamageBar = false

func _physics_process(_delta):
	if MoveDamageBar:
		damage_bar.value = move_toward(damage_bar.value, spirit_energy, 1.5)
	
	if !timer.is_stopped():
		MoveDamageBar = false

func _set_spirit_energy(new_spirit_energy):
	var prev_spirit_energy = spirit_energy
	spirit_energy = min(max_value, new_spirit_energy)
	value = spirit_energy
	
	if spirit_energy <= 0:
		pass
		
	if spirit_energy < prev_spirit_energy:
		timer.start()
	else:
		damage_bar.value = spirit_energy
	

func init_spirit_energy(_spirit_energy):
	spirit_energy = _spirit_energy
	max_value = spirit_energy
	value = spirit_energy
	damage_bar.max_value = spirit_energy
	damage_bar.value = spirit_energy


func _on_timer_timeout():
	MoveDamageBar = true
