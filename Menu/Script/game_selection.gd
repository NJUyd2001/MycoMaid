extends Control

@onready var continuegame = $ContinueGame
@onready var newgame = $NewGame
@onready var backButton = $BackButton
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	if continuegame:
		continuegame.pressed.connect(_on_continue_game)
	if newgame:
		newgame.pressed.connect(_on_new_game)
	if backButton:
		backButton.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	SceneTransition.change_scene("res://Menu/Scene/main_menu.tscn")

func _on_continue_game() -> void:
	SceneTransition.change_scene("res://Card/Scene/mainDeck.tscn")

func _on_new_game() -> void:
	SceneTransition.change_scene("res://map/node_2d.tscn")
