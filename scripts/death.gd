extends Node2D

@onready var coliseum = $"..".get_node("Coliseum")

func _on_play_again_button() -> void:
	#print_tree()
	coliseum.initialize()
	coliseum.visible = true
	print(get_tree().paused)
	get_tree().paused = false
	print("CHAU")
	visible = false
	queue_free()

func _on_menu_button() -> void:
	print("Menu")
