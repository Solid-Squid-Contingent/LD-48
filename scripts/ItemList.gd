extends ItemList

var selectableScenesProgression = [
	[
		preload("res://scenes/Spikes.tscn"),
		preload("res://scenes/ArrowTrap.tscn"),
		preload("res://scenes/PressurePlate.tscn"),
		preload("res://scenes/Lamp.tscn"),
	],[
		preload("res://scenes/ToggleWall.tscn"),
		preload("res://scenes/Spikes.tscn"),
		preload("res://scenes/ArrowTrap.tscn"),
		preload("res://scenes/FireTrap.tscn"),
		preload("res://scenes/PressurePlate.tscn"),
		preload("res://scenes/Lamp.tscn"),
	],[
		preload("res://scenes/ToggleWall.tscn"),
		preload("res://scenes/Spikes.tscn"),
		preload("res://scenes/ArrowTrap.tscn"),
		preload("res://scenes/FireTrap.tscn"),
		preload("res://scenes/Goo.tscn"),
		preload("res://scenes/PressurePlate.tscn"),
		preload("res://scenes/Lamp.tscn"),
	],[
		preload("res://scenes/ToggleWall.tscn"),
		preload("res://scenes/Spikes.tscn"),
		preload("res://scenes/CrocodilePit.tscn"),
		preload("res://scenes/ArrowTrap.tscn"),
		preload("res://scenes/FireTrap.tscn"),
		preload("res://scenes/Goo.tscn"),
		preload("res://scenes/PressurePlate.tscn"),
		preload("res://scenes/Lamp.tscn"),
	],
]

var progress = 0
var selectableScenes = selectableScenesProgression[progress]

onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	updateList()

func updateList():
	clear()
	var i = 1
	for scene in selectableScenes:
		var newItem = scene.instance()
		add_item("(" + String(i) + ") " + String(newItem.getPrice()) + "$", newItem.getIcon())
		newItem.free()
		i += 1
	
	add_item("(0) 0$", preload("res://resources/graphics/misc/Remove.png"))

func _on_ItemList_item_selected(index):
	if player.currentItemIndex == index:
		player.setCurrentItem(null, -1)
	elif index == selectableScenes.size():
		player.toggleRemoveMode()
	else:
		player.setCurrentItem(selectableScenes[index].instance(), index)
	unselect_all()

func _on_ItemList_nothing_selected():
	player.setCurrentItem(null, -1)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode >= KEY_1 and event.scancode <= KEY_9:
			var index = event.scancode - KEY_1
			if index >= selectableScenes.size() or player.currentItemIndex == index:
				player.setCurrentItem(null, -1)
			else:
				player.setCurrentItem(selectableScenes[index].instance(), index)
		elif event.scancode == KEY_0:
			player.toggleRemoveMode()

func _on_UI_allEnemiesDead():
	progress += 1
	if progress < selectableScenesProgression.size():
		selectableScenes = selectableScenesProgression[progress]
		updateList()
