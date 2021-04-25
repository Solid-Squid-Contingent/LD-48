extends TextureRect

signal start_game()
signal quit_game()
signal button_pressed()

# Called when the node enters the scene tree for the first time.
func _ready():
	popup()
	if OS.get_name() == "HTML5":
		$MarginContainer/VBoxContainer/QuitButton.set_disabled(true)

func setButtonFocus():
	$MarginContainer/VBoxContainer/StartButton.grab_focus()

func popup():
	visible = true
	setButtonFocus()

func go_away():
	visible = false

func _on_QuitButton_pressed():
	emit_signal("quit_game")
	emit_signal("button_pressed")

func _on_OptionsButton_pressed():
	$"../OptionsScreen".popup()
	emit_signal("button_pressed")

func _on_StartButton_pressed():
	go_away()
	emit_signal("start_game")
	emit_signal("button_pressed")

func _on_DeleteButton_pressed():
	$"../DeleteScreen".popup()
	emit_signal("button_pressed")

func _on_CreditsButton_pressed():
	$"../CreditsScreen".popup()
	emit_signal("button_pressed")


func _on_OptionsScreen_screenClosed():
	if visible:
		setButtonFocus()

func _on_DeleteScreen_screenClosed():
	if visible:
		setButtonFocus()

func _on_CreditsScreen_screenClosed():
	if visible:
		setButtonFocus()
