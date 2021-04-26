extends Area2D

const icon2 = preload("res://resources/graphics/traps/crocodiles.png")
const icon1 = preload("res://resources/graphics/traps/crocodiles_one_left.png")
const icon0 = preload("res://resources/graphics/traps/crocodiles_none_left.png")

const crocodileMunchTime = 5

var amountOfCrocodiles = 2

func _on_Spikes_body_entered(body):
	if $Crocodile1.is_stopped():
		$Crocodile1.start()
		amountOfCrocodiles -= 1
		body.collideWithCrocodiles()
	elif $Crocodile2.is_stopped():
		$Crocodile2.start()
		amountOfCrocodiles -= 1
		body.collideWithCrocodiles()
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
		1:
			$Sprite.texture = icon1
		2:
			$Sprite.texture = icon2

func _on_Crocodile1_timeout():
	amountOfCrocodiles += 1
	showAmountOfCrocodiles()


func _on_Crocodile2_timeout():
	amountOfCrocodiles += 1
	showAmountOfCrocodiles()
