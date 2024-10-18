extends Area2D

var sprite
var currentskin = "default"

var skins : Dictionary = {
	"default": ["res://assets/sprites/objects/spaceship_skins/default.png",
	 "res://assets/sprites/objects/spaceship_skins/default_outline.png"]
}



func _ready():
	sprite = $Sprite

func _on_Spaceship_body_entered(body):
	if body.is_in_group("player"):
		sprite.texture = load(skins[currentskin][1])
		body.get_node("CanvasLayer/player_ui/positionlayer/enter_buttons/spaceship").show()


func _on_Spaceship_body_exited(body):
	if body.is_in_group("player"):
		sprite.texture = load(skins[currentskin][0])
		body.get_node("CanvasLayer/player_ui/positionlayer/enter_buttons/spaceship").hide()
