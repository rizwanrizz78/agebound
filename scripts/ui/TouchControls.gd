extends Control

# This script generates two virtual joysticks dynamically on screen.
# And handles Interaction logic (Tap to Place, Hold to Break)

var left_joystick : Joystick
var right_joystick : Joystick

# Interaction State
var interaction_touch_index = -1
var interaction_start_pos = Vector2.ZERO
var interaction_start_time = 0.0
var is_holding = false
var interaction_pressed = false

func _ready():
	# Create Left Joystick (Movement)
	var left_rect = Control.new()
	left_rect.name = "LeftJoystickArea"
	left_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	left_rect.anchor_right = 0.5
	left_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(left_rect)

	left_joystick = Joystick.new()
	left_rect.add_child(left_joystick)

	# Create Right Joystick (Look)
	var right_rect = Control.new()
	right_rect.name = "RightJoystickArea"
	right_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	right_rect.anchor_left = 0.5
	right_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(right_rect)

	right_joystick = Joystick.new()
	right_rect.add_child(right_joystick)

func _input(event):
	if event is InputEventScreenTouch:
		# Check right side
		var is_right_side = event.position.x > get_viewport_rect().size.x * 0.5

		if event.pressed:
			if is_right_side:
				# Start potential interaction if not already tracking one
				if interaction_touch_index == -1:
					interaction_touch_index = event.index
					interaction_start_pos = event.position
					interaction_start_time = Time.get_ticks_msec()
					is_holding = false
					interaction_pressed = true
					Global.is_breaking = false
		else:
			if event.index == interaction_touch_index:
				# Released
				var duration = Time.get_ticks_msec() - interaction_start_time
				# If short tap and NOT holding/breaking
				if not is_holding and duration < 300:
					# Check if we dragged significantly? (Handled by _process check below)
					if Global.input_look.length() < 0.1: # Only place if we didn't look around
						Global.is_placing = true
						get_tree().create_timer(0.1).timeout.connect(func(): Global.is_placing = false)

				# Reset
				interaction_touch_index = -1
				Global.is_breaking = false
				is_holding = false
				interaction_pressed = false

func _process(delta):
	# Update Global Input State
	if left_joystick:
		Global.input_move = left_joystick.get_output()

	if right_joystick:
		Global.input_look = right_joystick.get_output() * 3.0 # Sensitivity multiplier

	# Check Hold / Drag Logic
	if interaction_pressed and interaction_touch_index != -1:
		var duration = Time.get_ticks_msec() - interaction_start_time

		# If moving camera (Right Joystick Active and outputting), cancel Break
		if right_joystick.get_output().length() > 0.05:
			Global.is_breaking = false
			is_holding = false # Cancel hold if we start looking
		elif duration > 300: # 300ms hold and NOT moving
			is_holding = true
			Global.is_breaking = true

# Inner Class for Joystick Logic
class Joystick extends Control:
	var _pressed = false
	var _touch_index = -1
	var _center = Vector2.ZERO
	var _output = Vector2.ZERO

	var _base : TextureRect
	var _tip : TextureRect

	const BASE_RADIUS = 64.0
	const TIP_RADIUS = 32.0

	func _ready():
		mouse_filter = Control.MOUSE_FILTER_IGNORE

		_base = TextureRect.new()
		var grad = Gradient.new()
		grad.set_color(0, Color(0.1, 0.1, 0.1, 0.5))
		grad.set_color(1, Color(0.1, 0.1, 0.1, 0.0))

		var tex = GradientTexture2D.new()
		tex.gradient = grad
		tex.width = int(BASE_RADIUS * 2)
		tex.height = int(BASE_RADIUS * 2)
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(0.5, 0.0)
		_base.texture = tex
		_base.position = Vector2(-BASE_RADIUS, -BASE_RADIUS)
		add_child(_base)
		_base.hide()

		_tip = TextureRect.new()
		var grad_tip = Gradient.new()
		grad_tip.set_color(0, Color(0.8, 0.8, 0.8, 0.8))
		grad_tip.set_color(1, Color(0.6, 0.6, 0.6, 0.0))

		var tex_tip = GradientTexture2D.new()
		tex_tip.gradient = grad_tip
		tex_tip.width = int(TIP_RADIUS * 2)
		tex_tip.height = int(TIP_RADIUS * 2)
		tex_tip.fill = GradientTexture2D.FILL_RADIAL
		tex_tip.fill_from = Vector2(0.5, 0.5)
		tex_tip.fill_to = Vector2(0.5, 0.0)
		_tip.texture = tex_tip
		_tip.position = Vector2(-TIP_RADIUS, -TIP_RADIUS)
		add_child(_tip)
		_tip.hide()

	func _input(event):
		if event is InputEventScreenTouch:
			if event.pressed:
				if _touch_index == -1:
					if get_parent().get_global_rect().has_point(event.position):
						_touch_index = event.index
						_pressed = true
						_center = event.position

						_base.global_position = _center - Vector2(BASE_RADIUS, BASE_RADIUS)
						_tip.global_position = _center - Vector2(TIP_RADIUS, TIP_RADIUS)

						_base.show()
						_tip.show()
						_output = Vector2.ZERO
			else:
				if event.index == _touch_index:
					_reset()

		elif event is InputEventScreenDrag:
			if event.index == _touch_index:
				var vector = event.position - _center
				if vector.length() > BASE_RADIUS:
					vector = vector.normalized() * BASE_RADIUS

				_output = vector / BASE_RADIUS
				_tip.global_position = _center + vector - Vector2(TIP_RADIUS, TIP_RADIUS)

	func _reset():
		_pressed = false
		_touch_index = -1
		_output = Vector2.ZERO
		_base.hide()
		_tip.hide()

	func get_output():
		return _output
