extends Node2D

@export var scene_1:Node
@export var scene_2:Node
@export var scene_3:Node

@export var maxRandomItemNum:int
@export var minRandomItemNum:int
@export var siteItem:Dictionary


func add_new_card(cardName,cardDeck,caller=scene_1)->Node:
	print("开始添加新卡牌："+str(cardName))
	var cardClass=cardCont.conDict[cardName]["base_cardClass"]
	print("添加的卡类型是%s:"%cardClass)
	
	var cardToAdd =preload("res://tech/miniCard.tscn").instantiate() as miniCard
	
	cardToAdd.initCard(cardName)
	
	cardToAdd.global_position=caller.global_position
	cardToAdd.z_index=100
	cardDeck.add_card(cardToAdd)
	
	return cardToAdd


func get_card():
	var num_card=randi()%(maxRandomItemNum-minRandomItemNum+1)+minRandomItemNum
	var total_weight=get_total_weight(siteItem)
	var select_cards=[]
	
	for i in range(num_card):
		var random_num=randi()% total_weight
		var cumulative_weight=0
		for c in siteItem.keys():
			cumulative_weight+=siteItem[c]
			if random_num<cumulative_weight:
				select_cards.append(c)
				break
				
	for c in select_cards:
		await get_tree().create_timer(0.1).timeout
		add_new_card(c,scene_3,scene_1)
		
		
func get_total_weight(card_dict):
	var total_weight=0
	for weight in card_dict.values():
		total_weight+=weight
	return total_weight
