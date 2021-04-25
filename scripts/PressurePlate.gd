extends Area2D

var bodiesOnPlate = 0

var notPressedImage = preload("res://resources/graphics/traps/pressurePlate.png")
var pressedImage = preload("res://resources/graphics/traps/pressurePlatePressed.png")
onready var wireScene = preload("res://scenes/Wire.tscn")

var player

var connectedTraps = []
var wires = []

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]


func activateTraps():
	for trap in connectedTraps:
		trap.activate()
	
func connectToTrap(node):
	connectedTraps.append(node)

func _on_PressurePlate_body_entered(_body):
	if bodiesOnPlate == 0:
		$Sprite.texture = pressedImage
		activateTraps()
	bodiesOnPlate += 1

func _on_PressurePlate_body_exited(_body):
	bodiesOnPlate -= 1
	if bodiesOnPlate == 0:
		$Sprite.texture = notPressedImage


func _on_PressurePlate_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed('interact'):
		var target = get_global_mouse_position()
		if (target - player.global_position).length() < player.INTERACT_RANGE:
			player.changeToConnectModeFrom(self)

func _on_PressurePlate_mouse_entered():
	for connection in connectedTraps:
		var newWire = wireScene.instance()
		newWire.points[1] = to_local(connection.getWireConnectionPoint().global_position)
		wires.append(newWire)
		add_child(newWire)

func _on_PressurePlate_mouse_exited():
	for i in range(wires.size()):
		wires[i].queue_free()
	wires = []
