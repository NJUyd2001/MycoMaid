extends CardState

func enter()-> void:
	card_ui.color.color=Color.YELLOW
	card_ui.state.text="被摁了"
	card_ui.area_2d.monitoring=true
	
func on_input(event: InputEvent)  ->void:
	if event is InputEventMouseMotion:
		transition_requested.emit(self,CardState.State.DRAGGING)
