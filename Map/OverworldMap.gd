extends RefCounted

class_name OverworldMap

var heights: Array
var maxX: int = 64
var maxY: int = 64

func GetHeightAtCellCoordinate(x,y):
	return heights[x][y]

func UpdateHeights(newHeights):
	heights = newHeights
	
func _UpdateDimensions():
	maxX = heights.size()
	maxY = heights[0].size()
