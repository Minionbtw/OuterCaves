extends Node2D

onready var anim_player = get_node("CanvasLayer/AnimationPlayer")

const MENU_SCENE = "res://scenes/startup/menu.tscn"

func _ready():
	anim_player.play("FadeIn")
# warning-ignore:return_value_discarded


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeIn":
		yield(get_tree().create_timer(1), "timeout")
		anim_player.play("FadeOut")
	if anim_name == "FadeOut":
		get_tree().change_scene(MENU_SCENE)
