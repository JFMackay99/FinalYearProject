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


var shortStraightHorSection = [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),] # 5w Only Space for one in center
var mediumStraightHorSection = [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0),Vector2i(6,0),] # 7w
var shortStraightVertSection = [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(0,3),Vector2i(0,4),] # 5w Only Space for one in center
var mediumStraightVertSection = [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(0,3),Vector2i(0,4),Vector2i(0,5),Vector2i(0,6),] # 7w
var shortTRCorner = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(2,1), Vector2i(2,2)]
var shortBLCorner = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,2), Vector2i(2,2)]
var mediumBLCorner = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3), Vector2i(1,3), Vector2i(2,3), Vector2i(3,3),]
var mediumTRCorner = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0), Vector2i(3,1), Vector2i(3,2), Vector2i(3,3),]

#
#		X	X	X	X	X
#
# 		X	X	X	X	X	X	X
#
#		X	X	X
#				X
#				X
#


var calculateMaxSizeSquareFromSectionsParams = [

	[shortStraightHorSection, Vector2i(2,0), 1], # center small horizontal
	[shortStraightVertSection, Vector2i(0,2), 1], # center small vertical
	[mediumStraightHorSection, Vector2i(3,0), 3], # center medium horizontal
	[mediumStraightVertSection, Vector2i(0,3), 3], # center medium vertical
	[shortTRCorner, Vector2i(2,0), 1], # center tr corner
	[shortBLCorner, Vector2i(0,2), 1], # center bl corner
	[mediumBLCorner, Vector2i(0,3), 3], # center med bl corner
	[mediumTRCorner, Vector2i(3,0), 3], # center med tr corner
	[mediumStraightHorSection, Vector2i(2,0), 1], # left medium horizontal
	[mediumStraightHorSection, Vector2i(4,0), 1], # right medium horizontal
	
]

func test_CalculateMaxSizeSquareFromSections(params = use_parameters(calculateMaxSizeSquareFromSectionsParams)):
	var section = params[0]
	var cell = params[1]
	var expected = params[2]
	
	var actual = generator.CalculateMaxSizeSquareFromSections(section, cell)
	
	assert_eq(actual, expected)
