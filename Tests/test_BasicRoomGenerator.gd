extends GutTest

var testUndergroundLayer: UndergroundLayer
var generator: BasicRoomGenerator

# Test Layer:
#	X X X X X F F F
#	X X X X X F F F
#	X X X X X F F F
#	X X X X X X F F
#	X X X X X X X F
#	X X X X X X X F
#	X X X X X X X F
#	X X X X X X X F
func before_all():
	generator = BasicRoomGenerator.new()
	testUndergroundLayer = UndergroundLayer.new(1,8,8)
	
	for i in testUndergroundLayer.mapMaxHeight:
		testUndergroundLayer.map[testUndergroundLayer.mapMaxWidth-1][i] = Constants.DUNGEON_TILES.FORBIDDEN
	
	testUndergroundLayer.map[5][0] = Constants.DUNGEON_TILES.FORBIDDEN
	testUndergroundLayer.map[6][0] = Constants.DUNGEON_TILES.FORBIDDEN
	testUndergroundLayer.map[5][1] = Constants.DUNGEON_TILES.FORBIDDEN
	testUndergroundLayer.map[6][1] = Constants.DUNGEON_TILES.FORBIDDEN
	testUndergroundLayer.map[5][2] = Constants.DUNGEON_TILES.FORBIDDEN
	testUndergroundLayer.map[6][2] = Constants.DUNGEON_TILES.FORBIDDEN
	testUndergroundLayer.map[6][3] = Constants.DUNGEON_TILES.FORBIDDEN
	
	
var maxSizeFromUndergroundStructureParams = [
	[Vector2i(3,3), 1, 1], # Max space scale =1
	[Vector2i(3,3), 3, 3], # Max space scale !=1
	[Vector2i(4,1), 3, 1], # Next to forbidden scale =3
	[Vector2i(5,1), 5, 1], # Next to forbidden scale =5
	[Vector2i(3,5), 5, 1], # Just Reaches forbidden scale =5
	[Vector2i(5,1), 5, 1], # Next to forbidden scale =5
]

func test_MaxSizeFromUndergroundStruncture(params=use_parameters(maxSizeFromUndergroundStructureParams)):
	var cell = params[0]
	generator.scale = params[1]
	var expected = params[2]
	
	var actual = generator.CalculateMaxSizeSquareFromUndergroundStructure(testUndergroundLayer, cell)
	
	assert_eq(expected, actual)
