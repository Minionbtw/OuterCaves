extends Node2D

export var timer_time : float = 0.5

const DISCORD_LINK = "https://discord.gg/kwnhHUqRAa"
const YOUTUBE_LINK = "https://youtube.com/@DynamicDreamsStudios"
const WORKAROUND_SCENE = "res://scenes/startup/workaround.tscn"

onready var canvaslayer = get_node("CanvasLayer")
onready var front_rect = get_node("CanvasLayer/front_rect")
onready var version_label = get_node("CanvasLayer/version")
onready var anim_player = get_node("AnimationPlayer")
onready var anim_player_2 = get_node("AnimationPlayer2")

func _ready():
	front_rect.show()
	version_label.text = (ProjectSettings.get_setting("application/config/version")) + " - " + (ProjectSettings.get_setting("application/config/build_version"))
	anim_player.play("menu_fadein")
	anim_player_2.play("taptoplay")
	yield(get_tree().create_timer(timer_time), "timeout")

#func _on_Play_pressed():
## warning-ignore:return_value_discarded
#	get_tree().change_scene("res://scenes/Main.tscn")

func _on_Youtube_pressed():
# warning-ignore:return_value_discarded
	OS.shell_open(YOUTUBE_LINK)

func _on_Discord_pressed():
# warning-ignore:return_value_discarded
	OS.shell_open(DISCORD_LINK)

func _on_Options_pressed():
	pass # Replace with function body.

func _on_Extras_pressed():
	pass # Replace with function body.

#func _on_Quit_pressed():
#	var quit_menu_instance = quit_menu.instance()
#	canvaslayer.add_child(quit_menu_instance)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "menu_fadein":
		front_rect.hide()
	elif anim_name == "menu_fadeout":
		canvaslayer.queue_free()
		get_tree().change_scene(WORKAROUND_SCENE)

func _on_TouchScreenButton_pressed():
	front_rect.show()
	anim_player.play("menu_fadeout")

