extends TextureRect

signal done

var enemySpawner
onready var container = $Container

func _ready():
	enemySpawner = get_tree().get_nodes_in_group("EnemySpawner")[0]

func show():
	get_tree().paused = true
	visible = true
	var waveIndex = 0
	for wave in enemySpawner.waves:
		var enemyIndex = 0
		for enemy in wave:
			enemy.position.x = 200 + 150 * enemyIndex
			enemy.position.y = 350 + 250 * waveIndex
			container.add_child(enemy)
			enemyIndex += 1
		waveIndex += 1
		if waveIndex >= 3:
			break
	
func _input(event):
	if visible and event is InputEventKey and event.pressed and !event.echo:
		get_tree().paused = false
		visible = false
		while container.get_child_count() > 0:
			container.remove_child(container.get_child(0))
		emit_signal("done")
