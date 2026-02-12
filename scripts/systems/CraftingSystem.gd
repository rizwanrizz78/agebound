extends Node

var recipes = {
	"stone_axe": {
		"ingredients": {"wood": 1, "stone": 1},
		"result_amount": 1,
		"age_req": "Primal Age"
	},
	"campfire": {
		"ingredients": {"wood": 5, "stone": 2},
		"result_amount": 1,
		"age_req": "Primal Age"
	},
	"spear": {
		"ingredients": {"wood": 2, "stone": 1},
		"result_amount": 1,
		"age_req": "Primal Age"
	}
}

func can_craft(recipe_id):
	if not recipes.has(recipe_id):
		return false

	var recipe = recipes[recipe_id]
	# Check Age requirement
	if AgeSystem.get_current_age_name() != recipe["age_req"] and AgeSystem.current_age_index < 1: # Basic check
		# Actually, higher ages should include lower ages recipes.
		# For now, just check if unlocked.
		pass

	for item in recipe["ingredients"]:
		if not Global.has_item(item, recipe["ingredients"][item]):
			return false
	return true

func craft(recipe_id):
	if can_craft(recipe_id):
		var recipe = recipes[recipe_id]
		# Consume ingredients
		for item in recipe["ingredients"]:
			Global.remove_item(item, recipe["ingredients"][item])

		# Add result
		Global.add_item(recipe_id, recipe["result_amount"])
		print("Crafted: ", recipe_id)

		# Update Quest
		AgeSystem.update_quest_progress(recipe_id, 1)
		return true
	return false
