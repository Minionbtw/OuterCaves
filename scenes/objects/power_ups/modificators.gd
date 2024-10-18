extends HBoxContainer

var magnet = ("res://ui/consumable_icons/magnet_icon.png")
var energy_drink = ("res://ui/consumable_icons/energy_icon.png")
var double_jump = ("res://ui/consumable_icons/double_jump_icon.png")
var shield = ("res://ui/consumable_icons/shield_icon.png")

var energy_counter = 0
var previous_size := Global.modificators.size()

func _ready():
	show_loot()

# warning-ignore:unused_argument
func _process(delta):
	if Global.modificators.size() != previous_size:
		previous_size = Global.modificators.size()
		show_loot()

func show_loot():
	# Lösche alle vorhandenen Texturen
	clear_items()

	if !Global.modificators.empty():
		for i in range(Global.modificators.size()):
			var item_name = Global.modificators[i]
			var texture = load_texture_for_item(item_name)
			set_item_for_position(texture, i + 1)

func clear_items():
	$item1.texture = null
	$item2.texture = null
	$item3.texture = null
	$item4.texture = null
	$item5.texture = null

func set_item_for_position(texture, position):
	match position:
		1:
			$item1.texture = texture
		2:
			$item2.texture = texture
		3:
			$item3.texture = texture
		4:
			$item4.texture = texture
		5:
			$item5.texture = texture
		_:
			print("Invalid position.")

func load_texture_for_item(item_name):
	match item_name:
		"energy_drink":
			return load(energy_drink)
		"double_jump":
			return load(double_jump)
		"magnet":
			return load(magnet)
		"shield":
			return load(shield)
		_:
			print("Unknown item:", item_name)
			return null

