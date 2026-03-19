extends Control


var paused=preload("res://PauseUI/Scene/PauseUI.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _open_scene(scene):
	var OpenScene=scene.instantiate()
	get_tree().root.add_child(OpenScene)

func _on_pause_button_pressed() -> void:
	print("展开暂停UI")
	_open_scene(paused)
	
