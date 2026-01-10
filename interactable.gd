class_name Interactable
extends Area2D


signal interacted

@onready var col:ColorRect=$CollisionShape2D/ColorRect

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(2, true)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func interact() -> void:
	print("[Interact] %s" % name)
	interacted.emit()


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.has_method("register_interactable"):
		body.register_interactable(self)

func _on_body_exited(body: CharacterBody2D) -> void:
	if body.has_method("unregister_interactable"):
		body.unregister_interactable(self)

func _control_quit() ->void:
	if Input.is_action_just_pressed("quit"):
		quit()

func quit() ->void:
	get_tree().change_scene_to_file("res://pages/game.tscn")
