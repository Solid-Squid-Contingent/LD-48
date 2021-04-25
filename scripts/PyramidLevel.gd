extends Node2D

const USED_COLLISION_LAYERS = 4

export var levelIndex = 0

func _ready():
	for child in get_children():
		correctCollisionLayers(child)

func correctCollisionLayers(node: Node):
	if levelIndex == 0:
		return
		
	for child in node.get_children():
		correctCollisionLayers(child)
	
	if "collision_layer" in node:
		for i in range(USED_COLLISION_LAYERS):
			node.set_collision_layer_bit(USED_COLLISION_LAYERS * levelIndex + i, 
				node.get_collision_layer_bit(i))
			node.set_collision_layer_bit(i, false)
			
	if "collision_mask" in node:
		for i in range(USED_COLLISION_LAYERS):
			node.set_collision_mask_bit(USED_COLLISION_LAYERS * levelIndex + i, 
				node.get_collision_mask_bit(i))
			node.set_collision_mask_bit(i, false)
		


func add_child(node: Node, legible_unique_name: bool = false):
	.add_child(node, legible_unique_name)
	correctCollisionLayers(node)
