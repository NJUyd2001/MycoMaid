extends Panel

@onready var cardDeck:Control =$ColorRect/cardDeck
@onready var cardPoiDeck:HBoxContainer=$ColorRect/ScrollContainer/HBoxContainer

@export var uniform_spacing: bool = true
@export var clamp_x_within_panel: bool = false
@export var clamp_padding_x: float = 2.0
@export var x_jitter_few_cards: int = 4
@export var x_jitter_many_cards: int = 10
@export var x_jitter_amount_few: float = 18.0
@export var x_jitter_amount_many: float = 8.0

@export var deal_to_hand_duration: float = 0.35

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if cardDeck.get_child_count()!=0:
		var children=cardDeck.get_children()
		_ensure_order_and_layout(children)
		
func _ensure_order_and_layout(children: Array) -> void:
	# 以节点顺序为准，避免操作后顺序被 position 排序打乱
	for i in range(children.size()):
		var card = children[i]
		# 拖拽/非静止状态不要被这里重置 z_index，否则会和“拖拽置顶”抢
		if "z_index" in card and "get_current_state" in card:
			var st = card.get_current_state()
			if st == null or (("state" in st) and st.state == CardState.State.BASE):
				card.z_index = i
	_apply_dynamic_jitter_and_snap(children)

func move_card_to_end(card) -> void:
	# 将卡牌与其槽位背景一起移动到最后，保证顺序稳定
	if not card:
		return
	if card.get_parent() == cardDeck:
		cardDeck.move_child(card, -1)
	if "follow_target" in card and card.follow_target and is_instance_valid(card.follow_target):
		if card.follow_target.get_parent() == cardPoiDeck:
			cardPoiDeck.move_child(card.follow_target, -1)
	# 立刻刷新一次布局/间距
	var children := cardDeck.get_children()
	_ensure_order_and_layout(children)

func _get_dynamic_jitter_amount(count: int) -> float:
	if uniform_spacing:
		return 0.0
	# 牌少偏差大，牌多偏差小；在 [few, many] 之间线性插值
	if count <= x_jitter_few_cards:
		return x_jitter_amount_few
	if count >= x_jitter_many_cards:
		return x_jitter_amount_many
	var t := float(count - x_jitter_few_cards) / float(max(1, x_jitter_many_cards - x_jitter_few_cards))
	return lerp(x_jitter_amount_few, x_jitter_amount_many, t)

func _apply_dynamic_jitter_and_snap(children: Array) -> void:
	var amount := _get_dynamic_jitter_amount(children.size())
	var panel_rect := get_global_rect()
	for card in children:
		if not ("set_rest_jitter_amount" in card):
			continue
		card.set_rest_jitter_amount(amount)
		# 弃牌区等需要叠放时，限制 X 偏差不要让卡片超出 panel 范围
		if clamp_x_within_panel and ("follow_target" in card) and card.follow_target and is_instance_valid(card.follow_target):
			if ("rest_x_offset" in card) and ("size" in card):
				var left: float = float(panel_rect.position.x) + float(clamp_padding_x)
				var right: float = float(panel_rect.position.x) + float(panel_rect.size.x) - float(card.size.x) - float(clamp_padding_x)
				var desired_x: float = float(card.follow_target.global_position.x) + float(card.rest_x_offset)
				var clamped_x: float = clamp(desired_x, left, right)
				card.rest_x_offset = clamped_x - card.follow_target.global_position.x
		# 只在静止状态吸附，避免和拖拽抢位置
		if "get_current_state" in card and (("move_to_rest" in card) or ("snap_to_rest" in card)):
			var st = card.get_current_state()
			if st == null or (("state" in st) and st.state == CardState.State.BASE):
				if "move_to_rest" in card:
					# 不在每帧反复重建 tween（move_to_rest 内部已做去抖）
					card.move_to_rest()
				else:
					card.snap_to_rest()
	
func sort_by_position(a,b):
	# 排序规则：从左到右、自下而上
	# Godot 2D 坐标系里 Y 越大越“靠下”，因此先按 Y 降序（下→上），再按 X 升序（左→右）
	if is_equal_approx(a.position.y, b.position.y):
		return a.position.x < b.position.x
	return a.position.y > b.position.y
	
func add_card(cardToAdd)-> void:
	var  index=cardToAdd.z_index
	var  cardBackground=preload("res://Card/Scene/card_background.tscn").instantiate()
	cardPoiDeck.add_child(cardBackground)
	
	if index<=cardPoiDeck.get_child_count():
		cardPoiDeck.move_child(cardBackground,index)
	else:
		cardPoiDeck.move_child(cardBackground,-1)
	var global_poi =cardToAdd.global_position
	
	if cardToAdd.get_parent():
		cardToAdd.get_parent().remove_child(cardToAdd)
	cardDeck.add_child(cardToAdd)
	cardToAdd.global_position=global_poi
	
	cardToAdd.follow_target=cardBackground
	# 为每张卡分配一个稳定的偏差方向（-1..1），幅度由牌数量动态决定
	if "rest_x_offset_norm" in cardToAdd:
		var stable_seed := float(cardToAdd.get_instance_id() % 9973)
		cardToAdd.rest_x_offset_norm = (fposmod(stable_seed * 0.61803398875, 1.0) * 2.0 - 1.0)
		if "set_rest_jitter_amount" in cardToAdd:
			cardToAdd.set_rest_jitter_amount(_get_dynamic_jitter_amount(cardDeck.get_child_count()))
		if "move_to_rest" in cardToAdd:
			cardToAdd.move_to_rest(deal_to_hand_duration)
		elif "snap_to_rest" in cardToAdd:
			cardToAdd.snap_to_rest()
	
	cardToAdd.preDeck = self
		
func remove_card(cardToRemove)-> void:
	if cardToRemove.follow_target:
		if cardToRemove.follow_target.get_parent():
			cardToRemove.follow_target.get_parent().remove_child(cardToRemove.follow_target)
		cardToRemove.follow_target.queue_free()
		cardToRemove.follow_target=null
	if cardToRemove.get_parent():
		cardToRemove.get_parent().remove_child(cardToRemove)
	cardToRemove.preDeck=null
