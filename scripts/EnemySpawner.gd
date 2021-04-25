extends Sprite

onready var enemyScene = preload("res://scenes/Enemy.tscn")

#drunkPathfinding: bool
#demolition: bool
#speed: int
#maxHealth: int
#texturePath: String
var enemyTypes = [
	Stats.new(false, false, 100, 100, 100, "evilBellPepper.png"),
	Stats.new(false, true, 50, 100, 100, "fancyBellPepper.png")
]

var waves = []
var betweenWaves = false

var player

func _ready():
	spawnEnemy()
	player = get_tree().get_nodes_in_group('Player')[0]

func generateWave():
	var wave = []
	for _i in range(rand_range(2,10)):
		var enemy : Enemy = enemyScene.instance()
		enemy.individualStats = []
		var type = null
		if randf() <= 0.5:
			type = enemyTypes[randi() % enemyTypes.size()]
			
		for _u in range(rand_range(2,5)):
			if type:
				enemy.individualStats.append(type.duplicate())
			else:
				enemy.individualStats.append(enemyTypes[randi() % enemyTypes.size()].duplicate())
		enemy.updateGroupStats()
		wave.append(enemy)
	waves.append(wave)
	
func spawnEnemy():
	betweenWaves = false
	
	while waves.size() < 3:
		generateWave()

	var enemy = waves[0].pop_front()
	enemy.position = position
	get_parent().call_deferred("add_child", enemy)

	if waves[0].empty():
		waves.pop_front()
		generateWave()
		$SpawnTimer.start(rand_range(20.0, 25.0))
		betweenWaves = true
	else:
		$SpawnTimer.start(rand_range(3.0, 5.0))

func _exit_tree():
	for wave in waves:
		for enemy in wave:
			enemy.free()

func _process(_delta):
	if betweenWaves:
		$WaveTimeLabel.text = String(int($SpawnTimer.time_left)) + " s"
	else:
		$WaveTimeLabel.text = ""
		

func _on_SpawnTimer_timeout():
	spawnEnemy()

func _on_WaveTimeLabel_gui_input(event):
	if event.is_action_pressed('interact'):
		var target = get_global_mouse_position()
		if (target - player.global_position).length() < player.INTERACT_RANGE:
			if betweenWaves:
				spawnEnemy()
