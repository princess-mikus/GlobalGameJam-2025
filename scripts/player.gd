extends CharacterBody3D

const SPEED = 1.0
const maxCoolDownBubble = 0.5
const maxCoolDownBubbleGum = 2.5
const chargedElapsed = 1
const chargedScale = 0.16
const nonChargedScale = 0.08
const verticalOffset = 0.08
const maxKnockbackSpeed = 1.5
const timeKnockback = 0.1

@onready var bubble_scene = preload("res://scenes/bubble.tscn")
@onready var bubble_gum_scene = preload("res://scenes/bubble_gum.tscn")
@onready var mesh = $MeshInstance3D
@onready var material = mesh.get_surface_override_material(0)
@onready var parent = $".."
@onready var pivot = $Pivot

var coolDownBubble = 0
var coolDownBubbleGum = 0

var timeStart = 0
var chargingBubble = null
var scaleBubble = 0

var knockbackSpeed = 0
var knockback = Vector3.ZERO

func _input(event):
	if Input.is_action_just_released("bubble") and coolDownBubble <= 0 and chargingBubble != null:
		coolDownBubble = maxCoolDownBubble
		chargingBubble.direction = pivot.get_global_transform().basis * Vector3(0,0,-1)
		chargingBubble = null
		timeStart = 0
	elif Input.is_action_pressed("bubble") and coolDownBubble <= 0 and chargingBubble == null:
		timeStart = Time.get_ticks_msec()
		chargingBubble = bubble_scene.instantiate()
		chargingBubble.transform.origin = global_position + Vector3(0,verticalOffset,0) + verticalOffset*(pivot.get_global_transform().basis * Vector3(0,0,-1)).normalized()
		chargingBubble.direction = Vector3.ZERO
		scaleBubble = nonChargedScale
		chargingBubble.get_child(0).scale = Vector3.ONE*scaleBubble
		chargingBubble.get_child(1).scale = Vector3.ONE*scaleBubble
		var material = chargingBubble.get_child(0).get_surface_override_material(0)
		material.albedo_color = Color(0,0,1)
		parent.add_child(chargingBubble)
	elif Input.is_action_just_pressed("bubble_gum") and coolDownBubbleGum <= 0 and timeStart <= 0:
		coolDownBubbleGum = maxCoolDownBubbleGum
		var bubble_gum = bubble_gum_scene.instantiate()
		bubble_gum.transform.origin = global_position + Vector3(0,verticalOffset,0)
		bubble_gum.direction = pivot.get_global_transform().basis * Vector3(0,0,-1)
		parent.add_child(bubble_gum)
		
func _physics_process(delta: float) -> void:
	
	if chargingBubble != null:
		chargingBubble.transform.origin = global_position + Vector3(0,verticalOffset,0) + verticalOffset*(pivot.get_global_transform().basis * Vector3(0,0,-1)).normalized()
		if scaleBubble < chargedScale:
			scaleBubble += (chargedScale-nonChargedScale)/(chargedElapsed*60.0)
			chargingBubble.get_child(0).scale = Vector3.ONE*scaleBubble
			chargingBubble.get_child(1).scale = Vector3.ONE*scaleBubble
		if (Time.get_ticks_msec()-timeStart)/1000.0 > chargedElapsed:
			var material = chargingBubble.get_child(0).get_surface_override_material(0)
			material.albedo_color = Color(1,1,0)
		
	if coolDownBubble > 0:
		coolDownBubble -= (1.0/60)
	
	if coolDownBubbleGum > 0:
		coolDownBubbleGum -= (1.0/60)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if knockbackSpeed <= 0:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")	
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		material.albedo_color = Color(1,1,1)
	else:
		velocity = knockbackSpeed * knockback.normalized()
		knockbackSpeed -= maxKnockbackSpeed/(60*timeKnockback)
		print(knockbackSpeed)
		print(maxKnockbackSpeed/(60*timeKnockback))

	move_and_slide()

	var camera = get_node("../Camera3D")
	var viewport := get_viewport()
	var mousePos = viewport.get_mouse_position()
	var spaceState = get_world_3d().direct_space_state
	var origin = camera.project_ray_origin(mousePos)
	var end = origin + camera.project_ray_normal(mousePos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = spaceState.intersect_ray(query)
	if result:
		$Pivot.look_at(Vector3(result.position.x, 0, result.position.z))

func damage(position: Vector3):
	if knockbackSpeed <= 0:
		var enemyCoor = transform.origin
		knockback = enemyCoor - position
		knockbackSpeed = maxKnockbackSpeed
		material.albedo_color = Color(1,0,0)
