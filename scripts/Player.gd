extends KinematicBody2D
class_name Player

signal placedSpikes
signal connectedTrap
signal switchedLevel

var pharaohImage = preload("res://resources/graphics/player/player.png")

var layout: TileMap
var level: Node
var layoutIndex: int
export var speed : int = 1000

const INTERACT_RANGE = 750

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

var topLeftMapCorner
var bottomRightMapCorner


func begin():
	waveScreen = get_tree().get_nodes_in_group('WaveScreen')[0]
	
	var i = 0
	for l in get_tree().get_nodes_in_group('Layout'):
		if l.visible:
			layout = l
			layoutIndex = i
			level = get_tree().get_nodes_in_group('PyramidLevel')[layoutIndex]
			break
		i += 1
	
	updateCameraLimits()

func spook():
	if !$SpookTimer.is_stopped():
		return false
	
	$SpookTimer.start()
	$Sprite.region_rect.position.x += 558 * 2
	return true

func updateCameraLimits():
	var indexRect : Rect2 = layout.get_used_rect()
	topLeftMapCorner = layout.map_to_world(indexRect.position)
	bottomRightMapCorner = layout.map_to_world(indexRect.end)
	$Camera.limit_left = topLeftMapCorner.x
	$Camera.limit_top = topLeftMapCorner.y
	$Camera.limit_right = bottomRightMapCorner.x
	$Camera.limit_bottom = bottomRightMapCorner.y

func connectTrap(node):
	connectOrigin.connectToTrap(node)
	changeToDefaultMode()
	emit_signal("connectedTrap")

func isInConnectMode():
	return mode == MODES.CONNECTING_TRAPS

func changeToConnectModeFrom(node):
	connectOrigin = node
	mode = MODES.CONNECTING_TRAPS

func changeToDefaultMode():
	connectOrigin = null
	mode = MODES.DEFAULT
	
func _input(event):
	if event.is_action_pressed("build"):
		if currentItem == null :
			layout.freeItemAt(get_global_mouse_position())
		elif canPlaceCurrentItem:
			placeItem(currentItem)
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
			
			updateCameraLimits()
			emit_signal("switchedLevel")

func placeItem(item):
	if money >= item.getPrice():
		money -= item.getPrice()
		currentItem = null
		level.add_child(item)
		layout.addItem(item)
		if item.has_method("isSpikes") and item.isSpikes():
			emit_signal("placedSpikes")

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
	
	if velocity.x > 0:
		$Sprite.region_rect.position.x = 558
	elif velocity.x < 0:
		$Sprite.region_rect.position.x = 0
	if velocity.y > 0:
		$Sprite.region_rect.position.y = 0
	elif velocity.y < 0:
		$Sprite.region_rect.position.y = 1022
	
	if velocity.x != 0 and !$SpookTimer.is_stopped():
			$Sprite.region_rect.position.x += 558 * 2
	
	velocity = velocity.normalized() * speed
	
func _process(_delta):
	var inWallFloor = layout.cellAtPosition((global_position - Vector2.ONE).floor()) == 0
	var inWallCeil = layout.cellAtPosition((global_position + Vector2.ONE).ceil()) == 0
	var inWall = inWallFloor or inWallCeil
	$Light.visible = !inWall
	$WallLight.visible = inWall

func _physics_process(_delta):
	get_input()
	velocity = move_and_slide(velocity)
	if position.x < topLeftMapCorner.x or position.y < topLeftMapCorner.y or \
		position.x > bottomRightMapCorner.x or position.y > bottomRightMapCorner.y:
			
		waveScreen.show()
		position.x = clamp(position.x, topLeftMapCorner.x, bottomRightMapCorner.x)
		position.y = clamp(position.y, topLeftMapCorner.y, bottomRightMapCorner.y)

func setCurrentItem(item):
	if currentItem:
		currentItem.free()
	currentItem = item

func getCurrentItem():
	return currentItem


func _on_SpookTimer_timeout():
	$Sprite.region_rect.position.x -= 558 * 2
