extends Node2D

@export var Library:Node
@export var HandArea:Node

@export var discard_deck:Node
@export var fever_bar:Node
@export var ap_bar:Node
@export var play_threshold_offset:float = 120.0

@export var maxRandomItemNum:int
@export var minRandomItemNum:int



var useSiteItem:Dictionary={
	"1":1,
	"2":1,
	"3":1,
	"4":1,
	"5":1,
	"6":1,
	"7":1,
	"8":1,
	"9":0,
	"10":0,
	"11":0
	}

var siteItem:=useSiteItem

var is_resetting: bool = false

var play_threshold_y:float
var fever_max:int = 100
var fever_min:int = 0
var fever_start:int = 50
var fever_value:int = 50
var fever_gain_per_card:int = 1

@onready var discard_index=$Panel/ColorRect/discard/ColorRect/ScrollContainer

func _ready() -> void:
	if HandArea:
		play_threshold_y = HandArea.global_position.y - play_threshold_offset
	fever_value = fever_start
	if fever_bar and fever_bar is ProgressBar:
		fever_bar.max_value = fever_max
		fever_bar.min_value = fever_min
		fever_bar.value = fever_value
	if ap_bar and ap_bar is ProgressBar:
		ap_bar.value=ap_bar.max_value
	draw_cards(5)


func add_new_card(cardName,cardDeck,caller=Library)->Node:
	print("添加新卡牌："+str(cardName))
	var cardClass=cardCont.conDict[cardName]["base_cardClass"]
	print("添加的卡类型是%s:"%cardClass)
	
	var cardToAdd =preload("res://Card/Scene/singleCard.tscn").instantiate()
	
	cardToAdd.initCard(cardName)
	cardToAdd.card_released.connect(_on_card_released)

	# 新卡从生成区域出现（例如牌堆位置），再由 HandDeck 动画移入手牌区
	if caller:
		cardToAdd.global_position = caller.global_position
	cardToAdd.z_index=100
	cardDeck.add_card(cardToAdd)

	return cardToAdd


#抽牌
func get_card():
	#var num_card=randi()%(maxRandomItemNum-minRandomItemNum+1)+minRandomItemNum
	#draw_cards(num_card)
	draw_cards(1)
func draw_cards(count:int) -> void:
	var total_weight=get_total_weight(useSiteItem)
	# 如果总权重为零，先重置权重再抽牌
	if total_weight == 0:
		_reset_site_items()
		total_weight = get_total_weight(useSiteItem)
		# 如果重置后仍为零，说明没有可用卡牌
		if total_weight == 0:
			return

	for i in range(count):
		var random_num=randi()% total_weight
		var cumulative_weight=0
		for c in useSiteItem.keys():
			cumulative_weight+=useSiteItem[c]
			if random_num<cumulative_weight:
				# 从生成区域发牌到手牌区域
				add_new_card(c, HandArea, Library)
				# 抽牌后减少该卡牌的权重（牌组权重-1，手牌+1，总权重守恒）
				useSiteItem[c] -= 1
				# 重新计算总权重用于下一次抽牌
				total_weight = get_total_weight(useSiteItem)
				break
func play_card(card) -> void:
	var global_pos = card.global_position
	if card.preDeck:
		card.preDeck.remove_card(card)
	if discard_deck:
		discard_deck.add_card(card)
		card.global_position = global_pos



#失去/充能fever
func lose_fever(count:int) ->void:
	var fever_updata = max(fever_bar.value-count, fever_min)
	if fever_bar and fever_bar is ProgressBar:
		fever_bar.value = fever_updata
func charge_fever(count:int) ->void:
	var fever_updata = min(fever_bar.value+count, fever_max)
	if fever_bar and fever_bar is ProgressBar:
		fever_bar.value = fever_updata

#AP消耗
func lose_AP(count:int) ->void:
	ap_bar.value-=count
func reset_AP() ->void:
	ap_bar.value=ap_bar.max_value


