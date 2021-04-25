extends Reference
class_name TreeNode
	
var children = []
var parent: WeakRef
var tileIndex: Vector2
var completed = false

func _init(tileIndex_, parent_):
	tileIndex = tileIndex_
	parent = weakref(parent_)

func duplicate(dupParent = null):
	var dup = get_script().new(tileIndex, dupParent)
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
