extends Sprite

var layout = null
var layoutIndex

const stairDownTexture = preload("res://resources/graphics/misc/stairsDown.png")
const chestTexture = preload("res://resources/graphics/misc/Chest.png")

const stairsUpScene = preload("res://scenes/StairsUp.tscn")

var pairedStair = null

func updateTexture():
	if !layout:
		var i = 0
		for l in get_tree().get_nodes_in_group("Layout"):
			if l.get_parent() == get_parent():
				layoutIndex = i
				layout = l
				break
			i += 1
			
		layout.addItem(self)
		
	if layoutIndex == get_tree().get_nodes_in_group("Layout").size() - 1:
		texture = chestTexture
	else:
		texture = stairDownTexture
		if !pairedStair:
			pairedStair = stairsUpScene.instance()
			pairedStair.position = position
			get_tree().get_nodes_in_group("PyramidLevel")[layoutIndex+1].add_child(pairedStair)
			get_tree().get_nodes_in_group("Layout")[layoutIndex+1].addItem(pairedStair)

func unremoveable():
	return true
