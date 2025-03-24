extends GutTest
func before_each():
	gut.p("ran setup", 2)

func after_each():
	gut.p("ran teardown", 2)

func before_all():
	gut.p("ran run setup", 2)

func after_all():
	gut.p("ran run teardown", 2)

var centralPointFromDungeonPointParams = [
	#[x,y,scale,expecte]
	[0,0,1,Vector2i(0,0)], # x=y=0 scale = 1
	[0,0,3,Vector2i(1,1)], # x=y=0 scale !=1
	[1,2,1,Vector2i(1,2)], # x!=y scale = 1
	[5,6,3,Vector2i(4,7)], # x!=y scale !=1	
	[4,7,3,Vector2i(4,7)], # x!=y scale !=1	center
]
func test_GetCentralPointFromDungeonPoint(params=use_parameters(centralPointFromDungeonPointParams)):
	var x = params[0]
	var y = params[1]
	var scale = params[2]
	var expected = params[3]
	
	var actual = UtilityMethods.GetCentralPointFromDungeonPoint(x,y,scale)
	
	assert_eq(actual, expected)

var getDungeonAreaFromOverworldCellParams = [
	#[cell,scale, expected]
	[Vector2i(0,0), 1, [Vector2i(0,0)]], # x=y=0 scale=1
	[Vector2i(0,0), 2, [Vector2i(0,0), Vector2i(0,1), Vector2i(1,0), Vector2i(1,1)]], # x=y=0 scale!=1
	[Vector2i(3,4), 1, [Vector2i(3,4)]], # x!=y scale=1
	[Vector2i(1,2), 2, [Vector2i(2,4), Vector2i(2,5), Vector2i(3,4), Vector2i(3,5)]], # x!=y scale!=1
	
]
func test_GetDungeonAreaFromOverworlCell(params = use_parameters(getDungeonAreaFromOverworldCellParams)):
	var cell = params[0]
	var scale = params[1]
	var expected = params[2]
	
	var actual = UtilityMethods.GetDungeonAreaFromOverworldCell(cell,scale)
	
	assert_eq_deep(actual, expected)

var getCentralPointFromOverWorldVectParams = [
	#[cell, scale, expected]
	[Vector2i(0,0), 1, Vector2i(0,0)], # x=y=0 scale =1
	[Vector2i(0,0), 3, Vector2i(1,1)], # x=y=0 scale !=1 odd
	[Vector2i(1,3), 1, Vector2i(1,3)], # x!=y scale =1
	[Vector2i(1,3), 3, Vector2i(4,10)], # x!=y scale !=1 odd
]
func test_GetCentralPointFromOverWorldVect(params = use_parameters(getCentralPointFromOverWorldVectParams)):	
	var cell = params[0]
	var scale = params[1]
	var expected = params[2]
	
	var actual = UtilityMethods.GetCentralPointFromOverWorldVect(cell,scale)
	
	assert_eq(actual, expected)
	

var getCentralPointFromOverWorldCoords = [
	#[x,y,scale,expected]
	[0,0,1,Vector2i(0,0)], # x=y=0 scale = 1
	[0,0,3,Vector2i(1,1)], # x=y=0 scale !=1
	[1,2,1,Vector2i(1,2)], # x!=y scale = 1
	[1,2,3,Vector2i(4,7)], # x!=y scale !=1	
	[1,2,4,Vector2i(5,9)], # x!=y scale =4
	[0,0,4,Vector2i(1,1)], # x=y=0 scale =4
]
func test_GetCentralPointFromOverWorldCoords(params=use_parameters(getCentralPointFromOverWorldCoords)):
	var x = params[0]
	var y = params[1]
	var scale = params[2]
	var expected = params[3]
	
	var actual = UtilityMethods.GetCentralPointFromOverWorldCoords(x,y,scale)
	
	assert_eq(actual, expected)

var getTopLeftPointFromCellParams = [
	#[cell,scale,expected]
	[Vector2i(0,0), 1, Vector2i(0,0)], # x=y=0 scale =1
	[Vector2i(0,0), 3, Vector2i(0,0)], # x=y=0 scale !=1
	[Vector2i(1,3), 1, Vector2i(1,3)], # x!=y scale =1
	[Vector2i(2,3), 3, Vector2i(6,9)], # x!=y scale !=1
	[Vector2i(3,3), 1, Vector2i(3,3)], # x=y!=0 scale =1
	[Vector2i(3,3), 3, Vector2i(9,9)], # x=y!=0 scale !=1
]
func test_GetTopLeftPointFromCell(params = use_parameters(getTopLeftPointFromCellParams)):	
	var cell = params[0]
	var scale = params[1]
	var expected = params[2]
	
	var actual = UtilityMethods.GetTopLeftPointFromCell(cell,scale)
	
	assert_eq(actual, expected)


var getTopLeftPointFrom3dCellParams = [
	#[cell, scale, expected]
	[Vector3i(0, 0, 0), 1, Vector2i(0,0)], #x=y=0 scale=1 z = 0
	[Vector3i(0, 0, 0), 3, Vector2i(0,0)], #x=y=0 scale!=1 z = 0
	[Vector3i(2, 4, 0), 1, Vector2i(2,4)], #x!=y scale=1 z = 0
	[Vector3i(2, 4, 0), 3, Vector2i(6,12)], #x!=y scale!=1 z = 0
	[Vector3i(0, 0, 5), 1, Vector2i(0,0)], #x=y=0 scale=1 z!=0
	[Vector3i(0, 0, 5), 3, Vector2i(0,0)], #x=y=0 scale!=1 z!=0
	[Vector3i(2, 4, 5), 1, Vector2i(2,4)], #x!=y scale=1 z!=0
	[Vector3i(2, 4, 5), 3, Vector2i(6,12)], #x!=y scale!=1 z!=0
]
func test_GetTopLeftPointFrom3dCell(params = use_parameters(getTopLeftPointFrom3dCellParams)):	
	var cell = params[0]
	var scale = params[1]
	var expected = params[2]
	
	var actual = UtilityMethods.GetTopLeftPointFrom3dCell(cell,scale)
	
	assert_eq(actual, expected)


var getOverworldCellCoordsFromDungeonPoint = [
	#[x,y,scale,expected]
	[0,0,1,Vector2i(0,0)], # x=y=0 scale = 1
	[0,0,3,Vector2i(0,0)], # x=y=0 scale !=1
	[1,2,1,Vector2i(1,2)], # x!=y scale = 1
	[4,7,3,Vector2i(1,2)], # x!=y scale !=1	
	[4,4,1,Vector2i(4,4)], # x=y!=0 scale =1	
	[4,4,3,Vector2i(1,1)], # x=y!=0 scale !=1	
]
func test_OverworldCellCoordsFromDungeonPoint(params=use_parameters(getOverworldCellCoordsFromDungeonPoint)):
	var x = params[0]
	var y = params[1]
	var scale = params[2]
	var expected = params[3]
	
	var actual = UtilityMethods.GetOverworldCellCoordsFromDungeonPoint(x,y,scale)
	
	assert_eq(actual, expected)
