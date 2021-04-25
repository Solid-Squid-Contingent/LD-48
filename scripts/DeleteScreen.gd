extends TextureRect

signal button_pressed()
signal deleteSaveData()
signal screenClosed()


func popup():
	visible = true
	$MarginContainer/VBoxContainer/NoButton.grab_focus()

func _on_YesButton_pressed():
	visible = false
	emit_signal("deleteSaveData")
	emit_signal("screenClosed")
	emit_signal("button_pressed")
	
func _on_NoButton_pressed():
	visible = false
	emit_signal("screenClosed")
	emit_signal("button_pressed")
