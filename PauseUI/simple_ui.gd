extends "res://PauseUI/pause_button.gd"

var setting=preload("res://Menu/Scene/settings_menu.tscn")


func _on_setting_button_pressed() -> void:
	print("展开暂停UI")
	_open_scene(setting)
		
