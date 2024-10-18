extends Control

func _ready():
	pass

func load_button_positions():
	for child in get_children():
		if child is Control:
			child.rect_position = Settings.getSetting(child.name)
			#print(child.rect_position)
	
