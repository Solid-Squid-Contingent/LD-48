extends TextureRect

signal pause()
signal unpause()
signal quit_game()
signal restart_game()
signal button_pressed()


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	
	if OS.get_name() == "HTML5":
		$MarginContainer/VBoxContainer/QuitButton.set_disabled(true)

func setButtonFocus():
	$MarginContainer/VBoxContainer/RestartButton.grab_focus()

func popup():
	setButtonFocus()
	visible = true
	emit_signal("pause")

func go_away():
	visible = false
	emit_signal("unpause")

func _on_QuitButton_pressed():
	emit_signal("quit_game")
	emit_signal("button_pressed")

func _on_RestartButton_pressed():
	emit_signal("restart_game")
	emit_signal("button_pressed")

func _on_OptionsScreen_screenClosed():
	if visible:
		setButtonFocus()
