class_name VoxelChunk
extends StaticBody3D

const CHUNK_SIZE = 16

var chunk_position : Vector3i
var noise : FastNoiseLite
var world : Node3D # VoxelWorld
var mesh_instance : MeshInstance3D
var collision_shape : CollisionShape3D

func _init(pos : Vector3i, n : FastNoiseLite, w : Node3D):
	chunk_position = pos
	noise = n
	world = w

	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)

	collision_shape = CollisionShape3D.new()
	add_child(collision_shape)

func generate():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Using a basic material with vertex colors
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	mesh_instance.material_override = material

	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				var global_pos = Vector3i(
					chunk_position.x * CHUNK_SIZE + x,
					chunk_position.y * CHUNK_SIZE + y,
					chunk_position.z * CHUNK_SIZE + z
				)

				var block_type = get_block_type(global_pos)
				if block_type != BlockData.Type.AIR:
					create_block_mesh(st, x, y, z, block_type, global_pos)

	st.index()
	var mesh = st.commit()
	mesh_instance.mesh = mesh

	# Generate collision shape
	if mesh.get_surface_count() > 0:
		collision_shape.shape = mesh.create_trimesh_shape()

func get_block_type(pos : Vector3i):
	# Check modified blocks
	if world.modified_blocks.has(pos):
		return world.modified_blocks[pos]

	# Simple terrain generation logic
	# Use noise for height map
	var height = int((noise.get_noise_2d(pos.x, pos.z) + 1.0) * 0.5 * 32.0) + 16

	# Tree Logic
	# Use a pseudo-random check based on position (deterministic)
	var tree_noise = noise.get_noise_2d(pos.x * 2.5, pos.z * 2.5) # Different scale
	var is_tree_pos = (tree_noise > 0.6) and (height > 20) # Only on high ground/grass

	if is_tree_pos:
		if pos.y > height and pos.y <= height + 4:
			return BlockData.Type.WOOD
		if pos.y == height + 5:
			return BlockData.Type.LEAVES

	if pos.y > height:
		return BlockData.Type.AIR
	elif pos.y == height:
		if pos.y < 20: # Water level or sand level?
			return BlockData.Type.SAND
		return BlockData.Type.GRASS
	elif pos.y > height - 4:
		return BlockData.Type.DIRT
	else:
		return BlockData.Type.STONE

func create_block_mesh(st : SurfaceTool, x, y, z, type, global_pos):
	var color = BlockData.get_color(type)
	st.set_color(color)

	# Check neighbors (simple check against noise function)
	# Top
	if get_block_type(global_pos + Vector3i(0, 1, 0)) == BlockData.Type.AIR:
		add_face(st, Vector3(x, y+1, z), Vector3(x+1, y+1, z), Vector3(x+1, y+1, z+1), Vector3(x, y+1, z+1), Vector3.UP)
	# Bottom
	if get_block_type(global_pos + Vector3i(0, -1, 0)) == BlockData.Type.AIR:
		add_face(st, Vector3(x, y, z+1), Vector3(x+1, y, z+1), Vector3(x+1, y, z), Vector3(x, y, z), Vector3.DOWN)
	# Left
	if get_block_type(global_pos + Vector3i(-1, 0, 0)) == BlockData.Type.AIR:
		add_face(st, Vector3(x, y, z), Vector3(x, y, z+1), Vector3(x, y+1, z+1), Vector3(x, y+1, z), Vector3.LEFT)
	# Right
	if get_block_type(global_pos + Vector3i(1, 0, 0)) == BlockData.Type.AIR:
		add_face(st, Vector3(x+1, y, z+1), Vector3(x+1, y, z), Vector3(x+1, y+1, z), Vector3(x+1, y+1, z+1), Vector3.RIGHT)
	# Front
	if get_block_type(global_pos + Vector3i(0, 0, 1)) == BlockData.Type.AIR:
		add_face(st, Vector3(x, y, z+1), Vector3(x+1, y, z+1), Vector3(x+1, y+1, z+1), Vector3(x, y+1, z+1), Vector3.BACK)
	# Back
	if get_block_type(global_pos + Vector3i(0, 0, -1)) == BlockData.Type.AIR:
		add_face(st, Vector3(x+1, y, z), Vector3(x, y, z), Vector3(x, y+1, z), Vector3(x+1, y+1, z), Vector3.FORWARD)

func add_face(st : SurfaceTool, v1, v2, v3, v4, normal):
	st.set_normal(normal)
	st.add_vertex(v1)
	st.add_vertex(v2)
	st.add_vertex(v3)

	st.add_vertex(v1)
	st.add_vertex(v3)
	st.add_vertex(v4)
