extends Control

@onready var btn_start = $VBoxContainer/TicketGroup
@onready var btn_load = $VBoxContainer/TicketGroup2
@onready var btn_option = $VBoxContainer/TicketGroup3
@onready var btn_quit = $VBoxContainer/TicketGroup4

func _ready():

	btn_start.ticket_opened.connect(_on_start_game)
	btn_load.ticket_opened.connect(_on_load_game)
	btn_option.ticket_opened.connect(_on_options)
	btn_quit.ticket_opened.connect(_on_quit_game)

func _on_start_game():
	print("逻辑：进入游戏场景...")
	# 在这里切换场景，例如：
	# get_tree().change_scene_to_file("res://Game.tscn")

func _on_load_game():
	print("逻辑：打开存档界面...")

func _on_options():
	print("逻辑：打开设置界面...")

func _on_quit_game():
	print("逻辑：退出游戏...")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
