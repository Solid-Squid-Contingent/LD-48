extends Sprite

signal spawnedWave
signal allEnemiesDead

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
	Stats.new(false, false, 100, 50, 10, 1, {}, "tourist.png", "evilBellPepperDead.png"),
	Stats.new(false, false, 150, 100, 100, 2, {Stats.DamageTypes.NORMAL : 0.1}, "tombRaider.png", "evilBellPepperDead.png"),
	Stats.new(false, true, 70, 100, 100, 5, {}, "tombRaider.png", "fancyBellPepperDead.png")
]

var enemyDescriptions = [
	["Tourist",
		"Isn’t this country wonderful? Wow, these spikes almost look like they could actually kill y-",
		"Weak. Puny. Nothing of note about them. Like all enemies they like to show up in groups and split up on intersections."],
	
	["Tomb Raider",
		"I hope to make enough of an impact on the world to make people want to plunder MY crypt.",
		"Your average grave robber. Stronger than tourists and other amateurs. More resistant to boring traps like spikes and arrows."],
	
	["Demolition Dude",
		"Actually, I’m also a pretty good rapper. Look: ‘Boom.’ Hahahaha… Oh, I blew my leg off.",
		"Slow but can place bombs that might blow up your pyramid. Right-click bombs to extinguish."],
]

var enemiesSeen = []

var waves = []
var betweenWaves = false

var showEnemyInfos = false

var enemyCount = 0

onready var player = get_tree().get_nodes_in_group('Player')[0]
onready var enemyInfo = get_tree().get_nodes_in_group('EnemyInfo')[0]

func begin():
	var layout
	for l in get_tree().get_nodes_in_group("Layout"):
		if l.get_parent() == get_parent():
			layout = l
			break
	
	layout.addItem(self)
		
	for enemyType in enemyTypes:
		enemiesSeen.append(false)
		
	$SpawnTimer.start(999.0)
	betweenWaves = true
	
	generateFirstWave()
	generateFirstWave()
	generateWave([enemyTypes[0]], 0)

func unremoveable():
	return true

func showEnemyInfoIfNeeded(typeIndex):
	if showEnemyInfos and !enemiesSeen[typeIndex]:
		if enemyInfo.visible:
			yield(enemyInfo, "done")
		enemiesSeen[typeIndex] = true
		enemyInfo.setSprite(enemyTypes[typeIndex].texturePath)
		enemyInfo.setText(enemyDescriptions[typeIndex])
		enemyInfo.show()

func generateFirstWave():
	var wave = []
	var enemy : Enemy = enemyScene.instance()
	enemy.individualStats = []
	var type = enemyTypes[0]
	for _u in range(2):
		enemy.individualStats.append(type.duplicate())
	enemy.updateGroupStats()
	wave.append(enemy)
	waves.append(wave)
	
func generateWave(enemyTypesUsed, addedGroupSize):
	var wave = []
	for _i in range(rand_range(2,10)):
		var enemy : Enemy = enemyScene.instance()
		enemy.individualStats = []
		var type = null
		if randf() <= 0.75:
			var typeIndex = randi() % enemyTypesUsed.size()
			type = enemyTypesUsed[typeIndex]
			
		for _u in range(rand_range(2,5) + addedGroupSize):
			if type:
				enemy.individualStats.append(type.duplicate())
			else:
				var typeIndex = randi() % enemyTypesUsed.size()
				showEnemyInfoIfNeeded(typeIndex)
				enemy.individualStats.append(enemyTypesUsed[typeIndex].duplicate())
		enemy.updateGroupStats()
		wave.append(enemy)
	waves.append(wave)
	
func spawnEnemy():
	if waves.empty():
		return
		
	betweenWaves = false

	var enemy = waves[0].pop_front()
	enemy.position = position
	get_parent().call_deferred("add_child", enemy)
	enemy.call_deferred("updateLevel")
	enemyCount += 1
	enemy.connect("groupDied", self, "enemyGroupDied")
	
	for stat in enemy.individualStats:
		showEnemyInfoIfNeeded(enemyTypes.find(stat))

	if waves[0].empty():
		waves.pop_front()
		if !waves.empty():
			betweenWaves = true
			$SpawnTimer.start(rand_range(30.0, 40.0))
	else:
		$SpawnTimer.start(rand_range(2.0, 4.0))
	
	emit_signal("spawnedWave")

var enemyTypeUnlockProgress = 0
var groupSizeDifficulty = 5
var waveNum = 5
func enemyGroupDied():
	enemyCount -= 1
	if enemyCount <= 0 and waves.empty():
		emit_signal("allEnemiesDead")
		while waves.size() < waveNum:
			generateWave(enemyTypes.slice(0, enemyTypeUnlockProgress), groupSizeDifficulty)
			
		enemyTypeUnlockProgress += 1
		groupSizeDifficulty += 3
		waveNum += 2
		
		betweenWaves = true
		$SpawnTimer.start(rand_range(30.0, 40.0))

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
