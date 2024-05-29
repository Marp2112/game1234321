extends CharacterBody2D

#some new stuff
@onready var animation_player = $AnimationPlayer

#Movement
var SPEED = 300.0
var ACCEL = 100
const WALK_SPEED = 300.0
const DASH_SPEED = 1800
const RUN_SPEED = 600.0
const WALK_ACCEL = 80.0
const RUN_ACCEL = 10

#Particles
@onready var running_particles = $RunningParticles
@onready var landing_particles = $LandingParticles

#Jumping & Gravity
const JUMP_VELOCITY = -800.0
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer

var DEFAULT_GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var FALLING_GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.5
var GRAVITY = 10

#Dashing
var isDashing = false
var dashdecel = 0
var can_air_dash = false
@onready var dash_cooldown = $DashCooldown
@onready var dash_buffer_timer = $DashBufferTimer

#Other
var CANMOVE = true
var GETMOVEINPUT = true #doesnt remove gravity while CANMOVE freezes the player completely
var DIRECTION
var InTheAir = false
@onready var sprite_2d = $AnimatedSprite2D

#Combat
var SWORD = false
var BLACKMODE = false
var isAttacking = false
@onready var attack_hitbox = $AttackHitbox
var isInvincible = false
@onready var attack_buffer_timer = $AttackBufferTimer
@onready var combo_timer = $ComboTimer
var attack_number = 0
@onready var combo_reset = $ComboReset


#Parry
var isParrying = false
@onready var parry_hitbox = $ParryHitbox
@onready var parry_duration = $ParryDuration
@onready var parry_cooldown = $ParryCooldown
@onready var parry_buffer_timer = $ParryBufferTimer

#TakingDmg
@onready var recovery_time = $RecoveryTime
@onready var invincible_time = $InvincibleTime

#Health Bar
var health
@onready var health_bar = $CanvasLayer/HealthBar

#Respawn
@onready var respawn_time = $RespawnTime
var regen_health = false

#Abilities
#Black
@onready var node_2d = $".."
@onready var black_mode_duration = $BlackModeDuration
@onready var black_projectile = load("res://scenes/black_projectile.tscn")
@onready var sword_particles = $SwordParticles

#Spirit Energy Bar
var spirit_energy
@onready var spirit_energy_bar = $CanvasLayer/SpiritEnergyBar

#Fishes
@onready var fish_point = $FishPoint
@onready var black_fish_sprite = $FishPoint/BlackFishSprite

#sword position,sprite
@onready var sword_pivot = $AnimatedSprite2D/SwordPivot
var sword_flipped = false

func  _ready():
	#Max energy
	spirit_energy = 99
	spirit_energy_bar.init_spirit_energy(spirit_energy)
	#Max health
	health = 100
	health_bar.init_health(health)
	

