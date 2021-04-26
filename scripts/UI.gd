extends Control

signal allEnemiesDead

var player : Player

func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]
	_process(0)


func _process(_delta):
	$MoneyLabel.text = String(player.money) + " $"
	$HealthLabel.text = "Treasure Chamber integrity: " + String(player.health)
	$LevelLabel.text = "Layer " + String(player.layoutIndex + 1)


func _on_EnemySpawner_allEnemiesDead():
	emit_signal("allEnemiesDead")
