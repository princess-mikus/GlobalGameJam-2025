extends Area3D

const timeDeath = 1

@onready var timer = $Timer

func _on_body_exited(body: Node3D) -> void:
	if body.name.contains("Enemy"):
		body.dead = true
		body.timer.start(1)
	elif body.name.contains("Player"):
		timer.start(timeDeath)


func _on_timer_timeout() -> void:
	var	deathScreen = preload("res://scenes/death.tscn").instantiate()
	$"..".get_tree().root.add_child(deathScreen)
	$"..".get_tree().paused = true
