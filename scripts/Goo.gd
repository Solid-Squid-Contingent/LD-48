extends Node

const icon = preload("res://resources/graphics/traps/goo.png")

func _ready():
	pass # Replace with function body.

func _on_Goo_body_entered(body):
	body.collideWithGoo()

static func getIcon():
	return icon
	
static func wallSnap():
	return false
