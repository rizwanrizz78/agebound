class_name Player
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8

var head : Node3D
var camera : Camera3D
var raycast : RayCast3D
var collision_shape : CollisionShape3D
var world : Node3D # VoxelWorld

func _ready():
	add_to_group("player")

	# Setup nodes programmatically
	collision_shape = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.height = 1.8
	shape.radius = 0.4
	collision_shape.shape = shape
	add_child(collision_shape)
	collision_shape.position.y = 0.9

	head = Node3D.new()
	add_child(head)
	head.position.y = 1.6

	camera = Camera3D.new()
	head.add_child(camera)
	camera.current = true

	raycast = RayCast3D.new()
	camera.add_child(raycast)
	raycast.target_position = Vector3(0, 0, -4) # 4 meters range
	raycast.enabled = true

	Global.player_position = global_position

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Handle Jump
	if Global.input_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		Global.input_jump = false # Consume jump input

	# Get movement direction from joystick
	var input_dir = Global.input_move
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	Global.player_position = global_position

# Breaking Logic
var break_timer = 0.0
var max_break_time = 0.8 # Seconds (Primal Age default)

func _process(delta):
	# Handle Interaction
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is VoxelChunk or collider.get_parent() is VoxelChunk: # Chunk is StaticBody
			var point = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()

			# Breaking (Hold)
			if Global.is_breaking:
				break_timer += delta
				if break_timer >= max_break_time:
					var block_pos = Vector3i(floor(point.x - normal.x * 0.5), floor(point.y - normal.y * 0.5), floor(point.z - normal.z * 0.5))
					# Remove block (set to AIR)
					if world and world.has_method("set_block"):
						world.set_block(block_pos, 0) # 0 is AIR
						# Simple drop logic
						if block_pos.y > 10:
							Global.add_item("wood", 1)
						else:
							Global.add_item("stone", 1)

					break_timer = 0.0
					# Do not force reset global, let player hold to keep breaking
					# Global.is_breaking = false
			else:
				break_timer = 0.0

			# Placing (Tap)
			if Global.is_placing:
				var block_pos = Vector3i(floor(point.x + normal.x * 0.5), floor(point.y + normal.y * 0.5), floor(point.z + normal.z * 0.5))
				if world and world.has_method("set_block"):
					# Place block (Stone for now)
					if Global.has_item("stone", 1):
						world.set_block(block_pos, 3) # 3 is STONE
						Global.remove_item("stone", 1)
				Global.is_placing = false
	else:
		break_timer = 0.0

	# Handle Look
	if Global.input_look != Vector2.ZERO:
		# Use sensitivity directly
		var look = Global.input_look
		rotate_y(deg_to_rad(-look.x))
		# Rotate head for pitch
		if head:
			head.rotate_x(deg_to_rad(-look.y))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		Global.input_look = Vector2.ZERO # Reset input
