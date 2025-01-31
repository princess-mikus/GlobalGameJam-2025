extends Area3D

const timeDeath = 1

@onready var deathAudio = $"../EnemyDeath"
@onready var timer = $Timer

func _on_body_exited(body: Node3D) -> void:
	if body.name.contains("Enemy"):
		body.dead = true
		body.timer.start(1)
		print(body.name)
		if not body.name.contains("Bomb_Enemy"):
			deathAudio.play(1.5)
	elif body.name.contains("Player"):
		timer.start(timeDeath)


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/death.tscn")
