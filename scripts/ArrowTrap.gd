extends Area2D

signal fired

var arrowScene = preload("res://scenes/Arrow.tscn")

const icon = preload("res://resources/graphics/traps/arrowTrap.png")

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]
	get_tree().get_nodes_in_group("AudioManager")[0].playPlaceTrapSfx(global_position)

func shoot():
	var newArrow = arrowScene.instance()
	var inAccuracy = (randf() - 0.5) * 0.05
	newArrow.position = position
	newArrow.rotation = rotation
	newArrow.add_central_force(Vector2(0, 1500).rotated(rotation).rotated(inAccuracy))
	get_parent().call_deferred("add_child", newArrow)
	emit_signal("fired")
	$ShootPlayer.play()
	
func activate():
	if $ShootInterval.is_stopped():
		$ShootInterval.start()
		shoot()
	else:
		print("tschhrkkk (Cooldown!)")

func getWireConnectionPoint():
	return $WireConnectionPoint


func _on_ArrowTrap_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed('interact'):
		var target = get_global_mouse_position()
		if (target - player.global_position).length() < player.INTERACT_RANGE:
			if player.isInConnectMode():
				player.connectTrap(self)
				$ConnectPlayer.play()
			else: 
				activate()

static func getIcon():
	return icon
	
static func wallSnap():
	return true
	
static func getPrice():
	return 10
