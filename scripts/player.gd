extends CharacterBody3D

const SPEED = 1.0
const BULLET_SPEED = 5.0

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

@onready var bullet = preload("res://scenes/bullet.tscn")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

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

func _input(event):
	pass
