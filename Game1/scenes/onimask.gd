extends CharacterBody2D
@onready var sprite_2d = $Sprite2D
@onready var ledge_check_right = $LedgeCheckRight
@onready var ledge_check_left = $LedgeCheckLeft
@onready var check_player = $CheckPlayer
var speed = 1000
var FacingRight = true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var target = null
var isAttacking = true
@onready var attack_duration = $Attack_Duration
@onready var attack_anticipation = $AttackAnticipation
@onready var collision_shape_2d = $AttackHitBox/CollisionShape2D
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
	if !stunned:
		if velocity.x != 0:
			sprite_2d.animation = "running"
			sprite_2d.speed_scale = velocity.x / 300
			sprite_2d.rotation = velocity.x / 1000
	else:
		sprite_2d.animation = "idle"
		sprite_2d.rotation = 0
	
	if !recover_time.is_stopped():
		sprite_2d.modulate = Color.RED
		isHurt=false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if ((!ledge_check_right.is_colliding() || !ledge_check_left.is_colliding()) && is_on_floor()) || is_on_wall():
		flip()
	if !stunned:
		velocity.x = speed
	move_and_slide()
		
		
func flip():
	FacingRight = !FacingRight
	sprite_2d.flip_h = !sprite_2d.flip_h
	if FacingRight:
		speed = abs(speed)
	else:
		speed = -abs(speed)

func _on_check_player_area_entered(area):
	pass

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
	sprite_2d.rotation = 0
	velocity.x = -velocity.x/10
	velocity.y = -600

func _on_stunned_timer_timeout():
	stunned = false
	isAttacking = true

func _on_attack_hit_box_area_entered(area):
	if area.is_in_group("playerhitbox") && !area.get_parent().isInvincible:
		area.get_parent().take_damage(global_position, 10)
