extends Area2D

signal died

@export var slime_walkspeed : float = 25

@onready var animator : AnimatedSprite2D = $AnimatedSprite2D

var isDead : bool = false

func _ready() -> void:
	add_to_group("enemy")

# 每个物理帧更新敌人位置，按帧间隔计算移动距离
func _physics_process(delta: float) -> void:
	if isDead:
		return
	position -= Vector2(slime_walkspeed,0) * delta
	# 走出屏幕左侧直接回收，避免无限累积
	if position.x < -300:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if isDead:
		return
	if body is CharacterBody2D:
		body.game_over()

# 被子弹击中
func die() -> void:
	if isDead:
		return
	isDead = true
	monitoring = false
	$CollisionShape2D.set_deferred("disabled", true)
	died.emit()
	if animator.sprite_frames.has_animation("die"):
		animator.play("die")
		await animator.animation_finished
	queue_free()
