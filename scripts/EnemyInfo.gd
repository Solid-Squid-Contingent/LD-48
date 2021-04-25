extends TextureRect

signal done

func setSprite(name):
	$Sprite.texture = load("res://resources/graphics/enemies/" + name)
	
func setText(text):
	$QuoteLabel.text = text[0]
	$InfoLabel.text = text[1]

func show():
	get_tree().paused = true
	visible = true

func _input(event):
	if visible and event is InputEventKey and event.pressed and !event.echo:
		get_tree().paused = false
		visible = false
		emit_signal("done")
