extends Node

signal health_changed(value)
signal hunger_changed(value)
signal thirst_changed(value)
signal player_died

var max_health = 100.0
var max_hunger = 100.0
var max_thirst = 100.0

var health = 100.0
var hunger = 100.0
var thirst = 100.0

var hunger_decay_rate = 0.5 # per second
var thirst_decay_rate = 0.8 # per second

func _process(delta):
	# Decay hunger and thirst
	hunger = max(0, hunger - hunger_decay_rate * delta)
	thirst = max(0, thirst - thirst_decay_rate * delta)

	emit_signal("hunger_changed", hunger)
	emit_signal("thirst_changed", thirst)

	if hunger <= 0 or thirst <= 0:
		damage(5.0 * delta)

func damage(amount):
	health = max(0, health - amount)
	emit_signal("health_changed", health)
	if health <= 0:
		die()

func heal(amount):
	health = min(max_health, health + amount)
	emit_signal("health_changed", health)

func eat(amount):
	hunger = min(max_hunger, hunger + amount)
	emit_signal("hunger_changed", hunger)

func drink(amount):
	thirst = min(max_thirst, thirst + amount)
	emit_signal("thirst_changed", thirst)

func die():
	print("Player died!")
	emit_signal("player_died")
	# Respawn logic (reset stats)
	health = max_health
	hunger = max_hunger
	thirst = max_thirst
	emit_signal("health_changed", health)
	emit_signal("hunger_changed", hunger)
	emit_signal("thirst_changed", thirst)
	# Reset position (handled by main game loop or player)
	if Global.player_position:
		# Signal to main to respawn?
		pass
