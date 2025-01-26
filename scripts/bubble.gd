extends RigidBody3D

const speed = 150
const verticalOffset = 0.16

@onready var bubble_explosion = preload("res://scenes/bubble_explotion.tscn")
@onready var parent = $".."

var direction = Vector3.ZERO
var explode = false

var enemies = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	linear_velocity = speed  *  delta * direction.normalized()
	
	if not explode:
		for node in get_colliding_bodies():
			if node.name.contains("Enemy"):
				node.collision(position,"Bubble")
				queue_free()
	else:
		explosion()
					
func explosion():
	if get_colliding_bodies().size() > 0:
			var flag = false
			for key in enemies:
				var node = enemies[key]
				if node.name.contains("Enemy"):	
					node.collision(position,"Bubble")
					flag = true
			if flag:
				var explosion = bubble_explosion.instantiate()
				explosion.transform.origin = position + Vector3(0,verticalOffset,0)
				explosion.get_child(0).play("Explode")
				parent.add_child(explosion)
				queue_free()
					
func _on_area_3d_body_entered(body: Node3D) -> void:
	enemies[body.name] = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if enemies.has(body.name):
		enemies.erase(body.name)
