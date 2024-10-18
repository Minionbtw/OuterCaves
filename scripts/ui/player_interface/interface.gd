extends Control

signal buttonsLoadable
# Preload scenes
var onCooldown: bool = false
var onDuration: bool = false
var debug_menu = preload("res://debugging/debug_menu.tscn")
var pause_menu = preload("res://debugging/settings/Settings.tscn")
var customizationUI = preload("res://ui/gui/customization/UI.tscn")

# Variables for revive UI
var revive_ui = null
var revive_ui_opened: bool

# Node references
onready var global = get_node("/root/Global")
onready var enter_cave = $positionlayer/enter_buttons/enter_cave
onready var return_home = $positionlayer/enter_buttons/return_home
onready var spaceship = $positionlayer/enter_buttons/spaceship
onready var buy = $positionlayer/enter_buttons/buy

# Button nodes
onready var skillButton = $positionlayer/control_buttons/skill/skill
onready var itemButton = $positionlayer/control_buttons/item

# Timers and status flags
onready var skillDurationTimer = skillButton.get_node("skillDuration")

# Audio
onready var pauseButtonAudio = $positionlayer/top_elements_right/pause/AudioStreamPlayer

# Active skill
onready var skill = skillManager.activeSkill

func _ready():
	var control_buttons = get_node("positionlayer/control_buttons")
	connect("buttonsLoadable", control_buttons, "load_button_positions")
	if Settings.firstTime:
		for child in control_buttons.get_children():
			if child is Control:
				Settings.settingsDict[child.name] = child.rect_position
				Settings.defaults[child.name] = child.rect_position
		Settings.firstTime = false
		Settings.savePlayerSettings()
	emit_signal("buttonsLoadable")

	$positionlayer.show()
	enter_cave.hide()
	return_home.hide()
	spaceship.hide()
	buy.hide()
	
	loadSkillButtons() # Load skill button settings
	skillButton.get_node("TextureProgress").value = 0 # Reset skill progress bar
	yield(get_tree().create_timer(1), "timeout") # Small delay before setting process mode
	#print("Time: " + str((skillButton.get_node("skillCooldown").time_left / skill.cooldownTime) * 100))
	set_process(false) # Disable processing initially

func _process(delta):
	# Update skill progress bar during cooldown
	if skillManager.activeSkill != null:
		#print_debug(skillButton.get_node("TextureProgress").value)
		if onCooldown:
			skillButton.get_node("TextureProgress").value = int(
				(skillButton.get_node("skillCooldown").time_left / skill.cooldownTime) * 100
			)
		if onDuration:
			skillButton.get_node("TextureProgress").value = int(
				((skill.duration - skillDurationTimer.time_left) / skill.duration) * 100
			)

func loadSkillButtons():
	# Setup skill buttons based on the active skill
	skill = skillManager.activeSkill
	if skillManager.activeSkill != null:
		if playerData.checkAbilityUnlocked(skillManager.activeSkillName):
			# Configure skill button textures and actions
			skillButton.normal = skill.button_normal_texture
			skillButton.pressed = skill.button_pressed_texture
			if !Global.is_in_main:
				skillButton.action = skill.action
			skillButton.get_node("TextureProgress").texture_progress = skill.button_normal_texture
			skillButton.get_node("skillDuration").wait_time = skill.duration
			skillButton.get_node("skillCooldown").wait_time = skill.cooldownTime
			#print_debug("Skill Duration: " + str(skill.duration))
			#print_debug("Skill Cooldown: " + str(skill.cooldownTime))

	# Reset gadget button
	itemButton.normal = null
	itemButton.pressed = null
	itemButton.action = "test"

func _on_pause_pressed():
	# Handle pause button press
	pauseButtonAudio.play()
	open_pause_menu()
	get_tree().paused = true

func open_debug_menu():
	# Open the debug menu
	var debug_instance = debug_menu.instance()
	get_parent().add_child(debug_instance)

func open_pause_menu():
	# Open the pause menu
	var pause_instance = pause_menu.instance()
	get_parent().add_child(pause_instance)

func _on_spaceship_pressed():
	# Open the customization UI when the spaceship button is pressed
	var custUiInstance = customizationUI.instance()
	get_parent().add_child(custUiInstance)
	get_tree().paused = true

func _on_skill_pressed():
	# Handle skill button press
	if skillManager.activeSkill != null:
		# Start the skill duration timer if no cooldown is active
		if !skillButton.get_node("skillDuration").time_left > 0 && !skillButton.get_node("TextureProgress").value > 0:
			skillButton.get_node("skillDuration").start(skill.duration)
			skillButton.pressed = skill.button_pressed_texture
			skillButton.normal = skill.button_pressed_texture
			skillButton.get_node("TextureProgress").value = 100
			skillButton.get_node("TextureProgress").fill_mode = 4 # Clockwise
			skillButton.get_node("TextureProgress").tint_progress = Color("3f3f3f")
			skillButton.action = ""
			set_process(true)
			onDuration = true
			onCooldown = false

func _on_skillDuration_timeout():
	# Handle the end of skill duration, starting the cooldown timer
	skillButton.get_node("skillCooldown").start(skill.cooldownTime)
	skillButton.get_node("TextureProgress").value = 100
	skillButton.get_node("TextureProgress").fill_mode = 5 # Counter Clockwise
	onDuration = false
	onCooldown = true
	#print_debug("Cooldown Start")
	set_process(true) # Enable processing to update progress bar

func _on_skillCooldown_timeout():
	# Handle the end of the cooldown period
	#print_debug("Cooldown Over")
	skillButton.action = skill.action
	skillButton.normal = skill.button_normal_texture
	skillButton.pressed = skill.button_pressed_texture
	skillButton.get_node("TextureProgress").value = 0
	onCooldown = false
	set_process(false) # Disable processing after cooldown

func _on_gadget_pressed():
	# Placeholder for gadget button functionality
	pass # Replace with function body

func on_ability_interrupt():
	#print("interrupted")
	skillButton.get_node("skillDuration").stop()
	skillButton.get_node("TextureProgress").value = 100
	skillButton.get_node("TextureProgress").fill_mode = 5 # Counter Clockwise
	onDuration = false
	onCooldown = true
	# Handle the end of skill duration, starting the cooldown timer
	skillButton.get_node("skillCooldown").start(skill.cooldownTime)
	#print_debug("Cooldown Start")
	set_process(true) # Enable processing to update progress bar


#880
#450



