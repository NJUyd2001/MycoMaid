extends Control

signal ticket_opened

@export_group("Visuals")
@export var body_texture: Texture2D  # 主票图片
@export var stub_texture: Texture2D  # 副票图片

@onready var anim_player = $Anim
@onready var btn_overlay = $BtnOverlay
@onready var stub = $Stub
@onready var body = $Body 

func _ready():
	if body_texture:
		body.texture = body_texture
	if stub_texture:
		stub.texture = stub_texture

	stub.modulate.a = 1.0
	
	if not btn_overlay.pressed.is_connected(_on_pressed):
		btn_overlay.pressed.connect(_on_pressed)
	if not btn_overlay.mouse_entered.is_connected(_on_mouse_entered):
		btn_overlay.mouse_entered.connect(_on_mouse_entered)
	if not btn_overlay.mouse_exited.is_connected(_on_mouse_exited):
		btn_overlay.mouse_exited.connect(_on_mouse_exited)

# 鼠标悬停
func _on_mouse_entered():
	if anim_player.has_animation("hover_tear"):
		# 【重要】每次进来时，必须重置为 1.0 (正常速度)
		anim_player.speed_scale = 1.0
		anim_player.play("hover_tear")

# 鼠标离开
func _on_mouse_exited():
	if anim_player.has_animation("hover_tear"):
		# 【修改这里】设置为 2.0 或 3.0 (数字越大回弹越快)
		# 比如这里设为 3倍速，意味着只需要 0.1秒 就能合上
		anim_player.speed_scale = 3.0
		anim_player.play_backwards("hover_tear")

# 鼠标点击
func _on_pressed():
	# 停止动画
	anim_player.stop()
	
	# 淡出效果
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(stub, "modulate:a", 0.0, 0.5)
	tween.tween_property(stub, "rotation_degrees", 25.0, 0.5)
	
	await tween.finished
	
	# 发送信号
	ticket_opened.emit()
