extends GutTest

var decorator : BasicDecorator

func before_all():
	decorator = TestDecorator.new()
	decorator.defaultDecorations = DefaultDecorations
	decorator.decorationsPerBiome.clear()
	decorator.decorationsPerBiome[Constants.BIOMES.FOREST] = ForestDecorations
	decorator.decorationsPerBiome[Constants.BIOMES.DESERT] = DesertDecorations
	decorator.rng = RandomNumberGenerator.new()
	decorator.rng.seed = 1234

var DesertDecorations = [ Constants.ROOM_DECORATION.TORCH, Constants.ROOM_DECORATION.DESK]
var ForestDecorations = [ Constants.ROOM_DECORATION.GOLD, Constants.ROOM_DECORATION.CHAIR, ]
var DefaultDecorations =[ Constants.ROOM_DECORATION.GEM]


var params_SelectDecorationOptionsFromBiome = [
	[Constants.BIOMES.DESERT, DesertDecorations],
	[Constants.BIOMES.FOREST, ForestDecorations],
	[Constants.BIOMES.GRASSLAND, DefaultDecorations], # Default
]

func test_SelectDecorationOptionsFromBiome(params = use_parameters(params_SelectDecorationOptionsFromBiome)):
	var biome = params[0]
	var expected = params[1]
	
	var actual = decorator.SelectDecorationOptionsFromBiome(biome)
	
	assert_eq(actual, expected)

var params_CalculateNumberOfDecorations = [
	[5],[1],[9],[20],[0]
]

func test_CalculateNumberOfDecorations(params = use_parameters(params_CalculateNumberOfDecorations)):
	var expected = params[0]
	decorator.numberOfDecorations = expected
	
	var room = SquareRoom.new(Constants.ROOM_TYPE.NORMAL, 9, 3, Vector2i(10,10))
	var map = Map.new()
	map.overworld = MockOverworld.new()
	
	decorator.DecorateRoom(room, map, Vector2i(10,10))
	
	var actual = room.decorations.size()
	
	assert_eq(actual, expected)
	
# Allows us to control the output of CalculateNumberOfDecorators
class TestDecorator:
	extends BasicDecorator
	
	var numberOfDecorations
	
	func CalculateNumberOfDecorations(freeSpace: Array) -> int:
		return numberOfDecorations
	
class MockOverworld:
	extends OverworldMap
	
	func GetBiomeAtCellCoordinate( x, y):
		return Constants.BIOMES.FOREST
