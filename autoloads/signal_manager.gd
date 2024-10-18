extends Node

func _ready():
	yield(get_tree().create_timer(1), "timeout")
	connectSignalsNodes()

func connectSignalsNodes():
		# Get all nodes in the "ability" group
	var ability_nodes = get_tree().get_nodes_in_group("ability")
	
	# Get all nodes in the "target_group"
	var target_nodes = get_tree().get_nodes_in_group("interface")
	
	# Loop through each node in the "ability" group
	for ability_node in ability_nodes:
		# Check if the signal exists in the ability node
		if ability_node.has_signal("interrupt"): # Replace "my_signal" with your actual signal name
			# Loop through each node in the "target_group"
			for target_node in target_nodes:
				# Connect the signal to a method on the target node
				if not ability_node.is_connected("interrupt", target_node, "on_ability_interrupt"): 
					ability_node.connect("interrupt", target_node, "on_ability_interrupt") # Replace with actual method



	yield(get_tree().create_timer(1), "timeout")
	connectSignalsNodes()


func connectControlNodes():
		# Get all nodes in the "ability" group
	var movable_buttons = get_tree().get_nodes_in_group("movable_buttons")
	
	# Get all nodes in the "target_group"
	var target_nodes = get_tree().get_nodes_in_group("controlButtons")
	
	# Loop through each node in the "ability" group
	for movable_button in movable_buttons:
		# Check if the signal exists in the ability node
		if movable_button.has_signal("update_positions"): # Replace "my_signal" with your actual signal name
			# Loop through each node in the "target_group"
			for target_node in target_nodes:
				# Connect the signal to a method on the target node
				if not movable_button.is_connected("update_positions", target_node, "load_button_positions"): 
					movable_button.connect("update_positions", target_node, "load_button_positions") # Replace with actual method

#func connectEditMode():
#	var sources = get_tree().get_nodes_in_group("movable_buttons")
#	var targets = get_tree().get_nodes_in_group("interface")
#	# Loop through each node in the "ability" group
#	for source in sources:
#		# Check if the signal exists in the ability node
#		if sources.has_signal("edit_mode"): # Replace "my_signal" with your actual signal name
#			# Loop through each node in the "target_group"
#			for target in targets:
#				# Connect the signal to a method on the target node
#				if not sources.is_connected("edit_mode", targets, "openEditMenu"): 
#					sources.connect("edit_mode", targets, "openEditMenu") # Replace with actual method
