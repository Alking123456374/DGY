extends CharacterBody2D

signal died

@export var basic_speed:float = 100
@export var animator : AnimatedSprite2D
@export var playerSprite : AnimatedSprite2D
@export var bulletScene : PackedScene
@export var bulletNum : int = 12

@onready var gunSound : AudioStreamPlayer = $GunSound
@onready var runningSound : AudioStreamPlayer = $RunningSound

var isDead : bool = false
var isReload : bool = false

func _ready() -> void:
	# 跑步音效循环播放
	if runningSound.stream is AudioStreamMP3:
		runningSound.stream.loop = true

# 每个物理帧更新移动和射击，时间参数表示本次物理帧的间隔
func _physics_process(delta: float):
	if isDead:
		return

	velocity = Input.get_vector("Left","Right","Up","Down") * basic_speed

	# 根据左右移动方向翻转角色图像，向左时水平缩放设为 -1
	if velocity.x != 0:
		playerSprite.scale.x = sign(velocity.x)

	# 静止时播放待机动画，移动时播放奔跑动画
	if velocity == Vector2.ZERO:
		animator.play("idle")
		if runningSound.playing:
			runningSound.stop()
	else:
		animator.play("run")  # 保持当前方向
		if !runningSound.playing:
			runningSound.play()

	# 玩家射击
	if Input.is_action_just_pressed("Shoot"):
		try_shoot()

	move_and_slide()

# 尝试射击：换弹过程中忽略输入，子弹打空后自动换弹
func try_shoot() -> void:
	if isReload:
		return
	if bulletNum <= 0:
		reload()
		return
	bulletNum -= 1
	shoot()
	gunSound.play()
	if bulletNum == 0:
		reload()

# 换弹：两秒后弹夹回满
func reload() -> void:
	isReload = true
	await get_tree().create_timer(2).timeout
	bulletNum = 12
	isReload = false

func shoot():
	var bulletNode = bulletScene.instantiate()
	if playerSprite.scale.x > 0 :
		bulletNode.position = position + Vector2(8,8)
	else:
		bulletNode.position = position + Vector2(-8,8)
		bulletNode.scale.x = -1
	get_tree().current_scene.add_child(bulletNode)

# 游戏结束
func game_over():
	if isDead:
		return
	isDead = true
	velocity = Vector2.ZERO
	if runningSound.playing:
		runningSound.stop()
	animator.play("die")
	died.emit()
