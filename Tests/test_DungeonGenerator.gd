extends GutTest

var generator: DungeonGenerator

func before_all():
	generator = DungeonGenerator.new()

var section1 = [
	Vector3i(0,0,0), Vector3i(0,1,0)
]
var section2 = [
	Vector3i(0,1,1), Vector3i(1,1,1), Vector3i(1,2,1)
]
var section3 = [
	Vector3i(1,2,2), Vector3i(2,2,2), Vector3i(2,3,2), Vector3i(2,4,2)
]

var section4 = [
	Vector3i(2,4,1), Vector3i(2,5,1)
]

var path12 = [
	Vector3i(0,0,0), Vector3i(0,1,0),
	Vector3i(0,1,1), Vector3i(1,1,1), Vector3i(1,2,1)
] 

var path123 = [
	Vector3i(0,0,0), Vector3i(0,1,0),
	Vector3i(0,1,1), Vector3i(1,1,1), Vector3i(1,2,1),
	Vector3i(1,2,2), Vector3i(2,2,2), Vector3i(2,3,2), Vector3i(2,4,2)
]

var path234 = [
	Vector3i(0,1,1), Vector3i(1,1,1), Vector3i(1,2,1),
	Vector3i(1,2,2), Vector3i(2,2,2), Vector3i(2,3,2), Vector3i(2,4,2),
	Vector3i(2,4,1), Vector3i(2,5,1)
	
]


var processPathParams = [
	#[path, expected]
	[[],[]], # Empty 
	[section1, [section1]], # single section
	[path12, [section1, section2]], # 2 sections
	[path123, [section1, section2, section3]], # 3 sections different heights
	[path234, [section2, section3, section4]] # 3 sections repeating a height
]


func test_ProcessPathIntoSections(params=use_parameters(processPathParams)):
	var path = params[0]
	var expected = params[1]
	
	var actual = generator.ProcessPathIntoHeightSections(path)
	
	assert_eq_deep(actual, expected)

var processSectionParams = [
	#[sections, expected]
	[[],[]], # Empty 
	[[section1], section1], # single section
	[[section1, section2], path12], # 2 sections
	[[section1, section2, section3], path123], # 3 sections different heights
	[[section2, section3, section4], path234] # 3 sections repeating a height
]
func test_ProcessSectionsIntoPath(params = use_parameters(processSectionParams)):
	var sections = params[0]
	var expected = params[1]
	
	var actual = generator.ReconnectPathHeightSectionsIntoPath(sections)
	
	assert_eq_deep(actual, expected)


var params_CountNonStairwellSingleSectionLength = [
	#[section, expected]
	[[Vector2i(0,0)], 0],
	[[Vector2i(0,0), Vector2i(0,1)], 0],
	[[Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)], 1],
	[[Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3), Vector2i(0,4)], 3],
]

func test_CountNonStairwellSingleSectionLength(params = use_parameters(params_CountNonStairwellSingleSectionLength)):
	var dungeon = Dungeon.new()
	var scale = 3
	var section = params[0]
	
	var expected = params[1]
	
	generator.CountNonStairwellSingleSectionLength(dungeon, scale, section)
	
	var actualCells = dungeon.nonRoomPathLengthCells
	
	assert_eq(actualCells, expected)


var params_CountNonStairwellPathLengths = [
	[[[Vector2i(0,0), Vector2i(0,1)]], 0],
	[[[Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3), Vector2i(0,4)]], 3],
	[[[Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)],[Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3), Vector2i(0,4)]], 4]
]

func test_CountNonStairwellPathLengths(params = use_parameters(params_CountNonStairwellPathLengths)):
	var dungeon = Dungeon.new()
	var scale = 3
	var sections = params[0]
	
	var expected = params[1]
	
	generator.CountNonStairwellPathLengths(dungeon, 3, sections)
	
	var actualCells = dungeon.nonRoomPathLengthCells
	
	assert_eq(actualCells, expected)
	
