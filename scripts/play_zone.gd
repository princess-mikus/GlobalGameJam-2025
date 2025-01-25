extends Area3D


func _on_body_exited(body: Node3D) -> void:
	if body.name.contains("Enemy"):
		body.dead = true
		body.timer.start(3)
