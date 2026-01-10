extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/game.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/设置.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()# Replace with function body.

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("start"):
		get_tree().change_scene_to_file("res://pages/game.tscn")
