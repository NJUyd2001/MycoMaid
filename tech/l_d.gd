extends Node2D

@export var scene_1:Node
@export var scene_2:Node
@export var scene_3:Node
@export var discard_deck:Node
@export var fever_bar:Node
@export var play_threshold_offset:float = 120.0

@export var maxRandomItemNum:int
@export var minRandomItemNum:int
@export var siteItem:Dictionary

var play_threshold_y:float
var fever_max:int = 100
var fever_start:int = 50
var fever_value:int = 50
var fever_gain_per_card:int = 1

func _ready() -> void:
	if scene_3:
		play_threshold_y = scene_3.global_position.y - play_threshold_offset
	fever_value = fever_start
	if fever_bar and fever_bar is ProgressBar:
		fever_bar.max_value = fever_max
		fever_bar.value = fever_value
	draw_cards(5)


func add_new_card(cardName,cardDeck,caller=scene_1)->Node:
	print("开始添加新卡牌："+str(cardName))
	var cardClass=cardCont.conDict[cardName]["base_cardClass"]
	print("添加的卡类型是%s:"%cardClass)
	
	var cardToAdd =preload("res://tech/miniCard.tscn").instantiate()
	
	cardToAdd.initCard(cardName)
	cardToAdd.card_released.connect(_on_card_released)
	
	cardToAdd.global_position=caller.global_position
	cardToAdd.z_index=100
	cardDeck.add_card(cardToAdd)
	
	return cardToAdd


func get_card():
	var num_card=randi()%(maxRandomItemNum-minRandomItemNum+1)+minRandomItemNum
	draw_cards(num_card)

func draw_cards(count:int) -> void:
	var total_weight=get_total_weight(siteItem)
	for i in range(count):
		var random_num=randi()% total_weight
		var cumulative_weight=0
		for c in siteItem.keys():
			cumulative_weight+=siteItem[c]
			if random_num<cumulative_weight:
				add_new_card(c,scene_3,scene_1)
				break

func _on_card_released(card) -> void:
	if is_card_played(card):
		if card.preDeck:
			card.preDeck.remove_card(card)
		if discard_deck:
			discard_deck.add_card(card)
		fever_value = min(fever_value + fever_gain_per_card, fever_max)
		if fever_bar and fever_bar is ProgressBar:
			fever_bar.value = fever_value
		draw_cards(2)

func is_card_played(card) -> bool:
	if play_threshold_y == 0.0 and scene_3:
		play_threshold_y = scene_3.global_position.y - play_threshold_offset
	return card.global_position.y < play_threshold_y
		
		
func get_total_weight(card_dict):
	var total_weight=0
	for weight in card_dict.values():
		total_weight+=weight
	return total_weight
