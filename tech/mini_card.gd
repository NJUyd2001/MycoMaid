extends Control

class_name miniCard

signal card_released(card: miniCard)

var velocity=Vector2.ZERO
var damping=0.35
var stiffness=500

var preDeck

@export var conDic:Dictionary
@export var cardName:String
@export var cardClass:String
@export var cardNum:String

var pickButton:Node

enum cardState{following,dragging}

@export var cardCurrentState = cardState.following
@export var follow_target:Node

func _ready() -> void:
	pickButton = $Button
	if pickButton:
		if not pickButton.button_down.is_connected(_on_button_button_down):
			pickButton.button_down.connect(_on_button_button_down)
		if not pickButton.button_up.is_connected(_on_button_button_up):
			pickButton.button_up.connect(_on_button_button_up)

func _process(delta: float) -> void:
	match cardCurrentState:
		cardState.dragging:
			var target_position = get_global_mouse_position()-size/2
			global_position=global_position.lerp(target_position,0.4)
		cardState.following:
			if follow_target!=null:
				var target_position=follow_target.global_position
				var displacement= target_position -global_position
				var force =displacement * stiffness
				velocity+=force*delta
				velocity*=(1.0 - damping)
				global_position+= velocity*delta

func _on_button_button_down() -> void:
	cardCurrentState=cardState.dragging


func _on_button_button_up() -> void:
	var was_dragging = cardCurrentState == cardState.dragging
	cardCurrentState=cardState.following
	if was_dragging:
		card_released.emit(self)


func initCard(Nm) -> void:
	conDic=cardCont.conDict[Nm]
	cardName=conDic["base_cardName"]
	cardClass=conDic["base_cardClass"]
	cardNum=conDic["index"]
	cardCurrentState=cardState.following
	
	drawCard()
	
	
func drawCard():
	var imgPath="res://asset/icon.svg"
	$Panel/ColorRect/pic.texture=load(imgPath)
	$Panel/ColorRect/name.text=conDic["base_display"]
