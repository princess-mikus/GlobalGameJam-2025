extends RigidBody3D

const speed = 50

var direction = Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	linear_velocity = speed  *  delta * direction.normalized()
	
	for node in get_colliding_bodies():
		if node.name.contains("Enemy"):	
			node.collision(position,"Bubble")
			queue_free()
