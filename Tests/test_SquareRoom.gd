extends GutTest

var room: SquareRoom



func before_each():
	room = SquareRoom.new(Constants.ROOM_TYPE.NORMAL, 3, Vector2i(3,3))
	gut.p("ran setup", 2)

var straightVSection = [Vector2i(3,0),Vector2i(3,1),Vector2i(3,2),Vector2i(3,3),Vector2i(3,4),Vector2i(3,5),Vector2i(3,6),Vector2i(3,7),]
var straightHSection = [Vector2i(0,3),Vector2i(1,3),Vector2i(2,3),Vector2i(3,3),Vector2i(4,3),Vector2i(5,3),Vector2i(6,3),Vector2i(7,3),]
var cornerSection = [Vector2i(3,0),Vector2i(3,1),Vector2i(3,2),Vector2i(3,3),Vector2i(4,3),Vector2i(5,3),Vector2i(6,3),Vector2i(7,3),]


var params_GetIndexOfPathSectionsPassingBoundary =[
	#[section,expected],
	[straightVSection, Vector2i(2,4)],
	[straightVSection, Vector2i(2,4)],
	[cornerSection, Vector2i(2,4)],
]

func test_GetIndexOfPathSectionsPassingBoundary(params=use_parameters(params_GetIndexOfPathSectionsPassingBoundary)):
	var section = params[0]
	var centerIndex = 3
	var expected = params[1]
	
	var actual = room.GetIndexOfPathSectionsPassingBoundary(section, centerIndex)
	assert_eq(actual, expected)
	

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
