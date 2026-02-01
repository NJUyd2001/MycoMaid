extends Control

@export var level2_music: AudioStream

# --- 1. 获取节点引用 (根据场景树图片顺序) ---
# TicketGroup 1: 开始游戏
@onready var btn_start = $VBoxContainer/TicketGroup
# TicketGroup 2: 读取存档
@onready var btn_load = $VBoxContainer/TicketGroup2
# TicketGroup 3: (新功能) 比如 CG画廊、制作人员名单等
@onready var btn_gallery = $VBoxContainer/TicketGroup3
# TicketGroup 4: 设置
@onready var btn_option = $VBoxContainer/TicketGroup4
# TicketGroup 5: (新位置) 退出游戏/退出到桌面
@onready var btn_quit_game = $VBoxContainer/TicketGroup5

# 独立的返回按钮 (场景树最下方的 quit)
@onready var btn_back = $quit

func _ready():
	# --- 2. 播放音乐逻辑 (保持不变) ---
	print("MainMenu 加载完毕")
	if AudioManager and level2_music:
		AudioManager.play_music(level2_music)
	else:
		print("提示：未设置音乐或 AudioManager 不存在")

	# --- 3. 连接信号 (重新分配功能) ---
	
	# 连接 5 个票据按钮的信号 (假设它们发出的信号是 ticket_opened)
	if btn_start:
		btn_start.ticket_opened.connect(_on_start_game)
	
	if btn_load:
		btn_load.ticket_opened.connect(_on_load_game)
		
	if btn_gallery:
		btn_gallery.ticket_opened.connect(_on_gallery_opened) # 新功能
		
	if btn_option:
		btn_option.ticket_opened.connect(_on_options)
		
	if btn_quit_game:
		btn_quit_game.ticket_opened.connect(_on_quit_game_logic) # 退出桌面的逻辑

	# 连接右下角/独立的返回按钮 (假设是普通按钮，信号是 pressed)
	if btn_back:
		btn_back.pressed.connect(_on_back_to_title_pressed)


# --- 4. 定义对应的功能函数 ---

func _on_start_game():
	print("逻辑：开始新游戏")
	# 示例：SceneTransition.change_scene("res://场景/game_scene.tscn")
	SceneTransition.change_scene("res://场景/game_selection.tscn")

func _on_load_game():
	print("逻辑：打开存档界面")

func _on_gallery_opened():
	print("TicketGroup3")
	# 可以在这里写跳转代码

func _on_options():
	print("TicketGroup4")

func _on_quit_game_logic():
	print("TicketGroup5")
	SceneTransition.change_scene("res://场景/settings_menu.tscn")

func _on_back_to_title_pressed():
	print("逻辑：返回上一级/标题画面 (quit按钮)")
	SceneTransition.change_scene("res://场景/start_menu.tscn")
