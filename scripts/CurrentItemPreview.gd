extends Sprite

onready var player = get_tree().get_nodes_in_group("Player")[0]

const previewOffset = Vector2(10, 5)

const minSnapDistance = 5

func _ready():
	pass # Replace with function body.

func closestWallSnapPosition():
	return Vector2(0,0)
	
func closestFloorSnapPosition():
	var currentLayout = player.layout
	var mousePositionInLevel = currentLayout.get_global_mouse_position()
	var positionInMap = currentLayout.world_to_map(currentLayout.to_local(mousePositionInLevel))
	var typeOfTile = currentLayout.get_cellv(positionInMap)
	if typeOfTile == 1: #is floor
		var whack = positionInMap * Vector2(50, 50) + Vector2(25,25)
		return whack
	else: 
		return get_global_mouse_position() + previewOffset
	
func _process(delta):
	var currentItem = player.getCurrentItem()
	if currentItem:
		show()
		texture = currentItem.getIcon()
		position = closestFloorSnapPosition()
	else:
		hide()
