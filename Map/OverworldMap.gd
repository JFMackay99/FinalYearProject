extends RefCounted

class_name OverworldMap

var heights: Array

func GetHeightAtCellCoordinate(x,y):
	return heights[x][y]
