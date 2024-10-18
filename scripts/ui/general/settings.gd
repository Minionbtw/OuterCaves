extends ScrollContainer

## Constants for Difficulty Levels ##
const EASY_VALUE = 1.0
const MEDIUM_VALUE = 2.0
const HARD_VALUE = 3.0

var crystalspawnrate

onready var musicSlider = get_node("VBoxContainer/AudioVBox/GridContainer/musicSlider")
onready var sfxSlider = get_node("VBoxContainer/AudioVBox/GridContainer/sfxSlider")

onready var dmgSlider = get_node("VBoxContainer/DifficultyVBox/DamageHBox/dmgSlider")
onready var hpSlider = get_node("VBoxContainer/DifficultyVBox/HealthHBox/hpSlider")
onready var speedSlider = get_node("VBoxContainer/DifficultyVBox/SpeedHBox/speedSlider")
onready var atkspeedSlider = get_node("VBoxContainer/DifficultyVBox/AttackSpeedHBox/AttackSpeedSlider")
onready var spawnrateSlider = get_node("VBoxContainer/DifficultyVBox/SpawnrateHBox/SpawnrateSlider")
onready var reset = get_node("VBoxContainer/DifficultyVBox/ResetValues")

func _ready():
	if Global.is_in_main:
		hpSlider.editable = true
		dmgSlider.editable = true
		speedSlider.editable = true
		atkspeedSlider.editable = true
		spawnrateSlider.editable = true
		reset.disabled = false
	else:
		hpSlider.editable = false
		dmgSlider.editable = false
		speedSlider.editable = false
		atkspeedSlider.editable = false
		spawnrateSlider.editable = false
		reset.disabled = true
		
	initDifficulty()
	initAudio()
	
func initAudio():
	musicSlider.value = Settings.getSetting("music")
	sfxSlider.value = Settings.getSetting("sfx")
	
	AudioServer.set_bus_volume_db(1, linear2db(musicSlider.value))
	AudioServer.set_bus_mute(1, musicSlider.value < 0.01)
	
	AudioServer.set_bus_volume_db(2, linear2db(sfxSlider.value))
	AudioServer.set_bus_mute(2, sfxSlider.value < 0.01)
	
## Initialize Difficulty ##
func initDifficulty():
	hpSlider.value = Settings.getSetting("health")
			
	match Settings.getSetting("damage"):
		"easy":
			dmgSlider.value = EASY_VALUE
		"medium":
			dmgSlider.value = MEDIUM_VALUE
		"hard":
			dmgSlider.value = HARD_VALUE
		_:
			dmgSlider.value = MEDIUM_VALUE 
			
	speedSlider.value = Settings.getSetting("speed")
	atkspeedSlider.value = Settings.getSetting("attackspeed")
	spawnrateSlider.value = Settings.getSetting("spawnrate")
	adjustSpawnrateCrystal()
	changeSpawnrate()
	
func _on_hpSlider_value_changed(value):
	Settings.changeSetting("health", value)
	adjustSpawnrateCrystal()
	changeSpawnrate()

func _on_dmgSlider_value_changed(value):
	match value:
		EASY_VALUE:
			Settings.changeSetting("damage", "easy")
		MEDIUM_VALUE:
			Settings.changeSetting("damage", "medium")
		HARD_VALUE:
			Settings.changeSetting("damage", "hard")
		_:
			pass
	adjustSpawnrateCrystal()
	changeSpawnrate()

func _on_speedSlider_value_changed(value):
	Settings.changeSetting("speed", value)
	adjustSpawnrateCrystal()
	changeSpawnrate()


func _on_AttackSpeedSlider_value_changed(value):
	Settings.changeSetting("attackspeed", value)
	adjustSpawnrateCrystal()
	changeSpawnrate()


func _on_SpawnrateSlider_value_changed(value):
	Settings.changeSetting("spawnrate", value)
	adjustSpawnrateCrystal()
	changeSpawnrate()


func _on_ResetValues_pressed():
	hpSlider.value = 1
	Settings.changeSetting("health", hpSlider.value)
	dmgSlider.value = 2
	Settings.changeSetting("damage", dmgSlider.value)
	speedSlider.value = 1
	Settings.changeSetting("speed", speedSlider.value)
	atkspeedSlider.value = 1
	Settings.changeSetting("attackspeed", atkspeedSlider.value)
	spawnrateSlider.value = 0.8
	Settings.changeSetting("spawnrate", spawnrateSlider.value)

func _on_musicSlider_value_changed(value):
	Settings.changeSetting("music", value)
	AudioServer.set_bus_volume_db(1, linear2db(value))
	AudioServer.set_bus_mute(1, value < 0.01)


func _on_sfxSlider_value_changed(value):
	Settings.changeSetting("sfx", value)
	AudioServer.set_bus_volume_db(2, linear2db(value))
	AudioServer.set_bus_mute(2, value < 0.01)
	
func adjustSpawnrateCrystal():
	var hp = hpSlider.value
	var dmg = dmgSlider.value
	var speed = speedSlider.value
	var attackspeed = atkspeedSlider.value
	var spawnrate = spawnrateSlider.value
	
	# Berechnung des Gesamtwerts
	var value = (hp + dmg + speed + (2 - attackspeed) + spawnrate)
	
	# Bestimmen der crystalspawnrate basierend auf dem Gesamtwert
	if value == 2.8:
		return 0.5
	elif value >= 3 and value < 4:
		return 0.6
	elif value >= 4 and value < 5:
		return 0.7
	elif value >= 5 and value < 6.5:
		return 0.8
	elif value >= 6.5 and value < 7.8:
		return 1
	elif value == 7.8:
		return 1.5
	else:
		return 0.4

func changeSpawnrate():
	# Setze den berechneten Wert in den Text
	$VBoxContainer/DifficultyVBox/Crystals/CrystalsValue.text = str(adjustSpawnrateCrystal())
	Settings.changeSetting("crystalSpawnrate", adjustSpawnrateCrystal())
