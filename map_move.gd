extends Node2D

@onready var player: Sprite2D = $Player
@onready var stamina_bar = $ProgressBar
# 配置参数
@export var map_width: int = 5   # 现在可以随心所欲修改大小
@export var map_height: int = 5
@export var max_stamina: int = 100
var current_stamina: int = 100
const TILE_SIZE = 64
const SCALE_FACTOR = 2
const NODE_SIZE = TILE_SIZE * SCALE_FACTOR # 128

var current_node = Vector2i(0, 0)
var is_moving = false
var map_offset: Vector2

var tile_events = {
	Vector2i(1, 1): "heal",   # 坐标 (1,1) 是回血
	Vector2i(3, 2): "trap",   # 坐标 (3,2) 是陷阱
	Vector2i(4, 4): "goal"    # 终点
}
func _ready():
	# 1. 自动计算居中偏移量
	calculate_layout()
	# 2. 初始化位置
	center_camera()
	snap_to_node_center(current_node)
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina
	update_stamina_display()
func update_stamina_display():
	stamina_bar.value = current_stamina
	if current_stamina < 30:
		stamina_bar.modulate = Color.RED # 低于30变红
	else:
		stamina_bar.modulate = Color.WHITE # 正常颜色
	# 如果你想让它显示具体的数值而不是百分比，可以这样写：
	# stamina_bar.get_node("Label").text = str(current_stamina) + "/" + str(max_stamina)
func update_ui():
	stamina_bar.value = current_stamina
func center_camera():
	var camera = $Camera2D
	var window_size = Vector2(1280, 720)
	var total_map_size = Vector2(map_width, map_height) * NODE_SIZE
	
	# 1. 计算居中位置
	# 不管 offset 是多少，相机对准地图的像素中心
	var map_center_pos = map_offset + (total_map_size / 2.0)
	camera.global_position = map_center_pos
	
	# 2. 自动调整缩放 (Zoom)
	# 如果地图比窗口大，就缩小相机 (Zoom 值变小)
	var margin = 1.1 # 留出 10% 的边距，不让地图贴边
	var x_ratio = window_size.x / (total_map_size.x * margin)
	var y_ratio = window_size.y / (total_map_size.y * margin)
	var zoom_value = min(x_ratio, y_ratio, 1.0) # 取最小值，且最大不超过 1.0
	
	camera.zoom = Vector2(zoom_value, zoom_value)
	
	# 3. 动态调整边界限制，防止看到负轴之外的虚空
	camera.limit_left = min(0, map_offset.x)
	camera.limit_top = min(0, map_offset.y)
	camera.limit_right = max(window_size.x, total_map_size.x + map_offset.x)
	camera.limit_bottom = max(window_size.y, total_map_size.y + map_offset.y)
func calculate_layout():
	var total_map_size = Vector2(map_width, map_height) * NODE_SIZE
	var window_size = Vector2(1280, 720)
	# 让地图在窗口中心
	map_offset.x = floor((window_size.x - total_map_size.x) / 2.0)
	map_offset.y = floor((window_size.y - total_map_size.y) / 2.0)
func consume_stamina(amount: int):
	current_stamina -= amount
	current_stamina = clamp(current_stamina, 0, max_stamina) # 确保在0到最大值之间
	
	# 关键：在这里调用更新 UI
	update_stamina_display()
	
	print("消耗体力: %d, 剩余体力: %d/%d" % [amount, current_stamina, max_stamina])
func _input(event):
	if is_moving: return
	
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var relative_pos = mouse_pos - map_offset
		
		var target_node = Vector2i(
			floor(relative_pos.x / NODE_SIZE),
			floor(relative_pos.y / NODE_SIZE)
		)
		if current_stamina < 10:
			print("❌ 体力不足，无法移动！")
			return
		# 逻辑判断：在当前动态地图范围内，且是相邻格（含斜向）
		if is_within_map(target_node) and is_adjacent(target_node):
			move_to_node(target_node)

func is_within_map(node: Vector2i) -> bool:
	return node.x >= 0 and node.x < map_width and node.y >= 0 and node.y < map_height

func is_adjacent(target: Vector2i) -> bool:
	var diff = (target - current_node).abs()
	return diff.x <= 1 and diff.y <= 1 and target != current_node

func move_to_node(next_node: Vector2i):
	is_moving = true
	current_node = next_node
	
	consume_stamina(10)
	
	var target_pixel_pos = Vector2(next_node) * NODE_SIZE + Vector2(NODE_SIZE/2, NODE_SIZE/2) + map_offset
	var tween = create_tween()
	tween.tween_property(player, "global_position", target_pixel_pos, 0.4).set_trans(Tween.TRANS_SINE)
	
	tween.finished.connect(func(): 
		is_moving = false
		trigger_event(current_node) # 角色停稳后触发事件
	)
func trigger_event(node_pos: Vector2i):
	if tile_events.has(node_pos):
		var event = tile_events[node_pos]
		match event:
			"heal":
				print("✨ 踩到了回血点！回复HP")
			"trap":
				print("💥 哎呀！踩到了陷阱")
			"goal":
				print("🏆 抵达终点！")
	else:
		print("走到了普通格点: ", node_pos)
	
func snap_to_node_center(node_pos: Vector2i):
	player.global_position = Vector2(node_pos) * NODE_SIZE + Vector2(NODE_SIZE/2, NODE_SIZE/2) + map_offset

# 调试：画出当前地图的所有格子
func _draw():
	# 增加一个安全检查，防止数值异常导致死循环
	if map_width > 100 or map_height > 100: return 
	
	var grid_color = Color(1, 1, 1, 0.3)
	var line_width = 1.0 # 保持为 1.0，如果还是看不清，再调项目设置的 Pixel Snap
	
	# 绘制垂直线
	for i in range(map_width + 1):
		var x = map_offset.x + i * NODE_SIZE
		draw_line(Vector2(x, map_offset.y), Vector2(x, map_offset.y + map_height * NODE_SIZE), grid_color, line_width)
		
	# 绘制水平线
	for i in range(map_height + 1):
		var y = map_offset.y + i * NODE_SIZE
		draw_line(Vector2(map_offset.x, y), Vector2(map_offset.x + map_width * NODE_SIZE, y), grid_color, line_width)

func draw_outline(rect: Rect2):
	draw_rect(rect, Color(1, 1, 1, 0.2), false, 1.0) # 画出淡淡的网格线