func _physics_process(delta):
	#Landing particles
	if !is_on_floor():
		InTheAir = true
	if is_on_floor() && InTheAir:
		InTheAir = false
		landing_particles.emitting = true
	
	#sword turn aroun
	if sprite_2d.flip_h && !sword_flipped:
		flip_sword()
	elif !sprite_2d.flip_h && sword_flipped:
		flip_sword()

	if SWORD:
		sword_pivot.visible = true
	else:
		sword_pivot.visible = false
		

	#Sword particles
	if sword_particles.emitting:
		if sprite_2d.flip_h:
			sword_particles.position.x = -abs(sword_particles.position.x)
			sword_particles.scale.x = -1
		else:
			sword_particles.position.x = abs(sword_particles.position.x)
			sword_particles.scale.x = 1

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	DIRECTION = direction

	#Dashing
	if Input.is_action_just_pressed("dash") && !isAttacking:
		if is_on_floor():
			dash_buffer_timer.start()
		elif !is_on_floor() && can_air_dash:
			dash_buffer_timer.start()
			can_air_dash = false
	
	if is_on_floor():
		can_air_dash = true
		
	if !dash_buffer_timer.is_stopped() && dash_cooldown.is_stopped() && direction && !animation_player.current_animation == "dash":
		isDashing = true
		animation_player.play("dash")
	
	# Animation running
	if velocity.x != 0 && !isDashing && is_on_floor() && !isAttacking && !isParrying:
		running_particles.emitting = true
		animation_player.play("run")
		sprite_2d.speed_scale = velocity.x / 300
		sprite_2d.rotation = velocity.x / 1000
	
	# Animation idle
	else:
		running_particles.emitting = false
		if !isDashing && !isAttacking && !isParrying:
			animation_player.play("idle")
	
	# Add the gravity.
	if not is_on_floor() && CANMOVE:
		velocity.y += GRAVITY * delta
		if velocity.y > 0 :
			GRAVITY = FALLING_GRAVITY #move_toward( GRAVITY, FALLING_GRAVITY, 100)
			if sprite_2d.flip_h:
				sprite_2d.rotation = 0.6
			else:
				sprite_2d.rotation = -0.6
		else:
			if !Input.is_action_pressed("jump"):
				GRAVITY = FALLING_GRAVITY * 1.5
				if sprite_2d.flip_h:
					sprite_2d.rotation = -0.6
				else:
					sprite_2d.rotation = 0.6
			else:
				GRAVITY = DEFAULT_GRAVITY
				if sprite_2d.flip_h:
					sprite_2d.rotation = -0.6
				else:
					sprite_2d.rotation = 0.6
	
	if sprite_2d.flip_h:
		attack_hitbox.rotation = PI
		parry_hitbox.rotation = PI
	else:
		attack_hitbox.rotation = 0
		parry_hitbox.rotation = 0
		
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()
		
	if !jump_buffer_timer.is_stopped()  && GETMOVEINPUT && CANMOVE && (is_on_floor() || !coyote_timer.is_stopped()):
		jump_buffer_timer.stop()
		velocity.y = JUMP_VELOCITY
	
	
	if (Input.is_action_just_pressed("left") && velocity.x > 0 || Input.is_action_just_pressed("right") && velocity.x < 0) && CANMOVE && GETMOVEINPUT:
		velocity.x = 0
	
	#move
	if direction && !animation_player.current_animation == "attack2" && !animation_player.current_animation == "dash":
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL)
	elif !animation_player.current_animation == "attack2":
		velocity.x = move_toward(velocity.x, 0, ACCEL)
		
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	# coyote timer.
	if was_on_floor && !is_on_floor() && velocity.y >= 0:
		coyote_timer.start()
	
	if velocity.x != 0 && GETMOVEINPUT:
		var isLeft = velocity.x < 0
		sprite_2d.flip_h = isLeft
	
	
	
	#handle attack
	if Input.is_action_just_pressed("attack"):
		attack_buffer_timer.start()
	if !attack_buffer_timer.is_stopped() && SWORD && CANMOVE && GETMOVEINPUT && !isDashing && !isAttacking && !isParrying && is_on_floor():
		combo_reset.start()
		isAttacking = true
		attack_number += 1
		if attack_number == 1:
			if !sprite_2d.flip_h:
				animation_player.play("attack1")
			else:
				animation_player.play("attack1L")
		elif attack_number == 2:
			if !sprite_2d.flip_h:
				animation_player.play("attack2")
			else:
				animation_player.play("attack2L")
		elif attack_number == 3 :
			if !sprite_2d.flip_h:
				animation_player.play("attack3")
			else:
				animation_player.play("attack3L")
			attack_number = 0
	
	
	if Input.is_action_just_pressed("parry"):
		parry_buffer_timer.start()
		
	if !parry_buffer_timer.is_stopped() && SWORD && CANMOVE && parry_cooldown.is_stopped() && !isAttacking && !isParrying:
		#parry()
		isParrying = true
		animation_player.play("parry")
	
	if Input.is_action_just_pressed("equipsword") && !SWORD:
		SWORD = true
	else:
		if Input.is_action_just_pressed("equipsword") && SWORD:
			SWORD = false

	if Input.is_action_just_pressed("ability1") && SWORD:
		black()
	if black_mode_duration.is_stopped():
		BLACKMODE = false
		black_fish_sprite.visible = false
		sword_particles.emitting = false
	else:
		fish_point.rotation = fish_point.rotation + 0.07
		black_fish_sprite.rotation = cos(fish_point.rotation + PI/2)
		fish_point.position.y = cos(fish_point.rotation)*20 - 50
	
	if regen_health:
		health = move_toward(health, 100, 1)
		health_bar.health = health
		if health == 100:
			regen_health = false
			
	if !is_on_floor() && Input.is_action_just_pressed("attack") && !sprite_2d.flip_h:
		isAttacking = true
		animation_player.play("air_attack")
	elif !is_on_floor() && Input.is_action_just_pressed("attack") && sprite_2d.flip_h:
		isAttacking = true
		animation_player.play("air_attackL")
		
