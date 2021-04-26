extends TileMap

var placedItems = {}

func positionInMap(pos):
	return world_to_map(to_local(pos))
	
func cellAtPosition(pos):
	return get_cellv(positionInMap(pos))
	
func addItem(item):
	var posInMap = positionInMap(item.global_position)
	placedItems[posInMap] = item
	if item.has_method("wallSnap") and item.wallSnap():
		placedItems[posInMap + Vector2.UP.rotated(item.rotation)] = item
	item.connect("tree_exiting", self, "removeItem", [item])

func removeItem(item):
	var posInMap = positionInMap(item.global_position)
	placedItems.erase(posInMap)
	if item.has_method("wallSnap") and item.wallSnap():
		placedItems.erase(posInMap + Vector2.UP.rotated(item.rotation))

func freeItemAt(pos):
	var index = positionInMap(pos)
	if placedItems.has(index) and positionInMap(placedItems[index].global_position) == index:
		if placedItems[index].has_method("unremoveable") and placedItems[index].unremoveable():
			return
		placedItems[index].queue_free()

func isItemAtPos(pos):
	return isItemAtIndex(positionInMap(pos))
	
func isItemAtIndex(index):
	return placedItems.has(index)
	

func pairOfCellAndPosition(index: Vector2, direction: Vector2):
	var typeOfCell = get_cellv(index + direction)
	return [typeOfCell, direction]
	
func getAdjacentCellsIndex(index: Vector2):
	var adjacentCells = []
	
	adjacentCells.append(pairOfCellAndPosition(index, Vector2(1,0)))
	adjacentCells.append(pairOfCellAndPosition(index, Vector2(0,1)))
	adjacentCells.append(pairOfCellAndPosition(index, Vector2(-1,0)))
	adjacentCells.append(pairOfCellAndPosition(index, Vector2(0,-1)))
	return adjacentCells


func getAdjacentCellsWithIdIndex(index: Vector2, tileId: int):
	var adjacentCells = getAdjacentCellsIndex(index)
	var chosenDirections = []
	for cell in adjacentCells:
		if cell[0] == tileId:
			chosenDirections.append(cell[1])
	
	return chosenDirections

func getAdjacentCellsWithIdPos(pos: Vector2, tileId: int):
	return getAdjacentCellsWithIdIndex(positionInMap(pos), tileId)

func canPlaceWallAtPos(pos):
	var index = positionInMap(pos)
	
	if get_cellv(index) == 0:
		return true
		
	var freeAdjacentCells = getAdjacentCellsWithIdIndex(index, 1)
	
	if freeAdjacentCells.size() <= 1:
		return true
		
	var toCheck = [index + freeAdjacentCells[0]]
	var checked = {index: true, index + freeAdjacentCells[0] : true}
	
	while !toCheck.empty():
		var currentCell = toCheck.pop_back()
		var adjacentCells = getAdjacentCellsWithIdIndex(currentCell, 1)
		for dir in adjacentCells:
			if !checked.has(currentCell + dir):
				checked[currentCell + dir] = true
				toCheck.append(currentCell + dir)
	
	for dir in freeAdjacentCells:
		if !checked.has(index + dir):
			return false
	
	return true
