extends Node2D

@onready var coliseum = $"..".get_node("Coliseum")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_again_button() -> void:
	#print_tree()
	coliseum.initialize()
	coliseum.visible = true
	print(get_tree().paused)
	get_tree().paused = false
	print("CHAU")
	visible = false
	queue_free()

func _on_menu_button() -> void:
	print("Menu")
