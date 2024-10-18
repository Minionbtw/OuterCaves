extends Node2D

var entered: bool = false
var _player: KinematicBody2D = null

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.get_node("CanvasLayer/player_ui/positionlayer/enter_buttons/enter_cave").show()
		entered = true

# warning-ignore:unused_argument
func _process(delta):
	if entered && Input.is_action_just_pressed("enter_cave"):
		entered = false
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://environment/RandomWalker/pathFinder.tscn")


func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		body.get_node("CanvasLayer/player_ui/positionlayer/enter_buttons/enter_cave").hide()
		entered = false
