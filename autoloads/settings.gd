extends Node

const save_path = "user://playerSettings.save"
var firstTime : bool = true

var settingsDict : Dictionary = {
	# Normal Settings
	"fps" : false,
	# Audio
	"music" : 1,
	"sfx" : 1,
	# Controls
	"jump": Vector2(850, 475),
	"attack": Vector2(700, 475),
	"skill": Vector2(775, 375),
	"item": Vector2(625, 375),
	# Difficulty
	"health" : 1,
	"damage" : "medium",
	"speed" : 1,
	"attackspeed": 1,
	"spawnrate": 0.8,
	"crystalSpawnrate": 0.4,
}

var defaults: Dictionary = {
	"jump": Vector2(850, 475),
	"attack": Vector2(700, 475),
	"skill": Vector2(775, 375),
	"item": Vector2(625, 375),
}

func _ready():
	#print(get_viewport().size)
	loadPlayerSettings()
	AudioServer.set_bus_volume_db(1, linear2db(getSetting("music")))
	AudioServer.set_bus_mute(1, getSetting("music") < 0.01)
	
	AudioServer.set_bus_volume_db(2, linear2db(getSetting("sfx")))
	AudioServer.set_bus_mute(2, getSetting("sfx") < 0.01)


func changeSetting(setting: String, value):
	settingsDict[setting] = value
	savePlayerSettings()

func getSetting(setting: String):
	return settingsDict.get(setting, 0)
	
func loadPlayerSettings():
	var file = File.new()

	if file.open(save_path, File.READ) == OK:
		var save_string = file.get_as_text()
		var save_data = parse_json(save_string)

		# Aktualisiere die Werte in der settingsDict
		for setting in settingsDict.keys():
			var loaded_value = save_data.get("settingsDict", {}).get(setting, settingsDict[setting])
			if typeof(settingsDict[setting]) == TYPE_VECTOR2 and typeof(loaded_value) == TYPE_ARRAY:
				loaded_value = Vector2(loaded_value[0], loaded_value[1])
			settingsDict[setting] = loaded_value

		# Lade die defaults-Werte
		for setting in defaults.keys():
			var loaded_value = save_data.get("defaults", {}).get(setting, defaults[setting])
			if typeof(defaults[setting]) == TYPE_VECTOR2 and typeof(loaded_value) == TYPE_ARRAY:
				loaded_value = Vector2(loaded_value[0], loaded_value[1])
			defaults[setting] = loaded_value

		# Lade den firstTime-Wert
		firstTime = save_data.get("firstTime", true)

		file.close()

		# print("Player data loaded.")
	else:
		print("No saved player data found.")



# Save player data to a JSON file
func savePlayerSettings():
	var save_data = {
		"settingsDict": {},
		"defaults": {},  # Füge das defaults-Dictionary hinzu
		"firstTime": firstTime
	}

	# Konvertiere Vector2-Werte in Arrays zum Speichern für settingsDict
	for setting in settingsDict.keys():
		var value = settingsDict[setting]
		if typeof(value) == TYPE_VECTOR2:
			save_data["settingsDict"][setting] = [value.x, value.y]
		else:
			save_data["settingsDict"][setting] = value

	# Konvertiere Vector2-Werte in Arrays zum Speichern für defaults
	for setting in defaults.keys():
		var value = defaults[setting]
		if typeof(value) == TYPE_VECTOR2:
			save_data["defaults"][setting] = [value.x, value.y]
		else:
			save_data["defaults"][setting] = value

	var save_string = JSON.print(save_data)

	var file = File.new()
	if file.open(save_path, File.WRITE) == OK:
		file.store_string(save_string)
		file.close()

		# print("Player data saved.")
	else:
		print("Error saving player data.")

