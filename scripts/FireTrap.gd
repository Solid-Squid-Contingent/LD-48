extends "res://scripts/ArrowTrap.gd"

const fireIcon = preload("res://resources/graphics/traps/fireTrap.png")

onready var particles = [$FireParticles, $FireParticles2, $FireParticles3,
						$FireParticles4, $FireParticles5, $FireParticles6]
	

static func getIcon():
	return fireIcon

func shoot():
	for particle in particles:
		particle.emitting = true
	$FireArea/CollisionShape2D.set_deferred("disabled", false)
	$FireTimer.start()

func _on_FireTimer_timeout():
	$FireArea/CollisionShape2D.disabled = true
