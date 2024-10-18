extends Node

var commonChance = 0.5
var rareChance = 0.3
var epicChance = 0.15
var legendaryChance = 0.05


var skin_preview : String = Playerdata.selected_skin
var particlePreview : String = Playerdata.selected_particle

var skins: Dictionary = {
	"default": [load("res://assets/sprites/player/skins/astronaut.png"), "Default Suit", 0, "common"],
	"red": [load("res://assets/sprites/player/skins/astronaut_cyan.png"), "Red Suit", 1500, "rare"],
	"cyan": [load("res://assets/sprites/player/skins/astronaut_cyan.png"), "Cyan Suit", 3000, "rare"],
	"green": [load("res://assets/sprites/player/skins/astronaut_green.png"), "Green Suit", 4500, "epic"],
	"gold": [load("res://assets/sprites/player/skins/astronaut_gold.png"), "Golden Suit", 5000, "legendary"]
}


var particles : Dictionary = {
	"default": [load("res://assets/resources/player/particles/default.tscn"), "Default Trail", 0, "common"],
	"blue": [load("res://assets/resources/player/particles/blue.tscn"), "Blue Trail", 2000, "rare"],
	"fire": [load("res://assets/resources/player/particles/fire.tscn"), "Fire Trail", 7500, "legendary"]
}

# Schema : Ressource 0, Name 1 , Icon 2 , Seltenheit 3 , id 4
var commonAbilities : Dictionary = {
	"dash": ["res://skillResources/dashRes.tres", "Dash", "res://player/skills/dash/dash_icon.png", "common", "dash"],
}

var rareAbilities : Dictionary = {
	"dash": ["res://skillResources/dashRes.tres", "Dash", "res://player/skills/dash/dash_icon.png", "rare", "dash"],
}

var epicAbilities : Dictionary = {
	"camouflage": ["res://skillResources/camouflage.tres", "Camouflage", "res://player/gadgets/camouflage/camouflage_icon.png", "epic", "camouflage"],
	"shrink": ["res://player/skills/shrink/shrinkRes.tres", "Shrink", "res://player/skills/shrink/shrink_icon.png", "epic", "shrink"]
}

var legendaryAbilities : Dictionary = {
	"portal": ["res://skillResources/portalRes.tres", "Portal", "res://player/skills/portal/portal_icon.png", "legendary", "portal"],
	"shadowworld": ["res://skillResources/shadowWorldRes.tres", "Shadow World", "res://player/skills/shadowWorld/shadowWorld_icon.png", "legendary", "shadowWorld"],
	#"drone": ["res://player/gadgets/drone/drone.tres", "Drone", "res://player/skills/shadowWorld/shadowWorld_icon.png", "legendary", "drone"]
}

func _ready():
	randomize()

func getRandomAbility():
	randomize()
	var randFloat = randf()
	var randomAbility
	
	if randFloat <= commonChance:
		randomAbility = get_random_ability_from_dict(commonAbilities)
		return randomAbility
	elif randFloat <= commonChance + rareChance:
		randomAbility = get_random_ability_from_dict(rareAbilities)
		return randomAbility
	elif randFloat <= commonChance + rareChance + epicChance:
		randomAbility = get_random_ability_from_dict(epicAbilities)
		return randomAbility
	if randFloat <= commonChance + rareChance + epicChance + legendaryChance:
		randomAbility = get_random_ability_from_dict(legendaryAbilities)
		return randomAbility
	else:
		print_debug("Keine passende Ability gefunden")
		return null

func get_random_ability_from_dict(ability_dict: Dictionary):
	if ability_dict.size() > 0:
		var random_key = ability_dict.keys()[randi() % ability_dict.size()]
		Playerdata.addUnlockedAbility(change_name(ability_dict[random_key][1]))
		
		return ability_dict[random_key]
	else:
		print_debug("Keine Fähigkeiten in dieser Kategorie vorhanden")
		return null

func change_name(string: String) -> String:
	var new_string = string.to_lower()
	new_string = new_string.strip_edges() 
	new_string = new_string.replace(" ", "")  
	
	return new_string

	

func getAbility(ability: String):
	if commonAbilities.has(ability):
		#print(commonAbilities[ability])
		return commonAbilities[ability]
	elif rareAbilities.has(ability):
		#print(rareAbilities[ability])
		return rareAbilities[ability]
	elif epicAbilities.has(ability):
		#print(epicAbilities[ability])
		return epicAbilities[ability]
	elif legendaryAbilities.has(ability):
		#print(legendaryAbilities[ability])
		return legendaryAbilities[ability]
	else:
		print_debug("Ability not found in any dictionary")
		return null
