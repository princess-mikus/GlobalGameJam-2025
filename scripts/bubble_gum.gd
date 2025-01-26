extends RigidBody3D

const speed = 150

@onready var bubbleGumHitAudio = $"../BubbleGumHit"

var direction = Vector3.ZERO

var enemies = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	linear_velocity = speed  *  delta * direction.normalized()
	
	if get_colliding_bodies().size() > 0:
		var flag = false
		for key in enemies:
			var node = enemies[key]
			if node.name.contains("Enemy"):	
				node.collision(position,"Bubble_Gum")
				flag = true
		if flag:
			bubbleGumHitAudio.play()
			queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	enemies[body.name] = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if enemies.has(body.name):
		enemies.erase(body.name)
