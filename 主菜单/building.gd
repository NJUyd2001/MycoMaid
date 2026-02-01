extends Area2D

# 定义一个信号，告诉父节点“我被点了”
signal clicked

@onready var sprite = $Sprite2D

func _ready():
	# 允许接收鼠标输入
	input_pickable = true
	# 确保材质里的 is_active 初始是关闭的
	(sprite.material as ShaderMaterial).set_shader_parameter("is_active", false)
	
	# 连接信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _on_mouse_entered():
	print("鼠标进来了！")# 鼠标悬停 -> 开启描边
	(sprite.material as ShaderMaterial).set_shader_parameter("is_active", true)

func _on_mouse_exited():
	# 鼠标离开 -> 关闭描边
	(sprite.material as ShaderMaterial).set_shader_parameter("is_active", false)

func _on_input_event(_viewport, event, _shape_idx):
	# 检测鼠标左键点击
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit() # 发出信号
