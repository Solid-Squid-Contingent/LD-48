extends Sprite

var layout: TileMap
var player

const INTERACT_RANGE = 50

func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]
	
func _input(event):
	if event.is_action_pressed("interact"):
		var target = get_global_mouse_position()
		if (target - global_position).length() < INTERACT_RANGE and \
			(target - player.global_position).length() < player.INTERACT_RANGE:
			queue_free()

func _on_Timer_timeout():
	var index = layout.positionInMap(global_position)
	layout.set_cellv(index, 1)
	layout.update_bitmask_area(index)
	get_tree().get_nodes_in_group("AudioManager")[0].playBombSfx(global_position)
	queue_free()
