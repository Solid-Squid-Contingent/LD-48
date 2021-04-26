extends TileMap

var placedItems = {}

func positionInMap(pos):
	return world_to_map(to_local(pos))
	
func cellAtPosition(pos):
	return get_cellv(positionInMap(pos))
	
func addItem(item):
	var posInMap = positionInMap(item.global_position)
	placedItems[posInMap] = item
	if item.wallSnap():
		placedItems[posInMap + Vector2.UP.rotated(item.rotation)] = item
	item.connect("tree_exiting", self, "removeItem", [item])

func removeItem(item):
	var posInMap = positionInMap(item.global_position)
	placedItems.erase(posInMap)
	if item.wallSnap():
		placedItems.erase(posInMap + Vector2.UP.rotated(item.rotation))

func freeItemAt(pos):
	var index = positionInMap(pos)
	if placedItems.has(index) and positionInMap(placedItems[index].global_position) == index:
		placedItems[index].queue_free()

func isItemAtPos(pos):
	return isItemAtIndex(positionInMap(pos))
	
func isItemAtIndex(index):
	return placedItems.has(index)
