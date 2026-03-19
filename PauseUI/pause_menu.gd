extends CanvasLayer

@export var pause_panel:Panel
@onready var root_path=$"."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func pause():
	get_tree().paused=true
	pause_panel.visible=true

func unpause():
	get_tree().paused=false
	pause_panel.visible=false
	for child in get_children():
		child.queue_free()

func quit():
	for child in get_children():
		child.queue_free()
