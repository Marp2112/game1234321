extends CharacterBody2D
@onready var sprite_2d = $Sprite2D
@onready var ledge_check_right = $LedgeCheckRight
@onready var ledge_check_left = $LedgeCheckLeft
@onready var check_player = $CheckPlayer
var chasing = false
var patrolspeed = 100.0
var chasingspeed = 200
var FacingRight = true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var target = null
var isAttacking
@onready var attack_duration = $Attack_Duration
@onready var attack_range = $AttackRange
@onready var attack_anticipation = $AttackAnticipation
@onready var collision_shape_2d = $AttackHitBox/CollisionShape2D
@onready var attack_hit_box = $AttackHitBox
@onready var attack_cooldown = $AttackCooldown
@onready var recover_time = $RecoverTime

#Health Bar
var health
@onready var health_bar = $HealthBar

@onready var blood = $Blood

var stunned = false

var isHurt = false

@onready var stunned_timer = $StunnedTimer


func _ready():
	health = 100
	health_bar.init_health(health)

func _physics_process(delta):
	# Animation running
	if !isAttacking && !stunned:
		if velocity.x != 0:
			if !chasing:
				sprite_2d.animation = "running"
			else:
				sprite_2d.animation = "runningsword"
			sprite_2d.speed_scale = velocity.x / 300
			sprite_2d.rotation = velocity.x / 1000
		else:
			if !chasing:
				sprite_2d.animation = "idle"
				sprite_2d.rotation = 0
			else:
				sprite_2d.animation = "idlesword"
	
	if !recover_time.is_stopped():
		sprite_2d.modulate = Color.RED
		isHurt=false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if (!ledge_check_right.is_colliding() || !ledge_check_left.is_colliding()) && is_on_floor && !chasing:
		flip()
	
	if !isAttacking:
		if !chasing && !stunned:
			velocity.x = patrolspeed
		elif abs(global_position.x - target.global_position.x) > 300 && !stunned:
			if global_position.x < target.global_position.x:
				velocity.x = chasingspeed
			else:
				velocity.x = -chasingspeed
		elif !stunned:
			if global_position.x < target.global_position.x:
				velocity.x = chasingspeed/1.5
			else:
				velocity.x = -chasingspeed/1.5
				
	if !sprite_2d.flip_h:
		check_player.rotation = 0
		attack_range.rotation = 0
		attack_hit_box.rotation = 0
	else:
		check_player.rotation = PI
		attack_range.rotation = PI
		attack_hit_box.rotation = PI
		
	if velocity.x != 0 && recover_time.is_stopped() && attack_anticipation.is_stopped() && attack_duration.is_stopped():
		var isLeft = velocity.x < 0
		sprite_2d.flip_h = isLeft
	
	if !attack_duration.is_stopped():
		if !sprite_2d.flip_h:
			velocity.x = 800
		else:
			velocity.x = -800
			
	if !attack_cooldown.is_stopped():
		velocity.x=0
	move_and_slide()
		
		
func flip():
	FacingRight = !FacingRight
	if FacingRight:
		patrolspeed = abs(patrolspeed)
	else:
		patrolspeed = -abs(patrolspeed)

func _on_check_player_area_entered(area):
	if area.get_parent().is_in_group("player") && !chasing:
		target = area.get_parent()
		chasing = true

func _on_attack_range_area_entered(area):
	if area.get_parent().is_in_group("player") && !isAttacking:
		call_deferred("attack")

func attack():
	isAttacking = true
	velocity.x = 0
	if sprite_2d.flip_h:
		sprite_2d.rotation = 1
	else:
		sprite_2d.rotation = -1
	if attack_duration.is_stopped() && attack_cooldown.is_stopped():
		attack_anticipation.start()

func _on_attack_anticipation_timeout():
	$AttackHitBox/CollisionShape2D.disabled = false
	sprite_2d.rotation = - sprite_2d.rotation
	attack_duration.start()

func _on_attack_duration_timeout():
	attack_cooldown.start()
	$AttackHitBox/CollisionShape2D.disabled = true

func _on_attack_hit_box_area_entered(area):
	if area.is_in_group("playerhitbox") && !area.get_parent().isInvincible:
		area.get_parent().take_damage(global_position, 10)

func _on_attack_cooldown_timeout():
	isAttacking = false
	
func take_damage(_damage_source_position: Vector2, received_damage: int):
	#Blood particles
	blood.emitting = true
	#Reduce Health
	health = health - received_damage
	health_bar.health = health
	
	recover_time.start()
	print("enemy took damage")

func _on_recover_time_timeout():
	sprite_2d.modulate = Color.WHITE

func get_parried():
	attack_duration.stop()
	stunned_timer.start()
	stunned = true
	isAttacking = false
	attack_hit_box.monitoring = false
	velocity.x = 0
	sprite_2d.rotation = 0
	attack_range.monitoring = false
	velocity.x = -velocity.x/10
	velocity.y = -600

func _on_stunned_timer_timeout():
	$AttackHitBox/CollisionShape2D.disabled = true
	stunned = false
	attack_hit_box.monitoring = true
	attack_range.monitoring = true
