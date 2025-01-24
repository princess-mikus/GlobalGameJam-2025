extends RigidBody3D

var speed = 50
var direction = Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	linear_velocity = speed  *  delta * direction.normalized()