func _on_card_released(card) -> void:
	if is_card_played(card):
		var cost=int(card.cardCost)
		var take=int(card.cardTake)
		var fever=int(card.cardCharge)
		card.card_is_played=true
		play_card(card)
		charge_fever(fever)
		draw_cards(take)
		lose_AP(cost)
	else:
		# 未打出：将该牌置于手牌区域最后一张，然后由 RELEASED->BASE 的延迟回弹负责退回动画
		if card.preDeck:
			card.preDeck.move_card_to_end(card)

func is_card_played(card) -> bool:
	if play_threshold_y == 0.0 and HandArea:
		play_threshold_y = HandArea.global_position.y - play_threshold_offset
	return card.global_position.y < play_threshold_y
		
		

func adjust_weight(card,count:int,add:bool=false) ->void:
	var value=0
	if add:
		value+=count
	else :
		value-=count
	useSiteItem[String(card.cardNum)]+=value

func get_total_weight(card_dict):
	var total_weight=0
	for weight in card_dict.values():
		total_weight+=weight
	return total_weight

func reset_discard()-> void:
	if discard_deck:
		var card_deck = discard_deck.get_node("ColorRect/cardDeck")
		for child in card_deck.get_children().duplicate():
			if child is singleCard:
				child.queue_free()

func reset_deck() -> void:
	# 防止重复触发
	if is_resetting:
		return
	if not Library:
		return

	# 获取弃牌区的所有卡牌
	var cards_to_move: Array[singleCard] = []
	if discard_deck:
		var card_deck = discard_deck.get_node("ColorRect/cardDeck")
		for child in card_deck.get_children():
			if child is singleCard:
				cards_to_move.append(child)

	if cards_to_move.is_empty():
		# 没有卡牌需要移动，直接重置牌库
		_reset_site_items()
		return

	# 设置标志，防止动画被打断
	is_resetting = true

	# 禁用卡牌交互，防止动画过程中被拖动
	for card in cards_to_move:
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 目标位置：抽牌区 deck 的中心
	var target_pos = Library.global_position

	# 创建动画：所有卡牌叠在一起移动到 deck
	var tween = create_tween()
	var anim_duration = 0.5
	var stagger_delay = 0.05  # 每张卡牌之间的延迟

	for i in range(cards_to_move.size()):
		var card = cards_to_move[i]
		# 叠放效果：稍微错开一点位置，形成堆叠感
		var stack_offset = Vector2(i * 2, i * 2)  # 每张牌稍微偏移一点
		var final_pos = target_pos + stack_offset

		# 添加到 tween，使用延迟启动
		tween.parallel().tween_property(card, "global_position", final_pos, anim_duration)\
			.set_delay(i * stagger_delay)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN_OUT)

		# 动画完成后正确清理卡牌和背景
		var card_ref = card  # 捕获引用
		tween.parallel().tween_callback(func():
			# 检查卡牌是否仍然有效（可能已被之前的回调删除）
			if not is_instance_valid(card_ref):
				return
			# 先从父节点移除并删除背景，保证ScrollContainer大小正确
			if card_ref.follow_target and is_instance_valid(card_ref.follow_target):
				var bg = card_ref.follow_target
				if bg.get_parent():
					bg.get_parent().remove_child(bg)
				bg.queue_free()
				card_ref.follow_target = null
			# 直接删除卡牌（不移除父节点，避免位置跳动产生虚影）
			card_ref.queue_free()
		).set_delay(i * stagger_delay + anim_duration)

	# 动画全部完成后重置牌库并清除标志
	tween.chain().tween_callback(func():
		_reset_site_items()
		is_resetting = false
	)
	

func _reset_site_items() -> void:
	# 直接恢复权重到初始值
	useSiteItem = siteItem.duplicate()

func _on_button_2_pressed() -> void:
	reset_deck()
func _on_button_3_pressed() -> void:
	reset_AP()
