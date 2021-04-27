extends Node2D

func playWallSfx(global_pos):
	$WallPlayer.global_position = global_pos
	$WallPlayer.play()

func playBombSfx(global_pos):
	$BombPlayer.global_position = global_pos
	$BombPlayer.play()
	
func playPlaceTrapSfx(global_pos):
	$PlaceTrapPlayer.global_position = global_pos
	$PlaceTrapPlayer.play()
