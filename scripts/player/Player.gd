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

	# Add Hands (Embodiment)
	_setup_hands()

	raycast = RayCast3D.new()
	camera.add_child(raycast)
	raycast.target_position = Vector3(0, 0, -5) # 5 meters range
	raycast.enabled = true
	raycast.collision_mask = 1 # Terrain only? Need to ensure
	raycast.exclude_parent = true # Should ignore player

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
	# Handle Hand Animation (Sway)
	_process_hand_sway(delta)

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

					if world and world.has_method("get_block_type"):
						var type = world.get_block_type(block_pos)
						var item_name = "dirt" # Default

						match type:
							1: item_name = "dirt" # DIRT
							2: item_name = "dirt" # GRASS drops dirt
							3: item_name = "stone" # STONE
							4: item_name = "wood" # WOOD
							5: item_name = "sapling" # LEAVES (chance?)
							6: item_name = "sand" # SAND

						if type != 0: # Don't break AIR
							world.set_block(block_pos, 0) # 0 is AIR
							Global.add_item(item_name, 1)

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
		# Yaw on Body
		rotate_y(deg_to_rad(-look.x))
		# Pitch on Head/Camera
		if head:
			head.rotate_x(deg_to_rad(-look.y))
			# Clamp Vertical Rotation (-80 to 80 degrees)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		Global.input_look = Vector2.ZERO # Reset input

# Hand Visuals
var hand_node : Node3D

func _setup_hands():
	hand_node = Node3D.new()
	camera.add_child(hand_node)
	hand_node.position = Vector3(0.5, -0.4, -0.6) # Bottom right
	hand_node.rotation_degrees = Vector3(0, -10, 0)

	# Arm
	var arm_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.15, 0.6, 0.15)
	arm_mesh.mesh = box
	# Simple skin material
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.6, 0.4)
	arm_mesh.material_override = mat
	hand_node.add_child(arm_mesh)
	arm_mesh.position.y = -0.3 # Offset so top is at origin

	# Tool/Hand
	var tool_mesh = MeshInstance3D.new()
	var tool_box = BoxMesh.new()
	tool_box.size = Vector3(0.18, 0.18, 0.18)
	tool_mesh.mesh = tool_box
	var tool_mat = StandardMaterial3D.new()
	tool_mat.albedo_color = Color(0.3, 0.3, 0.3) # Stone
	tool_mesh.material_override = tool_mat
	hand_node.add_child(tool_mesh)
	tool_mesh.position.y = 0.0
	tool_mesh.position.z = -0.1

func _process_hand_sway(delta):
	if hand_node:
		# Simple sway based on input/velocity
		var target_pos = Vector3(0.5, -0.4, -0.6)
		var target_rot = Vector3(0, deg_to_rad(-10), 0)

		if velocity.length() > 0.1:
			var time = Time.get_ticks_msec() / 200.0
			target_pos.y += sin(time) * 0.05
			target_pos.x += cos(time * 0.5) * 0.02

		if Global.is_breaking:
			# Swing animation
			var time = Time.get_ticks_msec() / 100.0
			target_rot.x += sin(time * 10.0) * 0.5
			target_pos.z -= abs(sin(time * 10.0)) * 0.2

		hand_node.position = hand_node.position.lerp(target_pos, delta * 5.0)
		hand_node.rotation = hand_node.rotation.lerp(target_rot, delta * 10.0)
