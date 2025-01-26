extends Node

func _ready():
	startAudio.volume_db = -80
	loop.volume_db = -80
	loop.play()
	randomize()
	roundStart()

@onready var enemy_scene1 = preload("res://scenes/enemy.tscn")
@onready var enemy_scene2 = preload("res://scenes/bomb_enemy.tscn")
@onready var enemy_scene3 = preload("res://scenes/slime_enemy.tscn")

@onready var parent = $".."
@onready var player = $"../Player"
@onready var label = $"../Camera3D/RichTextLabel"
@onready var startAudio = $start
@onready var loop = $loop
@onready var endAudio = $end
@onready var timer = $Timer
@onready var tween_out = get_tree().create_tween()

var butget = 1
var enemysLeft
var queue = Array()
var count = 0
var roundCount = 0;

const verticalOffset = 0.12
const maxCoolDown = 3.0
const groundRadious = 0.7
const spawnRadio = 1.5
const spawnLimitation = 0.3
const normalCost = 1
const explosiveCost = 2
const slimeSCost = 3
const transition_duration = 4.00

var coolDown = maxCoolDown
var roundStarted = false

func slimeDivided():
	enemysLeft += 2

func enemyDied(enemy: Node3D) -> void:
	enemysLeft -= 1
	print(enemysLeft)

func _on_timer_timeout() -> void:
	label.text = "";
	make_queue()

func roundStart():
	var tween = create_tween()
	if roundCount % 10 == 0:
		startAudio.play()
		#tween.parallel().tween_property(startAudio, "volumen_db", -80, 1)
		#tween.parallel().tween_property(loop, "volumen_db", 0, 1)
		label.text = "[color=red][font_size=100][center][font=res://resources/font3.otf] Wave " + str(roundCount)
	else:
		label.text = "[font_size=100][center][font=res://resources/font3.otf] Wave " + str(roundCount)
		#tween.tween_property(loop, "volumen_db", 0, 1)
	
	timer.start(4)

func roundEnd():
	endAudio.play()
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
		coolDown -= (1.0/60)
	if coolDown <= 0:
		coolDown = maxCoolDown
		spawn()
	if enemysLeft == 0 and roundStarted == false:
		roundStarted = true
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
	butget = floorf(butget * 1.2)
	enemysLeft = queue.size();
	roundStarted = false
