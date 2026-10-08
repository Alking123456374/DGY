extends Area2D
@export var bulletSpeed : float = 5


# 子弹首次进入场景树时，连接命中信号并启动回收计时
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	await  get_tree().create_timer(3).timeout
	queue_free()


# 每帧更新子弹位置，按帧间隔计算移动距离
func _process(delta: float) -> void:
	position.x += bulletSpeed * scale.x * delta * 60


# 命中敌人后让敌人死亡，并销毁子弹
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("die"):
		area.die()
		queue_free()
