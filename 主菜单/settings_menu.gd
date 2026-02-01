extends Control

# 获取控件引用
@onready var volume_slider = $CenterContainer/VBoxContainer/HBoxContainer/VolumeSlider
@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var fullscreen_check =$CenterContainer/VBoxContainer/HBoxContainer2/FullscreenCheck
# 获取主音量总线索引
var master_bus_index = AudioServer.get_bus_index("Master")

func _ready():
	# --- 1. 初始化音量滑块 ---
	# 获取当前真实音量(db)，转成 0-1 显示在滑块上
	var current_db = AudioServer.get_bus_volume_db(master_bus_index)
	volume_slider.value = db_to_linear(current_db)
	
	# --- 2. 初始化全屏勾选框 ---
	# 检查当前是否全屏
	var mode = DisplayServer.window_get_mode()
	fullscreen_check.button_pressed = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# --- 3. 连接信号 ---
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back_pressed)

# 音量调节逻辑
func _on_volume_changed(value: float):
	# 把滑块的 0-1 转回分贝 (logarithmic)
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))
	# 如果滑到底，静音
	AudioServer.set_bus_mute(master_bus_index, value < 0.05)

# 全屏切换逻辑
func _on_fullscreen_toggled(toggled_on: bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# 返回逻辑
func _on_back_pressed():
	# 切换回游戏选择菜单
	# 注意：这里路径要写对，确保是回到你刚才的二级菜单
	SceneTransition.change_scene("res://场景/mainmenu.tscn")
