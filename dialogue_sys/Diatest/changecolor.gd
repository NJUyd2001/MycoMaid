extends Control

@export var seconds:=2.0
@export var cr:String="ColorRect"

@export var DiaPanl:Control

var color_rect:ColorRect
var tt:Tween


func _ready() -> void:
	color_rect=get_node(cr)
	start_cycle()

func start_cycle():
	var colors:Array[Color]=[
		Color.BLACK,
		Color.RED,
		Color.BLUE,
		Color.GREEN,
		Color.YELLOW
	]
	tt=create_tween()
	tt.set_loops()
	
	for i in range(colors.size()):
		var next =(i+1)%colors.size()
		tt.tween_property(
			color_rect,
			"color",
			colors[next],
			seconds/colors.size()
		)




func _on_button_pressed() -> void:
	get_tree().paused=true
	DiaPanl.visible=true
