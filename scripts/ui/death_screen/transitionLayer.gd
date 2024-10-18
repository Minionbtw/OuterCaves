extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	print("hi")
	if !Global.is_in_main or Global.game_over:
		show()
		$AnimationPlayer.play("stages")
	else:
		queue_free()
	
	if Global.game_over:
		show()
		$position_control.show()
		$Souls.show()
		$game_over.show()
		$Label.hide()
		Global.game_over = false
		$AnimationPlayer.play("game_over")
		
	elif !Global.is_in_main && !Global.game_over:
		show()
		$Label.text = "Stage " + str(Global.current_stage)
		$game_over.hide()
		$position_control.hide()
		$Souls.hide()
		$Label.show()
		$AnimationPlayer.play("stages")


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "game_over":
		Global.pause = true
	if anim_name == "stages":
		get_tree().paused = false
		Global.pause = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "game_over":
		Global.pause = false
		queue_free()
	if anim_name == "stages":
		Global.pause = false
		queue_free()
