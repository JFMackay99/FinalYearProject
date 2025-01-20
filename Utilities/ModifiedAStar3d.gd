extends AStar3D
# Modification of the pathfinding heuristic to allow changing height layers to have a different cost
# in order to discourage unnecessary changes in heights
class_name ModifiedAStar3D


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
	return floor(z)*(Constants.OVERWORLD_MAX_X*Constants.OVERWORLD_MAX_Y)+10*y*Constants.OVERWORLD_MAX_X +x
