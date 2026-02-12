extends Node3D

# Preload Scripts and Scenes
const VoxelWorldScript = preload("res://scripts/world/VoxelWorld.gd")
const PlayerScene = preload("res://scenes/Player.tscn")
const UIScene = preload("res://scenes/UI.tscn")
const MobScene = preload("res://scenes/Mob.tscn")
const LoadingScreenScene = preload("res://scenes/LoadingScreen.tscn")

var world : Node3D
var player : CharacterBody3D
var ui : CanvasLayer
var loading_screen : CanvasLayer
var sun : DirectionalLight3D
var env : WorldEnvironment

func _ready():
	print("Initializing Agebound Survival...")

	# Show Loading Screen
	loading_screen = LoadingScreenScene.instantiate()
	add_child(loading_screen)

	# Setup Environment (Sky & Light)
	setup_environment()

	# Create World
	world = VoxelWorldScript.new()
	world.name = "VoxelWorld"
	add_child(world)
	world.initial_chunks_generated.connect(_on_world_ready)
	# Optional: connect chunk_generated to update loading screen
	world.chunk_generated.connect(func(pos):
		if loading_screen and loading_screen.has_method("update_progress"):
			loading_screen.update_progress(world.initial_chunks_ready, world.initial_chunks_target)
	)

	# Create Player (Disabled Initially)
	player = PlayerScene.instantiate()
	player.name = "Player"
	add_child(player)

	# Spawn Logic: Disable physics completely
	player.process_mode = Node.PROCESS_MODE_DISABLED
	player.visible = false
	player.position = Vector3(0, 100, 0)

	# Link Player and World
	if "world" in player:
		player.world = world

	# Update world player reference
	if "player" in world:
		world.player = player

	# Create UI
	ui = UIScene.instantiate()
	ui.name = "UI"
	add_child(ui)
	ui.visible = false # Hide UI during loading

	print("Game Initialized. Waiting for chunks...")

func _on_world_ready():
	print("World Ready! Spawning Player...")

	# Calculate safe spawn height at (0,0)
	var spawn_x = 0
	var spawn_z = 0
	# Use world helper (which uses noise, consistent with generation)
	var ground_y = 20 # Fallback
	if world.has_method("get_height_at"):
		ground_y = world.get_height_at(spawn_x, spawn_z)

	# Teleport
	player.position = Vector3(spawn_x, ground_y + 2, spawn_z)
	player.visible = true
	player.process_mode = Node.PROCESS_MODE_INHERIT

	# Show UI
	ui.visible = true

	# Hide Loading Screen
	if loading_screen:
		loading_screen.fade_out()

func _process(delta):
	# Simple Mob Spawner
	if get_tree().get_nodes_in_group("mobs").size() < 5 and player:
		spawn_mob()

func spawn_mob():
	var mob = MobScene.instantiate()
	add_child(mob)

	# Random position near player
	var angle = randf() * PI * 2
	var dist = randf_range(10, 30)
	var spawn_pos = player.position + Vector3(sin(angle) * dist, 20, cos(angle) * dist)
	mob.position = spawn_pos

	# Color mob red (aggressive/primal)
	var mesh_inst = mob.get_node("MeshInstance3D")
	if mesh_inst:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.8, 0.2, 0.2)
		mesh_inst.material_override = mat

func setup_environment():
	# Directional Light (Sun)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.shadow_enabled = true
	add_child(sun)

	# World Environment (Sky)
	env = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_SKY

	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.2, 0.4, 0.8)
	sky_mat.sky_horizon_color = Color(0.6, 0.7, 0.8)
	sky_mat.ground_bottom_color = Color(0.1, 0.1, 0.1)
	sky_mat.ground_horizon_color = Color(0.6, 0.7, 0.8)
	sky.sky_material = sky_mat

	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	env.environment = environment
	add_child(env)
