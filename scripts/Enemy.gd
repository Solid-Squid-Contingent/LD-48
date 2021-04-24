extends KinematicBody2D

var layout: TileMap;
var cellSize: Vector2;

var nextWaypoint: Vector2;

var health = 100;

# Called when the node enters the scene tree for the first time.
func _ready():
	layout = get_tree().get_nodes_in_group('Layout')[0]
	cellSize = layout.cell_size;
	print(layout.get_cell(1,1));
	pass # Replace with function body.

func collideWithSpikes():
	changeHealth(-100)
	print('oh snap!')

func die():
	queue_free()

func changeHealth(amount: int):
	health += amount
	if health <= 0:
		die()
	

func positionInMap():
	return layout.world_to_map(layout.to_local(global_position))

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
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (nextWaypoint-position).length() < 5 || !nextWaypoint:
		var adjacentCells = getAdjacentCells()
		var moveableDirections = []
		for cell in adjacentCells:
			if cell[0] == 1:
				moveableDirections.append(cell[1])
				
		##TODO check if always exists lol hey julian 
		nextWaypoint = layout.map_to_world(moveableDirections[randi() % moveableDirections.size()] + positionInMap()) + cellSize * 0.5
	
	move_and_slide((nextWaypoint-position).normalized() * 30)
	for collisionIndex in range(get_slide_count()):
		var collision = get_slide_collision(collisionIndex)
		collision.collider.collideWith(self)
