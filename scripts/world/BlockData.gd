class_name BlockData

enum Type {
	AIR = 0,
	DIRT = 1,
	GRASS = 2,
	STONE = 3,
	WOOD = 4,
	LEAVES = 5,
	SAND = 6,
	WATER = 7
}

const COLORS = {
	Type.DIRT: Color(0.42, 0.3, 0.15), # Standard Dirt Brown
	Type.GRASS: Color(0.3, 0.7, 0.2), # Vibrant Grass Green
	Type.STONE: Color(0.55, 0.55, 0.6), # Blue-ish Grey Stone
	Type.WOOD: Color(0.4, 0.25, 0.1), # Dark Wood
	Type.LEAVES: Color(0.15, 0.55, 0.1), # Darker Green Leaves
	Type.SAND: Color(0.9, 0.85, 0.6), # Pale Sand
	Type.WATER: Color(0.2, 0.4, 0.9, 0.8)
}

static func get_color(type):
	if type in COLORS:
		return COLORS[type]
	return Color.WHITE
