extends CardState

func enter()-> void:
	if not card_ui.is_node_ready():
		await card_ui.ready
	# 若拖拽时被 reparent 到 ui_layer，这里在回到 BASE 时把卡牌放回所属牌堆容器
	if "preDeck" in card_ui and card_ui.preDeck and ("cardDeck" in card_ui.preDeck):
		var target_deck = card_ui.preDeck.cardDeck
		if target_deck and is_instance_valid(target_deck) and card_ui.get_parent() != target_deck:
			var gp := card_ui.global_position
			if card_ui.get_parent():
				card_ui.get_parent().remove_child(card_ui)
			target_deck.add_child(card_ui)
			card_ui.global_position = gp
		# 确保卡牌在手牌中的顺序正确，重置 follow_target
		if "move_card_to_end" in card_ui.preDeck:
			card_ui.preDeck.move_card_to_end(card_ui)

	# 重置 z_index，让 HandDeck 能正确管理排序
	card_ui.z_index = 0

	# 回到静止状态时吸附回手牌槽位（若有）
	if "move_to_rest" in card_ui:
		card_ui.move_to_rest()
	elif "snap_to_rest" in card_ui:
		card_ui.snap_to_rest()
	card_ui.reparent_requested.emit(card_ui)
	card_ui.color.color=Color.WEB_GREEN
	card_ui.state.text="没变化"
	card_ui.pivot_offset=Vector2.ZERO
	
func on_gui_input(event:InputEvent)-> void:
	if event.is_action_pressed("left_mouse"):
		card_ui.pivot_offset=card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self,CardState.State.CLICKED)
