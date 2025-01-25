extends Node

func _ready():
	make_queue()
	randomize()

@onready var enemy_scene1 = preload("res://scenes/enemy.tscn")
@onready var enemy_scene2 = preload("res://scenes/enemy.tscn")
@onready var enemy_scene3 = preload("res://scenes/enemy.tscn")

@onready var parent = $".."
@onready var player = $"../Player"

var butget = 5
const maxCoolDown = 3.0
var coolDown = 0
var queue = Array()

const groundRadious = 0.7
const spawnRadious = 0.2
const normalCost = 1
const explosiveCost = 2
const slimeSCost = 3


func spawn():
	if (queue.is_empty()):
		return;
	var choice = [enemy_scene1, enemy_scene2, enemy_scene3]
	var rand_x = randf_range(-0.6, 0.6)
	var rand_y = randf_range(-0.6, 0.6)
	if ((absf(rand_x) - absf(player.position.x) > spawnRadious)
	&& (absf(rand_y) - absf(player.position.y) > spawnRadious)):
		var enemy = choice[queue[0] - 1].instantiate()
		print(queue[0])
		queue.remove_at(0)
		enemy.transform.origin = Vector3(rand_x,rand_y,player.position.z)
		parent.add_child(enemy)
	else:
		spawn()

func _physics_process(delta: float) -> void:
	
	if coolDown > 0:
		coolDown = coolDown-(1.0/60)
	if coolDown <= 0:
		coolDown = maxCoolDown
		spawn()

func make_queue():
	queue.clear()
	var last = normalCost
	var localButget = butget
	while localButget > 0:
		var next = randi() % 3 + 1
		if (!(last == explosiveCost && next == explosiveCost)
		&& !(last == slimeSCost && next == slimeSCost)
		&& (next <= localButget)):
			queue.append(next)
			last = next
			localButget -= next
	print(queue)
	butget = floor(butget * 1.2)
