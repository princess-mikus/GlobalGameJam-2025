extends Button

func _on_button_up() -> void:
	emit_signal("updatePreviousScene")
	get_tree().change_scene_to_file("res://scenes/menus/settings.tscn");
