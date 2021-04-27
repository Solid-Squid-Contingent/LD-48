extends Node2D

export(String, FILE) var saveFileName = "user://Save.save"

var gameScene = preload("res://scenes/Game.tscn")
var previousPauseState
var game = null

func _ready():
	restartLevel()
	pauseGame()
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		saveProgress()

func pauseGame():
	previousPauseState = get_tree().paused
	game.inMenu = true
	get_tree().paused = true
	$MenuMusicLoopPlayer.playing = true
	$MusicLoopPlayer.playing = false
	print("pausing")
	
func unpauseGame():
	get_tree().paused = previousPauseState
	game.inMenu = false
	$MenuMusicLoopPlayer.playing = false
	$MusicLoopPlayer.playing = true
	print("unpausing")

func quitGame():
	saveProgress()
	get_tree().quit()
	
func restartLevel():
	if game:
		game.queue_free()
	Engine.time_scale = 3
	game = gameScene.instance()
	add_child(game)
	game.inMenu = false

func restartGame():
	saveProgress()
	#warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	get_tree().paused = false


func saveProgress():
	$"MenuScreenLayer/OptionsScreen".save_options()

func _on_MenuScreen_restart_game():
	restartGame()

func _on_MenuScreen_restart_level():
	restartLevel()

func _on_StartMenuScreen_quit_game():
	quitGame()

func _on_MenuScreen_quit_game():
	quitGame()

func _on_MenuScreen_pause():
	pauseGame()

func _on_MenuScreen_unpause():
	unpauseGame()

func _on_StartMenuScreen_start_game():
	unpauseGame()

func _on_Game_restartGame():
	restartLevel()

func _on_DeathScreen_pause():
	pauseGame()

func _on_DeathScreen_unpause():
	unpauseGame()

func _on_DeathScreen_quit_game():
	quitGame()

func _on_DeathScreen_restart_game():
	restartGame()
