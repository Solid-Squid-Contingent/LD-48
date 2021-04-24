extends Sprite

onready var enemyScene = preload("res://scenes/Enemy.tscn")

#drunkPathfinding: bool
#demolition: bool
#speed: int
#maxHealth: int
#texturePath: String
var enemyTypes = [
	Enemy.Stats.new(false, false, 100, 100, "evilBellPepper.png"),
	Enemy.Stats.new(false, true, 50, 100, "fancyBellPepper.png")
]

var waves = []

func _ready():
	spawnEnemy()

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
