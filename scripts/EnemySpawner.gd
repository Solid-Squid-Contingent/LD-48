extends Sprite

onready var enemyScene = preload("res://scenes/Enemy.tscn")

#drunkPathfinding: bool
#demolition: bool
#speed: int
#maxHealth: int
#maxBravery: int
#resistances
#texturePath: String
#corpseTexturePath: String
var enemyTypes = [
	Stats.new(false, false, 100, 100, 100, {Stats.DamageTypes.NORMAL : 0.1}, "evilBellPepper.png", "evilBellPepperDead.png"),
	Stats.new(false, true, 50, 100, 100, {}, "fancyBellPepper.png", "fancyBellPepperDead.png")
]

var enemyDescriptions = [
	["Tomb Raider",
		"I hope to make enough of an impact on the world to make people want to plunder MY crypt.",
		"Your average grave robber. Stronger than tourists and other amateurs. More resistant to boring traps like spikes and arrows."],
	
	["Demolition Dude",
		"Actually, I’m also a pretty good rapper. Look: ‘Boom.’ Hahahaha… Oh, I blew off my leg.",
		"Slow but can place bombs that might blow up your pyramid. Right-click bombs to extinguish."],
]

var enemiesSeen = []

var waves = []
var betweenWaves = false

onready var player = get_tree().get_nodes_in_group('Player')[0]
onready var enemyInfo = get_tree().get_nodes_in_group('EnemyInfo')[0]

func _ready():
	var layout
	for l in get_tree().get_nodes_in_group("Layout"):
		if l.get_parent() == get_parent():
			layout = l
			break
	
	layout.addItem(self)
		
	for enemyType in enemyTypes:
		enemiesSeen.append(false)
		
	spawnEnemy()

func unremoveable():
	return true

func showEnemyInfoIfNeeded(typeIndex):
	return #TODO: Remove
	if !enemiesSeen[typeIndex]:
		if enemyInfo.visible:
			yield(enemyInfo, "done")
		enemiesSeen[typeIndex] = true
		enemyInfo.setSprite(enemyTypes[typeIndex].texturePath)
		enemyInfo.setText(enemyDescriptions[typeIndex])
		enemyInfo.show()
		

func generateWave():
	var wave = []
	for _i in range(rand_range(2,10)):
		var enemy : Enemy = enemyScene.instance()
		enemy.individualStats = []
		var type = null
		if randf() <= 0.75:
			var typeIndex = randi() % enemyTypes.size()
			showEnemyInfoIfNeeded(typeIndex)
			type = enemyTypes[typeIndex]
			
		for _u in range(rand_range(2,5)):
			if type:
				enemy.individualStats.append(type.duplicate())
			else:
				var typeIndex = randi() % enemyTypes.size()
				showEnemyInfoIfNeeded(typeIndex)
				enemy.individualStats.append(enemyTypes[typeIndex].duplicate())
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
	enemy.call_deferred("updateLevel")

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
