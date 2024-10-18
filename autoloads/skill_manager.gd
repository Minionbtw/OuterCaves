extends Node

const MAX_ACTIVE_SKILLS = 1
const MAX_ACTIVE_GADGETS = 1
const SAVE_PATH = "user://abilities.save"

var active_skill : Resource
var active_skill_name : String

func _ready():
	load_active_skill()
	if Playerdata.selected_ability != "":
		active_skill = load(Unlockables.get_ability(Playerdata.selected_ability)[0])
		active_skill_name = Playerdata.selected_ability

func setactive_skill(skill, skill_name):
	active_skill = load(skill[0])
	active_skill_name = skill_name
	save_active_skill(str(skill[0]))

func save_active_skill(skill : String) -> void:
	var save_data = {
		"active_skill": skill,
		"active_skill_name": active_skill_name
	}
	var file = File.new()
	if file.open(SAVE_PATH, File.WRITE) == OK:
		file.store_line(JSON.print(save_data))
		file.close()

func load_active_skill() -> void:
	var file = File.new()
	if file.file_exists(SAVE_PATH):
		if file.open(SAVE_PATH, File.READ) == OK:
			var save_data = parse_json(file.get_line())
			active_skill = load(save_data["active_skill"])
			active_skill_name = save_data["active_skill_name"]
			file.close()
