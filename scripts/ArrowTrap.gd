extends Sprite

var arrowScene = preload("res://scenes/Arrow.tscn")

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]

func activate():
	var newArrow = arrowScene.instance()
	var inAccuracy = (randf() - 0.5) * 0.05
	newArrow.position = position
	newArrow.rotation = rotation
	newArrow.add_central_force(Vector2(0, 300).rotated(rotation).rotated(inAccuracy))
	get_parent().add_child(newArrow)

func _input(event):
	if event.is_action_pressed('interact'):
		print("arrowTrap was clicked")
		var target = get_global_mouse_position()
		if (target - global_position).length() < 100 and \
			(target - player.global_position).length() < player.INTERACT_RANGE:
				if player.isInConnectMode():
					player.connectTrap(self)
