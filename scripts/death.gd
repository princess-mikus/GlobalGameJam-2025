extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_again_button() -> void:
	print("Nyarking?")
	get_tree().change_scene_to_file("res://scenes/coliseum.tscn")

func _on_menu_button() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/mainMenu.tscn")
