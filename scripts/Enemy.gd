extends KinematicBody2D
class_name Enemy

onready var treasureRayCast = $TreasureRayCast
var treasurePosition
var player

var layout: TileMap
var cellSize: Vector2

var nextWaypoint: Vector2 = Vector2(-1,-1)

var currentTreeNode : TreeNode = null
var rootTreeNode : TreeNode = null
var explored = {}

var dynamiteScene = preload("res://scenes/Dynamite.tscn")

var individualStats = [Stats.new()]
var groupStats: Stats = Stats.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	layout = get_tree().get_nodes_in_group('Layout')[0]
	player = get_tree().get_nodes_in_group('Player')[0]
	treasurePosition = get_tree().get_nodes_in_group('Treasure')[0].global_position
	cellSize = layout.cell_size
	updateGroupStats()

func collideWithSpikes():
	changeHealth(-100, Stats.DamageTypes.NORMAL)
	print('oh snap!')
	
func collideWithArrow():
	changeHealth(-100, Stats.DamageTypes.NORMAL)
	print('arrowed!')

func die():
	queue_free()

func changeHealth(amount: int, damageType):
	groupStats.changeHealth(amount, damageType, individualStats)	
	if groupStats.health <= 0:
		die()
	updateRendering()
	
func changeBravery(amount: int):
	groupStats.changeBravery(amount, individualStats)
	if groupStats.bravery <= 0:
		nextWaypoint = getNextWaypoint()
			
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
	groupStats.update(individualStats)
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
		if groupStats.bravery <= 0:
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
	$BraveryProgress.max_value = groupStats.maxBravery
	$BraveryProgress.value = groupStats.bravery
	$HealthProgress.max_value = groupStats.maxHealth
	$HealthProgress.value = groupStats.health

func _physics_process(delta):
	if (nextWaypoint-position).length() < 5 or nextWaypoint.x < 0:
		nextWaypoint = getNextWaypoint()
	
	if groupStats.demolition:
		demolish(delta)
	
	var dir = nextWaypoint-position
	# warning-ignore:return_value_discarded
	move_and_slide(dir.normalized() * min(groupStats.getActualSpeed(), dir.length() / delta))
	for collisionIndex in range(get_slide_count()):
		var collision = get_slide_collision(collisionIndex)
		if collision.collider.has_method("collideWith"):
			collision.collider.collideWith(self)


var mergeable = false
func _on_MergeArea_area_entered(area):
	var enemy = area.get_parent()
	if mergeable and enemy.mergeable and \
		groupStats.bravery > 0 and enemy.groupStats.bravery > 0 and \
		!is_queued_for_deletion():
			
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
			changeBravery(-50)
