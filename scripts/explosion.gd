extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#scale = Vector3(1, 1, 1)
	body_entered.connect(_on_body_in_area)
	print("I'm exploding!")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_duration_timeout() -> void:
	queue_free()

func _on_body_in_area(body):
	if body.name == "Player":
		body._on_damage()
