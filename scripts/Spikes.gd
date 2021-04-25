extends Area2D

const icon = preload("res://resources/graphics/traps/spikes.png")

func _ready():
	pass # Replace with function body.

func _on_Spikes_body_entered(body):
	body.collideWithSpikes()

static func getIcon():
	return icon

static func wallSnap():
	return false
