extends CharacterBody3D

const SPEED = 1.0
const maxCoolDown = 0.25

@onready var bubble_scene = preload("res://scenes/bubble.tscn")
@onready var parent = $".."
@onready var pivot = $Pivot

var coolDown = 0

func _input(event):
	print(coolDown)
	if Input.is_action_pressed("shoot") and coolDown <= 0:
		coolDown = maxCoolDown
		var bubble = bubble_scene.instantiate()
		bubble.transform.origin = global_position + Vector3(0,0.08,0)
		bubble.direction = pivot.get_global_transform().basis * Vector3(0,0,-1)
		parent.add_child(bubble)
		
func _physics_process(delta: float) -> void:
	
	if coolDown > 0:
		coolDown = coolDown-(1.0/60)
	
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

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Enemy":
			collision.get_collider().collision(collision.get_position())

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
