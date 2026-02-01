extends Sprite2D

#在这里调整速度 (数字越大转越快)
var speed = 50.0 

func _process(delta):
	# 每一帧都增加一点角度
	rotation_degrees += speed * delta
