extends Panel

@onready var cardDeck:Control =$ColorRect/cardDeck
@onready var cardPoiDeck:HBoxContainer=$ColorRect/ScrollContainer/HBoxContainer

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if cardDeck.get_child_count()!=0:
		var children=cardDeck.get_children()
		sort_node_by_position(children)
		
func sort_node_by_position(children):
	children.sort_custom(sort_by_position)
	for i in range(children.size()):
		if children[i].cardCurrentState:
			children[i].z_index=i
			cardDeck.move_child(children[i],i)
	
func sort_by_position(a,b):
	return a.position.x<b.position.x
	
func add_card(cardToAdd)-> void:
	var  index=cardToAdd.z_index
	var  cardBackground=preload("res://tech/card_background.tscn").instantiate()
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
	
	cardToAdd.preDeck=self
	
	cardToAdd.cardCurrentState=cardToAdd.cardState.following

func remove_card(cardToRemove)-> void:
	if cardToRemove.follow_target:
		if cardToRemove.follow_target.get_parent():
			cardToRemove.follow_target.get_parent().remove_child(cardToRemove.follow_target)
		cardToRemove.follow_target.queue_free()
		cardToRemove.follow_target=null
	if cardToRemove.get_parent():
		cardToRemove.get_parent().remove_child(cardToRemove)
	cardToRemove.preDeck=null
