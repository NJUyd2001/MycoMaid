extends Control

# 定义一个点击信号，供外部(如GameSelection)连接使用
signal pressed

# --- 外部变量设置 ---
@export_group("Visuals")
@export var paper_texture: Texture2D # 在编辑器里拖入图片

@export_group("Animation Settings")
@export var float_scale: Vector2 = Vector2(1.1, 1.1) # 悬浮时的放大倍数
@export var lift_distance: float = 15.0 # 向上浮动的距离 (像素)
@export var shadow_offset: Vector2 = Vector2(10.0, 10.0) # 阴影偏移量 (模拟光照)
@export var anim_time: float = 0.2 # 动画持续时间

# --- 节点引用 ---
@onready var shadow = $Shadow
@onready var paper = $Paper
@onready var btn_overlay = $BtnOverlay

var tween: Tween

func _ready():
	# 1. 应用纹理
	if paper_texture:
		paper.texture = paper_texture
		# 阴影层复用同一张图，但依靠 Modulate 变黑
		shadow.texture = paper_texture
	
	# 2. 【关键修复】等待一帧
	# 等待 Godot 完成 UI 的自动布局计算，确保 size 属性是正确的
	await get_tree().process_frame
	
	# 3. 设置轴心点 (Pivot) 为图片中心
	# 这样缩放时才会以中心为原点，而不是左上角
	paper.pivot_offset = paper.size / 2
	shadow.pivot_offset = shadow.size / 2
	
	# 4. 强制复位初始状态
	_reset_state_immediate()

	# 5. 连接信号
	btn_overlay.mouse_entered.connect(_on_mouse_entered)
	btn_overlay.mouse_exited.connect(_on_mouse_exited)
	# 转发点击信号
	btn_overlay.pressed.connect(_on_pressed)

# 瞬间复位 (无动画)，用于初始化或防bug
func _reset_state_immediate():
	if tween: tween.kill()
	
	# 纸张和阴影相对于父节点(FloatingPaper)的位置归零
	paper.scale = Vector2.ONE
	paper.position = Vector2.ZERO
	shadow.position = Vector2.ZERO
	shadow.scale = Vector2.ONE

func _on_mouse_entered():
	# 杀掉旧动画
	if tween: tween.kill()
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK) # 使用 Back 曲线会有Q弹的感觉
	
	# --- 纸张动作：变大 + 上浮 ---
	tween.tween_property(paper, "scale", float_scale, anim_time)
	tween.tween_property(paper, "position:y", -lift_distance, anim_time)
	
	# --- 阴影动作：位移 + 稍微变小(模拟光线聚焦) ---
	tween.tween_property(shadow, "position", shadow_offset, anim_time)
	# (可选) 阴影稍微变小一点点，增加透视感
	tween.tween_property(shadow, "scale", Vector2(0.95, 0.95), anim_time)

func _on_mouse_exited():
	# 恢复原状
	if tween: tween.kill()
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	# 全部归位
	tween.tween_property(paper, "scale", Vector2.ONE, anim_time)
	tween.tween_property(paper, "position", Vector2.ZERO, anim_time)
	tween.tween_property(shadow, "position", Vector2.ZERO, anim_time)
	tween.tween_property(shadow, "scale", Vector2.ONE, anim_time)

func _on_pressed():
	# 发出信号，告诉父场景“我被点了”
	pressed.emit()
