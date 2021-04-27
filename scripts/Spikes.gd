extends Area2D

signal bodyExitedSpikes

const icon = preload("res://resources/graphics/traps/spikes.png")

func _ready():
	get_tree().get_nodes_in_group("AudioManager")[0].playPlaceTrapSfx(global_position)

func _on_Spikes_body_entered(body):
	body.collideWithSpikes()
	$TriggerPlayer.play()

static func getIcon():
	return icon

static func wallSnap():
	return false
	
static func getPrice():
	return 10
	
static func isSpikes():
	return true

func _on_Spikes_body_exited(_body):
	emit_signal("bodyExitedSpikes")
