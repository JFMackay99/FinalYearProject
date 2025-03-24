extends GutTest

var room: SquareRoom



func before_each():
	room = SquareRoom.new(Constants.ROOM_TYPE.NORMAL, 3, 3, Vector2i(3,3))
	gut.p("ran setup", 2)


	

var params_CalculateDoorPosition = [
	#[boundaryCell, outOfBoundarCell, scale, expected],
	[Vector2i(3,3), Vector2i(3,2), 3, Vector2i(10, 9)],
	[Vector2i(3,3), Vector2i(3,4), 3, Vector2i(10, 11)],
	[Vector2i(3,3), Vector2i(2,3), 3, Vector2i(9, 10)],
	[Vector2i(3,3), Vector2i(4,3), 3, Vector2i(11, 10)],
	[Vector2i(2,3), Vector2i(1,3), 3, Vector2i(6, 10)],
	[Vector2i(2,3), Vector2i(3,3), 3, Vector2i(8, 10)],
	[Vector2i(2,3), Vector2i(2,2), 3, Vector2i(7, 9)],
	[Vector2i(2,3), Vector2i(2,4), 3, Vector2i(7, 11)],
]

func test_CalculateDoorPosition(params = use_parameters(params_CalculateDoorPosition)):
	var boundaryCell = params[0]
	var outOfBoundaryCell = params[1]
	var scale = params[2]
	var expected = params[3]
	
	var actual = room.CalculateDoorPosition(boundaryCell, outOfBoundaryCell, scale)
	
	assert_eq(actual, expected)




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
