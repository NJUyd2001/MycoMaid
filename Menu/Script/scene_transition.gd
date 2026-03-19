extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready():
	# 初始化时，圆是最大的（画面完全可见）
	# shader parameter 必须和 shader 代码里的 uniform 名字一致
	color_rect.material.set_shader_parameter("circle_size", 1.5)
	color_rect.material.set_shader_parameter("screen_width", get_viewport().get_visible_rect().size.x)
	color_rect.material.set_shader_parameter("screen_height", get_viewport().get_visible_rect().size.y)
	# 初始状态不阻挡点击
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# 这是你唯一需要调用的函数
func change_scene(target_path: String):
	# 1. 开始转场，阻挡鼠标点击防止误触
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. 创建动画 (Tween)
	var tween = create_tween()
	# 设置动画曲线，EASE_IN_OUT 看起来更自然
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# 3. 第一阶段：关门 (Circle Size 从 1.5 变到 0.0) -> 向圆心变黑
	tween.tween_method(set_circle_size, 1.5, 0.0, 1.0) # 1.0是持续时间
	
	# 等待关门动画结束
	await tween.finished
	
	# 4. 切换场景
	get_tree().change_scene_to_file(target_path)
	
	# 5. 第二阶段：开门 (Circle Size 从 0.0 变回 1.5) -> 从圆心向外变亮
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(set_circle_size, 0.0, 1.5, 1.0)
	
	# 等待开门结束
	await tween.finished
	
	# 6. 恢复鼠标穿透
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# 辅助函数：用来给 Tween 调用设置 Shader 参数
func set_circle_size(value: float):
	color_rect.material.set_shader_parameter("circle_size", value)
