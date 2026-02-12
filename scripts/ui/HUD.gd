extends Control

var health_label : Label
var hunger_label : Label
var thirst_label : Label
var age_label : Label
var quest_label : Label
var inventory_label : Label
var break_progress : ProgressBar
var hotbar_container : HBoxContainer
var hotbar_slots = []

var craft_axe_btn : Button
var craft_campfire_btn : Button

func _ready():
	# Ensure proper sizing
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Create UI elements
	var vbox = VBoxContainer.new()
	vbox.name = "StatsBox"
	add_child(vbox)
	vbox.position = Vector2(40, 40) # Margin

	age_label = Label.new()
	vbox.add_child(age_label)

	quest_label = Label.new()
	vbox.add_child(quest_label)

	health_label = Label.new()
	vbox.add_child(health_label)

	hunger_label = Label.new()
	vbox.add_child(hunger_label)

	thirst_label = Label.new()
	vbox.add_child(thirst_label)

	# Removed old text inventory
	# inventory_label = Label.new()
	# vbox.add_child(inventory_label)

	# Hotbar (Bottom Center)
	hotbar_container = HBoxContainer.new()
	hotbar_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE) # Or CENTER_BOTTOM
	hotbar_container.alignment = BoxContainer.ALIGNMENT_CENTER
	hotbar_container.custom_minimum_size = Vector2(0, 80)
	hotbar_container.position.y = -100 # Offset manually if needed
	hotbar_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	hotbar_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hotbar_container.anchor_top = 1.0
	hotbar_container.anchor_bottom = 1.0
	hotbar_container.offset_bottom = -20 # Margin from bottom
	hotbar_container.offset_top = -100
	add_child(hotbar_container)

	for i in range(5):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(80, 80)
		var lbl = Label.new()
		lbl.text = ""
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		slot.add_child(lbl)
		hotbar_container.add_child(slot)
		hotbar_slots.append({"panel": slot, "label": lbl})

	# Crosshair (Center)
	var crosshair = ColorRect.new()
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.custom_minimum_size = Vector2(4, 4)
	crosshair.color = Color(1, 1, 1, 0.8)
	crosshair.position = -crosshair.custom_minimum_size / 2 # Center pivot manually?
	# Actually PRESET_CENTER centers it relative to parent size, but origin is top-left.
	# We need to offset by half size.
	# But let's just use CenterContainer if needed, or simple offset logic.
	# A 4x4 rect at center is fine.
	add_child(crosshair)
	# Fix position after adding?
	# Better to use a CenterContainer for crosshair? Overkill.
	# Just set position in _process or use anchors with offset.
	crosshair.grow_horizontal = Control.GROW_DIRECTION_BOTH
	crosshair.grow_vertical = Control.GROW_DIRECTION_BOTH
	crosshair.anchor_left = 0.5
	crosshair.anchor_top = 0.5
	crosshair.anchor_right = 0.5
	crosshair.anchor_bottom = 0.5
	crosshair.offset_left = -2
	crosshair.offset_top = -2
	crosshair.offset_right = 2
	crosshair.offset_bottom = 2

	# Break Progress Bar (Center)
	break_progress = ProgressBar.new()
	break_progress.set_anchors_preset(Control.PRESET_CENTER)
	break_progress.custom_minimum_size = Vector2(200, 20)
	break_progress.show_percentage = false
	break_progress.max_value = 1.0
	break_progress.value = 0.0
	add_child(break_progress)
	break_progress.hide()

	# Crafting Buttons (Bottom Right)
	var craft_box = VBoxContainer.new()
	craft_box.name = "CraftBox"
	# Anchor to Bottom Right
	craft_box.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	craft_box.position = Vector2(-300, -200) # Offset from bottom right?
	# Actually better to use anchors properly
	add_child(craft_box)
	craft_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	craft_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	craft_box.anchor_left = 1.0
	craft_box.anchor_top = 1.0
	craft_box.anchor_right = 1.0
	craft_box.anchor_bottom = 1.0
	craft_box.offset_left = -320
	craft_box.offset_top = -200
	craft_box.offset_right = -20
	craft_box.offset_bottom = -20

	craft_axe_btn = Button.new()
	craft_axe_btn.text = "Craft Axe (1 Wood, 1 Stone)"
	craft_axe_btn.pressed.connect(_on_craft_axe)
	craft_box.add_child(craft_axe_btn)

	craft_campfire_btn = Button.new()
	craft_campfire_btn.text = "Craft Campfire (5 Wood, 2 Stone)"
	craft_campfire_btn.pressed.connect(_on_craft_campfire)
	craft_box.add_child(craft_campfire_btn)

	# Removed Action Buttons (replaced by gestures)

	# Connect signals
	if has_node("/root/Survival"):
		Survival.health_changed.connect(_on_health_changed)
		Survival.hunger_changed.connect(_on_hunger_changed)
		Survival.thirst_changed.connect(_on_thirst_changed)
		_on_health_changed(Survival.health)
		_on_hunger_changed(Survival.hunger)
		_on_thirst_changed(Survival.thirst)

	if has_node("/root/AgeSystem"):
		AgeSystem.age_changed.connect(_on_age_changed)
		AgeSystem.new_quest_available.connect(_on_quest_updated)
		AgeSystem.quest_completed.connect(_on_quest_completed)
		_on_age_changed(AgeSystem.get_current_age_name())
		# Initial quest update might need delay or manual call

	if has_node("/root/Global"):
		Global.inventory_changed.connect(_on_inventory_changed)
		_on_inventory_changed()

func _on_health_changed(val):
	health_label.text = "Health: %d" % val

func _on_hunger_changed(val):
	hunger_label.text = "Hunger: %d" % val

func _on_thirst_changed(val):
	thirst_label.text = "Thirst: %d" % val

func _on_age_changed(val):
	age_label.text = "Age: " + str(val)

func _on_quest_updated(id, desc):
	quest_label.text = "Quest: " + desc

func _on_quest_completed(desc):
	quest_label.text = "Completed: " + desc

func _on_inventory_changed():
	# Simple visualization: Fill slots with inventory items
	var items = Global.player_inventory.keys()
	for i in range(hotbar_slots.size()):
		var slot = hotbar_slots[i]
		if i < items.size():
			var item = items[i]
			var count = Global.player_inventory[item]
			slot["label"].text = item + "\n" + str(count)
			slot["panel"].modulate = Color(1, 1, 1, 1) # Active
		else:
			slot["label"].text = ""
			slot["panel"].modulate = Color(0.5, 0.5, 0.5, 0.5) # Empty

func _on_craft_axe():
	CraftingSystem.craft("stone_axe")

func _on_craft_campfire():
	CraftingSystem.craft("campfire")

func _process(delta):
	# Update Break Progress
	if Global.is_breaking:
		# Access player break timer if possible, or just fake it?
		# Ideal: Player script exposes progress, or Global has it.
		# For now, let's just show indeterminate or hacky read.
		# BUT, we need to know the MAX time to fill bar.
		# The player has `break_timer` and `max_break_time`.
		var player = get_tree().get_first_node_in_group("player")
		if player and "break_timer" in player and "max_break_time" in player:
			break_progress.show()
			break_progress.value = player.break_timer / player.max_break_time
		else:
			break_progress.hide()
	else:
		break_progress.hide()
		break_progress.value = 0
