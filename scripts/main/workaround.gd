extends Control

export var timer_time: float = 0.01

const MAIN_SCENE = "res://scenes/environment/main_scene.tscn"

func _ready():
	yield(get_tree().create_timer(timer_time), "timeout")
	get_tree().change_scene(MAIN_SCENE)
