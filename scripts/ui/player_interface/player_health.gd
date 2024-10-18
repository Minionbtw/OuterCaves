extends Control

var anim_started
var current_value
var new_value
onready var max_health = playerData.getStat("health")
onready var healthbar = $HBoxContainer/VBoxContainer/healthbar

const TIMER_LIMIT = 0.5
var timer = 0.0

func _ready():
	$HBoxContainer/VBoxContainer/healthbar/Label.text = str(Global.player_health) + "/" + str(max_health)
	$HBoxContainer/VBoxContainer/healthbar.value = Global.player_health
	#health_debug()

# warning-ignore:unused_argument
func _process(delta):
	new_value = Global.player_health
	current_value = $HBoxContainer/VBoxContainer/healthbar.value
	if current_value != new_value && !anim_started:
		healthbar_anim()
	if Settings.getSetting("fps"):
		timer += delta
		if timer > TIMER_LIMIT: # Prints every 2 seconds
			timer = 0.0
			get_node("Label").text = ("fps: " + str(Engine.get_frames_per_second()))
	else:
		get_node("Label").text = ""

#func health_debug():
#	print("healthbar: " + str(healthbar.value))
#	print("hp: " + str(Global.player_health))
#	yield(get_tree().create_timer(1), "timeout")
#	health_debug()

func healthbar_anim():
	anim_started = true
	$Tween.interpolate_property($HBoxContainer/VBoxContainer/healthbar, "value", current_value, new_value, 0.2, Tween.TRANS_LINEAR)
	$Tween.start()





func _on_Tween_tween_all_completed():
	anim_started = false
	$HBoxContainer/VBoxContainer/healthbar/Label.text = str(Global.player_health) + "/" + str(max_health)
