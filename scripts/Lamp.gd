extends Node2D

func getIcon():
	return $Sprite.texture 
	
static func wallSnap():
	return false
	
static func getPrice():
	return 1
