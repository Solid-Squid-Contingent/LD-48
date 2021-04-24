extends KinematicBody2D

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

export var drunkPathfinding: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	layout = get_tree().get_nodes_in_group('Layout')[0]
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

func getMoveableDirections():
	var adjacentCells = getAdjacentCells()
	var moveableDirections = []
	for cell in adjacentCells:
		if cell[0] == 1:
			moveableDirections.append(cell[1])
	
	return moveableDirections

func directionToWaypoint(direction: Vector2):
	return centeredWorldPosition(positionInMap() + direction)

func getRandomAdjacentWaypoint():
	var moveableDirections = getMoveableDirections()
	if moveableDirections.empty():
		return position
	return directionToWaypoint(moveableDirections[randi() % moveableDirections.size()])
	
func getNextWaypoint():
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
				return getRandomAdjacentWaypoint()
		else:
			currentTreeNode = currentTreeNode.children[0]
			
		return centeredWorldPosition(currentTreeNode.tileIndex)
			
	
func _physics_process(_delta):
	if (nextWaypoint-position).length() < 5 or nextWaypoint.x < 0:
		nextWaypoint = getNextWaypoint()
	
	move_and_slide((nextWaypoint-position).normalized() * 200)
