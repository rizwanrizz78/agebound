class_name Mob
extends CharacterBody3D

var speed = 3.0
var gravity = 9.8
var turn_speed = 2.0
var roam_timer = 0.0
var roam_interval = 4.0
var target_rotation = 0.0

var health = 30.0

func _ready():
	add_to_group("mobs")
	roam_timer = randf_range(0, roam_interval)
	pick_random_direction()

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Roam Logic
	roam_timer -= delta
	if roam_timer <= 0:
		roam_timer = roam_interval
		pick_random_direction()

	# Rotate towards target
	rotation.y = lerp_angle(rotation.y, target_rotation, turn_speed * delta)

	# Move forward
	var direction = Vector3(sin(rotation.y), 0, cos(rotation.y))
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()

func pick_random_direction():
	target_rotation = randf_range(-PI, PI)
	# Maybe pause sometimes?
	if randf() > 0.7:
		speed = 0.0
	else:
		speed = 3.0

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()
	# Drop loot (e.g. meat/leather)
	Global.add_item("meat", 1)
