extends CharacterBody3D

@onready var player = $"../Player"
@onready var timer = $Timer

@onready var mesh = $MeshInstance3D

@onready var slimeling = preload("res://scenes/slimeling_enemy.tscn")

const moveSpeed = 20
const maxKnockbackSpeed = 60
const timeKnockback = 1
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
	queue_free()
