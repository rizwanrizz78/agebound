extends Node

# Global signals and state

signal age_unlocked(age_name)
signal quest_updated(quest_name, progress)
signal inventory_changed

# Current Age
var current_age = "Primal"
var ages_unlocked = ["Primal"]

# Player stats (basic)
var player_position = Vector3()
var player_inventory = {}

# Input (for mobile controls)
var input_move = Vector2.ZERO
var input_look = Vector2.ZERO
var input_jump = false
var input_break = false
var input_place = false

func _ready():
	print("Agebound Survival initialized. Current Age: ", current_age)

func unlock_age(age_name):
	if not age_name in ages_unlocked:
		ages_unlocked.append(age_name)
		current_age = age_name
		emit_signal("age_unlocked", age_name)
		print("Unlocked Age: ", age_name)

func add_item(item_name, amount):
	if item_name in player_inventory:
		player_inventory[item_name] += amount
	else:
		player_inventory[item_name] = amount
	emit_signal("inventory_changed")
	print("Added item: ", item_name, " x", amount)

	# Check quests
	if item_name == "wood" or item_name == "stone":
		# Assuming 'wood' and 'stone' are internal IDs
		# In a real game, I'd map item ID to quest ID
		# But AgeSystem handles specific quests like gather_wood
		if has_node("/root/AgeSystem"):
			get_node("/root/AgeSystem").update_quest_progress(item_name, amount)

func has_item(item_name, amount):
	return player_inventory.get(item_name, 0) >= amount

func remove_item(item_name, amount):
	if has_item(item_name, amount):
		player_inventory[item_name] -= amount
		if player_inventory[item_name] <= 0:
			player_inventory.erase(item_name)
		emit_signal("inventory_changed")
		return true
	return false
