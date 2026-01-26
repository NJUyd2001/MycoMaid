extends CanvasLayer

@export var pause_panel:Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_panel.visible=false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pause():
	get_tree().paused=true
	pause_panel.visible=true

func unpause():
	get_tree().paused=false
	pause_panel.visible=false

func quit():
	get_tree().quit()
