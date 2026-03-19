extends CardState

var played:bool

func enter()-> void:
	card_ui.color.color=Color.FLORAL_WHITE
	card_ui.state.text="解放解放"
	played=false
	if not card_ui.targets.is_empty():
		played =true
		print("play card for targets (s)",card_ui.targets)
		
func on_input(event: InputEvent)  ->void:
	if played :
		return
	
	transition_requested.emit(self,CardState.State.BASE)	
	
func on_gui_input(event:InputEvent)-> void:
	if event.is_action_pressed("left_mouse"):
		card_ui.pivot_offset=card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self,CardState.State.BASE)
