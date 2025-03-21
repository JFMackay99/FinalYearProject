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
	
