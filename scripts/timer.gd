extends Timer

@onready var enemy = $".."

func _on_timeout() -> void:
	enemy.queue_free()
	get_node("../../waveMaker").enemyDied(enemy)

