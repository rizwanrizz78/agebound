extends CanvasLayer

var progress_bar : ProgressBar
var label : Label

func _ready():
	# Background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.1, 0.1, 1.0)
	add_child(bg)

	# Container
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.custom_minimum_size = Vector2(400, 100)
	add_child(vbox)

	# Label
	label = Label.new()
	label.text = "Generating World..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	# Progress Bar
	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(0, 30)
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	vbox.add_child(progress_bar)

func update_progress(current, target):
	if target > 0:
		progress_bar.value = float(current) / float(target)
		label.text = "Loading Chunks: %d/%d" % [current, target]

func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
