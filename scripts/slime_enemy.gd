extends CharacterBody3D

@onready var parent = $".."
@onready var player = $"../Player"
@onready var timer = $Timer

@onready var sprite = $Sprite3D
@onready var gum = $Gum
@onready var wave = $"../waveMaker"
@onready var mesh = $MeshInstance3D
@onready var originalPosition = transform.origin

@onready var slimelingScene = preload("res://scenes/slimeling_enemy.tscn")

@onready var mat1 = preload("res://sprites/IMG_3100.png")
@onready var mat2 = preload("res://sprites/IMG_3101.png")
@onready var mat3 = preload("res://sprites/IMG_3102.png")


const moveSpeed = 20

const maxKnockbackSpeed = 40
const timeKnockback = 1
const fallSpeed = 100
const maxTimeFreeze = 2
const damageArea = 0.4
const probDivide = 0.5
const verticalOffset = 0.16

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
		if randf() < probDivide:
			divide()
		#material.albedo_color = Color(1,0,0)
	elif name == "Bubble_Gum":
		knockbackSpeed = 0
		timeFreeze = maxTimeFreeze
		sprite.modulate = Color(1,0,1)
		gum.visible = true
		#material.albedo_color = Color(0,0,1)

func divide():
	var slimes = [slimelingScene.instantiate(),slimelingScene.instantiate(),slimelingScene.instantiate()]
	var offset = [Vector3(0.1,0,0),Vector3(0,0,0.1),Vector3(-0.1,0,0)]
	var sprites = [mat1,mat2,mat3]
	for i in slimes.size():
		slimes[i].transform.origin = global_position + Vector3(0,verticalOffset,0) + offset[i]
		slimes[i].name = name + "_" + str(i)
		slimes[i].get_child(0).texture = sprites[i]
		parent.add_child(slimes[i])
	wave.slimeDivided()
	queue_free()
