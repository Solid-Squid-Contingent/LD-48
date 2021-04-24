extends Sprite

onready var enemyScene = preload("res://scenes/Enemy.tscn")

var waves = []

func _ready():
	spawnEnemy()

func generateWave():
	var wave = []
	for _i in range(rand_range(2,10)):
		var enemy : Enemy = enemyScene.instance()
		enemy.individualStats = []
		for _u in range(rand_range(2,5)):
			enemy.individualStats.append(Enemy.Stats.new())
		enemy.updateGroupStats()
		wave.append(enemy)
	waves.append(wave)
func spawnEnemy():
	while waves.size() < 3:
		generateWave()
	
	var enemy = waves[0].pop_front()
	enemy.position = position
	get_parent().call_deferred("add_child", enemy)
	
	if waves[0].empty():
		waves.pop_front()
		generateWave()
		$SpawnTimer.start(rand_range(10.0, 11.0))
	else:
		$SpawnTimer.start(rand_range(5.0, 6.0))

func _on_SpawnTimer_timeout():
	spawnEnemy()
