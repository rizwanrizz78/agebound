extends Node

signal age_changed(new_age_name)
signal quest_completed(quest_name)
signal new_quest_available(quest_name, description)

var ages = [
	{
		"name": "Primal Age",
		"description": "Survive with basic tools.",
		"quests": [
			{"id": "gather_wood", "desc": "Gather 5 Wood Logs", "target": "wood", "count": 5, "current": 0, "completed": false},
			{"id": "craft_axe", "desc": "Craft a Stone Axe", "target": "stone_axe", "count": 1, "current": 0, "completed": false}
		],
		"unlocks": ["campfire", "stone_axe", "spear"]
	},
	{
		"name": "Tribal Age",
		"description": "Form a tribe and build shelters.",
		"quests": [],
		"unlocks": ["leather_armor", "totem"]
	}
]

var current_age_index = 0

func _ready():
	emit_signal("age_changed", get_current_age_name())
	check_quests()

func get_current_age_name():
	return ages[current_age_index]["name"]

func get_current_quests():
	return ages[current_age_index]["quests"]

func update_quest_progress(target_id, amount):
	var quests = get_current_quests()
	var updated = false

	for q in quests:
		if q["target"] == target_id and not q["completed"]:
			q["current"] += amount
			if q["current"] >= q["count"]:
				complete_quest(q)
			updated = true

	if updated:
		check_age_progression()

func complete_quest(quest):
	quest["completed"] = true
	emit_signal("quest_completed", quest["desc"])
	print("Quest Completed: ", quest["desc"])

func check_age_progression():
	var quests = get_current_quests()
	var all_complete = true
	for q in quests:
		if not q["completed"]:
			all_complete = false
			break

	if all_complete and current_age_index < ages.size() - 1:
		advance_age()

func advance_age():
	current_age_index += 1
	var new_age = ages[current_age_index]
	emit_signal("age_changed", new_age["name"])
	print("ADVANCED TO AGE: ", new_age["name"])
	check_quests()

func check_quests():
	for q in get_current_quests():
		emit_signal("new_quest_available", q["id"], q["desc"])
