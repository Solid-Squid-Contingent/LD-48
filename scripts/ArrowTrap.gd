extends Sprite

var arrowScene = preload("res://scenes/Arrow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_ShootInterval_timeout():
	var newArrow = arrowScene.instance()
	newArrow.position = position
	newArrow.add_central_force(Vector2(0, -10).rotated(rotation))
	get_parent().add_child(newArrow)
