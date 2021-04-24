extends KinematicBody2D
class_name Player

var pharaohImage = preload("res://resources/graphics/player.png")
var buildingImage = preload("res://resources/graphics/buildingPharaoh.png")

var layout: TileMap
export var speed : int = 200

const INTERACT_RANGE = 100

enum MODES{
	DEFAULT,
	CONNECTING_TRAPS
}

var velocity = Vector2()
var money = 100
var health = 100
var mode = MODES.DEFAULT

var connectOrigin


onready var lampScene = preload("res://scenes/Lamp.tscn")
onready var pressurePlateScene = preload("res://scenes/PressurePlate.tscn")
onready var arrowTrapScene = preload("res://scenes/ArrowTrap.tscn")
onready var spikesScene = preload("res://scenes/Spikes.tscn")

onready var placeableItems = [
	["", "placeNothing"],
	["Wall", "toggleWall"],
	["Lamp", lampScene],
	["Pressure Plate", pressurePlateScene],
	["Arrow Trap", arrowTrapScene],
	["Spike Trap", spikesScene],
	["", "placeNothing"],
	["", "placeNothing"],
	["", "placeNothing"],
	["", "placeNothing"]
]

onready var currentItem = placeableItems[0]

func _ready():
	layout = get_tree().get_nodes_in_group('Layout')[0]

func connectTrap(node):
	connectOrigin.connectToTrap(node)
	changeToDefaultMode()

func isInConnectMode():
	return mode == MODES.CONNECTING_TRAPS

func changeToConnectModeFrom(node):
	connectOrigin = node
	mode = MODES.CONNECTING_TRAPS
	$Sprite.texture = buildingImage
	print(mode)

func changeToDefaultMode():
	mode = MODES.DEFAULT
	$Sprite.texture = pharaohImage
	print(mode)

func positionInMap(pos):
	return layout.world_to_map(layout.to_local(pos))
	
func _input(event):
	if event.is_action_pressed("build"):
		var target = get_global_mouse_position()
		
		if (target - global_position).length() < INTERACT_RANGE:
			placeItem(currentItem[1], target)
			# call(currentItem[1], target)
	elif event is InputEventKey and event.pressed:
		if event.scancode >= KEY_0 and event.scancode <= KEY_9:
			currentItem = placeableItems[event.scancode - KEY_0]

func placeItem(item, target):
	if item is String:
		call(item, target)
		return
	if money >= 10:
		var index = positionInMap(target)
		if layout.get_cellv(index) == 1:
			money -= 10
			var newItem = item.instance()
			newItem.position = target
			get_parent().add_child(newItem)

func placeNothing(_target):
	pass
	
func toggleWall(target):
	if money >= 10:
		var index = positionInMap(target)
		money -= 10
		layout.set_cellv(index, 1 - layout.get_cellv(index))

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed
	
func _process(delta):
	var inWallSnapped = layout.get_cellv(positionInMap(global_position.snapped(Vector2.ONE))) == 0
	var inWallUnsnapped = layout.get_cellv(positionInMap(global_position)) == 0
	var inWall = inWallSnapped or inWallUnsnapped
	$Light.visible = !inWall
	$WallLight.visible = inWall

func _physics_process(_delta):
	get_input()
	look_at(position + velocity)
	velocity = move_and_slide(velocity)
