extends Reference
class_name Stats

var drunkPathfinding: bool
var demolition: bool
var speed: int
var maxHealth: int
var health: int
var maxBravery: int
var bravery: int
var texturePath: String
	
func _init(drunkPathfinding_ = false,
	demolition_ = false,
	speed_ = 100,
	maxHealth_ = 100,
	maxBravery_ = 100,
	texturePath_ = "evilBellPepper.png"):
		
	drunkPathfinding = drunkPathfinding_
	demolition = demolition_
	speed = speed_
	maxHealth = maxHealth_
	health = maxHealth
	maxBravery = maxBravery_
	bravery = maxBravery
	texturePath = texturePath_

func duplicate():
	var s = get_script().new(drunkPathfinding, demolition, speed, maxHealth, maxBravery, texturePath)
	s.health = health
	return s

func update(individualStats):
	drunkPathfinding = true
	demolition = false
	speed = 0
	maxHealth = 0
	health = 0
	maxBravery = 0
	bravery = 0
	texturePath = individualStats[0].texturePath
	
	for stat in individualStats:
		if !stat.drunkPathfinding:
			drunkPathfinding = false
		if stat.demolition:
			demolition = true
		speed += stat.speed
		maxHealth += stat.maxHealth
		health += stat.health
		maxBravery += stat.maxBravery
		bravery += stat.bravery
		if stat.texturePath != texturePath:
			texturePath = "mixedBellPepper.png"
	
	speed /= individualStats.size()
