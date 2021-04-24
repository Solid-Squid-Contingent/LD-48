extends KinematicBody2D

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


func _ready():
	layout = get_tree().get_nodes_in_group('Layout')[0]

func connectTrap(node):
	connectOrigin.connectToTrap(node)

func isInConnectMode():
	return mode == MODES.CONNECTING_TRAPS

func changeToConnectModeFrom(node):
	connectOrigin = node
	mode = MODES.CONNECTING_TRAPS
	print(mode)

func changeToDefaultMode():
	mode = MODES.DEFAULT
	print(mode)

func positionInMap(pos):
	return layout.world_to_map(layout.to_local(pos))

func _input(event):
	if event.is_action_pressed("build"):
		var target = get_global_mouse_position()
		
		if (target - global_position).length() < INTERACT_RANGE and money >= 10:
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

func _physics_process(_delta):
	get_input()
	look_at(position + velocity)
	velocity = move_and_slide(velocity)
