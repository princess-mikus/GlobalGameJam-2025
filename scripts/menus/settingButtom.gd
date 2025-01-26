extends Button

func _on_button_up() -> void:
	print(get_tree().root)
	get_tree().root.get_node("menu").visible = false
	var settings = preload("res://scenes/menus/settings.tscn").instantiate()
	get_tree().root.add_child(settings);
