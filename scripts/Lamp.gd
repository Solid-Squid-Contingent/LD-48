extends Node2D

var noise = OpenSimplexNoise.new()


var value = 0

func _ready():
	noise.period = 16.0 

func getIcon():
	return $Sprite.texture 
	
static func wallSnap():
	return false
	
static func getPrice():
	return 1

func _physics_process(_delta):
	value += 1
	if value > 10000:
		value = 0
	var alpha = noise.get_noise_1d((value + 1) / 10.0 ) + 0.95
	$Light.color.a = alpha
	
