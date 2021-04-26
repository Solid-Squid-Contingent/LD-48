extends TextureRect

signal done
	
func setText(text):
	$Label.text = text

func show():
	get_tree().paused = true
	visible = true

func _input(event):
	if visible and event is InputEventKey and event.pressed and !event.echo:
		get_tree().paused = false
		visible = false
		emit_signal("done")
