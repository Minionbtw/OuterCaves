extends Node

# === Global Variables ===
# Arrays to store skills and modifiers
var skills: Array = []
var modificators: Array = []

# Game State Variables
var current_stage: int = 1
var is_in_main: bool = true
var touch_index: int
var joystick_pressed: bool = false
var pause: bool = false
var game_over: bool = false
var player_health: int = 100
var damage_enabled: bool = true
var checkpoint_activated: bool = false
var checkpoint_used: bool = false
var level_seed: int
var current_seed: int
var checkpoint_position

# Environmental and Gameplay Variables
var altar_pos
var relict_pos
var planet_tileset: int = 1
var planet: int = 2
var bg_color 
var show_player_state: bool = false
var item_selected: bool = false
var player_dead: bool = false
var door

# Modifier Limit
var maxModifier: int = 5

# Display Options
var hp_hidden: bool = false
var lvl_hidden: bool = false

# Ability Flags
var magnet_enabled: bool = false
var shield_enabled: bool = false
var double_jump_enabled: bool = false
var collectedItem: String

# Timer for game start delay
var start_timer: Timer = Timer.new()
var start: bool = false
var start_timer_started: bool = false

# Player and Game State
var player
var changedWorld: bool = false
var music_changed: bool = false

# Positions for undestroyable objects
var undestroyable_pos_1: Vector2 = Vector2()
var undestroyable_pos_2: Vector2 = Vector2()

# Areas related to purchasing or checkpoints
var buyAreas = []

# Statistics and Currency
var collected_coins: int = 0
var total_distance_traveled: float = 0.0
var enemies_killed: int = 0

# === Functions ===

# Called when the node enters the scene
func _ready():
	# Initialize and start the start timer
	add_child(start_timer)
	start_timer.set_one_shot(true)
	start_timer.connect("timeout", self, "_on_start_timer_timeout")
	start_timer.start(1.5)
		
# Handles input events
func _input(event):
	if event is InputEventScreenTouch:
		if joystick_pressed:
			touch_index = event.index

# Called when a button is pressed
func button_pressed():
	joystick_pressed = true

# Updates the player's health by reducing it with a given damage value
func update_player_health(value: int):
	if modificators.has("shield") and damage_enabled:
		# Disable shield if player is shielded
		shield_enabled = false
		modificators.remove(modificators.find("shield"))
	elif damage_enabled:
		# Reduce health but not below zero
		player_health = max(0, player_health - value)

# Called every frame, updates game states
func _process(delta):
	if is_in_main: 
		# Reset game states when in the main scene
		current_stage = 1
		checkpoint_activated = false
		checkpoint_used = false
		checkpoint_position = null
		if not music_changed:
			# Set volume and mute state for music and sound effects
			AudioServer.set_bus_volume_db(1, linear2db(Settings.getSetting("music")))
			AudioServer.set_bus_mute(1, Settings.getSetting("music") < 0.01)
			AudioServer.set_bus_volume_db(2, linear2db(Settings.getSetting("sfx")))
			AudioServer.set_bus_mute(2, Settings.getSetting("sfx") < 0.01)
			music_changed = true

# Resets the checkpoint states
func reset_checkpoint():
	checkpoint_activated = false
	checkpoint_used = false
	checkpoint_position = null

# Resets relic-related positions
func reset_relict():
	altar_pos = null
	relict_pos = null
	
# Resets player abilities
func reset_abilities():
	magnet_enabled = false
	double_jump_enabled = false
	if player_health > 0:
		# Remove all modifiers except shield
		for i in range(modificators.size() - 1, -1, -1):
			if modificators[i] != "shield":
				modificators.remove(i)
	if is_in_main:
		modificators.clear()
		shield_enabled = false

# Increases the player's health, capped to the maximum
func increase_player_health(value: int):
	var max_health = Playerdata.getStat("health")
	player_health = min(player_health + value, max_health)

# Called when the start timer ends
func _on_start_timer_timeout():
	start = false

# Sets the background color based on the index and type
func set_bg_color(index, type):
	door = index
	if type == 1:
		match index:
			0: bg_color = load("res://environment/backgrounds/shadow_bg.png")
			1: bg_color = load("res://environment/backgrounds/bg_0.png")
			2: bg_color = load("res://environment/backgrounds/bg_2.png")
			3: bg_color = load("res://environment/backgrounds/bg_1.png")
			4: bg_color = load("res://environment/backgrounds/bg_4.png")
			5: bg_color = load("res://environment/backgrounds/bg_5.png")
			6: bg_color = load("res://environment/backgrounds/bg_6.png")
			7: bg_color = load("res://environment/backgrounds/bg_6.png")
	elif type == 2:
		match index:
			0: "res://environment/backgrounds/stage11/lava_bg.png"

# Returns the current background color
func get_bg_color():
	return bg_color
	
# Starts the game start timer
func start_timer():
	start_timer.start(1.5)
	
# Sets the main scene state
func set_main_scene(_value: bool):
	is_in_main = _value
	
# Returns the current state of the main scene
func return_main_state():
	return is_in_main
	
# Returns the current level seed
func return_level_seed():
	return level_seed
	
# Resets the level seed to zero
func reset_level_seed():
	level_seed = 0

# Sets the current seed for the level
func set_current_seed(_seed: int):
	current_seed = _seed

# Gets the state of a particular ability
func get_ability_state(_string: String):
	match _string:
		"magnet":
			return magnet_enabled
		"medkit":
			return player_health >= Playerdata.getStat("health")
		"double_jump":
			return double_jump_enabled
		_:
			return false
	
# Adds the collected coins to the player data
func add_collected_coins():
	Playerdata.increaseCoins(collected_coins)

# Resets the collected coins count
func reset_collected_coins():
	collected_coins = 0
	
# Decreases the collected coins count by a value
func decrease_collected_coins(value: int):
	collected_coins -= value
	
# Gets the current collected coins count
func get_collected_coins() -> int:
	return collected_coins
	
# Sets the collected item name
func set_collected_item(item: String):
	collectedItem = item
	
# Gets the name of the collected item
func get_collected_item() -> String:
	return collectedItem

# Adds to the count of enemies killed
func add_killed_enemy():
	enemies_killed += 1

# Resets all game statistics
func reset_statistics():
	total_distance_traveled = 0.0
	enemies_killed = 0

# Handles game over state
func game_over():
	reset_abilities()
	game_over = true
	if player_health > 0:
		add_collected_coins()
	reset_statistics()
	reset_collected_coins()
	is_in_main = true
	player_health = Playerdata.getStat("health")
	get_tree().change_scene("res://environment/main/mainScene.tscn")
