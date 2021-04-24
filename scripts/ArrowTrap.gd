extends Sprite

var arrowScene = preload("res://scenes/Arrow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_ShootInterval_timeout():
	var newArrow = arrowScene.instance()
	var inAccuracy = (randf() - 0.5) * 0.05
	newArrow.position = position
	newArrow.rotation = rotation
	newArrow.add_central_force(Vector2(0, 300).rotated(rotation).rotated(inAccuracy))
	get_parent().add_child(newArrow)
