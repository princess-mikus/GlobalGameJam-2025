extends Node3D

@onready var waveMaker = $waveMaker
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize():
	waveMaker.budget = 5
	waveMaker.roundCount = 1
	player.position = Vector3.ZERO
