extends ItemList

var selectableScenes = [
	preload("res://scenes/Spikes.tscn"),
	preload("res://scenes/ArrowTrap.tscn"),
	preload("res://scenes/Goo.tscn"),
	preload("res://scenes/PressurePlate.tscn"),
	preload("res://scenes/Lamp.tscn"),
]

onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	for scene in selectableScenes:
		var newItem = scene.instance()
		add_icon_item(newItem.getIcon())
		newItem.free()

func _on_ItemList_item_selected(index):
	player.setCurrentItem(selectableScenes[index].instance())
	unselect_all()

func _on_ItemList_nothing_selected():
	player.setCurrentItem(null)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode >= KEY_1 and event.scancode <= KEY_9:
			player.setCurrentItem(selectableScenes[event.scancode - KEY_1].instance())

