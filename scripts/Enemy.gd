extends KinematicBody2D
class_name Enemy

onready var treasureRayCast = $TreasureRayCast
var treasurePosition
var player

var layout: TileMap
var cellSize: Vector2
var layoutIndex: int

var nextWaypoint: Vector2 = Vector2(-1,-1)

var currentTreeNode : TreeNode = null
var rootTreeNode : TreeNode = null
var explored = {}

const dynamiteScene = preload("res://scenes/Dynamite.tscn")
const corpseScene = preload("res://scenes/Corpse.tscn")

var individualStats = [Stats.new()]
var groupStats: Stats = Stats.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	updateLevel()
	player = get_tree().get_nodes_in_group('Player')[0]
	updateGroupStats()

func updateLevel():
	layout = findInCurrentLevel('Layout', true)
	if layout:
		cellSize = layout.cell_size
		treasurePosition = findInCurrentLevel('Treasure').global_position

func findInCurrentLevel(name, setLayoutIndex = false):
	var i = 0
	for l in get_tree().get_nodes_in_group(name):
		if l.get_parent() == get_parent():
			if setLayoutIndex:
				layoutIndex = i
			return l
		i += 1

func collideWithCrocodiles():
	changeHealth(-200, Stats.DamageTypes.CROCODILES)
	
func collideWithSpikes():
	changeHealth(-50, Stats.DamageTypes.NORMAL)
	
func collideWithArrow():
	changeHealth(-100, Stats.DamageTypes.NORMAL)

func collideWithFire():
	$FireTimer.start()
	
func stopCollidingWithFire():
	$FireTimer.stop()

func collideWithGoo():
	groupStats.isSlowed = true
	$GooTimer.start(5.0)

func die():
	queue_free()

func changeHealth(amount: int, damageType):
	var deaths = groupStats.changeHealth(amount, damageType, individualStats)
	for death in deaths:
		var corpse = corpseScene.instance()
		corpse.setTexture(load("res://resources/graphics/enemies/" + death))
		corpse.position = position
		get_parent().add_child(corpse)
		
	if individualStats.empty():
		die()
	updateRendering()
	
func changeBravery(amount: int):
	groupStats.changeBravery(amount, individualStats)
	if groupStats.bravery <= 0:
		nextWaypoint = getNextWaypoint()
			
	updateRendering()

func positionInMap():
	return layout.positionInMap(global_position)

func centeredWorldPosition(mapIndex: Vector2):
	return layout.map_to_world(mapIndex) + cellSize * 0.5


func directionToWaypoint(direction: Vector2):
	return centeredWorldPosition(positionInMap() + direction)

func getRandomAdjacentWaypoint():
	var moveableDirections = layout.getAdjacentCellsWithIdPos(global_position, 1)
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

func reachedEnd():
	var levels = get_tree().get_nodes_in_group("PyramidLevel")
	if layoutIndex >= levels.size() - 1:
		player.health -= 10 * individualStats.size()
		queue_free()
	else:
		get_parent().remove_child(self)
		levels[layoutIndex + 1].add_child(self)
		updateLevel()
		resetNavigation()
	
func getNextWaypoint():
	if groupStats.bravery <= 0 and !groupStats.drunkPathfinding:
		if currentTreeNode.parent and currentTreeNode.parent.get_ref():
			currentTreeNode = currentTreeNode.parent.get_ref()
			return centeredWorldPosition(currentTreeNode.tileIndex)
		else:
			queue_free()
			return position
				
	if (treasurePosition - global_position).length() < 5:
		reachedEnd()
	
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
			rootTreeNode = currentTreeNode
		
		if !currentTreeNode.completed:
			var moveableDirections = layout.getAdjacentCellsWithIdPos(global_position, 1)
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

const MAX_DEMOLITION_COOLDOWN = 10.0
var demolitionCooldown = MAX_DEMOLITION_COOLDOWN
func demolish(delta):
	if demolitionCooldown > 0.0:
		demolitionCooldown -= delta
	else:
		var moveableDirections = layout.getAdjacentCellsWithIdPos(global_position, 0)
		var possiblePlacements = []
		for d in moveableDirections:
			if !layout.isItemAtIndex(positionInMap() + d):
				possiblePlacements.append(d)
			
		if !possiblePlacements.empty():
			demolitionCooldown = MAX_DEMOLITION_COOLDOWN
			var demolishPos = positionInMap() + possiblePlacements[randi() % possiblePlacements.size()]
			
			var dynamite = dynamiteScene.instance()
			dynamite.position = centeredWorldPosition(demolishPos)
			dynamite.layout = layout
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


func _on_GooTimer_timeout():
	groupStats.isSlowed = false


func _on_FireTimer_timeout():
	changeHealth(-10, Stats.DamageTypes.FIRE)
