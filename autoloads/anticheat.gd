extends Node

var enabled : bool = false
var coins: int = 0
var coins_mod: int = 0
var current_modulo_divisor: int = 13
var coin_change_counter: int = 0  # Zähler für die Änderungen an den Coins
const MODULO_DIVISORS: Array = [7, 11, 13, 17, 19, 23, 29]  # Liste von möglichen Divisoren

func _ready():
	randomize()
	coins = int(Playerdata.get_coins())
	current_modulo_divisor = MODULO_DIVISORS[randi() % MODULO_DIVISORS.size()]
	coins_mod = coins % current_modulo_divisor
	example_usage()

func _process(delta):
	pass
#	if not check_coins():
#		print("Cheating detected in _process!")
#		Playerdata.setStat("coins", coins)
#		get_tree().quit()
#	else:
#		Playerdata.savePlayerdata()

func increaseCoins():
	if enabled:
		coin_change_counter += 1
		if coin_change_counter % 3 == 0:
			coins += coin_change_counter
			coins_mod = coins % current_modulo_divisor
			coin_change_counter = 0
			print("Increased coins: ", coins, " coins_mod: ", coins_mod)

func decreaseCoins(value: int):
	if enabled:
		if coins >= value:
			coins -= value
			coins_mod = coins % current_modulo_divisor
			coin_change_counter = 0
			print("Decreased coins: ", coins, " coins_mod: ", coins_mod)

func check_coins() -> bool:
	if enabled:
	# Berechne die erwarteten Coins basierend auf dem Zähler
		var expected_coins = coins + (coin_change_counter)
		return (int(Playerdata.get_coins()) % current_modulo_divisor) == (expected_coins % current_modulo_divisor)
	return false
# Beispielaufruf zum Hinzufügen von Coins und Überprüfen
func example_usage():
	if enabled:
		if not check_coins():
			print("Cheating detected in example_usage!")
			Playerdata.setStat("coins", (coins + coin_change_counter))
			get_tree().quit()
		else:
			Playerdata.save_player_data()
			print("All good. Coins: ", coins, " coins_mod: ", coins_mod)
		current_modulo_divisor = MODULO_DIVISORS[randi() % MODULO_DIVISORS.size()]
		coins_mod = coins % current_modulo_divisor
		yield(get_tree().create_timer(1), "timeout")
		example_usage()
