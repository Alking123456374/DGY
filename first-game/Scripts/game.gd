extends Node2D

@export var enemyScene : PackedScene
@export var spawnInterval : float = 2.0

@onready var player : CharacterBody2D = $Player
@onready var spawnTimer : Timer = $EnemySpawnTimer
@onready var scoreLabel : Label = $UI/ScoreLabel
@onready var gameOverPanel : Control = $UI/GameOverPanel
@onready var finalScoreLabel : Label = $UI/GameOverPanel/Center/VBox/FinalScore
@onready var bgm : AudioStreamPlayer = $BGM
@onready var enemyDeathSound : AudioStreamPlayer = $EnemyDeathSound
@onready var gameOverSound : AudioStreamPlayer = $GameOverSound

var score : int = 0
var isGameOver : bool = false

func _ready() -> void:
	randomize()
	# 背景音乐循环播放
	if bgm.stream is AudioStreamOggVorbis:
		bgm.stream.loop = true
	bgm.play()

	gameOverPanel.visible = false
	update_score()

	player.connect("died", _on_player_died)
	spawnTimer.timeout.connect(_on_spawn_timer_timeout)
	spawnTimer.wait_time = spawnInterval
	spawnTimer.start()
	spawn_enemy()

func _on_spawn_timer_timeout() -> void:
	if isGameOver:
		return
	spawn_enemy()

# 从屏幕右侧外面刷一只史莱姆
func spawn_enemy() -> void:
	var enemy = enemyScene.instantiate()
	enemy.position = Vector2(300, randf_range(-120, 120))
	enemy.connect("died", _on_enemy_died)
	add_child(enemy)

func _on_enemy_died() -> void:
	score += 1
	update_score()
	enemyDeathSound.play()

func update_score() -> void:
	scoreLabel.text = "Score: %d" % score

# 玩家死亡后停止刷怪和背景音乐，显示结算界面，稍后重新开始
func _on_player_died() -> void:
	if isGameOver:
		return
	isGameOver = true
	spawnTimer.stop()
	bgm.stop()
	gameOverSound.play()
	finalScoreLabel.text = "Score: %d" % score
	gameOverPanel.visible = true
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()
