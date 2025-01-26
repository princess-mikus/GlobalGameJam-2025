extends Area3D

const maxSize = 1
const explosionTime = 0.1

@onready var sprite = $Sprite3D
@onready var originalScale = sprite.transform.basis.get_scale()

var size = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#scale = Vector3(1, 1, 1)
	sprite.scale = Vector3(0,0,0)
	body_entered.connect(_on_body_in_area)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if size < maxSize:
		sprite.scale = size*originalScale
		size += 1/(explosionTime*60.0)

func _on_duration_timeout() -> void:
	queue_free()

func _on_body_in_area(body):
	print(body)
	if body.name == "Player":
		body._on_damage(position,true)
	elif body.name.contains("Enemy"):
		body.collision(position, name)
