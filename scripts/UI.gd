extends Control

var player : Player

func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]


func _process(_delta):
	$MoneyLabel.text = String(player.money)
	$HealthLabel.text = String(player.health)
