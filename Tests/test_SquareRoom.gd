extends GutTest

var room: SquareRoom



func before_each():
	gut.p("ran setup", 2)


var params_construct_OddScale = [
	#[	cellWidth,	scale,	centralPoint, 	expectedTLCorner]
	[	3,			3,		Vector2i(4,4),		Vector2i(0,0)],
	[	3,			3,		Vector2i(7,10),		Vector2i(3,6)],
	[	5,			3,		Vector2i(7,10),		Vector2i(0,3)],
	[	3,			5,		Vector2i(7,12),		Vector2i(0,5)],
	[	5,			5,		Vector2i(12,17),	Vector2i(0,5)],
	[	1,			3,		Vector2i(4,7),		Vector2i(3,6)],
	[	2,			3,		Vector2i(10,13),	Vector2i(9,12)],
	[	4,			3,		Vector2i(10,13),	Vector2i(6,9)],
	[	2,			5,		Vector2i(7,12),		Vector2i(5,10)],
	[	2,			7,		Vector2i(10,17),	Vector2i(7,14)],
	[	3,			2,		Vector2i(2,4),		Vector2i(0,2)],
	[	3,			4,		Vector2i(5,13),		Vector2i(0,8)],
	[	4,			4,		Vector2i(5,13),		Vector2i(0,8)],
	[	5,			4,		Vector2i(9,21),		Vector2i(0,12)],
	
]

func test_SquareRoomConstruction_OddScale(params = use_parameters(params_construct_OddScale)):
	var cellWidth=params[0]
	var scale = params[1]
	var width = cellWidth * scale
	var centralPoint = params[2]
	
	var expectedTLCorner = params[3]
	
	var room = SquareRoom.new(Constants.ROOM_TYPE.NORMAL, width, cellWidth, centralPoint)
	
	var actualCorner = room.topLeft
	assert_eq(actualCorner, expectedTLCorner)
	

var params_vertSection = [
	#[scale, index, cellWidth, expected]
	[3,5,3,Vector2i(4,6)],
	[4,5,3,Vector2i(4,6)],
	[3,5,4,Vector2i(4,7)],
	[4,5,4,Vector2i(4,7)],
	[3,5,5,Vector2i(3,7)],
	[3,15,3,Vector2i(14,16)],
	[3,15,13,Vector2i(9,21)],
	[3,15,13,Vector2i(9,21)],
]

func test_GetIndexOfPathSectionsPassingBoundary_Vert(params = use_parameters(params_vertSection)):
	var scale = params[0]
	var verticalSection = []
	for i in 30:
		verticalSection.append(Vector2i(3,i))
	
	var index = params[1]
	var centerCell = verticalSection[index]
	var centerPoint = UtilityMethods.GetCentralPointFromOverWorldVect(centerCell, scale)
	var cellWidth = params[2]
	var width = cellWidth*scale
	
	var room = SquareRoom.new(Constants.ROOM_TYPE.NORMAL, width, cellWidth, centerPoint)
	var expected = params[3]
	
	var actual = room.GetIndexOfPathSectionsPassingBoundary(verticalSection, index)
	assert_eq(actual, expected)
	

var params_horzSection = [
	#[scale, index, cellWidth, expected]
	[3,5,3,Vector2i(4,6)],
	[4,5,3,Vector2i(4,6)],
	[3,5,4,Vector2i(4,7)],
	[4,5,4,Vector2i(4,7)],
	[3,5,5,Vector2i(3,7)],
	[3,15,3,Vector2i(14,16)],
	[3,15,13,Vector2i(9,21)],
]

func test_GetIndexOfPathSectionsPassingBoundary_Horz(params = use_parameters(params_horzSection)):
	var scale = params[0]
	var horizontalSection = []
	for i in 30:
		horizontalSection.append(Vector2i(3,i))
	
	var index = params[1]
	var centerCell = horizontalSection[index]
	var centerPoint = UtilityMethods.GetCentralPointFromOverWorldVect(centerCell, scale)
	var cellWidth = params[2]
	var width = cellWidth*scale
	
	var room = SquareRoom.new(Constants.ROOM_TYPE.NORMAL, width, cellWidth, centerPoint)
	var expected = params[3]
	
	var actual = room.GetIndexOfPathSectionsPassingBoundary(horizontalSection, index)
	assert_eq(actual, expected)


var params_CalculateDoorPosition_VertSection = [
	#[boundaryCell,	oobCell,		cellWidth,	scale, 	centereCell, 	expected]
	[Vector2i(1,1),	Vector2i(1,0),	1,			3,		Vector2i(1,1), 	Vector2i(4,3)], # Stairwells
	[Vector2i(1,1),	Vector2i(1,2),	1,			3,		Vector2i(1,1), 	Vector2i(4,5)], # Stairwells
	[Vector2i(1,1),	Vector2i(0,1),	1,			3,		Vector2i(1,1), 	Vector2i(3,4)], # Stairwells
	[Vector2i(1,1),	Vector2i(2,1),	1,			3,		Vector2i(1,1), 	Vector2i(5,4)], # Stairwells
	[Vector2i(1,1),	Vector2i(1,0),	1,			4,		Vector2i(1,1), 	Vector2i(5,4)], # Stairwells
	[Vector2i(1,1),	Vector2i(1,2),	1,			4,		Vector2i(1,1), 	Vector2i(5,7)], # Stairwells
	[Vector2i(1,1),	Vector2i(0,1),	1,			4,		Vector2i(1,1), 	Vector2i(4,5)], # Stairwells
	[Vector2i(1,1),	Vector2i(2,1),	1,			4,		Vector2i(1,1), 	Vector2i(7,5)], # Stairwells
	[Vector2i(2,1),	Vector2i(2,0),	3,			3,		Vector2i(2,2), 	Vector2i(7,3)],
	[Vector2i(2,3),	Vector2i(2,4),	3,			3,		Vector2i(2,2), 	Vector2i(7,11)],
	[Vector2i(1,2),	Vector2i(0,2),	3,			3,		Vector2i(2,2), 	Vector2i(3,7)],
	[Vector2i(3,2),	Vector2i(4,2),	3,			3,		Vector2i(2,2), 	Vector2i(11,7)],
	[Vector2i(2,1),	Vector2i(2,0),	2,			3,		Vector2i(2,2), 	Vector2i(7,3)],
	[Vector2i(2,3),	Vector2i(2,4),	2,			3,		Vector2i(2,2), 	Vector2i(7,11)],
	[Vector2i(1,2),	Vector2i(0,2),	2,			3,		Vector2i(2,2), 	Vector2i(3,7)],
	[Vector2i(3,2),	Vector2i(4,2),	2,			3,		Vector2i(2,2), 	Vector2i(11,7)],
]

func test_CalculateDoorPosition_VertSection(params = use_parameters(params_CalculateDoorPosition_VertSection)):
	var boundaryCell = params[0]
	var oobCell = params[1]
	
	var cellWidth = params[2]
	var scale = params[3]
	var width= cellWidth * scale
	var centerCell = params[4]
	var centerPoint = UtilityMethods.GetCentralPointFromOverWorldVect(centerCell, scale)
	
	var expected = params[5]
	
	var room = SquareRoom.new(Constants.ROOM_TYPE.NORMAL, width, cellWidth, centerPoint)
	
	var actual = room.CalculateDoorPosition(boundaryCell, oobCell, scale)
	
	assert_eq(actual, expected)
	
