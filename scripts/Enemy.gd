extends KinematicBody2D

onready var treasureRayCast = $TreasureRayCast
var treasurePosition
var player

var layout: TileMap
var cellSize: Vector2

var nextWaypoint: Vector2 = Vector2(-1,-1)

class TreeNode:
	extends Reference
	var children = []
	var parent: TreeNode
	var tileIndex: Vector2
	var completed = false
	
	func _init(tileIndex_, parent_):
		tileIndex = tileIndex_
		parent = parent_

var currentTreeNode : TreeNode = null
var explored = {}

var dynamiteScene = preload("res://scenes/Dynamite.tscn")

export var drunkPathfinding: bool = false
export var demolition: bool = true
export var speed: int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	layout = get_tree().get_nodes_in_group('Layout')[0]
	player = get_tree().get_nodes_in_group('Player')[0]
	treasurePosition = get_tree().get_nodes_in_group('Treasure')[0].global_position
	cellSize = layout.cell_size

func positionInMap():
	return layout.world_to_map(layout.to_local(global_position))

func centeredWorldPosition(mapIndex: Vector2):
	return layout.map_to_world(mapIndex) + cellSize * 0.5

func pairOfCellAndPosition(direction: Vector2):
	var typeOfCell = layout.get_cellv(positionInMap() + direction)
	return [typeOfCell, direction]

func getAdjacentCells():
	var adjacentCells = []
	
	adjacentCells.append(pairOfCellAndPosition(Vector2(1,0)))
	adjacentCells.append(pairOfCellAndPosition(Vector2(0,1)))
	adjacentCells.append(pairOfCellAndPosition(Vector2(-1,0)))
	adjacentCells.append(pairOfCellAndPosition(Vector2(0,-1)))
	return adjacentCells

func getMoveableDirections(tileId = 1):
	var adjacentCells = getAdjacentCells()
	var moveableDirections = []
	for cell in adjacentCells:
		if cell[0] == tileId:
			moveableDirections.append(cell[1])
	
	return moveableDirections

func directionToWaypoint(direction: Vector2):
	return centeredWorldPosition(positionInMap() + direction)

func getRandomAdjacentWaypoint():
	var moveableDirections = getMoveableDirections()
	if moveableDirections.empty():
		return position
	return directionToWaypoint(moveableDirections[randi() % moveableDirections.size()])

func resetNavigation():
	currentTreeNode = null
	explored.clear()
	
func getNextWaypoint():
	if (treasurePosition - global_position).length() < 5:
		player.health -= 10
		queue_free()
	
	treasureRayCast.cast_to = treasurePosition - global_position
	treasureRayCast.force_raycast_update()
	if !treasureRayCast.is_colliding():
		return treasurePosition
	
	if drunkPathfinding:
		return getRandomAdjacentWaypoint()
	else:
		var posInMap = positionInMap()
		explored[posInMap] = true
		
		if !currentTreeNode:
			currentTreeNode = TreeNode.new(posInMap, null)
		
		if !currentTreeNode.completed:
			var moveableDirections = getMoveableDirections()
			moveableDirections.shuffle()
			
			for direction in moveableDirections:
				if !explored.has(posInMap + direction):
					var newTreeNode = TreeNode.new(posInMap + direction, currentTreeNode)
					currentTreeNode.children.push_back(newTreeNode)
			
			currentTreeNode.completed = true
		
		while !currentTreeNode.children.empty() and explored.has(currentTreeNode.children[0].tileIndex):
			currentTreeNode.children.remove(0)
		
		if currentTreeNode.children.empty():
			if currentTreeNode.parent:
				currentTreeNode = currentTreeNode.parent
				currentTreeNode.children.remove(0)
			else:
				resetNavigation()
				return getNextWaypoint()
		else:
			currentTreeNode = currentTreeNode.children[0]
		
		if layout.get_cellv(currentTreeNode.tileIndex) != 1:
				resetNavigation()
				return getNextWaypoint()
			
		return centeredWorldPosition(currentTreeNode.tileIndex)

const MAX_DEMOLITION_COOLDOWN = 4.0
var demolitionCooldown = MAX_DEMOLITION_COOLDOWN
func demolish(delta):
	if demolitionCooldown > 0.0:
		demolitionCooldown -= delta
	else:
		var moveableDirections = getMoveableDirections(0)
		if !moveableDirections.empty():
			demolitionCooldown = MAX_DEMOLITION_COOLDOWN
			var demolishPos = positionInMap() + moveableDirections[randi() % moveableDirections.size()]
			
			var dynamite = dynamiteScene.instance()
			dynamite.position = centeredWorldPosition(demolishPos)
			get_parent().add_child(dynamite)
		
	
func _physics_process(delta):
	if (nextWaypoint-position).length() < 5 or nextWaypoint.x < 0:
		nextWaypoint = getNextWaypoint()
	
	if demolition:
		demolish(delta)
	
	move_and_slide((nextWaypoint-position).normalized() * speed)
