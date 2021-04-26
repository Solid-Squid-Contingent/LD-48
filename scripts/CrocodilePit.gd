extends Area2D

const icon2 = preload("res://resources/graphics/traps/crocodiles.png")
const icon0 = preload("res://resources/graphics/traps/crocodiles_none_left.png")

const crocodileMunchTime = 5

var amountOfCrocodiles = 2

func _on_Spikes_body_entered(body):
	if $Crocodile1.is_stopped():
		$Crocodile1.start()
		amountOfCrocodiles -= 2
		body.collideWithCrocodiles()
		$EatPlayer.play()
	showAmountOfCrocodiles()
		
static func getIcon():
	return icon2

static func wallSnap():
	return false
	
static func getPrice():
	return 50

func showAmountOfCrocodiles():
	match amountOfCrocodiles:
		0:
			$Sprite.texture = icon0
		2:
			$Sprite.texture = icon2

func _on_Crocodile1_timeout():
	amountOfCrocodiles += 2
	showAmountOfCrocodiles()
