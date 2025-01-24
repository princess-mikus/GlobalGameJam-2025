extends CharacterBody3D

const SPEED = 1.0
const JUMP_VELOCITY = 0.0

@onready var parent = $".."

const bubble_scene: PackedScene = preload("res://scenes/bubble.tscn")

func _input(event):
	if Input.is_action_pressed("shoot"):
		var bubble = bubble_scene.instantiate()
		bubble.transform.origin = global_position
		bubble.direction = Vector3(1,0,0)
		parent.add_child(bubble)
		
		
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
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Enemy":
			collision.get_collider().collision(collision.get_position())
