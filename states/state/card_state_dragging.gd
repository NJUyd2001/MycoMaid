extends CardState

const Drag_MONIMUN_THESHOLD:=0.10

var minimum_drag_time_elapesed:=false

func enter()-> void:
	var ui_layer :=get_tree().get_first_node_in_group("ui_layer")
	if ui_layer:
		card_ui.reparent(ui_layer)
	card_ui.color.color=Color.DARK_GOLDENROD
	card_ui.state.text="拉扯咯~"
	minimum_drag_time_elapesed=false
	var thresholdd_timer :=get_tree().create_timer(Drag_MONIMUN_THESHOLD,false)
	thresholdd_timer.timeout.connect(func():minimum_drag_time_elapesed=true)
	
func on_input(event: InputEvent)  ->void:
	var mouse_motion:=event is InputEventMouseMotion
	var cancel = event.is_action_pressed("right_mouse")
	var confirm = event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")
	if mouse_motion:
		card_ui.global_position=card_ui.get_global_mouse_position() -card_ui.pivot_offset
		
	if cancel:
		transition_requested.emit(self,CardState.State.BASE)
	elif  confirm:
		get_viewport().set_input_as_handled()
		transition_requested.emit(self,CardState.State.RELEASED)
