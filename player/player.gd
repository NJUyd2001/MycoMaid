extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800.0
const MAX_FALL_SPEED = 500.0  # 防止下落过快

@onready var sprite := $Sprite as AnimatedSprite2D
var interactables: Array = []

func register_interactable(interactable: Interactable) -> void:
	if !interactables.has(interactable):
		interactables.append(interactable)
		interactable.interacted.connect(_on_interacted)

func unregister_interactable(interactable: Interactable) -> void:
	interactables.erase(interactable)
	interactable.interacted.disconnect(_on_interacted)

func _on_interacted(interactable: Interactable) -> void:
	# 处理交互逻辑
	print("Interacted with %s" % interactable.name)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("sbs")

func _physics_process(delta: float) -> void:
	# 应用重力
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		# 可选：限制最大下落速度
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	else:
		velocity.y = 0  # 可防止在斜坡上积累速度（视需求而定）

	# 获取左右输入
	var direction := Input.get_axis("left","right")

	if direction > 0:
		velocity.x = SPEED
		sprite.animation = "run"
		sprite.flip_h = false
	elif direction < 0:
		velocity.x = -SPEED
		sprite.animation = "run"
		sprite.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite.animation = "idle"

	# 只有在地面时才能跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 更新动画（仅当动画真正变化时才播放，避免重复触发）
	if sprite.is_playing() == false:
		sprite.play()

	# 移动角色
	move_and_slide()
	
	
func _control_quit() ->void:
	if Input.is_action_just_pressed("quit"):
		quit()

func quit() ->void:
	get_tree().change_scene_to_file("res://pages/game.tscn")
