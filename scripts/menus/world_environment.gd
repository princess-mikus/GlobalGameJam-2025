extends WorldEnvironment

var previousScene;

signal updatePreviousScene;

func set_previousScene(scene):
	previousScene = scene;

func get_previousScene():
	return(previousScene);

func _on_update_previous_scene() -> void:
	print("jajajaj");
