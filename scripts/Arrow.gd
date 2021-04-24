extends RigidBody2D 

func collideWith(body):
	if !is_queued_for_deletion():
		body.collideWithArrow()
		queue_free()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func _on_Arrow_body_entered(body):
	if body is TileMap:
		if $Stuck.is_stopped():
			sleeping = true
			set_deferred("mode", MODE_STATIC)
			$CollisionShape2D.set_deferred("disabled", true)
			$Stuck.start()
	else:
		collideWith(body)


func _on_Stuck_timeout():
	queue_free()
