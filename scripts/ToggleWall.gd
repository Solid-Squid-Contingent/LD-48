extends Node2D

const icon = preload("res://resources/graphics/walls/wall.png")

var layout
	
func _ready():
	get_tree().get_nodes_in_group("AudioManager")[0].playWallSfx(global_position)
	
	for l in get_tree().get_nodes_in_group('Layout'):
		if l.get_parent().visible:
			layout = l
			break
	
	var index = layout.positionInMap(global_position)
	layout.set_cellv(index, 1 - layout.get_cellv(index))
	layout.update_bitmask_area(index)
	
	queue_free()

static func getIcon():
	return icon

static func wallSnap():
	return false
	
static func everywhereSnap():
	return true

static func getPrice():
	return 10
