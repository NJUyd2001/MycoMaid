extends Control

# 暴露给编辑器的变量
@export var menu_music: AudioStream

# 获取场景里的节点
@onready var building = $Building
@onready var btn_exit = $BtnExit  # 你的退出按钮

func _ready():
	# --- 1. 播放音乐 ---
	if AudioManager and menu_music:
		AudioManager.play_music(menu_music)
	
	# --- 2. 连接建筑点击信号 ---
	if building:
		# 连接建筑的 clicked 信号到 _on_building_clicked 函数
		building.clicked.connect(_on_building_clicked)
		
	# --- 3. 连接退出按钮信号 ---
	if btn_exit:
		# 连接按钮的 pressed 信号到 _on_button_pressed 函数
		btn_exit.pressed.connect(_on_button_pressed)

# --- 核心修复：这里不能写 pass，要写切换场景的代码 ---
func _on_building_clicked():
	print("点击了建筑，正在切换场景...")
	# 切换到第二级菜单
	SceneTransition.change_scene("res://场景/mainmenu.tscn")

# --- 退出按钮的功能 ---
func _on_button_pressed() -> void:
	print("退出游戏")
	get_tree().quit()
