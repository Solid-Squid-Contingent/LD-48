extends Node

func _ready():
	pass # Replace with function body.

func _on_Goo_body_entered(body):
	body.collideWithGoo()
