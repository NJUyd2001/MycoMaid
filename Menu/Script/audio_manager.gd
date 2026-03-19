extends Node

@onready var bgm_player = $BGMPlayer

# 播放指定音乐
func play_music(stream: AudioStream):
	if bgm_player.stream == stream:
		return # 如果是同一首，就不重播
		
	bgm_player.stream = stream
	bgm_player.play()

# 停止音乐
func stop_music():
	bgm_player.stop()
