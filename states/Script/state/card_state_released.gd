extends CardState

var played:bool
var _waiting_return: bool = false
var _aborted: bool = false
var _entered_at_ms: int = 0

func enter()-> void:
	card_ui.color.color=Color.RED
	card_ui.state.text="解放解放"
	played=false
	_waiting_return = false
	_aborted = false
	_entered_at_ms = Time.get_ticks_msec()
	if not card_ui.targets.is_empty():
		played =true
		print("play card for targets (s)",card_ui.targets)
	if played:
		return
	# 未打出：展示 RELEASED 状态 0.5 秒，期间禁用操作；若有新输入则立即回手牌并取消等待
	_waiting_return = true
	var t := get_tree().create_timer(0.5, false)
	t.timeout.connect(func():
		if not _waiting_return or _aborted:
			return
		_waiting_return = false
		transition_requested.emit(self, CardState.State.BASE)
	)
		
func on_input(event: InputEvent)  ->void:
	if played :
		return
	# 刚进入 RELEASED 的同一帧/极短时间内，可能还会收到“松手/释放”等事件；
	# 为了能看到红色展示，这里先忽略一小段时间内的输入。
	if Time.get_ticks_msec() - _entered_at_ms < 60:
		return

	# 等待期间仅把“真实的新操作（鼠标按下）”视为打断；忽略 MouseMotion/Release 以避免误触发
	if _waiting_return:
		var abort := event.is_action_pressed("left_mouse") or event.is_action_pressed("right_mouse")
		if not abort:
			return
		_aborted = true
		_waiting_return = false

	transition_requested.emit(self, CardState.State.BASE)
	
func on_gui_input(event:InputEvent)-> void:
	if played:
		return
	# GUI 输入同样只在“按下”时打断；释放/移动不打断展示
	if Time.get_ticks_msec() - _entered_at_ms < 60:
		return
	if _waiting_return:
		var abort := event.is_action_pressed("left_mouse") or event.is_action_pressed("right_mouse")
		if not abort:
			return
		_aborted = true
		_waiting_return = false
	transition_requested.emit(self, CardState.State.BASE)
