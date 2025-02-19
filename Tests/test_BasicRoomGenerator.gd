extends GutTest

var testUndergroundLayer: UndergroundLayer
var generator: BasicRoomGenerator

func before_all():
	generator = BasicRoomGenerator.new()
	

func before_each():
	# Forbidden tiles can be added during tests 
	testUndergroundLayer = UndergroundLayer.new(1,9,9)
	
	
	
var maxSizeFromUndergroundStructureParams = [
	# [ ForbiddenTiles: Array, maxRoomCells: int, expected: int ]
	[[], 1,1], # No Forbidden, maxRoomCells = 1
	[[], 3,3], # No Forbidden, maxRoomCells != 1
	[[Vector2i(0,0)], 1,1], # 1 Forbidden out of range, maxRoomCells = 1
	[[Vector2i(0,0)], 3,3], # 1 Forbidden out of range, maxRoomCells != 1
	[[Vector2i(5,4)], 1,1], # 1 Forbidden adjacent, maxRoomCells = 1
	[[Vector2i(5,4)], 5,1], # 1 Forbidden adjacent, maxRoomCells != 1
	[[Vector2i(5,5)], 5,1], # 1 Forbidden adjacent BR corner, maxRoomCells != 1
	[[Vector2i(6,4)], 5,3], # 1 Forbidden edge of check, maxRoomCells != 1
	[[Vector2i(4,6)], 5,3], # 1 Forbidden edge of check TR corner, maxRoomCells != 1
	[[Vector2i(6,6)], 5,3], # 1 Forbidden edge of check BR corner, maxRoomCells != 1
	[[Vector2i(4,6)], 5,3], # 1 Forbidden edge of check TL corner, maxRoomCells != 1
	[[Vector2i(6,6)], 5,3], # 1 Forbidden edge of check TR corner, maxRoomCells != 1
	[[Vector2i(5,4)], 5,1], # 1 Forbidden middle of check, maxRoomCells != 1
	[[Vector2i(5,5)], 5,1], # 1 Forbidden middle of check BR corner, maxRoomCells != 1
]

func test_MaxSizeFromUndergroundStruncture(params=use_parameters(maxSizeFromUndergroundStructureParams)):
	generator.scale = 1
	var cell = Vector2i(4,4)
	
	for tile in params[0]:
		testUndergroundLayer.SetTile(tile.x, tile.y, Constants.DUNGEON_TILES.FORBIDDEN)
	
	generator.maxRoomCells = params[1]
	var expected = params[2]
	
	var actual = generator.CalculateMaxSizeSquareFromUndergroundStructure(testUndergroundLayer, cell)
	
	assert_eq( actual, expected)
