extends Control

onready var distance_text = get_node("Background/distance_travelled/length")
onready var killed_text = get_node("Background/enemies_killed/killed")
onready var stage_text = get_node("Background/reached_stage/reached")
onready var over_progress = get_node("Background/over_progress")

func _ready():
	distance_text.text = str(round(Global.total_distance_traveled))
	killed_text.text = str(Global.enemies_killed)
	stage_text.text = str(Global.current_stage)
	get_tree().paused = true

func _process(delta):
	over_progress.value = $Timer.time_left

func _on_Timer_timeout():
	get_tree().paused = false
	Global.game_over()
