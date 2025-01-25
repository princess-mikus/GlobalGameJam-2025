extends CharacterBody3D

@onready var player = $"../Player"
@onready var timer = $Timer

@onready var mesh = $MeshInstance3D
@onready var explosion_scene = preload("res://scenes/explosion.tscn")

const moveSpeed = 20
const maxKnockbackSpeed = 5
const timeKnockback = 0.5
const fallSpeed = 100

var dead = false
var knockbackSpeed = 0
var knockback = Vector3.ZERO

func _physics_process(delta: float) -> void:
	
	var gravity
	var direction
	
	# Add the gravity.
	if not is_on_floor():
		gravity = fallSpeed*Vector3(0,-1,0)
	else:
		gravity = Vector3.ZERO
	
	if not dead and knockbackSpeed == 0:
		var playerCoor = player.transform.origin
		var enemyCoor = transform.origin
		direction = moveSpeed * (playerCoor - enemyCoor).normalized()
	elif knockbackSpeed > 0:
		direction = knockbackSpeed * knockback.normalized()
		knockbackSpeed -= maxKnockbackSpeed/(60/timeKnockback)
	else:
		direction = Vector3.ZERO
	
	velocity = delta * (direction + gravity)
	
	move_and_slide()
	
func collision(collision: Vector3):
	var enemyCoor = transform.origin
	knockback = enemyCoor - collision
	knockbackSpeed = maxKnockbackSpeed

func _on_area_3d_body_exited(body: Node3D) -> void:
	dead = true
	timer.start(3)

func _on_timer_timeout() -> void:
	dead = false
	position = Vector3(0.5,0.12,0)

# Mira mi bombita tic tac tic
func _on_kaboom_timeout() -> void:
	var explosion = explosion_scene.instantiate()
	dead = true
	print("Kaboom!!!")
	explosion.position = position
	get_node("..").add_child(explosion)
	queue_free()
