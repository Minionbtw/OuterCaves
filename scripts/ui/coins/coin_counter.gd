extends NinePatchRect

onready var font = $HBoxContainer/HBoxContainer/balance.get_font("font")

func _process(_delta):
	if Global.is_in_main:
		$HBoxContainer/HBoxContainer/balance.set_text(str(playerData.getStat("coins")))
	else:
		$HBoxContainer/HBoxContainer/balance.set_text(str(Global.collected_coins))
	if playerData.getStat("coins") < 10000:
		updateFont(15)
	if playerData.getStat("coins") >= 10000:
		updateFont(14)
	if playerData.getStat("coins") >= 100000:
		updateFont(12)
	if playerData.getStat("coins") >= 1000000:
		updateFont(10)

func updateFont(_value: int):
	font.size = _value
