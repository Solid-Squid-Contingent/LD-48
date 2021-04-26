extends Reference
class_name Stats

enum DamageTypes {
	NORMAL, FIRE, CROCODILES
}

var drunkPathfinding: bool
var demolition: bool
var speed: int
var maxHealth: int
var health: int
var maxBravery: int
var bravery: int
var moneyDropped:int
var resistances: Dictionary
var texturePath: String
var corpseTexturePath: String
var isSlowed = false
	
func _init(drunkPathfinding_ = false,
	demolition_ = false,
	speed_ = 100,
	maxHealth_ = 100,
	maxBravery_ = 100,
	moneyDropped_ = 1,
	resistances_ = {},
	texturePath_ = "",
	corpseTexturePath_ = ""):
		
	drunkPathfinding = drunkPathfinding_
	demolition = demolition_
	speed = speed_
	maxHealth = maxHealth_
	health = maxHealth
	maxBravery = maxBravery_
	bravery = maxBravery
	moneyDropped = moneyDropped_
	resistances = resistances_
	texturePath = texturePath_
	corpseTexturePath = corpseTexturePath_
	
	for damageType in DamageTypes:
		if !resistances.has(DamageTypes[damageType]):
			resistances[DamageTypes[damageType]] = 0

func duplicate():
	var s = get_script().new(drunkPathfinding, demolition, speed, maxHealth,
		maxBravery, moneyDropped, resistances.duplicate(), texturePath, corpseTexturePath)
		
	s.health = health
	s.bravery = bravery
	return s

func getActualSpeed():
	var speedMultiplier = 1
	if bravery <= 0:
		speedMultiplier *= 5
	if isSlowed:
		speedMultiplier *= 0.25
	return speed * speedMultiplier

func changeHealth(amount: int, damageType, individualStats):
	var deaths = []
	
	while amount <= 0 and !individualStats.empty():
		var hitIndividualIndex = randi() % individualStats.size()
		var stat = individualStats[hitIndividualIndex]
		
		var previousHealth = stat.health
		stat.health += amount * (1.0 - stat.resistances[damageType])
		amount += previousHealth
		if stat.health <= 0:
			deaths.append(stat)
			individualStats.remove(hitIndividualIndex)
	
	update(individualStats)
	
	return deaths

func changeBravery(amount: int, individualStats):
	if bravery <= 0:
		return
		
	var remainingAmount = amount
	for stat in individualStats:
		remainingAmount += stat.bravery
		stat.bravery += amount * stat.bravery / bravery
	
	if remainingAmount < 0:
		for stat in individualStats:
			if stat.bravery > -remainingAmount:
				stat.bravery += remainingAmount
			else:
				remainingAmount += stat.bravery
				stat.bravery = 0
	
	update(individualStats)

func update(individualStats):
	if individualStats.empty():
		return
		
	drunkPathfinding = true
	demolition = false
	speed = 0
	maxHealth = 0
	health = 0
	maxBravery = 0
	bravery = 0
	moneyDropped = 0
	texturePath = individualStats[0].texturePath
	corpseTexturePath = individualStats[0].corpseTexturePath
	
	for damageType in resistances:
		resistances[damageType] = 0
	
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
		moneyDropped += stat.moneyDropped
		
		for damageType in resistances:
			resistances[damageType] += stat.resistances[damageType]
	
	speed /= individualStats.size()
	for damageType in resistances:
		resistances[damageType] /= individualStats.size()
