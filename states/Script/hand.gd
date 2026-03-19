extends HBoxContainer
class_name Hand

func _ready() -> void:
	for child in get_children():
		var card_ui:=child as CardUI
		card_ui.reparent_requested.connect(_on_card_ui_reparent_requuested)
		
func _on_card_ui_reparent_requuested(child:CardUI) ->void:
	child.reparent(self)
