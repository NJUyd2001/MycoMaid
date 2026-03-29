extends Node
class_name CardStateMachines

@export var initial_state:CardState

var current_state:CardState
var states:={}

func init(card:singleCard)->void:
	states.clear()
	for child in get_children():
		if child is CardState:
			states[child.state] = child
			child.transition_requested.connect(_on_transition_requested)
			child.card_ui = card

	if initial_state and initial_state.state in states:
		current_state = states[initial_state.state]
		current_state.enter()
	else:
		printerr("Invalid initial state configured: ", initial_state)



func on_input(event:InputEvent)->void:
	if current_state:
		current_state.on_input(event)

func on_gui_input(event:InputEvent)->void:
	if current_state:
		current_state.on_gui_input(event)

func on_mouse_entered()->void:
	if current_state:
		current_state.on_mouse_entered()

func on_mouse_exited()-> void:
	if current_state:
		current_state.on_mouse_exited()
		
func _on_transition_requested(from:CardState,to:CardState.State)->void:
	if from!=current_state:
		return
	var new_state:CardState = states.get(to, null)
	if not new_state:
		return
	# 避免同一状态之间无限自切换导致递归
	if new_state == current_state:
		return
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state
