extends HSlider

func _ready():
	set_value_no_signal(GlobalWorldEnvironment.environment.adjustment_brightness)

func _on_value_changed(value: float) -> void:
	GlobalWorldEnvironment.environment.adjustment_brightness = value;
