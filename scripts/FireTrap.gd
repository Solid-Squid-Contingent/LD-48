extends "res://scripts/ArrowTrap.gd"

const fireIcon = preload("res://resources/graphics/traps/fireTrap.png")

onready var particles = [$Particles/FireParticles, $Particles/FireParticles2, $Particles/FireParticles3,
						$Particles/FireParticles4, $Particles/FireParticles5, $Particles/FireParticles6]
	

static func getIcon():
	return fireIcon

func shoot():
	for particle in particles:
		particle.emitting = true
	$FireArea/CollisionShape2D.set_deferred("disabled", false)
	$FireTimer.start()
	$FirePlayer.play()

func _on_FireTimer_timeout():
	$FireArea/CollisionShape2D.disabled = true
	$FirePlayer.stop()
	
static func getPrice():
	return 30


func _on_FireTrap_input_event(viewport, event, shape_idx):
	_on_ArrowTrap_input_event(viewport, event, shape_idx)
