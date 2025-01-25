extends Node

func pause():
	if get_tree().paused == false:
		get_tree().paused = true;
	else:
		get_tree().paused = false;
