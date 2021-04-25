extends Area2D

const icon = preload("res://resources/graphics/traps/crocodiles.png")

func _on_Spikes_body_entered(body):
	body.collideWithCrocodiles()

static func getIcon():
	return icon

static func wallSnap():
	return false
