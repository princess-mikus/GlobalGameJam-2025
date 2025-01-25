extends CharacterBody3D

@onready var parent = $".."
@onready var player = $"../Player"
@onready var timer = $Timer

@onready var mesh = $MeshInstance3D
@onready var material = mesh.get_surface_override_material(0)
@onready var originalColor = material.albedo_color
@onready var originalPosition = transform.origin

@onready var slimelingScene = preload("res://scenes/slimeling_enemy.tscn")

const moveSpeed = 20
const maxKnockbackSpeed = 40
const timeKnockback = 1
const fallSpeed = 100
const maxTimeFreeze = 2
const damageArea = 0.25
const probDivide = 0.5
const verticalOffset = 0.08

var dead = false
var knockbackSpeed = 0
var knockback = Vector3.ZERO
var timeFreeze = 0


func _ready():
	randomize()

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
		#material.albedo_color = originalColor
	elif knockbackSpeed > 0:
		print(knockbackSpeed)
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
		player._on_damage(position)
	
	
func collision(collision: Vector3, name: String):
	if name == "Bubble" and timeFreeze <= 0:
		var enemyCoor = transform.origin
		knockback = enemyCoor - collision
		knockbackSpeed = maxKnockbackSpeed
		if randf() < probDivide:
			divide()
		#material.albedo_color = Color(1,0,0)
	elif name == "Bubble_Gum":
		knockbackSpeed = 0
		timeFreeze = maxTimeFreeze
		#material.albedo_color = Color(0,0,1)

func _on_timer_timeout() -> void:
	dead = false
	queue_free()

func divide():
	var slimes = [slimelingScene.instantiate(),slimelingScene.instantiate(),slimelingScene.instantiate()]
	var offset = [Vector3(0.1,0,0),Vector3(0,0,0.1),Vector3(-0.1,0,0)]
	for i in slimes.size():
		slimes[i].transform.origin = global_position + Vector3(0,verticalOffset,0) + offset[i]
		slimes[i].name = name + "_" + str(i)
		parent.add_child(slimes[i])
	queue_free()
