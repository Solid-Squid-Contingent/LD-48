extends Area2D

var arrowScene = preload("res://scenes/Arrow.tscn")

const icon = preload("res://resources/graphics/traps/arrowTrap.png")

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]
	
func activate():
	if $ShootInterval.is_stopped():
		$ShootInterval.start()
		var newArrow = arrowScene.instance()
		var inAccuracy = (randf() - 0.5) * 0.05
		newArrow.position = position
		newArrow.rotation = rotation
		newArrow.add_central_force(Vector2(0, 300).rotated(rotation).rotated(inAccuracy))
		get_parent().call_deferred("add_child", newArrow)
	else:
		print("tschhrkkk (Cooldown!)")

func getWireConnectionPoint():
	return $WireConnectionPoint


func _on_ArrowTrap_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('interact'):
		var target = get_global_mouse_position()
		if (target - global_position).length() < 100 and \
				(target - player.global_position).length() < player.INTERACT_RANGE:
					if player.isInConnectMode():
						player.connectTrap(self)
					else: 
						activate()

static func getIcon():
	return icon
