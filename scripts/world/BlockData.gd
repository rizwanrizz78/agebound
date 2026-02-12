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
	Type.DIRT: Color(0.4, 0.25, 0.1),
	Type.GRASS: Color(0.2, 0.8, 0.2),
	Type.STONE: Color(0.5, 0.5, 0.5),
	Type.WOOD: Color(0.35, 0.2, 0.05),
	Type.LEAVES: Color(0.1, 0.6, 0.1),
	Type.SAND: Color(0.9, 0.8, 0.5),
	Type.WATER: Color(0.2, 0.4, 0.9, 0.8)
}

static func get_color(type):
	if type in COLORS:
		return COLORS[type]
	return Color.WHITE
