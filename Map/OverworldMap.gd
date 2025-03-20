extends RefCounted

class_name OverworldMap

var heights: Array
var biomes: Array

var overworldConstructionTime: int

func GetHeightAtCellCoordinate(x,y):
	return heights[x][y]

func UpdateHeights(newHeights):
	heights = newHeights
	
func GetBiomeAtCellCoordinate(x,y):
	return biomes[x][y]
	
func UpdateBiomes(newBiomes):
	biomes = newBiomes
