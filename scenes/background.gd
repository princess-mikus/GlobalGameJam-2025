extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at($"../Camera3D".position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
