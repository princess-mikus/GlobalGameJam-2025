extends CheckBox

func _on_button_up() -> void:
	if DisplayServer.window_get_mode():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
