extends Control

class_name singleCard

@warning_ignore("unused_signal")
signal reparent_requested(which_card_ui:CardUI)
signal card_released(card:singleCard)


@onready var color: ColorRect =$Panel/color
@onready var state: Label=$Panel/color/state
@onready var area_2d: Area2D = $DropPointDetector

@onready var card_state_machine: CardStateMachines =$CardStateMachines as CardStateMachines
@onready var dragging=$CardStateMachines/CardStateDragging

@onready var targets:Array[Node] =[]

var preDeck

@export var conDic:Dictionary
@export var cardName:String
@export var cardClass:String
@export var cardNum:String
@export var cardCost:String
@export var cardTake:String
@export var cardCharge:String
@export var card_is_played:bool
var pickButton:Node


@export var follow_target:Node

# 静止时相对 follow_target 的 X 轴偏差（由 HandDeck 分配）
var rest_x_offset: float = 0.0
# 稳定的归一化偏差（-1..1），用于动态幅度缩放
var rest_x_offset_norm: float = 0.0

@export var move_to_rest_duration: float = 0.28

var _move_tween: Tween
var _move_target: Vector2 = Vector2.ZERO

func get_rest_global_position() -> Vector2:
	if follow_target and is_instance_valid(follow_target):
		return follow_target.global_position + Vector2(rest_x_offset, 0.0)
	return global_position

func snap_to_rest() -> void:
	global_position = get_rest_global_position()

func set_rest_jitter_amount(amount: float) -> void:
	rest_x_offset = rest_x_offset_norm * amount

func move_to_rest(duration: float = -1.0) -> void:
	var d := duration
	if d < 0.0:
		d = move_to_rest_duration
	var target := get_rest_global_position()
	# 若目标没变且 tween 还在跑，就别反复 kill/create，避免拖拽时卡顿
	if _move_tween and is_instance_valid(_move_tween) and _move_target.is_equal_approx(target):
		return
	_move_target = target
	if _move_tween and is_instance_valid(_move_tween):
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.set_trans(Tween.TRANS_QUAD)
	_move_tween.set_ease(Tween.EASE_OUT)
	_move_tween.tween_property(self, "global_position", target, d)

func _ready() -> void:
	dragging.connect("card_released",_on_dragging_card_released)
	card_state_machine.init(self)

func _on_dragging_card_released(card:singleCard):
	emit_signal("card_released",card)

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		card_state_machine.on_input(event)

func initCard(Nm) -> void:
	conDic=cardCont.conDict[Nm]
	cardName=conDic["base_cardName"]
	cardClass=conDic["base_cardClass"]
	cardNum=conDic["index"]
	cardCost=conDic["base_price"]
	cardTake=conDic["take"]
	cardCharge=conDic["fever"]
	card_is_played=false
	
	var imgPath="res://Card/asset/icon.svg"
	$Panel/color/pic.texture=load(imgPath)
	$Panel/color/name.text=conDic["base_display"]


func _on_input(event: InputEvent)  ->void:
	card_state_machine.on_input(event)
func _on_gui_input(event:InputEvent)-> void:
	card_state_machine.on_gui_input(event)
	
func _on_mouse_entered()-> void:
	card_state_machine.on_mouse_entered()
func _on_mouse_exited()-> void:
	card_state_machine.on_mouse_exited()


func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)


func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	targets.erase(area)

func get_current_state():
	var state=card_state_machine.current_state
	return state
