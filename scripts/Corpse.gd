extends Node2D

var fading = false

func _ready():
	$Particles2D.emitting = true


func setTexture(texture: Texture):
	$Sprite.texture = texture

func _on_FadeStartTimer_timeout():
	fading = true
	
func _process(delta):
	if fading:
		modulate.a -= delta
		if modulate.a <= 0:
			queue_free()