func dash():
	dash_cooldown.start()
	CANMOVE = false
	velocity.x = DIRECTION * DASH_SPEED
	velocity.y = 0

func black():
	#Reduce Spirit Energy
	var spirit_energy_used = 33
	if spirit_energy_bar.value >= spirit_energy_used:
		spirit_energy = spirit_energy - spirit_energy_used
		spirit_energy_bar.spirit_energy = spirit_energy
		
		# black projectile
		var instance = black_projectile.instantiate()
		black_mode_duration.start()
		instance.dir = rotation
		instance.spawnPos.y = global_position.y
		if sprite_2d.flip_h :
			instance.direction = -1
			instance.spawnPos.x = global_position.x - 40
		else:
			instance.direction = 1
			instance.spawnPos.x = global_position.x + 40
		node_2d.add_child.call_deferred(instance)
		BLACKMODE = true
		# black fish
		black_fish_sprite.visible = true
		sword_particles.emitting = true

func attack():
	isAttacking = true
	velocity.x = 0
	combo_timer.start()
	if sprite_2d.flip_h:
		velocity.x = velocity.x - 30
	else:
		velocity.x = velocity.x + 30

func _on_attack_hitbox_area_entered(area):
	if area.is_in_group("enemiehitbox"):
		area.get_parent().take_damage(global_position, 5)
		if animation_player.current_animation == "air_attack" || animation_player.current_animation == "air_attackL":
			velocity.y = JUMP_VELOCITY * 1.5

func take_damage(damage_source_position: Vector2, received_damage: int):
	var knockback_direction = damage_source_position.direction_to(self.global_position)
	var knockback_strength = 100
	var knockback = knockback_direction * knockback_strength
	
	velocity.x = knockback.x * 25
	velocity.y = -600
	
	frame_freeze(0.1, 0.4)
	
	#Reduce Health
	health = health - received_damage
	health_bar.health = health
	
	isInvincible = true
	GETMOVEINPUT = false
	recovery_time.start()
	invincible_time.start()

func _on_recovery_time_timeout():
	GETMOVEINPUT = true

func _on_invincible_time_timeout():
	isInvincible = false 
	
func frame_freeze(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1

func parry():
	parry_duration.start()
	GETMOVEINPUT = false
	isParrying = true
	spirit_energy_bar.spirit_energy += 33
	spirit_energy += 33
	if spirit_energy > 99:
		spirit_energy = 99
		spirit_energy_bar.spirit_energy = 99
	
func _on_parry_hitbox_area_entered(area):
	if area.is_in_group("EnemyAttack") && (!area.get_parent().attack_duration.is_stopped() || area.get_parent().isAttacking):
		area.get_parent().call_deferred("get_parried")
		frame_freeze(0.1,0.4)

func _on_parry_duration_timeout():
	isParrying = false
	GETMOVEINPUT = true
	parry_cooldown.start()

func flip_sword():
		sword_pivot.position.x = -sword_pivot.position.x
		sword_pivot.rotation = -sword_pivot.rotation
		sword_pivot.scale.x = -sword_pivot.scale.x
		sword_flipped = !sword_flipped

func die():
	regen_health = true

func reset():
	isDashing = false
	CANMOVE = true
	GETMOVEINPUT = true
	isAttacking = false
	isParrying = false


func _on_combo_reset_timeout():
	attack_number = 0
