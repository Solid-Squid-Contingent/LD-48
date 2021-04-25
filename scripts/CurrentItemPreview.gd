extends Sprite

onready var player = get_tree().get_nodes_in_group("Player")[0]

const previewOffset = Vector2(0,0) # Vector2(10, 5)

const minSnapDistance = 5

func _ready():
	pass # Replace with function body.

func wallSnapRotation():
	return Vector2(0,0)
	
func setClosestFloorSnapPosition(wallSnap):
	player.canPlaceCurrentItem = true
	
	var currentLayout = player.layout
	var mousePositionInLevel = get_global_mouse_position()
	var positionInMap = currentLayout.world_to_map(currentLayout.to_local(mousePositionInLevel))
	var typeOfTile = currentLayout.get_cellv(positionInMap)
	if typeOfTile == 1: #is floor
		if (mousePositionInLevel - player.global_position).length() < player.INTERACT_RANGE:
			modulate = Color.green
		else:
			modulate = Color.yellow
			modulate.a = 0.5
			player.canPlaceCurrentItem = false
		
		var cellPosition = currentLayout.map_to_world(positionInMap)
		var cellSize = currentLayout.cell_size
		
		if wallSnap:
			var offset = mousePositionInLevel - cellPosition
			if offset.x > offset.y:
				if cellSize.x - offset.x > offset.y:
					rotation = deg2rad(0)
				else:
					rotation = deg2rad(90)
			else:
				if cellSize.x - offset.x > offset.y:
					rotation = deg2rad(270)
				else:
					rotation = deg2rad(180)
			
			if currentLayout.get_cellv(positionInMap + Vector2.UP.rotated(rotation)) == 1: #is floor
				modulate = Color.red
				modulate.a = 0.5
				player.canPlaceCurrentItem = false
			
		position = cellPosition + cellSize / 2
	else: 
		modulate = Color.red
		modulate.a = 0.5
		player.canPlaceCurrentItem = false
		
		position = get_global_mouse_position() + previewOffset
	
func _process(_delta):
	var currentItem = player.getCurrentItem()
	if currentItem:
		show()
		texture = currentItem.getIcon()
		setClosestFloorSnapPosition(currentItem.wallSnap())
		currentItem.position = position
		currentItem.rotation = rotation
	else:
		hide()
