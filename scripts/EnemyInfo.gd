extends TextureRect

signal done

func setSprite(name):
	$Sprite.texture = load("res://resources/graphics/enemies/" + name)
	
func setText(text):
	$NameLabel.text = text[0]
	$QuoteLabel.text = "\"" + text[1] + "\""
	$InfoLabel.text = text[2]

func show():
	get_tree().paused = true
	visible = true

func _input(event):
	if visible and event is InputEventKey and event.pressed and !event.echo:
		get_tree().paused = false
		visible = false
		emit_signal("done")
