extends CharacterBody3D

const SPEED = 1.0
const BULLET_SPEED = 5.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

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
	#$Crosshair.global_position = get_node("../Ground").to_local(camera.project_position(mousePos, 1))
	$Crosshair.global_position = camera.project_position(mousePos, mousePos.y / 1000)
	var newVector = Vector3($Crosshair.global_position.x, 0, $Crosshair.global_position.z)
	$Pivot.look_at(newVector)
	print(newVector)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var camera = get_node("../Camera3D")
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000
		$Pivot.look_at(Vector3(to.x - from.x, 0, to.z - from.x))
