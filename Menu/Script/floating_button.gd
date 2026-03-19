extends Button

# 定义漂浮的距离和时间
@export var float_distance: float = 8.0  # 上下浮动 8 像素
@export var float_time: float = 1.0      # 一次浮动耗时 1 秒

var tween: Tween

func _ready():
	# 设置锚点在中心，这样缩放或移动更自然（可选）
	pivot_offset = size / 2
	
	# 连接信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# 确保按钮初始位置是对的
	position = Vector2.ZERO

func _on_mouse_entered():
	# 1. 杀掉旧的动画，防止冲突
	if tween: tween.kill()
	
	# 2. 创建新 Tween
	tween = create_tween()
	
	# 3. 设置为循环模式 (Set Loops)
	tween.set_loops() 
	
	# 4. 动作 A: 向上浮动 (相对位置 -8)
	# set_trans(Tween.TRANS_SINE) 让运动像波浪一样平滑
	tween.tween_property(self, "position:y", -float_distance, float_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 5. 动作 B: 向下浮动 (回到 0)
	tween.tween_property(self, "position:y", 0.0, float_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 6. 动作 C: 向下沉一点 (相对位置 +8)
	tween.tween_property(self, "position:y", float_distance, float_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 7. 动作 D: 回到中间 (回到 0)
	tween.tween_property(self, "position:y", 0.0, float_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_mouse_exited():
	# 鼠标离开，停止漂浮并归位
	if tween: tween.kill()
	
	# 快速回到原点 (0, 0)
	tween = create_tween()
	tween.tween_property(self, "position:y", 0.0, 0.2).set_ease(Tween.EASE_OUT)
