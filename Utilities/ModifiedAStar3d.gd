extends AStar3D
# Modification of the pathfinding heuristic to allow changing height layers to have a different cost
# in order to discourage unnecessary changes in heights
class_name ModifiedAStar3D

var maxX
var maxY
var maxZ

func _init(maxX = Constants.OVERWORLD_MAX_X, maxY = Constants.OVERWORLD_MAX_Y, maxZ = Constants.MAX_HEIGHT_LEVELS) -> void:
	self.maxX = maxX
	self.maxY = maxY
	self.maxZ = maxZ


var heightChangeCostFactor = 10
var heightLayerWeightFactor = 10
	
func _compute_cost(from_id: int, to_id: int) -> float:
	var fromVector = get_point_position(from_id)
	var toVector = get_point_position(to_id)
	var dx = abs(fromVector.x - toVector.x)
	var dy = abs(fromVector.y - toVector.y)
	var dz = heightChangeCostFactor * abs(fromVector.z - toVector.z)
	
	return sqrt(dx*dx+dy*dy+dz*dz)

func _estimate_cost(from_id: int, to_id: int) -> float:
	var fromVector = get_point_position(from_id)
	var toVector = get_point_position(to_id)
	var dx = abs(fromVector.x - toVector.x)
	var dy = abs(fromVector.y - toVector.y)
	var dz = heightChangeCostFactor * abs(fromVector.z - toVector.z)
	
	return sqrt(dx*dx+dy*dy+dz*dz)
	

# Gets the ID corresponding to the given cell coordinates given as a vector
func CellVectToAStarID(vector : Vector3):
	return CellCoordsToAStarID(vector.x, vector.y, vector.z)

# Gets the ID corresponding to the given cell coordinates given as individual coordinates
func CellCoordsToAStarID(x: int, y: int, z: int):
	if x >= maxX || y >= maxY || z >= maxZ || x < 0 || y < 0 || z < 0:
		return -1
		
	return floor(z)*(maxX*maxY)+y*maxX +x
