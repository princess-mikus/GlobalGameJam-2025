extends CharacterBody3D

@onready var player = $"../Player"
@onready var timer = $Timer

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite3D
@onready var gum = $Gum
@onready var originalPosition = transform.origin
@onready var explosionScene = preload("res://scenes/explosion.tscn")

const moveSpeed = 20
const maxKnockbackSpeed = 20
const timeKnockback = 0.5
const fallSpeed = 100
const maxTimeFreeze = 2
const damageArea = 0.22

var dead = false
var knockbackSpeed = 0
var knockback = Vector3.ZERO
var timeFreeze = 0


func _physics_process(delta: float) -> void:
	
	var gravity
	var direction
	
	# Add the gravity.
	if not is_on_floor():
		gravity = fallSpeed * Vector3(0,-1,0)
	else:
		gravity = Vector3.ZERO
	
	if not dead and knockbackSpeed <= 0 and timeFreeze <= 0:
		var playerCoor = player.transform.origin
		var enemyCoor = transform.origin
		direction = moveSpeed * (playerCoor - enemyCoor).normalized()
		animation.play()
		#material.albedo_color = originalColor
		if sprite != null:
			sprite.flip_h = direction.x > 0
			sprite.modulate = Color(1,1,1)
			gum.visible = false
	elif knockbackSpeed > 0:
		direction = knockbackSpeed * knockback.normalized()
		knockbackSpeed -= maxKnockbackSpeed/(60.0*timeKnockback)
	elif timeFreeze > 0:
		direction = Vector3.ZERO
		timeFreeze -= (1.0/60)
	else:
		direction = Vector3.ZERO
		#material.albedo_color = originalColor
	
	velocity = delta * (direction + gravity)
	
	move_and_slide()

	if (position-player.position).length() <= damageArea:
		player._on_damage(position,false)
	
func collision(collision: Vector3, name: String):
	if (name == "Explosion" or name == "Bubble") and timeFreeze <= 0:
		var enemyCoor = transform.origin
		knockback = enemyCoor - collision
		knockbackSpeed = maxKnockbackSpeed
		animation.pause()
		#material.albedo_color = Color(1,0,0)
	elif name == "Bubble_Gum":
		knockbackSpeed = 0
		timeFreeze = maxTimeFreeze
		sprite.modulate = Color(1,0,1)
		animation.pause()
		gum.visible = true
		#material.albedo_color = Color(0,0,1)

func _on_area_3d_body_exited(body: Node3D) -> void:
	dead = true
	timer.start(3)

func _on_timer_timeout() -> void:
	dead = false
	position = Vector3(0.5,0.12,0)

# Mira mi bombita tic tac tic
func _on_kaboom_timeout() -> void:
	var explosion = explosionScene.instantiate()
	dead = true
	explosion.position = position
	get_node("../waveMaker").enemyDied(self)
	get_node("..").add_child(explosion)
	queue_free()
