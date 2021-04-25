extends Area2D

func _on_FireArea_body_entered(body):
	body.collideWithFire()


func _on_FireArea_body_exited(body):
	body.stopCollidingWithFire()
