extends GutTest

var pathfinder: ModifiedAStar3D



func before_all():
	pathfinder = ModifiedAStar3D.new(5, 5, 5)
	pathfinder.heightChangeCostFactor = 10
	pathfinder.heightLayerWeightFactor = 10
	

var coordsToIDParams = [
	[0,0,0,0], # 0
	[1,0,0,1], # x
	[0,1,0,5], # y
	[0,0,1,25], # z
	[4,0,0,4], # maxX
	[0,4,0,20], # maxY
	[0,0,4,100 ], # maxZ
	[3,2,4,113], # different values
	[4,4,4,124], # max values
	[10,0,0,-1], # OOB x
	[0,10,0,-1], # OOB y
	[0,0,10,-1], # OOB z
	[-10,0,0,-1], # Neg x
	[0,-10,0,-1], # Neg y
	[0,0,-10,-1], # Neg z
]
func test_CellCoordsToAStarId(params = use_parameters(coordsToIDParams)):
	
	var x = params[0]
	var y = params[1]
	var z = params[2]
	var expected = params[3]
	
	var actual = pathfinder.CellCoordsToAStarID(x,y,z)
	
	assert_eq(actual, expected)

var vectToIDParams = [
	[Vector3(0,0,0),0], # 0
	[Vector3(1,0,0),1], # x
	[Vector3(0,1,0),5], # y
	[Vector3(0,0,1),25], # z
	[Vector3(4,0,0),4], # maxX
	[Vector3(0,4,0),20], # maxY
	[Vector3(0,0,4),100 ], # maxZ
	[Vector3(3,2,4),113], # different values
	[Vector3(4,4,4),124], # max values
	[Vector3(10,0,0),-1], # OOB x
	[Vector3(0,10,0),-1], # OOB y
	[Vector3(0,0,10),-1], # OOB z
]
func test_CellVectToAStarId(params = use_parameters(vectToIDParams)):
	
	var cell = params[0]
	var expected = params[1]
	
	var actual = pathfinder.CellVectToAStarID(cell)
	
	assert_eq(actual, expected)
