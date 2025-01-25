extends Node

func _ready():
	randomize()
	roundStart()

@onready var enemy_scene1 = preload("res://scenes/enemy.tscn")
@onready var enemy_scene2 = preload("res://scenes/bomb_enemy.tscn")
@onready var enemy_scene3 = preload("res://scenes/slime_enemy.tscn")

@onready var parent = $".."
@onready var player = $"../Player"

var butget = 5
var enemysLeft
var queue = Array()
var count = 0
var roundCount = 1;

const verticalOffset = 0.12
const maxCoolDown = 3.0
const groundRadious = 0.7
const spawnRadio = 1.5
const spawnLimitation = 0.3
const normalCost = 1
const explosiveCost = 2
const slimeSCost = 3

var coolDown = maxCoolDown

func slimeDivided():
	enemysLeft += 2

func enemyDied(enemy: Node3D) -> void:
	enemysLeft -= 1
	print(enemysLeft)

func roundStart():
	var label = $"../Camera3D/RichTextLabel"
	label.text = "[font_size=100][center][font=res://resources/font2.ttf] Wave " + str(roundCount)
	print(label.text)
	make_queue()

func roundEnd():
	roundCount += 1
	roundStart()

func spawn():
	if (queue.is_empty()):
		return;
	var choice = [enemy_scene1, enemy_scene2, enemy_scene3]
	var choice_name = ["Enemy","Bomb_Enemy", "Slime_Enemy"]
	var rand = Vector3(randf_range(-spawnRadio, spawnRadio),player.position.y,randf_range(-spawnRadio, spawnRadio))
	while ((rand-player.position).length() < spawnLimitation):
		rand = Vector3(randf_range(-spawnRadio, spawnRadio),player.position.y,randf_range(-spawnRadio, spawnRadio))
	print(queue, choice)

	var enemy = choice[queue[0] - 1].instantiate()
	enemy.name = choice_name[queue[0] - 1] + str(count)
	queue.remove_at(0)
	enemy.transform.origin = Vector3(rand.x,rand.y + verticalOffset,rand.z)
	print(count)
	count += 1
	parent.add_child(enemy)

func _physics_process(delta: float) -> void:
	if coolDown > 0:
		coolDown = coolDown-(1.0/60)
	if coolDown <= 0:
		coolDown = maxCoolDown
		spawn()
	if enemysLeft == 0:
		roundEnd()
	

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
	enemysLeft = queue.size();
