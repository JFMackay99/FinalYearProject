extends BasicDecorator

class_name BasicBiomeDecorator

func _init() -> void:
	self.decorationsPerBiome = {
		Constants.BIOMES.GRASSLAND: [
			Constants.ROOM_DECORATION.TORCH,
			Constants.ROOM_DECORATION.DESK, 
			Constants.ROOM_DECORATION.CHAIR, 
			Constants.ROOM_DECORATION.CHEST,
			Constants.ROOM_DECORATION.PUDDLE,
			],
		Constants.BIOMES.FOREST: [
			Constants.ROOM_DECORATION.DESK, 
			Constants.ROOM_DECORATION.CHAIR, 
			Constants.ROOM_DECORATION.CHEST,
			Constants.ROOM_DECORATION.VINES,
			Constants.ROOM_DECORATION.LEAVES,
			],
		Constants.BIOMES.SAVANNAH: [
			Constants.ROOM_DECORATION.TORCH,
			Constants.ROOM_DECORATION.DESK, 
			Constants.ROOM_DECORATION.CHAIR, 
			Constants.ROOM_DECORATION.ROCK,
			Constants.ROOM_DECORATION.GEM,
			Constants.ROOM_DECORATION.GOLD,
			],
		Constants.BIOMES.DESERT: [
			Constants.ROOM_DECORATION.TORCH,
			Constants.ROOM_DECORATION.GEM,
			Constants.ROOM_DECORATION.GOLD,
			],
		Constants.BIOMES.ROCKY: [
			Constants.ROOM_DECORATION.TORCH,
			Constants.ROOM_DECORATION.GEM,
			Constants.ROOM_DECORATION.ROCK,
			],
	}
