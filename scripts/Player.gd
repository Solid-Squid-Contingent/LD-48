extends KinematicBody2D
class_name Player

var pharaohImage = preload("res://resources/graphics/player/player.png")
var buildingImage = preload("res://resources/graphics/player/buildingPharaoh.png")

var layout: TileMap
var level: Node
var layoutIndex: int
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

var waveScreen


const lampScene = preload("res://scenes/Lamp.tscn")
const pressurePlateScene = preload("res://scenes/PressurePlate.tscn")
const arrowTrapScene = preload("res://scenes/ArrowTrap.tscn")
const spikesScene = preload("res://scenes/Spikes.tscn")
var currentItem = null
var canPlaceCurrentItem = true


func _ready():
	updateLayout()
	waveScreen = get_tree().get_nodes_in_group('WaveScreen')[0]

func updateLayout():
	var i = 0
	for l in get_tree().get_nodes_in_group('Layout'):
		if l.visible:
			layout = l
			layoutIndex = i
			level = get_tree().get_nodes_in_group('PyramidLevel')[layoutIndex]
			break
		i += 1

func connectTrap(node):
	connectOrigin.connectToTrap(node)
	changeToDefaultMode()

func isInConnectMode():
	return mode == MODES.CONNECTING_TRAPS

func changeToConnectModeFrom(node):
	connectOrigin = node
	mode = MODES.CONNECTING_TRAPS
	$Sprite.texture = buildingImage

func changeToDefaultMode():
	mode = MODES.DEFAULT
	$Sprite.texture = pharaohImage

func positionInMap(pos):
	return layout.world_to_map(layout.to_local(pos))
	
func _input(event):
	if event.is_action_pressed("build"):
		var target = get_global_mouse_position()
		
		if canPlaceCurrentItem:
			placeItem(currentItem, target)
	elif event is InputEventKey and event.pressed:
		if event.scancode == KEY_Q:
			var levels = get_tree().get_nodes_in_group('PyramidLevel')
			
			level.visible = false
			layout.occluder_light_mask = 0
			
			layoutIndex = (layoutIndex + 1) % levels.size()
			layout = get_tree().get_nodes_in_group('Layout')[layoutIndex]
			level = levels[layoutIndex]
			level.visible = true
			layout.occluder_light_mask = 1

func placeItem(item, target):
	if item == null:
		return
	if money >= 10:
		var index = positionInMap(target)
		if layout.get_cellv(index) == 1:
			money -= 10
			currentItem = null
			level.add_child(item)

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
	
func _process(_delta):
	var inWallSnapped = layout.get_cellv(positionInMap(global_position.snapped(Vector2.ONE))) == 0
	var inWallUnsnapped = layout.get_cellv(positionInMap(global_position)) == 0
	var inWall = inWallSnapped or inWallUnsnapped
	$Light.visible = !inWall
	$WallLight.visible = inWall		

func _physics_process(_delta):
	get_input()
	look_at(position + velocity)
	velocity = move_and_slide(velocity)
	if position.x < 0 or position.x > 1920 or position.y < 0 or position.y > 1080:
		waveScreen.show()
		position.x = clamp(position.x, 0, 1920)
		position.y = clamp(position.y, 0, 1080)

func setCurrentItem(item):
	if currentItem:
		currentItem.free()
	currentItem = item

func getCurrentItem():
	return currentItem
