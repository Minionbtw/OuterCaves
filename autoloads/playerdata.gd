extends Node

const save_path = "user://Playerdata.save"
const increase_value = 1


var selected_skin : String = "default"
var selected_particle : String = "default"
var selected_ability : String
var player_stats : Dictionary = {
	"health": 100,
	"damage": 100,
	"critical_damage": 20,
	"critical_damage_chance": 0.2,
	"coins": 0,
}

var unlocked_skins : Array = ["default"]
var unlocked_particles : Array = ["default"]
var unlocked_abilities : Array = []


func _ready():
	load_player_data()
	#print(selected_ability)
	
	
func get_coins():
	return player_stats["coins"]
	
func checkSkinUnlocked(skin: String):
	return unlocked_skins.has(skin)
	
func set_skin_unlocked(skin: String):
	if !unlocked_skins.has(skin):
		unlocked_skins.append(skin)
		save_player_data()
	else:
		print_debug("Skin not found.")
		
func add_unlocked_ability(ability : String):
	if !unlocked_abilities.has(ability):
		unlocked_abilities.append(ability)
		save_player_data()
	else:
		return false
		
func check_ability_unlocked(ability : String):
	return unlocked_abilities.has(ability)

func add_unlocked_particle(particle : String):
	if !unlocked_particles.has(particle):
		unlocked_particles.append(particle)
		save_player_data()
	else:
		return false
		
func check_particle_unlocked(particle : String):
	return unlocked_particles.has(particle)
	
func set_stat(stat: String, value: int):
	if OS.is_debug_build():
		player_stats[stat] = value
		save_player_data()

func get_stat(stat: String) -> int:
	return player_stats.get(stat, 0)

# Add this method to increase the Splinter
func increase_coins(value : int):
	if get_coins() < 100000000:
		player_stats["coins"] += value
		save_player_data()
		
func decrease_coins(value : int):
	if get_coins() >= 0:
		player_stats["coins"] -= value
		save_player_data()
		
func change_selected_skin(skin: String):
	selected_skin = skin
	save_player_data()
	
func change_selected_particle(particle : String):
	selected_particle = particle
	save_player_data()
	
func change_selected_ability(ability : String):
	selected_ability = ability
	save_player_data()
	
	
# Save player data to a JSON file
# Load player data at game start
func load_player_data():
	var file = File.new()

	if file.open(save_path, File.READ) == OK:
		var save_string = file.get_as_text()
		var save_data = parse_json(save_string)

		selected_skin = save_data.get("selected_skin", selected_skin)
		selected_particle = save_data.get("selected_particle", selected_particle)
		selected_ability = save_data.get("selected_ability", selected_ability)
		for stat in player_stats.keys():
			player_stats[stat] = save_data.get("player_stats", {}).get(stat, player_stats[stat])
		unlocked_skins = save_data.get("unlocked_skins", unlocked_skins)
		unlocked_particles = save_data.get("unlocked_particles", unlocked_particles)
		unlocked_abilities = save_data.get("unlocked_abilities", unlocked_abilities)
		file.close()
	else:
		print("No saved player data found.")

# Save player data to a JSON file
func save_player_data():
	var save_data = {
		"selected_skin": selected_skin,
		"selected_particle": selected_particle,
		"selected_ability": selected_ability,
		"player_stats": player_stats,
		"unlocked_skins": unlocked_skins,
		"unlocked_abilities": unlocked_abilities,
		"unlocked_particles": unlocked_particles
	}

	var save_string = JSON.print(save_data)

	var file = File.new()
	if file.open(save_path, File.WRITE) == OK:
		file.store_string(save_string)
		file.close()

		#print("Player data saved.")
	else:
		print("Error saving player data.")
