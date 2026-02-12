extends Control

var touch_points = {} # index -> "move" or "look"
var move_center = Vector2.ZERO
var move_index = -1
var look_index = -1
var screen_size = Vector2.ZERO

const JOYSTICK_RADIUS = 100.0

func _ready():
	screen_size = get_viewport_rect().size
	# Enable multi-touch if needed? It's automatic on Android.

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Check which side of screen
			if event.position.x < screen_size.x * 0.5:
				# Left side - Movement
				if move_index == -1:
					move_index = event.index
					move_center = event.position
					touch_points[event.index] = "move"
			else:
				# Right side - Look
				if look_index == -1:
					look_index = event.index
					touch_points[event.index] = "look"
		else:
			# Released
			if event.index == move_index:
				move_index = -1
				Global.input_move = Vector2.ZERO
			elif event.index == look_index:
				look_index = -1
				Global.input_look = Vector2.ZERO

			if touch_points.has(event.index):
				touch_points.erase(event.index)

	elif event is InputEventScreenDrag:
		if event.index == move_index:
			# Calculate joystick vector
			var diff = event.position - move_center
			var length = diff.length()
			if length > JOYSTICK_RADIUS:
				diff = diff.normalized() * JOYSTICK_RADIUS
			Global.input_move = diff / JOYSTICK_RADIUS
		elif event.index == look_index:
			# Look is relative motion
			Global.input_look += event.relative * 0.2 # Sensitivity
