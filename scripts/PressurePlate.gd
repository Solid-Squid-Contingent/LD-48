extends Area2D

var bodiesOnPlate = 0

const notPressedImage = preload("res://resources/graphics/traps/pressurePlate.png")
var pressedImage = preload("res://resources/graphics/traps/pressurePlatePressed.png")
onready var wireScene = preload("res://scenes/Wire.tscn")

var player

var connectedTraps = []
var wires = []
var currentWire = null

func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]
	
	#im sorry junber
	for layout in get_tree().get_nodes_in_group('Layout'):
		if layout.visible:
			layout.connect("itemRemoved", self, "_on_itemRemoved")
			break



func activateTraps():
	for trap in connectedTraps:
		if trap:
			trap.activate()
	
func connectToTrap(node):
	connectedTraps.append(node)

func _on_PressurePlate_body_entered(_body):
	if bodiesOnPlate == 0:
		$Sprite.texture = pressedImage
		$TriggerPlayer.play()
		activateTraps()
	bodiesOnPlate += 1

func _on_PressurePlate_body_exited(_body):
	bodiesOnPlate -= 1
	if bodiesOnPlate == 0:
		$Sprite.texture = notPressedImage


func _on_PressurePlate_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed('interact'):
		if player.connectOrigin == self:
			player.changeToDefaultMode()
		else:
			var target = get_global_mouse_position()
			if (target - player.global_position).length() < player.INTERACT_RANGE:
				player.changeToConnectModeFrom(self)
				currentWire = wireScene.instance()
				add_child(currentWire)

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

static func getIcon():
	return notPressedImage
	
static func wallSnap():
	return false
	
func _on_itemRemoved(item):
	var pos = connectedTraps.find(item)
	if pos != -1:
		connectedTraps.remove(pos)
	

func _process(_delta):
	if currentWire:
		if player.connectOrigin != self:
			currentWire.queue_free()
			currentWire = null
		else:
			currentWire.points[1] = get_local_mouse_position()
			
static func getPrice():
	return 10
