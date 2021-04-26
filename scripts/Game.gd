extends Node2D

var inMenu = true
var tutorialProgress = 0

onready var textbox = get_tree().get_nodes_in_group("Textbox")[0]
onready var enemySpawner = get_tree().get_nodes_in_group("EnemySpawner")[0]
onready var player = get_tree().get_nodes_in_group("Player")[0]
	
const tutorial = [
	"""Curses, these pesky mortals are at it again. How dare they disturb ye, oh mighty pharaoh?
Float around using WASD and investigate outside of your pyramid.""",
	["WaveScreen", "done"],
	
	"""Look at them lining up to steal your riches. Or, should you say, like lambs to the slaughter?
Click the spikes on the right side of the screen (or press 1) and then place them next to the entrance by floating nearby and clicking again.""",
	["Player", "placedSpikes"],
	
	"""Hahahaha, this will show them not to mess with the gods above. Or with you, for that matter.
Right-click the countdown on the entrance to the pyramid to make enemies appear immediately and watch them DIE.""",
	["Spikes", "bodyExitedSpikes"],
	["Spikes", "bodyExitedSpikes"],
	0.5,
	
	"""What? One of them survived the spikes of DESTRUCTION?! Such an action shall not be tolerated!
Right click the enemy when floating nearby to scare them.""",
	["Enemy", "enemyDied"],
	0.5,
	
	"""Ha! The spikes of DESTRUCTION strike yet again! But maybe they need some support after all, purely emotional support of course.
Place an arrow trap (2) at the end of the first straight hallway and call the next enemies.""",
	["EnemySpawner", "spawnedWave"],
	
	"""Right-click the arrow trap to fire it.""",
	["ArrowTrap", "fired"],
	1.0,
	
	"""That trap might have been effective but your time is too precious to waste on performing lowly tasks like manually shooting arrows.
Place a pressure plate (3) and connect it by first right-clicking it and then the arrow trap.""",
	["Player", "connectedTrap"],
	
	"""Oh, technology. A most trusty minion. SOON IT SHALL REPLACE MANKIND. At least, you hope so.
Place more traps to defeat the rest of these pesky humans. You can remove traps by clicking them again but you will not get your money back.""",
	["EnemySpawner", "allEnemiesDead"],
	1.0,
	
	"""Ahh. Free at last. You used the time to move your treasure deeper into your buried pyramid.
Press Q to switch between levels.""",
	["Player", "switchedLevel"],
	0.5,
	
	"""The footsteps grow louder. They are approaching again. There is no time to move the treasure any deeper right now.
Enemies will still enter on the upper level of the pyramid but they will try to reach the second level via the stairs.""",
	
	"""You can now place and remove walls. When adding walls, you have to make sure that all floor tiles that were previously reachable are still reachable.""",

]

func _ready():
	unlockNewPyramidLayer()
	enemySpawner.begin()
	player.begin()
	doTutorial()

func doTutorial():
	while tutorialProgress < tutorial.size():
		var currentStep = tutorial[tutorialProgress]
		if currentStep is String:
			textbox.setText(currentStep)
			textbox.show()
		elif currentStep is float:
			yield(get_tree().create_timer(currentStep), "timeout")
		else:
			var nodes = get_tree().get_nodes_in_group(currentStep[0])
			if nodes.empty():
				break
			yield(nodes[0], currentStep[1])
		tutorialProgress += 1
	
	enemySpawner.showEnemyInfos = true

func unlockNewPyramidLayer():
	var potentialNextLevels = get_tree().get_nodes_in_group("PotentialPyramidLevel")
	if potentialNextLevels.size() > 0:
		var nextLevel : Node2D = potentialNextLevels[0]
		nextLevel.remove_from_group("PotentialPyramidLevel")
		nextLevel.add_to_group("PyramidLevel")
		nextLevel.get_node("Layout").add_to_group("Layout")
		nextLevel.get_node("TreasureChamber").add_to_group("Treasure")
		
		get_tree().call_group("Treasure", "updateTexture")
	else: 
		print("no more layers")
		
func _on_EnemySpawner_allEnemiesDead():
	unlockNewPyramidLayer()
