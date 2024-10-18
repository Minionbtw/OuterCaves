extends Control

var start_pos: Vector2 = Vector2.ZERO
var end_pos: Vector2 = Vector2.ZERO
var valid_pos = false
var touch_pos = Vector2()
var _touch_index : int = -1
var direction

onready var js_pos = get_node("joystickBackground").rect_position
onready var js_bg = get_node("joystickBackground")
onready var js_handle = get_node("joystickBackground/handle")


const MAX_SWIPE_DISTANCE = 100
const LEFT_THRESHOLD = -0.5
const RIGHT_THRESHOLD = 0.5
const UP_THRESHOLD = -0.5
const DOWN_THRESHOLD = 0.5

func _ready():
	Input.action_release("move_left")
	Input.action_release("move_right")

func _input(event: InputEvent) -> void:
	if OS.get_name() != "X11":
		if event is InputEventScreenTouch:
			if event.pressed:
				if _touch_index == -1 && valid_pos:
					touch_pos = event.position
					_touch_index = event.index
					if valid_pos and is_in_rect(touch_pos, $region_pos.get_rect()):
						start_pos = event.position
						js_bg.rect_position = Vector2(start_pos.x - js_bg.rect_size.x / 2, start_pos.y - js_bg.rect_size.y / 2)
						get_tree().set_input_as_handled()
			else:
				if event.index == _touch_index:
					_reset()

		if event is InputEventScreenDrag:
			if _touch_index == event.index and valid_pos and is_in_rect(touch_pos, $region_pos.get_rect()):
				if start_pos == Vector2.ZERO:
					get_tree().set_input_as_handled()
					start_pos = event.position
					js_bg.rect_position = Vector2(start_pos.x - js_bg.rect_size.x / 2, start_pos.y - js_bg.rect_size.y / 2)
				if is_in_rect(event.position, $region_pos.get_rect()):
					end_pos = event.position
					direction = end_pos - start_pos

					if direction.length() < MAX_SWIPE_DISTANCE:
						js_handle.rect_position.x = 66 + direction.length()
						js_handle.rect_pivot_offset.x = 30 - direction.length()

					js_handle.rect_rotation = rad2deg(direction.angle())

			

				# Triggering actions based on the swipe direction
				if direction.x < LEFT_THRESHOLD:
					Input.action_release("move_right")
					Input.action_press("move_left")
				elif direction.x > RIGHT_THRESHOLD:
					Input.action_release("move_left")
					Input.action_press("move_right")
				else:
					Input.action_release("move_left")
					Input.action_release("move_right")

func is_in_rect(pos, rect):
	return pos.x > rect.position.x and pos.y > rect.position.y and pos.x < rect.end.x and pos.y < rect.end.y 

func _on_TouchScreenButton_pressed():
	valid_pos = true

func _on_TouchScreenButton_released():
	_reset()

func _reset():
	Input.action_release("move_left")
	Input.action_release("move_right")
	js_bg.rect_position = js_pos
	start_pos = Vector2.ZERO
	end_pos = Vector2.ZERO
	valid_pos = false
	js_handle.rect_position.x = 66
	js_handle.rect_pivot_offset.x = 30
	_touch_index = -1
