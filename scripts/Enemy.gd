extends KinematicBody2D
class_name Enemy

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
onready var enemyScene = load("res://scenes/Enemy.tscn")

class Stats:
	var drunkPathfinding: bool = false
	var demolition: bool = true
	var speed: int = 200
	var maxHealth: int = 100
	var health: int = maxHealth

var individualStats = [Stats.new(), Stats.new(), Stats.new(), Stats.new(), Stats.new(), Stats.new(), Stats.new()]
var groupStats = Stats.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	layout = get_tree().get_nodes_in_group('Layout')[0]
	player = get_tree().get_nodes_in_group('Player')[0]
	treasurePosition = get_tree().get_nodes_in_group('Treasure')[0].global_position
	cellSize = layout.cell_size
	updateGroupStats()

func collideWithSpikes():
	changeHealth(-100)
	print('oh snap!')
	
func collideWithArrow():
	changeHealth(-100)
	print('arrowed!')

func die():
	queue_free()

func changeHealth(amount: int):
	groupStats.health += amount
	if groupStats.health <= 0:
		die()
		return
	
	while amount <= 0:
		var hitIndividualIndex = randi() % individualStats.size()
		var previousHealth = individualStats[hitIndividualIndex].health
		individualStats[hitIndividualIndex].health += amount
		amount += previousHealth
		if individualStats[hitIndividualIndex].health <= 0:
			individualStats.remove(hitIndividualIndex)
	

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

func updateGroupStats():
	groupStats.drunkPathfinding = true
	groupStats.demolition = false
	groupStats.speed = 0
	groupStats.maxHealth = 0
	groupStats.health = 0
	
	for stat in individualStats:
		if !stat.drunkPathfinding:
			groupStats.drunkPathfinding = false
		if stat.demolition:
			groupStats.demolition = true
		groupStats.speed += stat.speed
		groupStats.maxHealth += stat.maxHealth
		groupStats.health += stat.health
	
	groupStats.speed /= individualStats.size()

func seperateGroup(stats, i):
	var enemy : Enemy = enemyScene.instance()
	enemy.explored = explored.duplicate()
	enemy.individualStats = stats
	enemy.updateGroupStats()
	var enemyTreeRoot = TreeNode.new(currentTreeNode.tileIndex, null)
	enemy.currentTreeNode = TreeNode.new(currentTreeNode.children[i].tileIndex, enemyTreeRoot)
	enemy.position = position
	enemy.nextWaypoint = centeredWorldPosition(enemy.currentTreeNode.tileIndex)
	get_parent().add_child(enemy)
	
func getNextWaypoint():
	if (treasurePosition - global_position).length() < 5:
		player.health -= 10 * individualStats.size()
		queue_free()
	
	treasureRayCast.cast_to = treasurePosition - global_position
	treasureRayCast.force_raycast_update()
	if !treasureRayCast.is_colliding():
		return treasurePosition
	
	if groupStats.drunkPathfinding:
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
				currentTreeNode.parent.children.erase(currentTreeNode)
				currentTreeNode = currentTreeNode.parent
			else:
				resetNavigation()
				return getNextWaypoint()
		elif currentTreeNode.children.size() > 1 and individualStats.size() > 1:
			if currentTreeNode.children.size() >= individualStats.size():
				for i in range(individualStats.size() - 1):
					seperateGroup([individualStats[i]], i)
					
				currentTreeNode = currentTreeNode.children[individualStats.size() - 1]
				
				individualStats = [individualStats[individualStats.size() - 1]]
				updateGroupStats()
			else:
				var enemiesPerPath = individualStats.size() / currentTreeNode.children.size()
				for i in range(currentTreeNode.children.size() - 1):
					seperateGroup(individualStats.slice(i * enemiesPerPath, (i + 1) * enemiesPerPath - 1), i)
					
					
				individualStats = individualStats.slice(
							(currentTreeNode.children.size() - 1) * enemiesPerPath,
							individualStats.size())
							
				currentTreeNode = currentTreeNode.children.back()
				updateGroupStats()
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

func _process(delta):
	$Label.text = String(individualStats.size())

func _physics_process(delta):
	if (nextWaypoint-position).length() < 5 or nextWaypoint.x < 0:
		nextWaypoint = getNextWaypoint()
	
	if groupStats.demolition:
		demolish(delta)
	
	
	move_and_slide((nextWaypoint-position).normalized() * groupStats.speed)
	for collisionIndex in range(get_slide_count()):
		var collision = get_slide_collision(collisionIndex)
		if collision.collider.has_method("collideWith"):
			collision.collider.collideWith(self)
