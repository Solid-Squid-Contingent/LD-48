extends Area2D

const icon = preload("res://resources/graphics/traps/goo.png")

func _ready():
	get_tree().get_nodes_in_group("AudioManager")[0].playPlaceTrapSfx(global_position)

func _on_Goo_body_entered(body):
	body.collideWithGoo()
	$TriggerPlayer.play()

static func getIcon():
	return icon
	
static func wallSnap():
	return false
	
static func getPrice():
	return 15
