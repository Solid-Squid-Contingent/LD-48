extends TextureRect

signal done

func setSprite(name):
	$Sprite.texture = load("res://resources/graphics/enemies/" + name)
	$Sprite.region_rect.size = $Sprite.texture.get_size() / 2
	
func setText(text):
	$NameLabel.text = text[0]
	$QuoteLabel.text = "\"" + text[1] + "\""
	$InfoLabel.text = text[2]

func show():
	$MinimumShowTime.start()
	get_tree().paused = true
	visible = true

func _input(event):
	if visible and event is InputEventKey and event.pressed and !event.echo and \
		$MinimumShowTime.is_stopped() and !get_tree().get_nodes_in_group("Game")[0].inMenu:
		get_tree().paused = false
		visible = false
		emit_signal("done")
