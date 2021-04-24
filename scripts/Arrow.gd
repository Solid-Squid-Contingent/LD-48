extends RigidBody2D 

func collideWith(body): 
	body.collideWithArrow()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func _on_Arrow_body_entered(body):
	if $Stuck.is_stopped():
		sleeping = true
		mode = MODE_STATIC
		contact_monitor = false
		$CollisionShape2D.disabled = true
		$Stuck.start()


func _on_Stuck_timeout():
	print("i am free")
	queue_free()
