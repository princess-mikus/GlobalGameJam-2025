extends HSlider

var bus_name = "Master"

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	# If you're using Godot 3, replace db_to_linear() with `db2linear()
	value = AudioServer.get_bus_volume_db(bus_index)

func _on_value_changed(value: float) -> void:
	# If you're using Godot 3, replace linear_to_db() with linear2db()
	if value == -20:
		AudioServer.set_bus_volume_db(bus_index, -80)
	else:
		AudioServer.set_bus_volume_db(bus_index, value)
	
