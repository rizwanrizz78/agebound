class_name VoxelWorld
extends Node3D

const CHUNK_SIZE = 16
const VIEW_DISTANCE = 4
const CHUNKS_PER_FRAME = 2

var noise : FastNoiseLite
var chunks = {}
var modified_blocks = {} # Vector3i -> BlockData.Type
var player : Node3D

var generation_queue = []
var chunks_pending = {} # Set of pending chunks

func _ready():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	noise.fractal_octaves = 4

	# Initial generation around origin if no player yet
	update_chunks(Vector3.ZERO)

func _process(delta):
	if player:
		var player_chunk = get_chunk_coord(player.global_position)
		update_chunks(player_chunk)

	# Process Queue
	var processed = 0
	while processed < CHUNKS_PER_FRAME and generation_queue.size() > 0:
		var chunk_pos = generation_queue.pop_front()
		chunks_pending.erase(chunk_pos)

		# Double check if already created (race condition?)
		if not chunks.has(chunk_pos):
			create_chunk(chunk_pos)

		processed += 1

func get_chunk_coord(pos : Vector3) -> Vector3i:
	return Vector3i(floor(pos.x / CHUNK_SIZE), floor(pos.y / CHUNK_SIZE), floor(pos.z / CHUNK_SIZE))

func update_chunks(center_chunk : Vector3i):
	for x in range(center_chunk.x - VIEW_DISTANCE, center_chunk.x + VIEW_DISTANCE + 1):
		for z in range(center_chunk.z - VIEW_DISTANCE, center_chunk.z + VIEW_DISTANCE + 1):
			# Vertical chunks
			for y in range(0, 4): # 0 to 64 height
				var chunk_pos = Vector3i(x, y, z)
				if not chunks.has(chunk_pos) and not chunks_pending.has(chunk_pos):
					chunks_pending[chunk_pos] = true
					generation_queue.append(chunk_pos)

func create_chunk(pos : Vector3i):
	var chunk = VoxelChunk.new(pos, noise, self)
	add_child(chunk)
	chunk.position = Vector3(pos.x * CHUNK_SIZE, pos.y * CHUNK_SIZE, pos.z * CHUNK_SIZE)
	chunk.generate()
	chunks[pos] = chunk

func set_block(global_pos : Vector3i, type):
	modified_blocks[global_pos] = type
	# Find which chunk needs update
	var chunk_pos = get_chunk_coord(Vector3(global_pos.x + 0.5, global_pos.y + 0.5, global_pos.z + 0.5))
	if chunks.has(chunk_pos):
		chunks[chunk_pos].generate()
		# Check neighbors if on edge (todo)
