extends Control

var health_label : Label
var hunger_label : Label
var thirst_label : Label
var age_label : Label
var quest_label : Label
var inventory_label : Label

var craft_axe_btn : Button
var craft_campfire_btn : Button

func _ready():
	# Create UI elements
	var vbox = VBoxContainer.new()
	add_child(vbox)
	vbox.position = Vector2(20, 20)

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

	inventory_label = Label.new()
	vbox.add_child(inventory_label)

	# Crafting Buttons (Bottom Right)
	var craft_box = VBoxContainer.new()
	add_child(craft_box)
	craft_box.position = Vector2(get_viewport_rect().size.x - 200, get_viewport_rect().size.y - 150)

	craft_axe_btn = Button.new()
	craft_axe_btn.text = "Craft Axe (1 Wood, 1 Stone)"
	craft_axe_btn.pressed.connect(_on_craft_axe)
	craft_box.add_child(craft_axe_btn)

	craft_campfire_btn = Button.new()
	craft_campfire_btn.text = "Craft Campfire (5 Wood, 2 Stone)"
	craft_campfire_btn.pressed.connect(_on_craft_campfire)
	craft_box.add_child(craft_campfire_btn)

	# Action Buttons
	var action_box = HBoxContainer.new()
	add_child(action_box)
	action_box.position = Vector2(get_viewport_rect().size.x - 300, get_viewport_rect().size.y - 100)

	var break_btn = Button.new()
	break_btn.text = "BREAK"
	break_btn.button_down.connect(func(): Global.input_break = true)
	break_btn.button_up.connect(func(): Global.input_break = false)
	action_box.add_child(break_btn)

	var place_btn = Button.new()
	place_btn.text = "PLACE"
	place_btn.button_down.connect(func(): Global.input_place = true)
	place_btn.button_up.connect(func(): Global.input_place = false)
	action_box.add_child(place_btn)

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
	var text = "Inventory:\n"
	for item in Global.player_inventory:
		text += item + ": " + str(Global.player_inventory[item]) + "\n"
	inventory_label.text = text

func _on_craft_axe():
	CraftingSystem.craft("stone_axe")

func _on_craft_campfire():
	CraftingSystem.craft("campfire")
