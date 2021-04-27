extends TextureRect

signal done
	
func setText(text):
	$Label.text = text

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
