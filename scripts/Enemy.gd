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
	var parent: WeakRef
	var tileIndex: Vector2
	var completed = false
	
	func _init(tileIndex_, parent_):
		tileIndex = tileIndex_
		parent = weakref(parent_)
	
	func duplicate(dupParent = null):
		var dup = TreeNode.new(tileIndex, dupParent)
		dup.completed = completed
		
		for child in children:
			dup.children.append(child.duplicate(dup))
		
		return dup
	
	func find(tileIndexToFind):
		if tileIndex == tileIndexToFind:
			return self
		else:
			for child in children:
				var foundInChild = child.find(tileIndexToFind)
				if foundInChild:
					return foundInChild
			return null

var currentTreeNode : TreeNode = null
var rootTreeNode : TreeNode = null
var explored = {}

var dynamiteScene = preload("res://scenes/Dynamite.tscn")

class Stats:
	extends Reference
	
	var drunkPathfinding: bool
	var demolition: bool
	var speed: int
	var maxHealth: int
	var health: int
	var texturePath: String
		
	func _init(drunkPathfinding_ = false,
		demolition_ = false,
		speed_ = 100,
		maxHealth_ = 100,
		texturePath_ = "evilBellPepper.png"):
			
		drunkPathfinding = drunkPathfinding_
		demolition = demolition_
		speed = speed_
		maxHealth = maxHealth_
		health = maxHealth
		texturePath = texturePath_
	
	func duplicate():
		var s = Stats.new(drunkPathfinding, demolition, speed, maxHealth, texturePath)
		s.health = health
		return s

var individualStats = [Stats.new()]
var groupStats: Stats = Stats.new()

var spooked = false

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
			
	updateRendering()

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
	rootTreeNode = null

func updateGroupStats():
	groupStats.drunkPathfinding = true
	groupStats.demolition = false
	groupStats.speed = 0
	groupStats.maxHealth = 0
	groupStats.health = 0
	groupStats.texturePath = individualStats[0].texturePath
	
	for stat in individualStats:
		if !stat.drunkPathfinding:
			groupStats.drunkPathfinding = false
		if stat.demolition:
			groupStats.demolition = true
		groupStats.speed += stat.speed
		groupStats.maxHealth += stat.maxHealth
		groupStats.health += stat.health
		if stat.texturePath != groupStats.texturePath:
			groupStats.texturePath = "mixedBellPepper.png"
	
	groupStats.speed /= individualStats.size()
	updateRendering()

func seperateGroup(stats, i):
	var enemy = load("res://scenes/Enemy.tscn").instance()
	enemy.explored = explored.duplicate()
	enemy.individualStats = stats
	enemy.updateGroupStats()
	enemy.position = position
	enemy.rootTreeNode = rootTreeNode.duplicate()
	enemy.currentTreeNode = enemy.rootTreeNode.find(currentTreeNode.children[i].tileIndex)
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
		if spooked:
			if currentTreeNode.parent and currentTreeNode.parent.get_ref():
				currentTreeNode = currentTreeNode.parent.get_ref()
				return centeredWorldPosition(currentTreeNode.tileIndex)
			else:
				queue_free()
				return position
				
		var posInMap = positionInMap()
		explored[posInMap] = true
		
		if !currentTreeNode:
			currentTreeNode = TreeNode.new(posInMap, null)
			rootTreeNode = currentTreeNode
		
		if !currentTreeNode.completed:
			var moveableDirections = getMoveableDirections()
			moveableDirections.shuffle()
			
			for direction in moveableDirections:
				if !explored.has(posInMap + direction):
					var newTreeNode = TreeNode.new(posInMap + direction, currentTreeNode)
					currentTreeNode.children.push_back(newTreeNode)
			
			currentTreeNode.completed = true
		
		var curChildIndex = 0
		while curChildIndex < currentTreeNode.children.size():
			if explored.has(currentTreeNode.children[curChildIndex].tileIndex):
				currentTreeNode.children.remove(curChildIndex)
			else:
				curChildIndex += 1
		
		if currentTreeNode.children.empty():
			if currentTreeNode.parent and currentTreeNode.parent.get_ref():
				currentTreeNode.parent.get_ref().children.erase(currentTreeNode)
				currentTreeNode = currentTreeNode.parent.get_ref()
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

func updateRendering():
	$Label.text = String(individualStats.size())
	$Sprite.texture = load("res://resources/graphics/enemies/" + groupStats.texturePath)

func _physics_process(delta):
	if (nextWaypoint-position).length() < 5 or nextWaypoint.x < 0:
		nextWaypoint = getNextWaypoint()
	
	if groupStats.demolition:
		demolish(delta)
	
	# warning-ignore:return_value_discarded
	move_and_slide((nextWaypoint-position).normalized() * groupStats.speed)
	for collisionIndex in range(get_slide_count()):
		var collision = get_slide_collision(collisionIndex)
		if collision.collider.has_method("collideWith"):
			collision.collider.collideWith(self)


var mergeable = false
func _on_MergeArea_area_entered(area):
	var enemy = area.get_parent()
	if mergeable and enemy.mergeable and !is_queued_for_deletion():
		enemy.queue_free()
		for stat in enemy.individualStats:
			individualStats.append(stat)
		updateGroupStats()
		for explore in enemy.explored:
			explored[explore] = true


func _on_MergeArea_area_exited(_area):
	mergeable = true


func _on_Enemy_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed('interact'):
		var target = get_global_mouse_position()
		if (target - player.global_position).length() < player.INTERACT_RANGE:
			for stat in individualStats:
				stat.speed *= 5
			updateGroupStats()
			spooked = true
			nextWaypoint = getNextWaypoint()
