extends Sprite

onready var player = get_tree().get_nodes_in_group("Player")[0]

const previewOffset = Vector2(0,0) # Vector2(10, 5)

const minSnapDistance = 5

func _ready():
	pass # Replace with function body.

func wallSnapRotation():
	return Vector2(0,0)
	
func setClosestFloorSnapPosition(wallSnap, everywhereSnap):
	player.canPlaceCurrentItem = true
	
	var currentLayout = player.layout
	var mousePos= get_global_mouse_position()
	var positionInMap = currentLayout.positionInMap(mousePos)
	var typeOfTile = currentLayout.get_cellv(positionInMap)
	if (typeOfTile == 1 or everywhereSnap) and \
		(currentLayout.canPlaceWallAtPos(mousePos) or !everywhereSnap) and \
		not currentLayout.isItemAtPos(mousePos): #is floor
		
		if (mousePos - player.global_position).length() < player.INTERACT_RANGE:
			modulate = Color.green
		else:
			modulate = Color.yellow
			modulate.a = 0.5
			player.canPlaceCurrentItem = false
		
		var cellPosition = currentLayout.map_to_world(positionInMap)
		var cellSize = currentLayout.cell_size
		
		if wallSnap:
			var offset = mousePos - cellPosition
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
		scale = currentItem.get_node("Sprite").scale
		rotation = 0
		var everywhereSnap = false
		if currentItem.has_method("everywhereSnap"):
			everywhereSnap = currentItem.everywhereSnap()
		setClosestFloorSnapPosition(currentItem.wallSnap(), everywhereSnap)
		currentItem.position = position
		currentItem.rotation = rotation
		checkMoneyIndicator()
	elif player.mode == player.MODES.REMOVING:
		show()
		texture = preload("res://resources/graphics/misc/Remove.png")
		position = get_global_mouse_position()
		modulate = Color.white
		modulate.a = 0.5
		$NoMoneyIndicator.visible = false
	else:
		hide()


func checkMoneyIndicator():
	$NoMoneyIndicator.visible = player.money < player.getCurrentItem().getPrice()
