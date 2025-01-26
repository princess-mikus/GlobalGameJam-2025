extends Button

func _on_button_up() -> void:
	get_node("../../../menu").visible = true
	get_node("../..").queue_free()
