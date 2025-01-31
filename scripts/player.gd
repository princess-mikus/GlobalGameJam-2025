extends CharacterBody3D

const SPEED = 2.0
const maxCoolDownBubble = 0.25
const maxCoolDownBubbleGum = 1.5
const chargedElapsed = 1
const chargedScale = 0.20
const nonChargedScale = 0.10
const verticalOffset = 0.1
const horizontalOffset = 0.2
const maxKnockbackSpeed = 1
const timeKnockback = 0.1

const damageArea = 5
const gumArea = 3

const explosionKnockBack = 5

@onready var bubbleChargeAudio = $"../BubbleCharge"
var playingBubbleChargeAudio = false
@onready var bubbleGumChargeAudio = $"../BubbleGumCharge"
@onready var hitAudio = $"../Hit"

@onready var shieldBubble = $Shield
@onready var sprite = $Sprite3D
@onready var bubble_scene = preload("res://scenes/bubble.tscn")
@onready var bubble_gum_scene = preload("res://scenes/bubble_gum.tscn")
@onready var mesh = $MeshInstance3D
@onready var parent = $".."
@onready var pivot = $Pivot
@onready var animation = $AnimationPlayer
var scaleOriginal

var coolDownBubble = 0
var coolDownBubbleGum = 0

var timeStart = 0
var chargingBubble = null
var scaleBubble = 0

var knockbackSpeed = 0
var knockback = Vector3.ZERO

var shield = true
var invulnerable = false
var invulnerableTime = 2.05

func _input(event):
	if Input.is_action_just_released("bubble") and coolDownBubble <= 0 and chargingBubble != null:
		playingBubbleChargeAudio = false
		bubbleChargeAudio.stop()
		coolDownBubble = maxCoolDownBubble
		chargingBubble.direction = pivot.get_global_transform().basis * Vector3(0,0,-1)
		chargingBubble.explode = scaleBubble >= chargedScale
		chargingBubble.holded = false
		chargingBubble.get_child(3).play("RESET")
		chargingBubble = null
		timeStart = 0
	elif Input.is_action_pressed("bubble") and coolDownBubble <= 0 and chargingBubble == null:
		timeStart = Time.get_ticks_msec()
		chargingBubble = bubble_scene.instantiate()
		scaleOriginal = chargingBubble.get_child(0).transform.basis.get_scale()
		chargingBubble.transform.origin = global_position + Vector3(0,verticalOffset,0) + horizontalOffset*(pivot.get_global_transform().basis * Vector3(0,0,-1)).normalized()
		chargingBubble.direction = Vector3.ZERO
		scaleBubble = nonChargedScale
		chargingBubble.get_child(0).scale = scaleOriginal*scaleBubble
		chargingBubble.get_child(1).scale = Vector3.ONE*scaleBubble
		chargingBubble.get_child(2).scale = damageArea*Vector3.ONE*scaleBubble
		parent.add_child(chargingBubble)
	elif Input.is_action_just_pressed("bubble_gum") and coolDownBubbleGum <= 0 and timeStart <= 0:
		bubbleGumChargeAudio.play(1.8)
		coolDownBubbleGum = maxCoolDownBubbleGum
		var bubble_gum = bubble_gum_scene.instantiate()
		scaleOriginal = bubble_gum.get_child(0).transform.basis.get_scale()
		bubble_gum.transform.origin = global_position + Vector3(0,verticalOffset,0)
		bubble_gum.direction = pivot.get_global_transform().basis * Vector3(0,0,-1)
		bubble_gum.get_child(0).scale = scaleOriginal*nonChargedScale
		bubble_gum.get_child(1).scale = Vector3.ONE*nonChargedScale
		bubble_gum.get_child(2).scale = gumArea*Vector3.ONE*nonChargedScale
		parent.add_child(bubble_gum)
		
func _physics_process(delta: float) -> void:
	if chargingBubble != null:
		chargingBubble.transform.origin = global_position + Vector3(0,verticalOffset,0) + horizontalOffset*(pivot.get_global_transform().basis * Vector3(0,0,-1)).normalized()
		if scaleBubble < chargedScale:
			scaleBubble += (chargedScale-nonChargedScale)/(chargedElapsed*60.0)
			chargingBubble.get_child(0).scale = scaleOriginal*scaleBubble
		chargingBubble.get_child(1).scale = Vector3.ONE*scaleBubble
		chargingBubble.get_child(2).scale = damageArea*Vector3.ONE*scaleBubble
		if (Time.get_ticks_msec()-timeStart)/1000.0 > chargedElapsed:
			chargingBubble.get_child(3).play("bubbleFlickering")
			
		if (Time.get_ticks_msec()-timeStart)/1000.0 > 0.2 and not playingBubbleChargeAudio:
			playingBubbleChargeAudio = true
			bubbleChargeAudio.play(1.4)
		
	if coolDownBubble > 0:
		coolDownBubble -= (1.0/60)
	
	if coolDownBubbleGum > 0:
		coolDownBubbleGum -= (1.0/60)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if knockbackSpeed <= 0:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")	
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if not invulnerable:
				animation.play("playerRun")
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			if not invulnerable:
				animation.play("playerIdle")
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity = knockbackSpeed * knockback.normalized()
		knockbackSpeed -= maxKnockbackSpeed/(60*timeKnockback)

	move_and_slide()

	var camera = get_node("../Camera3D")
	var viewport := get_viewport()
	var mousePos = viewport.get_mouse_position()
	var spaceState = get_world_3d().direct_space_state
	var origin = camera.project_ray_origin(mousePos)
	var end = origin + camera.project_ray_normal(mousePos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = spaceState.intersect_ray(query)
	if result:
		$Crosshair.global_position = result.position
		$Pivot.look_at(Vector3(result.position.x, 0, result.position.z))
		sprite.flip_h = position.x - result.position.x >= 0

func	 _on_damage(position: Vector3, explosion: bool):
	
	if not invulnerable:
		hitAudio.play()
	# DEJAR
	if knockbackSpeed <= 0:
		var enemyCoor = transform.origin
		knockback = enemyCoor - position
		knockbackSpeed = maxKnockbackSpeed
		if explosion:
			knockbackSpeed = maxKnockbackSpeed*explosionKnockBack
	if shield and not invulnerable:
		shield = false
		shieldBubble.visible = false
		invulnerable = true
		$Invulnerability.start(invulnerableTime)
		animation.play("playerDamage")
		var shieldKnock = bubble_scene.instantiate()
		shieldKnock.get_child(0).visible = false
		shieldKnock.explode = true
		shieldKnock.transform.origin = global_position + Vector3(0,verticalOffset,0)
		scaleOriginal = shieldKnock.get_child(0).transform.basis.get_scale()
		shieldKnock.direction = Vector3.ZERO
		shieldKnock.get_child(0).scale = scaleOriginal*chargedScale
		shieldKnock.get_child(1).scale = Vector3.ONE*chargedScale
		shieldKnock.get_child(2).scale = damageArea*Vector3.ONE*chargedScale
		parent.add_child(shieldKnock)
	elif not invulnerable:
		get_tree().change_scene_to_file("res://scenes/death.tscn")

func _on_invulnerability_timeout() -> void:
	invulnerable = false
